----
--- Setup variables for default initialization

-- Define a variable to check if pyodide is present.
local missingPyodideCell = true

-- Define a variable to only include the initialization once
local hasDonePyodideSetup = false

--- Setup default initialization values
-- Default values taken from:
-- https://pyodide.org/en/stable/usage/api/js-api.html#globalThis.loadPyodide

-- Define a base compatibile version
local baseVersionPyodide = "0.27.2"

-- Define where Pyodide can be found. Default:
-- https://cdn.jsdelivr.net/pyodide/v0.z.y/full/
-- https://cdn.jsdelivr.net/pyodide/v0.z.y/debug/
local baseUrl = "https://cdn.jsdelivr.net/pyodide/v".. baseVersionPyodide .."/"
local buildVariant = "full/"
local indexURL = baseUrl .. buildVariant

-- Define user directory
local homeDir = "/home/pyodide"

-- Define whether a startup status message should be displayed
local showStartUpMessage = "true"

-- Define an empty string if no packages need to be installed.
local installPythonPackagesList = "''"
----

--- Setup variables for tracking number of code cells

-- Define a counter variable
local qPyodideCounter = 0

-- Initialize a table to store the CodeBlock elements
local qPyodideCapturedCodeBlocks = {}

-- Initialize a table that contains the default cell-level options
local qPyodideDefaultCellOptions = {
  ["context"] = "interactive",
  ["warning"] = "true",
  ["message"] = "true",
  ["results"] = "markup",
  ["read-only"] = "false",
  ["output"] = "true",
  ["comment"] = "",
  ["label"] = "",
  ["autorun"] = "",
  ["classes"] = "",
  ["dpi"] = 72,
  ["fig-cap"] = "",
  ["fig-width"] = 7,
  ["fig-height"] = 5,
  ["out-width"] = "700px",
  ["out-height"] = ""
}

----
--- Process initialization

-- Check if variable missing or an empty string
local function isVariableEmpty(s)
  return s == nil or s == ''
end

-- Check if variable is present
local function isVariablePopulated(s)
  return not isVariableEmpty(s)
end

-- Copy the top level value and its direct children
-- Details: http://lua-users.org/wiki/CopyTable
local function shallowcopy(original)
  -- Determine if its a table
  if type(original) == 'table' then
    -- Copy the top level to remove references
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    -- Return the copy
    return copy
  else
    -- If original is not a table, return it directly since it's already a copy
    return original
  end
end

-- Custom method for cloning a table with a shallow copy.
function table.clone(original)
  return shallowcopy(original)
end

local function mergeCellOptions(localOptions)
  -- Copy default options to the mergedOptions table
  local mergedOptions = table.clone(qPyodideDefaultCellOptions)

  -- Override default options with local options
  for key, value in pairs(localOptions) do
    if type(value) == "string" then
      value = value:gsub("[\"']", "")
    end
    mergedOptions[key] = value
  end

  -- Return the customized options
  return mergedOptions
end

-- Parse the different Pyodide options set in the YAML frontmatter, e.g.
--
-- ```yaml
-- ----
-- pyodide:
--   base-url: https://cdn.jsdelivr.net/pyodide/[version]
--   build-variant: full
--   packages: ['matplotlib', 'pandas']
-- ----
-- ```
--
-- 
function setPyodideInitializationOptions(meta)

  -- Let's explore the meta variable data! 
  -- quarto.log.output(meta)
  
  -- Retrieve the pyodide options from meta
  local pyodide = meta.pyodide

  -- Does this exist? If not, just return meta as we'll just use the defaults.
  if isVariableEmpty(pyodide) then
    return meta
  end

  -- The base URL used for downloading Python WebAssembly binaries 
  if isVariablePopulated(pyodide["base-url"]) then
    baseUrl = pandoc.utils.stringify(pyodide["base-url"])
  end

  -- The build variant for Python WebAssembly binaries. Default: 'full'
  if isVariablePopulated(pyodide["build-variant"]) then
    buildVariant = pandoc.utils.stringify(pyodide["build-variant"])
  end

  if isVariablePopulated(pyodide["build-variant"]) or isVariablePopulated(pyodide["base-url"]) then
    indexURL = baseUrl .. buildVariant
  end

  -- The WebAssembly user's home directory and initial working directory. Default: '/home/pyodide'
  if isVariablePopulated(pyodide['home-dir']) then
    homeDir = pandoc.utils.stringify(pyodide["home-dir"])
  end

  -- Display a startup message indicating the pyodide state at the top of the document.
  if isVariablePopulated(pyodide['show-startup-message']) then
    showStartUpMessage = pandoc.utils.stringify(pyodide["show-startup-message"])
  end

  -- Attempt to install different packages.
  if isVariablePopulated(pyodide["packages"]) then
    -- Create a custom list
    local package_list = {}

    -- Iterate through each list item and enclose it in quotes
    for _, package_name in pairs(pyodide["packages"]) do
      table.insert(package_list, "'" .. pandoc.utils.stringify(package_name) .. "'")
    end

    installPythonPackagesList = table.concat(package_list, ", ")
  end
  
  return meta
