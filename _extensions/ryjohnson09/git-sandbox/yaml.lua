--[[--------------------------------------------------------------------
  yaml.lua — a deliberately small YAML subset parser.

  Why not use pandoc.read to parse the YAML? Because pandoc parses metadata
  *values* as Markdown, which mangles exactly the strings we care about:
  `echo "# hi" > f.txt` loses its quotes to smart punctuation, and a literal
  block's newlines collapse into spaces. We need the text verbatim, so we
  parse it ourselves and hand only the fields that *should* be Markdown
  (task text, intro prose) to pandoc afterwards.

  Supported:
    key: scalar                    bare, 'single' or "double" quoted
    key: [a, b, "c, d"]            flow sequence
    key: |                         literal block, newlines preserved
    key: >                         folded block, newlines become spaces
    key:                           nested mapping or sequence, indented
      - scalar                     block sequence
      - key: value                 block sequence of mappings
        other: value
    # comments, whole-line or trailing

  Not supported (and not needed): anchors, aliases, tags, multiple
  documents, flow mappings, complex keys, indentation indicators.
----------------------------------------------------------------------]]

local M = {}

--[[ Raising errors.

  Quarto replaces the global `error` inside Lua filters with its own logger:
  calling error() prints a message and then *returns*, so parsing carries on
  with nil values and crashes somewhere unrelated. `assert` is untouched, so
  raise through that instead. M.parse strips the "yaml.lua:123:" prefix that
  assert adds and hands the message back as a plain second return value.
--]]
local function raise(msg)
  assert(false, msg)
end

--------------------------------------------------------------------- utils

local function rtrim(s) return (s:gsub('%s+$', '')) end
local function trim(s) return (s:gsub('^%s+', ''):gsub('%s+$', '')) end

