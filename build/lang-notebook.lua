local filename = quarto.doc.input_file
local dirname = quarto.project.directory

-- Escape special characters in dirname
local function escape_pattern(str)
    return str:gsub("([^%w])", "%%%1")
end

dirname = escape_pattern(dirname)

local filename_relative = filename:gsub("^" .. dirname, "")
filename_relative = "https://pythonds.linogaliana.fr" .. filename_relative
filename_relative = filename_relative:gsub(".qmd", ".html")

quarto.log.output("Directory name: " .. dirname)
quarto.log.output("Filename: " .. filename)
quarto.log.output("Relative filename: " .. filename_relative)

-- Function to check if string ends with a specific suffix
local function ends_with(str, suffix)
    return str:sub(-#suffix) == suffix
end

-- Determine the language based on the filename suffix
local function get_text_language(filename_relative)
    local text
    -- Add html formatting around
    local headBox = "<div class=\"alert alert-info\" role=\"alert\">\n" ..
        "<h3 class=\"alert-heading\">Version</h3>\n"

    if ends_with(filename_relative, "_en.html") then
        text = "This is the English 🇬🇧 🇺🇸 version of that chapter," ..
            "to see the French version go " ..
            "<a href=\"" .. filename_relative:gsub("_en.html", ".html") ..
            "\">there</a>"
        quarto.log.output("Language detected: english")  -- Debug print
    else
        text = "This is the French version 🇫🇷 of that chapter," ..
            "to see the English version go " ..
            "<a href=\"" .. filename_relative:gsub("_fr.html", "_en.html") ..
            "\">there</a>"
        quarto.log.output("Language detected: french")  -- Debug print
    end

    text = headBox .. text .. "\n</div>"

    return text
end

-- Get the language-specific text
local text_language = get_text_language(filename_relative)

if quarto.doc.is_format("ipynb") then
    return {
        {
          Para = function (elem)
            for i, v in ipairs(elem.content) do
                if v.text == "{{warninglang}}" then
                    return pandoc.Div(
                        pandoc.RawBlock("html", text_language),
                        {class = "markdown"}
                    )
                end
            end
            return elem
          end,
        }
      }    
end