end


-- Obtain a template file
function readTemplateFile(template)
  -- Establish a hardcoded path to where the .html partial resides
  -- Note, this should be at the same level as the lua filter.
  -- This is crazy fragile since Lua lacks a directory representation (!?!?)
  -- https://quarto.org/docs/extensions/lua-api.html#includes
  local path = quarto.utils.resolve_path(template) 

  -- Let's hopefully read the template file... 

  -- Open the template file
  local file = io.open(path, "r")

  -- Check if null pointer before grabbing content
  if not file then        
    error("\nWe were unable to read the template file `" .. template .. "` from the extension directory.\n\n" ..
          "Double check that the extension is fully available by comparing the \n" ..
          "`_extensions/coatless-quarto/pyodide` directory with the main repository:\n" ..
          "https://github.com/coatless-quarto/pyodide/tree/main/_extensions/pyodide\n\n" ..
          "You may need to modify `.gitignore` to allow the extension files using:\n" ..
          "!_extensions/*/*/*\n")
    return nil
  end

  -- *a or *all reads the whole file
  local content = file:read "*a" 

  -- Close the file
  file:close()

  -- Return contents
  return content
end

-- Define a function that escape control sequence
function escapeControlSequences(str)
  -- Perform a global replacement on the control sequence character
  return str:gsub("[\\%c]", function(c)
    if c == "\\" then
      -- Escape backslash
      return "\\\\"
    end
  end)
end

function initializationPyodide()

  -- Setup different Pyodide specific initialization variables
  local substitutions = {
    ["INDEXURL"] = indexURL, 
    ["HOMEDIR"] = homeDir,
    ["SHOWSTARTUPMESSAGE"] = showStartUpMessage, 
    ["INSTALLPYTHONPACKAGESLIST"] = installPythonPackagesList,
    ["QPYODIDECELLDETAILS"] = quarto.json.encode(qPyodideCapturedCodeBlocks),
  }
  
  -- Make sure we perform a copy
  local initializationTemplate = readTemplateFile("qpyodide-document-settings.js")

  -- Make the necessary substitutions
  local initializedPyodideConfiguration = substitute_in_file(initializationTemplate, substitutions)

  return initializedPyodideConfiguration 
end

local function generateHTMLElement(tag)
  -- Store a map containing opening and closing tabs
  local tagMappings = {
      module = { opening = "<script type=\"module\">\n", closing = "\n</script>" },
      js = { opening = "<script type=\"text/javascript\">\n", closing = "\n</script>" },
      css = { opening = "<style type=\"text/css\">\n", closing = "\n</style>" }
  }

  -- Find the tag
  local tagMapping = tagMappings[tag]

  -- If present, extract tag and return
  if tagMapping then
      return tagMapping.opening, tagMapping.closing
  else
      quarto.log.error("Invalid tag specified")
  end
end

-- Custom functions to include values into Quarto
-- https://quarto.org/docs/extensions/lua-api.html#includes

local function includeTextInHTMLTag(location, text, tag)

  -- Obtain the HTML element opening and closing tag
  local openingTag, closingTag = generateHTMLElement(tag)

  -- Insert the file into the document using the correct opening and closing tags
  quarto.doc.include_text(location, openingTag .. text .. closingTag)

end

local function includeFileInHTMLTag(location, file, tag)

  -- Obtain the HTML element opening and closing tag
  local openingTag, closingTag = generateHTMLElement(tag)

  -- Retrieve the file contents
  local fileContents = readTemplateFile(file)

  -- Insert the file into the document using the correct opening and closing tags
  quarto.doc.include_text(location, openingTag .. fileContents .. closingTag)

end


-- Setup Pyodide's pre-requisites once per document.
function ensurePyodideSetup()
  
  -- If we've included the initialization, then bail.
  if hasDonePyodideSetup then
    return
  end
  
  -- Otherwise, let's include the initialization script _once_
  hasDonePyodideSetup = true

  local initializedConfigurationPyodide = initializationPyodide()

  -- Insert different partial files to create a monolithic document.
  -- https://quarto.org/docs/extensions/lua-api.html#includes

  -- Embed Support Files to Avoid Resource Registration Issues
  -- Note: We're not able to use embed-resources due to the web assembly binary and the potential for additional service worker files.
  quarto.doc.include_text("in-header", [[
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/monaco-editor@0.46.0/min/vs/editor/editor.main.css" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" integrity="sha512-DTOQO9RWCH3ppGqcWaEA1BIZOC6xxalwEsw9c2QQeAIftl+Vegovlnee1c9QX4TctnWMn13TZye+giMm8e2LwA==" crossorigin="anonymous" referrerpolicy="no-referrer" />
  ]])

  -- Insert CSS styling and external style sheets
  includeFileInHTMLTag("in-header", "qpyodide-styling.css", "css")

  -- Insert the Pyodide initialization routine
  includeTextInHTMLTag("in-header", initializedConfigurationPyodide, "module")

  -- Insert JS routine to add document status header
  includeFileInHTMLTag("in-header", "qpyodide-document-status.js", "module")

  -- Insert JS routine to bring Pyodide online
  includeFileInHTMLTag("in-header", "qpyodide-document-engine-initialization.js", "module")

  -- Insert the Monaco Editor initialization
  quarto.doc.include_file("before-body", "qpyodide-monaco-editor-init.html")

  -- Insert the cell data at the end of the document
  includeFileInHTMLTag("after-body", "qpyodide-cell-classes.js", "module")

  includeFileInHTMLTag("after-body", "qpyodide-cell-initialization.js", "module")

