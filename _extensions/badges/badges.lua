-- badges.lua

-- Helper function to generate badge HTML
function make_badge(link, image_url, alt_text)
  return string.format('<a href="%s" target="_blank" rel="noopener"><img src="%s" alt="%s"></a>', link, image_url, alt_text)
end

-- Escape special characters in dirname
local function escape_pattern(str)
  return str:gsub("([^%w])", "%%%1")
end


-- Function to substitute a value based on a key in kwargs or a default
local function sub_value(kwargs, key, default)
  if kwargs[key] and type(kwargs[key]) == "string" and kwargs[key] ~= "" then
    return kwargs[key]
  else
    return default
  end
end


function reminder_badges(args, kwargs)

  -- Get the language from the environment variable
  local lang = os.getenv("QUARTO_PROFILE") or "fr" -- Default to "fr" if QUARTO_PROFILE is not set
  quarto.log.output("Language: " .. lang)

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
  local printMessage = sub_value(kwargs, 'printMessage', "true")
  local container_class = sub_value(kwargs, 'container_class', 'badge-container')
  local badge_class = sub_value(kwargs, 'badge_class', 'badge')

  local substitution = "notebooks"
  if (correction == "true") then
    substitution = "corrections"
  end
  if lang == "en" then
    substitution = substitution .. "/en"
  end

  notebook = notebook:gsub("content", substitution)

  -- Modify URLs based on language
  local githubAlias = "github.com/linogaliana/python-datascientist-notebooks"
  local githubRepoNotebooks = "https://" .. githubAlias
  local githubLink = githubRepoNotebooks .. "/blob/main" .. notebook
  local githubBadge = make_badge(githubLink, "https://img.shields.io/static/v1?logo=github&label=&message=View%20on%20GitHub&color=181717", "View on GitHub", badge_class)

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

  -- Modify URLs for SSPCloud based on language
  local sspcloudJupyterLinkLauncher = string.format(
    "https://datalab.sspcloud.fr/launcher/ide/jupyter-%s%s?autoLaunch=true&name=%s",
    sspCloudService, 
    gpuSuffix, 
    "«" .. chapterNoExtension .. "»"
  )
  
  sspcloudJupyterLinkLauncher = sspcloudJupyterLinkLauncher ..
      "&init.personalInit=" ..
      "«https%3A%2F%2Fraw.githubusercontent.com%2Flinogaliana%2Fpython-datascientist-" .. lang .. "%2Fmaster%2Fsspcloud%2Finit-jupyter.sh»" ..
      "&init.personalInitArgs=" ..
      "«" .. table.concat(onyxiaInitArgs, "%20") .. "»" ..
      "&security.allowlist.enabled=false"

  local sspcloudJupyterBadge = make_badge(sspcloudJupyterLinkLauncher, "https://img.shields.io/badge/SSP%20Cloud-Tester_avec_Jupyter-orange?logo=Jupyter&logoColor=orange", "Onyxia", badge_class)

  local sspcloudVscodeLinkLauncher = string.format(
    "https://datalab.sspcloud.fr/launcher/ide/vscode-%s%s?autoLaunch=true&name=%s",
    sspCloudService, 
    gpuSuffix, 
    "«" .. chapterNoExtension .. "»"
  )

  sspcloudVscodeLinkLauncher = sspcloudVscodeLinkLauncher ..
      "&init.personalInit=" ..
      "«https%3A%2F%2Fraw.githubusercontent.com%2Flinogaliana%2Fpython-datascientist-" .. lang .. "%2Fmaster%2Fsspcloud%2Finit-vscode.sh»" ..
      "&init.personalInitArgs=" ..
      "«" .. table.concat(onyxiaInitArgs, "%20") .. "»" ..
      "&security.allowlist.enabled=false"

  local sspcloudVscodeBadge = make_badge(sspcloudVscodeLinkLauncher, "https://img.shields.io/badge/SSP%20Cloud-Tester_avec_VSCode-blue?logo=visualstudiocode&logoColor=blue", "Onyxia", badge_class)

  local colabLink = string.format(
    "https://colab.research.google.com/github/linogaliana/python-datascientist-" .. lang .. "/blob/main/%s",
    notebook
  )

  local colabBadge = make_badge(colabLink, "https://colab.research.google.com/assets/colab-badge.svg", "Open In Colab", badge_class)

  local badges = { githubBadge, sspcloudVscodeBadge, sspcloudJupyterBadge }

  if not onyxiaOnly then
    table.insert(badges, colabBadge)
  end

  -- Concatenate badges and ensure the result is treated as HTML
  local badges_html = table.concat(badges, type == "html" and "\n" or " ")

  -- Add message
  local message
  if lang == "en" then
    message = "If you want to try the examples in this tutorial:"
  else
    message = "Pour essayer les exemples présents dans ce tutoriel :"
  end

  if (correction == "true") then
    if lang == "en" then
      message = "To open the correction on a dedicated notebook"
    else
      message = "Pour ouvrir la version corrigée sous forme de <i>notebook</i>:"
    end
  end

  if (printMessage == "true") then
    if (correction == "true") then
      badges_html = '<div class="badge-container">' ..
        '<details>' ..
        '<summary class="badge-text">' ..
        message .. 
        '</summary>' ..
        badges_html ..
        '</details>'
    else
      badges_html = string.format(
        '<div class="%s"><div class="badge-text">%s</div>%s<br></div>',
        "badge-container", message, badges_html
      )
      end
  else
    badges_html = string.format(
      '<div class="%s">%s<br></div>',
      "badge-container", badges_html
    )
  end

  badges_html = pandoc.RawBlock('html', badges_html)
  
  if quarto.doc.is_format("ipynb") then
    return pandoc.Div(
      badges_html,
      {class = "markdown"}
    )    
  end

  return badges_html
end

-- Main function to print badges
return {
  ['badges'] = function(args, kwargs)
    return reminder_badges(args, kwargs)
  end  
}