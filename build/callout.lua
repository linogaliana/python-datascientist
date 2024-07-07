function Div(div)
  -- process exercise

  if div.classes:includes("note") then
    -- default title
    local title = "Exercise"
    -- Use first element of div as title if this is a header
    if div.content[1] ~= nil and div.content[1].t == "Header" then
      title = pandoc.utils.stringify(div.content[1])
      div.content:remove(1)
    end

    if quarto.doc.is_format("ipynb") then
      -- Add html formatting around
      local headBox = "<div class=\"alert alert-info\" role=\"alert\">"
      local headNote = "<h3 class=\"alert-heading\"><i class=\"fa-solid fa-comment\"></i> " .. title .. "</h3>"
      
      -- Insert raw HTML blocks
      div.content:insert(1, pandoc.RawBlock('html', headBox .. "\n" .. headNote))
      div.content:insert(pandoc.RawBlock('html', "</div>"))   
      return div
    else
      local old_attr = div.attr
      local appearanceRaw = div.attr.attributes["appearance"]
      local icon = div.attr.attributes["icon"]
      local collapse = div.attr.attributes["collapse"]
      return quarto.Callout({
        type = "note",
        title = title, 
        collapse = collapse,
        content = div.content,
        icon = icon
      })      
    end
  end
end