end

-- Define a function to replace keywords given by {{ WORD }}
-- Is there a better lua-approach?
function substitute_in_file(contents, substitutions)

  -- Substitute values in the contents of the file
  contents = contents:gsub("{{%s*(.-)%s*}}", substitutions)

  -- Return the contents of the file with substitutions
  return contents
end

local function qPyodideJSCellInsertionCode(counter)
  local insertionLocation = '<div id="qpyodide-insertion-location-' .. counter ..'"></div>\n'
  local noscriptWarning = '<noscript>Please enable JavaScript to experience the dynamic code cell content on this page.</noscript>'
  return insertionLocation .. noscriptWarning
end

-- Extract Quarto code cell options from the block's text
local function extractCodeBlockOptions(block)
  
  -- Access the text aspect of the code block
  local code = block.text

  -- Define two local tables:
  --  the block's attributes
  --  the block's code lines
  local cellOptions = {}
  local newCodeLines = {}

  -- Iterate over each line in the code block 
  for line in code:gmatch("([^\r\n]*)[\r\n]?") do
    -- Check if the line starts with "#|" and extract the key-value pairing
    -- e.g. #| key: value goes to cellOptions[key] -> value
    local key, value = line:match("^#|%s*(.-):%s*(.-)%s*$")

    -- If a special comment is found, then add the key-value pairing to the cellOptions table
    if key and value then
      cellOptions[key] = value
    else
      -- Otherwise, it's not a special comment, keep the code line
      table.insert(newCodeLines, line)
    end
  end

  -- Merge cell options with default options
  cellOptions = mergeCellOptions(cellOptions)

  -- Set the codeblock text to exclude the special comments.
  cellCode = table.concat(newCodeLines, '\n')

  -- Return the code alongside options
  return cellCode, cellOptions
end



-- Replace the code cell with a Pyodide interactive editor
function enablePyodideCodeCell(el)
      
  -- Let's see what's going on here:
  -- quarto.log.output(el)
  
  -- Should display the following elements:
  -- https://pandoc.org/lua-filters.html#type-codeblock
  
  -- Verify the element has attributes and the document type is HTML
  -- not sure if this will work with an epub (may need html:js)
  if not (el.attr and (quarto.doc.is_format("html") or quarto.doc.is_format("markdown"))) then
    return el
  end

  -- Check for the new engine syntax that allows for the cell to be 
  -- evaluated in VS Code or RStudio editor views, c.f.
  -- https://github.com/quarto-dev/quarto-cli/discussions/4761#discussioncomment-5338631
  if not el.attr.classes:includes("{pyodide-python}") then
    return el
  end

  -- We detected a webR cell
  missingPyodideCell = false

  -- Local code cell storage
  local cellOptions = {}
  local cellCode = ''

  -- Convert webr-specific option commands into attributes
  cellCode, cellOptions = extractCodeBlockOptions(el)

  -- Modify the counter variable each time this is run to create
  -- unique code cells
  qPyodideCounter = qPyodideCounter + 1
  
  -- Create a new table for the CodeBlock
  local codeBlockData = {
    id = qPyodideCounter,
    code = cellCode,
    options = cellOptions
  }

  -- Store the CodeDiv in the global table
  table.insert(qPyodideCapturedCodeBlocks, codeBlockData)

  -- Return an insertion point inside the document
  return pandoc.RawInline('html', qPyodideJSCellInsertionCode(qPyodideCounter))
end

local function stitchDocument(doc)

  -- Do not attach webR as the page lacks any active webR cells
  if missingPyodideCell then 
    return doc
  end

  -- Release injections into the HTML document after each cell
  -- is visited and we have collected all the content.
  ensurePyodideSetup()

  return doc
end

return {
  {
    Meta = setPyodideInitializationOptions
  }, 
  {
    CodeBlock = enablePyodideCodeCell
  }, 
  {
    Pandoc = stitchDocument
  }
}
