-- badges.lua

-- Helper function to generate badge HTML
function make_badge(link, image_url, alt_text)
  return string.format('<a href="%s" target="_blank" rel="noopener"><img src="%s" alt="%s"></a>', link, image_url, alt_text)
end

-- Escape special characters in dirname
local function escape_pattern(str)
  return str:gsub("([^%w])", "%%%1")
end

local char_to_hex = function(c)
  return string.format("%%%02X", string.byte(c))
end

local function urlencode(url)
  if url == nil then
    return
  end
  url = url:gsub("\n", "\r\n")
  url = url:gsub("([^%w ])", char_to_hex)
  url = url:gsub(" ", "+")
  return url
end

local hex_to_char = function(x)
  return string.char(tonumber(x, 16))
end

local urldecode = function(url)
  if url == nil then
    return
  end
  url = url:gsub("+", " ")
  url = url:gsub("%%(%x%x)", hex_to_char)
  return url
end

-- Function to substitute a value based on a key in kwargs or a default
local function sub_value(kwargs, key, default)
  if kwargs[key] and type(kwargs[key]) == "string" and kwargs[key] ~= "" then
    -- Log the use of the key's value
    quarto.log.output("Using " .. key .. ": " .. kwargs[key])
    return kwargs[key]
  else
    -- Log the use of the default value
    quarto.log.output("Using default: " .. default)
    return default
  end
end


-- Function to create the badges
function reminder_badges(args, kwargs)

  -- Ensure kwargs is a table
  kwargs = kwargs or {}

  -- Get the current file path
  local inputfilename = quarto.doc.input_file
  local dirname = quarto.project.directory
  dirname = escape_pattern(dirname)

  -- Compute the relative path from the project root
  local sourceFile = inputfilename:gsub("^" .. dirname, "")
  
  -- Check if 'fpath' exists and is a string
  local filename = sub_value(kwargs, 'fpath', sourceFile)

  -- Convert the filename to the corresponding notebook path
  local notebook = filename:gsub("%.qmd$", ".ipynb")

  -- Use sub_value function to get other values
  local type = sub_value(kwargs, 'type', 'html')
  local sspCloudService = sub_value(kwargs, 'sspCloudService', 'python')
  local GPU = sub_value(kwargs, 'GPU', "false")
  local correction = sub_value(kwargs, 'correction', "false")

  if (correction == "true") then
    notebook = notebook:gsub("content", "corrections")
  else
    notebook = notebook:gsub("content", "notebooks")
  end


  local githubAlias = "github.com/linogaliana/python-datascientist-notebooks"
  local githubRepoNotebooks = "https://" .. githubAlias

  local githubLink = githubRepoNotebooks .. "/blob/main" .. notebook
  local githubBadge = make_badge(githubLink, "https://img.shields.io/static/v1?logo=github&label=&message=View%20on%20GitHub&color=181717", "View on GitHub")

  local section, chapter = notebook:match("([^/]+)/([^/]+)$")
  local chapterNoExtension = chapter:gsub("%.ipynb$", "")

  local onyxiaInitArgs = { section, chapterNoExtension }
  if correction then
    table.insert(onyxiaInitArgs, "correction")
  end

  local gpuSuffix
  if (GPU == "true") then
    gpuSuffix = "-gpu"
  else
    gpuSuffix = ""
  end

  local sspcloudJupyterLinkLauncher = string.format(
    "https://datalab.sspcloud.fr/launcher/ide/jupyter-%s%s?autoLaunch=true&name=%s",
    sspCloudService, 
    gpuSuffix, 
    "«" .. chapterNoExtension .. "»"
  )
  
  sspcloudJupyterLinkLauncher = sspcloudJupyterLinkLauncher ..
      "&init.personalInit=" ..
      "«https%3A%2F%2Fraw.githubusercontent.com%2Flinogaliana%2Fpython-datascientist%2Fmaster%2Fsspcloud%2Finit-jupyter.sh»" ..
      "&init.personalInitArgs=" ..
      "«" .. table.concat(onyxiaInitArgs, "%20") .. "»" ..
      "&security.allowlist.enabled=false"

  
  local sspcloudJupyterBadge = make_badge(sspcloudJupyterLinkLauncher, "https://img.shields.io/badge/SSP%20Cloud-Tester_avec_Jupyter-orange?logo=Jupyter&logoColor=orange", "Onyxia")

  local sspcloudVscodeLinkLauncher = string.format(
    "https://datalab.sspcloud.fr/launcher/ide/vscode-%s%s?autoLaunch=true&name=%s",
    sspCloudService, 
    gpuSuffix, 
    "«" .. chapterNoExtension .. "»"
  )

  sspcloudVscodeLinkLauncher = sspcloudVscodeLinkLauncher ..
      "&init.personalInit=" ..
      "«https%3A%2F%2Fraw.githubusercontent.com%2Flinogaliana%2Fpython-datascientist%2Fmaster%2Fsspcloud%2Finit-vscode.sh»" ..
      "&init.personalInitArgs=" ..
      "«" .. table.concat(onyxiaInitArgs, "%20") .. "»" ..
      "&security.allowlist.enabled=false"
    

  local sspcloudVscodeBadge = make_badge(sspcloudVscodeLinkLauncher, "https://img.shields.io/badge/SSP%20Cloud-Tester_avec_VSCode-blue?logo=visualstudiocode&logoColor=blue", "Onyxia")

  local colabLink = string.format(
    "https://colab.research.google.com/github/linogaliana/python-datascientist-notebooks/blob/main/%s",
    notebook
  )

  local colabBadge = make_badge(colabLink, "https://colab.research.google.com/assets/colab-badge.svg", "Open In Colab")

  local badges = { githubBadge, sspcloudVscodeBadge, sspcloudJupyterBadge }

  if not onyxiaOnly then
    table.insert(badges, colabBadge)
  end

  -- Concatenate badges and ensure the result is treated as HTML
  local badges_html = table.concat(badges, type == "html" and "\n" or " ")
  return pandoc.RawBlock('html', badges_html)
end

-- Main function to print badges
return {
  ['badges'] = function(args, kwargs)
    return reminder_badges(args, kwargs)
  end  
}
