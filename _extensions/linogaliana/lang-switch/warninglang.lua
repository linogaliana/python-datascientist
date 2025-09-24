-- filters/warninglang.lua
function Div(el)
  if el.classes:includes("warninglang") then
    local filename_relative = quarto.doc.input_file
    local html_text

    if filename_relative:find("/en/") then
      local link = filename_relative:gsub("/en/", "/")
      html_text =
        "This is the English 🇬🇧 🇺🇸 version of this chapter, " ..
        "to see the French version go " ..
        "<a href=\"https://pythonds.linogaliana.fr/" .. link .. "\">there</a>."
    else
      local link = filename_relative:gsub("/content/", "/en/content/")
      html_text =
        "Ceci est la version française 🇫🇷 de ce chapitre, " ..
        "pour voir la version anglaise rendez-vous sur " ..
        "<a href=\"https://pythonds.linogaliana.fr/" .. link .. "\">le site du cours</a>."
    end

    -- Ici on réintroduit bien le callout
    return pandoc.Div(
      { pandoc.Para{ pandoc.RawInline("html", html_text) } },
      pandoc.Attr("", { "callout", "callout-note" })
    )
  end
end
