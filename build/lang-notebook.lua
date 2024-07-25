local filename = quarto.doc.input_file

-- Function to check if string ends with a specific suffix
local function ends_with(str, suffix)
    return str:sub(-#suffix) == suffix
end

-- Determine the language based on the filename suffix
local function get_text_language(filename)
    quarto.log.output("Checking filename: " .. filename)  -- Debug print
    local text

    if ends_with(filename, "_en.qmd") then
        text = "This is the English version of that chapter, to see French version go [there](" .. filename .. ")"
        quarto.log.output("Language detected: english")  -- Debug print
        return text
    else
        text = "This is the English version of that chapter, to see French version go [there](" .. filename .. ")"
        quarto.log.output("Language detected: french")  -- Debug print
        return text
    end
end

if quarto.doc.is_format("ipynb") then
    return {
        ["print-warning-language"] = function(args, kwargs)
            local text = get_text_language(filename)
            quarto.log.output("Final output: " .. text)  -- Debug print
            return text
        end
    }
end