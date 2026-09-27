-- Sortie Typst: le code en ligne (`toto`) est confié à `ds-inline` (styles/typst/style.typ)
-- plutôt qu'à la coloration syntaxique de pandoc, dont les couleurs sont celles du
-- thème sombre des blocs de code.
if not quarto.doc.is_format("typst") then
  return {}
end

local function typst_string(s)
  s = s:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", " ")
  return '"' .. s .. '"'
end

return {
  {
    Code = function(el)
      return pandoc.RawInline("typst", "#ds-inline(" .. typst_string(el.text) .. ")")
    end,
  },
}
