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
        -- An example for future use (taken from quarto docs)...
        -- local cmdArgs = ""
        -- local short = pandoc.utils.stringify(kwargs["short"])
        -- if short == "true" then cmdArgs = cmdArgs .. "--short " end


        local header =  "| tag | date | author | description |\n"
        local divider = "|:----|:-----|:-------|:------------|\n"

        -- run the command
        local filename = quarto.doc.input_file
        --local formatting = "[%h]($repo/%h)
        local raw_cmd = "log --follow --pretty=format:\"| [%h]($repo/%h) | %ar | %an | %s | \" -- "
        local raw_cmd_sub = string.gsub(raw_cmd, "$repo", github_repo)
        local cmd = raw_cmd_sub .. filename
        --local cmd = "for-each-ref --format='| %(refname:short) | %(authordate:short) | %(authorname) | %(subject) |' refs/heads/master"
        local tags = git(cmd)

        -- return as string
        if tags ~= nil then
            return pandoc.read(
                "<details> \n <summary>View commit history for this file</summary> \n" ..
                header .. divider .. tags .. "\n\n" .. "</details>"
            ).blocks
        else
            return pandoc.Null()
        end
    end
}
