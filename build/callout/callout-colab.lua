-- Helper function to create Python code snippets
function createPythonSnippet(div, type)
    -- Define custom content mappings for specific types
    local customContent = {
        exercise = "'''\n# Exercise: " .. pandoc.utils.stringify(div.content[1]) .. "\n\n",
        note = "'''\n# Note: " .. pandoc.utils.stringify(div.content[1]) .. "\n\n",
        tip = "'''\n# Tip: " .. pandoc.utils.stringify(div.content[1]) .. "\n\n",
        warning = "'''\n# Warning: " .. pandoc.utils.stringify(div.content[1]) .. "\n\n",
        important = "'''\n# Important: " .. pandoc.utils.stringify(div.content[1]) .. "\n\n"
    }

    -- Use the type to determine the content prefix
    local contentPrefix = customContent[type] or "'''\n# Custom Type: " .. pandoc.utils.stringify(div.content[1]) .. "\n\n"

    -- Prepare the Python snippet
    local pythonCode = contentPrefix .. pandoc.utils.stringify(pandoc.List:new(div.content):remove(1)) .. "\n'''"

    -- Wrap it as a Python cell
    local wrappedCode = "```{python}\n" .. pythonCode .. "\n```\n"

    -- Return the snippet as a raw Markdown block
    return pandoc.RawBlock("markdown", wrappedCode)
end

-- Main function to process Div elements
function Div(div)
    -- List of supported types
    local callout_types = { "note", "caution", "warning", "important", "tip", "exercise" }

    -- Check if the Div matches a supported callout type
    for _, type in ipairs(callout_types) do
        if div.classes:includes(type) then
            return createPythonSnippet(div, type)
        end
    end
end
