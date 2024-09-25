function createCallout(div, type)
  local title = type:gsub("^%l", string.upper)
  -- Use first element of div as title if this is a header
  if div.content[1] ~= nil and div.content[1].t == "Header" then
    title = pandoc.utils.stringify(div.content[1])
    div.content:remove(1)
  end

  if quarto.doc.is_format("ipynb") then
    if type == "exercise" then
      type = "tip"
    end
    -- Add html formatting around
    local headBox = "<div class=\"callout callout-style-default callout-" .. type .. " callout-titled\">\n" ..
      "<div class=\"callout-header d-flex align-content-center\">\n" ..
      "<div class=\"callout-icon-container\">" ..
      "<i class=\"callout-icon\"></i>\n" ..
      "</div>\n"

    local headNote = "<div class=\"callout-title-container flex-fill\">\n" ..
      title .. "\n" ..
      "</div>\n" ..
      "</div>\n"

    local preBody = "<div class=\"callout-body-container callout-body\">\n"

    -- Insert raw HTML blocks
    div.content:insert(1, pandoc.RawBlock('html', headBox .. "\n" .. headNote))
    div.content:insert(pandoc.RawBlock('html', "\n</div>\n</div>"))   
    return div
  else
    local old_attr = div.attr
    local appearanceRaw = div.attr.attributes["appearance"]
    local icon = div.attr.attributes["icon"]
    local collapse = div.attr.attributes["collapse"]
    return quarto.Callout({
      type = type,
      title = title, 
      collapse = false,
      content = div.content,
      icon = icon
    })      
  end
end

function Div(div)
  -- List of supported callout types
  local callout_types = {"note", "caution",  "warning", "important", "tip", "exercise"}

  for _, type in ipairs(callout_types) do
    if div.classes:includes(type) then
      return createCallout(div, type)
    end
  end
end
