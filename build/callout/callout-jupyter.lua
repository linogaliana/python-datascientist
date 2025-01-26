function createCallout(div, type)
    local customIcons = {
      exercise = "<i class=\"fa-solid fa-pencil\"></i>",
      note = "<i class=\"fa-solid fa-comment\"></i>",
      tip = "<i class=\"fa-solid fa-lightbulb\"></i>",
      warning = "<i class=\"fa-solid fa-triangle-exclamation\"></i>",
      important =  "<i class=\"fa-solid fa-triangle-exclamation\"></i>"
    }
    local customColor = {
        note = "info",
        tip = "success",
        exercise = "success",
        warning = "danger",
        important = "danger"
    }
  
    local title = type:gsub("^%l", string.upper)
    -- Use first element of div as title if this is a header
    if div.content[1] ~= nil and div.content[1].t == "Header" then
      title = pandoc.utils.stringify(div.content[1])
      div.content:remove(1)
    end
  
    local icon = customIcons[type] or ""
    local color = customColor[type] or ""
  
    if quarto.doc.is_format("ipynb") then
      if type == "exercise" then
        type = "tip"
        icon = customIcons["exercise"]
      end
      -- Add html formatting around
      local headBox = "<div class=\"alert alert-" .. color .. "\" role=\"alert\">\n" ..
        "<h3 class=\"alert-heading\">" .. icon .. " " .. title .. "</h3>\n"
  
      -- Insert raw HTML blocks
      div.content:insert(1, pandoc.RawBlock('html', headBox .. "\n"))
      div.content:insert(pandoc.RawBlock('html', "\n</div>"))   
      return div
    else
      local old_attr = div.attr
      local appearanceRaw = div.attr.attributes["appearance"]
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
  