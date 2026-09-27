-- Sortie Typst: supprime la sortie des cellules qui affichent une carte
-- `folium`. Ces cartes n'existent qu'en HTML (Leaflet); faute de rendu
-- HTML, Jupyter se rabat sur leur représentation texte
-- (`<folium.folium.Map at 0x...>`), qui n'a aucun sens dans le PDF.
-- Le code de la cellule est conservé.
if not quarto.doc.is_format("typst") then
  return {}
end

local function is_folium_repr(block)
  return block.t == "CodeBlock" and block.text:match("^%s*<folium%.[%w_.]+ at 0x%x+>%s*$") ~= nil
end

return {
  {
    Div = function(el)
      if not el.classes:includes("cell-output-display") then
        return nil
      end
      for _, block in ipairs(el.content) do
        if not is_folium_repr(block) then
          return nil
        end
      end
      return {}
    end,
  },
}
