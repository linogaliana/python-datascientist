function pdf(args, kwargs)
  local data = pandoc.utils.stringify(args[1]) or pandoc.utils.stringify(kwargs['file'])
  local width = pandoc.utils.stringify(kwargs['width'])
  local height = pandoc.utils.stringify(kwargs['height'])
  local border = pandoc.utils.stringify(kwargs['border'])
  local class = pandoc.utils.stringify(kwargs['class'])
  local image = pandoc.utils.stringify(kwargs['image'])
  local image_force = pandoc.utils.stringify(kwargs['image_force'])
  local image_width = pandoc.utils.stringify(kwargs['image_width'])
  local image_height = pandoc.utils.stringify(kwargs['image_height'])
  local image_border = pandoc.utils.stringify(kwargs['image_border'])
  local image_class = pandoc.utils.stringify(kwargs['image_class'])
  
  if width ~= '' then
    width = 'width="' .. width .. '" '
  end
  
  if height ~= '' then
    height = 'height="' .. height .. '" '
  end
  
  if border ~= '' then
    border = 'border="' .. border .. '" '
  end
  
  if class ~= '' then
    class = 'class="' .. class .. '" '
  end
  
  if image_width ~= '' then
    image_width = 'width="' .. image_width .. '" '
  end
  
  if image_height ~= '' then
    image_height = 'height="' .. image_height .. '" '
  end
  
  if image_border ~= '' then
    image_border = 'border="' .. image_border .. '" '
  end
  
  if image_class ~= '' then
    image_class = 'class="' .. image_class .. '" '
  end
  
  -- detect html
  if quarto.doc.isFormat("html:js") then
    if image_force == 'TRUE' then
      return pandoc.RawInline('html', '<a href="' .. data .. '" download><img src="' .. image .. '" ' .. image_width .. image_height .. image_class .. image_border .. ' /></a>')
    end
    if image ~= '' then
      return pandoc.RawInline('html', '<object data="' .. data .. '" type="application/pdf"' .. width .. height .. class .. border .. '><a href="' .. data .. '" download><img src="' .. image .. '" ' .. image_width .. image_height .. image_class .. image_border .. ' /></a></object>')
    else
      return pandoc.RawInline('html', '<object data="' .. data .. '" type="application/pdf"' .. width .. height .. class .. border .. '><a href="' .. data .. '" download>Download PDF file.</a></object>')
    end
  else
    return pandoc.Null()
  end

end

-- Add alias shortcode
function embedpdf(...)
  return pdf(...)
end
