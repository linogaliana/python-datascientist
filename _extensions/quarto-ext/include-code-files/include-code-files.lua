--- include-code-files.lua – filter to include code from source files
---
--- Copyright: © 2020 Bruno BEAUFILS
--- License:   MIT – see LICENSE file for details

--- Dedent a line
local function dedent(line, n)
  return line:sub(1, n):gsub(" ", "") .. line:sub(n + 1)
end

--- Find snippet start and end.
--
--  Use this to populate startline and endline.
--  This should work like pandocs snippet functionality: https://github.com/owickstrom/pandoc-include-code/tree/master
local function snippet(cb, fh)
  if not cb.attributes.snippet then
    return
  end

  -- Cannot capture enum: http://lua-users.org/wiki/PatternsTutorial
  local comment
  local comment_stop = ""
  if
    string.match(cb.attributes.include, ".py$")
    or string.match(cb.attributes.include, ".jl$")
    or string.match(cb.attributes.include, ".r$")
  then
    comment = "#"
  elseif string.match(cb.attributes.include, ".o?js$") or string.match(cb.attributes.include, ".css$") then
    comment = "//"
  elseif string.match(cb.attributes.include, ".lua$") then
    comment = "--"
  elseif string.match(cb.attributes.include, ".html$") then
    comment = "<!%-%-"
    comment_stop = " *%-%->"
  else
    -- If not known assume that it is something one or two long and not alphanumeric.
    comment = "%W%W?"
  end

  local p_start = string.format("^ *%s start snippet %s%s", comment, cb.attributes.snippet, comment_stop)
  local p_stop = string.format("^ *%s end snippet %s%s", comment, cb.attributes.snippet, comment_stop)
  local start, stop = nil, nil

  -- Cannot use pairs.
  local line_no = 1
  for line in fh:lines() do
    if start == nil then
      if string.match(line, p_start) then
        start = line_no + 1
      end
    elseif stop == nil then
      if string.match(line, p_stop) then
        stop = line_no - 1
      end
    else
      break
    end
    line_no = line_no + 1
  end

  -- Reset so nothing is broken later on.
  fh:seek("set")

  -- If start and stop not found, just continue
  if start == nil or stop == nil then
    return nil
  end

  cb.attributes.startLine = tostring(start)
  cb.attributes.endLine = tostring(stop)
end

--- Filter function for code blocks
local function transclude(cb)
  if cb.attributes.include then
    local content = ""
    local fh = io.open(cb.attributes.include)
    if not fh then
      io.stderr:write("Cannot open file " .. cb.attributes.include .. " | Skipping includes\n")
    else
      local number = 1
      local start = 1

      -- change hyphenated attributes to PascalCase
      for i, pascal in pairs({ "startLine", "endLine" }) do
        local hyphen = pascal:gsub("%u", "-%0"):lower()
        if cb.attributes[hyphen] then
          cb.attributes[pascal] = cb.attributes[hyphen]
          cb.attributes[hyphen] = nil
        end
      end

      -- Overwrite startLine and stopLine with the snippet if any.
      snippet(cb, fh)

      if cb.attributes.startLine then
        cb.attributes.startFrom = cb.attributes.startLine
        start = tonumber(cb.attributes.startLine)
      end

      for line in fh:lines("L") do
        if cb.attributes.dedent then
          line = dedent(line, cb.attributes.dedent)
        end
        if number >= start then
          if not cb.attributes.endLine or number <= tonumber(cb.attributes.endLine) then
            content = content .. line
          end
        end
        number = number + 1
      end

      fh:close()
    end

    -- remove key-value pair for used keys
    cb.attributes.include = nil
    cb.attributes.startLine = nil
    cb.attributes.endLine = nil
    cb.attributes.dedent = nil

    -- return final code block
    return pandoc.CodeBlock(content, cb.attr)
  end
end

return {
  { CodeBlock = transclude },
}
