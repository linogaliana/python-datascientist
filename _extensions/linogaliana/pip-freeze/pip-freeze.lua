-- run pip and read its output
local function pip(command)
    local p = io.popen("pip " .. command)
    local output = ""
    if p ~= nil then
      output = p:read('*a') -- Use '*a' to read the entire output
      p:close()
    end
    return output
end

return {
    ["pip-freeze"] = function(args, kwargs)
        local raw_cmd = "list"
        local piplist = pip(raw_cmd)

        -- return as string
        if piplist ~= nil and piplist ~= "" then
            return pandoc.read(
                "<div class = \"pip-freeze\">\n" ..
                piplist .. "</div>"
            ).blocks
        else
            return "nothing returned"
            --return pandoc.Null()
        end
    end
}