-- Strip a trailing `# comment`, but not a `#` inside quotes or one that is
-- part of a word (so `echo "# heading"` and `a#b` survive).
local function strip_comment(s)
  local out, i, quote = {}, 1, nil
  while i <= #s do
    local c = s:sub(i, i)
    if quote then
      if c == '\\' and quote == '"' then
        out[#out + 1] = c
        i = i + 1
        out[#out + 1] = s:sub(i, i)
      else
        if c == quote then quote = nil end
        out[#out + 1] = c
      end
    elseif c == '"' or c == "'" then
      quote = c
      out[#out + 1] = c
    elseif c == '#' and (i == 1 or s:sub(i - 1, i - 1):match('%s')) then
      break
    else
      out[#out + 1] = c
    end
    i = i + 1
  end
  return rtrim(table.concat(out))
end

local ESCAPES = { n = '\n', t = '\t', r = '\r', ['0'] = '\0' }

local function unquote(s)
  s = trim(s)
  if #s >= 2 and s:sub(1, 1) == '"' and s:sub(-1) == '"' then
    local body = s:sub(2, -2)
    return (body:gsub('\\(.)', function (c) return ESCAPES[c] or c end))
  end
  if #s >= 2 and s:sub(1, 1) == "'" and s:sub(-1) == "'" then
    return (s:sub(2, -2):gsub("''", "'"))
  end
  return s
end

-- split on commas that are not inside quotes or nested brackets
local function split_flow(s)
  local parts, cur, i, quote, depth = {}, {}, 1, nil, 0
  while i <= #s do
    local c = s:sub(i, i)
    if quote then
      if c == '\\' and quote == '"' then
        cur[#cur + 1] = c
        i = i + 1
        cur[#cur + 1] = s:sub(i, i)
      else
        if c == quote then quote = nil end
        cur[#cur + 1] = c
      end
    elseif c == '"' or c == "'" then
      quote = c
      cur[#cur + 1] = c
    elseif c == '[' or c == '{' then
      depth = depth + 1
      cur[#cur + 1] = c
    elseif c == ']' or c == '}' then
      depth = depth - 1
      cur[#cur + 1] = c
    elseif c == ',' and depth == 0 then
      parts[#parts + 1] = table.concat(cur)
      cur = {}
    else
      cur[#cur + 1] = c
    end
    i = i + 1
  end
  parts[#parts + 1] = table.concat(cur)
  local out = {}
  for _, p in ipairs(parts) do
    if trim(p) ~= '' then out[#out + 1] = unquote(p) end
  end
  return out
end

local function parse_flow_seq(s, lineno)
  s = trim(s)
  if s:sub(1, 1) ~= '[' or s:sub(-1) ~= ']' then
    raise(('line %d: expected a flow sequence like [a, b, c]'):format(lineno))
  end
  return split_flow(s:sub(2, -2))
end

--------------------------------------------------------------- line scanner

-- Produce a list of significant lines: { indent, text, no }
-- Blank lines and whole-line comments are dropped, but their raw text is kept
-- in `raw` so literal blocks can reproduce internal blank lines.
local function scan(src)
  local raw, lines = {}, {}
  local n = 0
  for line in (src .. '\n'):gmatch('([^\n]*)\n') do
    n = n + 1
    raw[n] = line
    local indent = #(line:match('^ *') or '')
    local body = line:sub(indent + 1)
    if body ~= '' and body:sub(1, 1) ~= '#' then
      lines[#lines + 1] = { indent = indent, text = rtrim(body), no = n }
    end
  end
  return lines, raw
end

--------------------------------------------------------------------- parser

local Parser = {}
Parser.__index = Parser

local function new_parser(src)
  local lines, raw = scan(src)
  return setmetatable({ lines = lines, raw = raw, i = 1 }, Parser)
end

function Parser:peek() return self.lines[self.i] end

-- Gather a literal/folded block: every raw line more indented than `indent`,
-- dedented by the block's own minimum indent.
function Parser:read_block(indent, style, after_line)
  local collected, blanks = {}, {}
  local n = after_line + 1
  local min_indent = nil
  while n <= #self.raw do
    local line = self.raw[n]
    if line:match('^%s*$') then
      blanks[#blanks + 1] = #collected
      collected[#collected + 1] = ''
      n = n + 1
    else
      local ind = #(line:match('^ *') or '')
      if ind <= indent then break end
      min_indent = (min_indent == nil or ind < min_indent) and ind or min_indent
      collected[#collected + 1] = line
      n = n + 1
    end
  end
  -- drop trailing blank lines
  while #collected > 0 and collected[#collected] == '' do table.remove(collected) end
  local out = {}
  for _, line in ipairs(collected) do
    out[#out + 1] = (line == '') and '' or line:sub((min_indent or 0) + 1)
  end
  -- advance the significant-line cursor past everything we consumed
  while self.lines[self.i] and self.lines[self.i].no < n do self.i = self.i + 1 end

  local chomp = style:match('%-$') ~= nil
  local text
  if style:sub(1, 1) == '>' then
    -- folded: blank lines stay as newlines, single newlines become spaces
    local folded = {}
    for _, line in ipairs(out) do
      if line == '' then folded[#folded + 1] = '\n'
      elseif #folded == 0 or folded[#folded] == '\n' then folded[#folded + 1] = line
      else folded[#folded] = folded[#folded] .. ' ' .. line end
    end
    text = table.concat(folded)
  else
    text = table.concat(out, '\n')
  end
  if not chomp and text ~= '' then text = text .. '\n' end
  return text
end

local KEY_PATTERN = '^([%w_][%w_%-%.]*)%s*:(.*)$'
local QUOTED_KEY_PATTERN = '^"([^"]+)"%s*:(.*)$'

local function split_key(text)
  local k, rest = text:match(KEY_PATTERN)
  if k then return k, rest end
  k, rest = text:match(QUOTED_KEY_PATTERN)
  if k then return k, rest end
  return nil, nil
end

-- Parse whatever value belongs to a key whose line has already been consumed.
function Parser:read_value(rest, indent, lineno)
  rest = strip_comment(rest)
  local bare = trim(rest)

  if bare:match('^[|>][%-+]?$') then
    return self:read_block(indent, bare, lineno)
  end
  if bare:sub(1, 1) == '[' then
    return parse_flow_seq(bare, lineno)
  end
  if bare ~= '' then
    return unquote(bare)
  end

  -- nothing on the line: the value is a nested block, if it is more indented
  local nxt = self:peek()
  if nxt and nxt.indent > indent then
    return self:parse_node(nxt.indent)
  end
  return ''
end

function Parser:parse_mapping(indent)
  local map, order = {}, {}
  while true do
    local line = self:peek()
    if not line or line.indent < indent then break end
    if line.indent > indent then
      raise(('line %d: unexpected indentation'):format(line.no))
    end
    if line.text:sub(1, 2) == '- ' or line.text == '-' then break end

    local key, rest = split_key(line.text)
    if not key then
      raise(('line %d: expected "key: value", got %q'):format(line.no, line.text))
    end
    self.i = self.i + 1
    map[key] = self:read_value(rest, indent, line.no)
    order[#order + 1] = key
  end
  map.__keys = order
  return map
end

function Parser:parse_sequence(indent)
  local seq = {}
  while true do
    local line = self:peek()
    if not line or line.indent ~= indent then break end
    if not (line.text:sub(1, 2) == '- ' or line.text == '-') then break end

    local rest = (line.text == '-') and '' or line.text:sub(3)
    self.i = self.i + 1

    if trim(rest) == '' then
      local nxt = self:peek()
      if nxt and nxt.indent > indent then
        seq[#seq + 1] = self:parse_node(nxt.indent)
      else
        seq[#seq + 1] = ''
      end
    else
      local key = split_key(strip_comment(rest))
      if key then
        -- a mapping that begins on the dash line; continuation lines are
        -- whatever indent the following line uses (conventionally indent + 2)
        local nxt = self:peek()
        local child_indent = (nxt and nxt.indent > indent) and nxt.indent or (indent + 2)
        table.insert(self.lines, self.i, { indent = child_indent, text = rest, no = line.no })
        seq[#seq + 1] = self:parse_mapping(child_indent)
      else
        seq[#seq + 1] = self:read_value(rest, indent, line.no)
      end
    end
  end
  return seq
end

function Parser:parse_node(indent)
  local line = self:peek()
  if not line then return '' end
  if line.text:sub(1, 2) == '- ' or line.text == '-' then
    return self:parse_sequence(indent)
  end
  return self:parse_mapping(indent)
end

--------------------------------------------------------------------- public

local function do_parse(src)
  if src == nil then return {} end
  local p = new_parser(src)
  local first = p:peek()
  if not first then return {} end
  local value = p:parse_node(first.indent)
  local leftover = p:peek()
  if leftover then
    raise(('line %d: unexpected content %q'):format(leftover.no, leftover.text))
  end
  return value
end

-- Parse a YAML document into nested Lua tables. Mappings carry a `__keys`
-- array recording key order, which lets callers report unknown keys in the
-- order the author wrote them.
--
-- Returns the value, or nil plus a message an author can act on. It does not
-- raise, because a raise inside a Quarto filter is not reliably catchable.
function M.parse(src)
  local ok, res = pcall(do_parse, src)
  if ok then return res end
  local msg = tostring(res):gsub('^.-yaml%.lua:%d+:%s*', '')
  return nil, msg
end

M.unquote = unquote
M.strip_comment = strip_comment

return M
