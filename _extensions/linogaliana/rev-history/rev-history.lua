-- run git and read its output
local function git(command)
    local p = io.popen("git " .. command)
    local output = ""
    if p ~= nil then
      output = p:read('*all')
      p:close()
    end
    return output
end

local github_repo = "https://github.com/linogaliana/python-datascientist/commit"

-- return a table containing shortcode definitions
-- defining shortcodes this way allows us to create helper 
-- functions that are not themselves considered shortcodes 
return {
    ["rev-history"] = function(args, kwargs)
        local header = "<thead><tr>" ..
            "<th>SHA</th>" ..
            "<th>Date</th>" ..
            "<th>Author</th>" .. 
            "<th>Description</th>" ..
            "</tr></thead>\n"
        local divider = "<tbody>"
        
        -- run the command
        local filename = quarto.doc.input_file
        local raw_cmd = "log --follow --pretty=format:\"<tr><td>[%h]($repo/%h)</td><td>%ad</td><td>%an</td><td>%s</td></tr>\" --date=format:'%Y-%m-%d %H:%M:%S' -- "
        local raw_cmd_sub = string.gsub(raw_cmd, "$repo", github_repo)
        local cmd = raw_cmd_sub .. filename
        local tags = git(cmd)
        
        -- return as string
        if tags ~= nil then
            return pandoc.read(
                "<table class='commit-table' border='1'>" ..
                header .. divider .. tags ..
                "</tbody></table>\n\n"
            ).blocks
        else
            return pandoc.Null()
        end
    end
}
