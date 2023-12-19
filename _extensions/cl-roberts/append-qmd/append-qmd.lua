
-- Append quarto document with all .qmd files in same directory as lua filter script

function Pandoc(el)
    local current_dir = pandoc.path.directory(PANDOC_SCRIPT_FILE)
    local format = "markdown"
    for dir in io.popen("ls " .. current_dir):lines() do
        if (string.match(dir, ".qmd") and (current_dir .. "/" .. dir ~= PANDOC_SCRIPT_FILE)) then
            local filepath = current_dir .. "/" .. dir
            local content = pandoc.read(
                  io.open(filepath):read "*a", format, 
                  PANDOC_READER_OPTIONS
                ).blocks
            el.blocks:extend(content)
        end
    end
    return el
end
