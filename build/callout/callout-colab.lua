-- Helper function to create Python code snippets
function createPythonSnippet(div, type)


    local content = div.content
    if div.content[1] ~= nil and div.content[1].t == "Header" then
        title = pandoc.utils.stringify(div.content[1])
        div.content:remove(1)
    end

    -- Define the Python code for the cell
    local pythonCode = [[
#@title ]] .. title .. [[

style = """
    <style>
    body {
        font-family: Arial, sans-serif;
        margin: 20px;
        line-height: 1.6;
        background-color: #f8f9fa;
    }
    /* Callout box styles */
    .callout {
        border: 2px solid #d1d5db;
        border-radius: 8px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        margin-bottom: 20px;
        background-color: #ffffff;
        padding: 15px;
    }
    .callout-header {
        font-weight: bold;
        margin-bottom: 10px;
        color: #ffffff;
        background-color: #1d4ed8;
        padding: 10px;
        border-radius: 6px 6px 0 0;
    }
    .blockquote {
        margin: 10px 0;
        padding: 10px;
        background-color: #f1f5f9;
        border-left: 4px solid #93c5fd;
        font-style: italic;
    }
    code {
        background-color: #f3f4f6;
        padding: 2px 4px;
        border-radius: 4px;
        font-family: Consolas, Monaco, "Courier New", monospace;
        color: #1d4ed8;
    }
    ol {
        padding-left: 20px;
    }
    ol li {
        margin-bottom: 10px;
    }
"""

content = """
    <div class="callout callout-style-default callout-]] .. type .. [[ callout-titled">
        <div class="callout-header">
            ]] .. title .. [[
        </div>
        <div class="callout-body">
            ]] .. pandoc.utils.stringify(content) .. [[
        </div>
    </div>
"""
box = f'{content}{style}'

from IPython.core.display import HTML
HTML(box)
]]

    -- Return as a Python code block
    return pandoc.RawBlock("Python", pythonCode)
end

-- Main function to process Div elements
function Div(div)
    -- List of supported callout types
    local callout_types = { "note", "caution", "warning", "important", "tip", "exercise" }

    -- Check if the Div matches a supported callout type
    for _, type in ipairs(callout_types) do
        if div.classes:includes(type) then
            return createPythonSnippet(div, type)
        end
    end
end
