-- Création du bloc .callout-note avec contenu HTML
local function get_callout_div()
  local html_text

  if filename_relative:find("/en/") then
    -- English version: link to French
    local link = filename_relative:gsub("/en/", "/")
    html_text = "This is the English 🇬🇧 🇺🇸 version of that chapter, to see the French version go " ..
                "<a href=\"" .. link .. "\">there</a>."
  else
    -- French version: link to English
    local link = filename_relative:gsub("/content/", "/en/content/")
    html_text = "Ceci est la version française 🇫🇷 de ce chapitre, pour voir la version anglaise allez " ..
                "<a href=\"" .. link .. "\">ici</a>."
  end

  return pandoc.Div(
    { pandoc.Para{ pandoc.RawInline("html", html_text) } },
    pandoc.Attr("", { "callout-note" })
  )
end
