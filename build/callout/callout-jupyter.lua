function createCallout(div, type)
  local customIcons = {
    exercise = "<i class=\"fa-solid fa-pencil\"></i>",
    note = "<i class=\"fa-solid fa-comment\"></i>",
    tip = "<i class=\"fa-solid fa-lightbulb\"></i>",
    warning = "<i class=\"fa-solid fa-triangle-exclamation\"></i>",
    important = "<i class=\"fa-solid fa-triangle-exclamation\"></i>"
  }

  local customColor = {
    note = "info",
    tip = "success",
    exercise = "success",
    warning = "danger",
    important = "danger"
  }

  local title = type:gsub("^%l", string.upper)

  -- Use first element of div as title if it is a Header
  if div.content[1] ~= nil and div.content[1].t == "Header" then
    title = pandoc.utils.stringify(div.content[1])
    div.content:remove(1)
  end

  local icon = customIcons[type] or ""
  local color = customColor[type] or ""

  -- Add HTML formatting for ipynb output
  local headBox = "<div class=\"alert alert-" .. color .. "\" role=\"alert\">\n" ..
                  "<h3 class=\"alert-heading\">" .. icon .. " " .. title .. "</h3>\n"

  div.content:insert(1, pandoc.RawBlock('html', headBox))
  div.content:insert(pandoc.RawBlock('html', "</div>"))

  return div
end

function Div(div)
  if not quarto.doc.is_format("ipynb") then
    return nil
  end

  -- List of base callout types
  local baseTypes = { "note", "caution", "warning", "important", "tip", "exercise" }

  for _, type in ipairs(baseTypes) do
    if div.classes:includes(type) or div.classes:includes("callout-" .. type) then
      return createCallout(div, type)
    end
  end
end
