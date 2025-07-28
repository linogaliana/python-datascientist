local filename = quarto.doc and quarto.doc.input_file or ""
local dirname = quarto.project and quarto.project.directory or ""

-- Escape special characters
local function escape_pattern(str)
  return str and str:gsub("([^%w])", "%%%1") or ""
end

dirname = escape_pattern(dirname)

local filename_relative = filename:gsub("^" .. dirname, "")
filename_relative = "https://pythonds.linogaliana.fr" .. filename_relative
filename_relative = filename_relative:gsub("%.qmd$", ".html")

-- Vérifie la langue
local function ends_with(str, suffix)
  return str:sub(-#suffix) == suffix
end

-- Création du bloc .callout-note avec contenu HTML
local function get_callout_div()
  local html_text

  if ends_with(filename_relative, "_en.html") then
    html_text = "This is the English 🇬🇧 🇺🇸 version of that chapter, to see the French version go " ..
                "<a href=\"" .. filename_relative:gsub("_en.html", ".html") .. "\">there</a>."
  else
    html_text = "Ceci est la version française 🇫🇷 de ce chapitre, pour voir la version anglaise allez " ..
                "<a href=\"" .. filename_relative:gsub(".html", "_en.html") .. "\">ici</a>."
  end

  return pandoc.Div(
    { pandoc.Para{ pandoc.RawInline("html", html_text) } },
    pandoc.Attr("", { "callout-note" })
  )
end

-- Hook principal : remplace {{warninglang}} par un .callout-note
return {
  {
    Para = function (elem)
      for i, v in ipairs(elem.content) do
        if v.t == "Str" and v.text == "{{warninglang}}" then
          return get_callout_div()
        end
      end
      return elem
    end
  }
}
