function Meta(meta)
    -- Helper function to print metadata table
    local function print_meta_table(meta_table)
        for key, value in pairs(meta_table) do
            print(key, pandoc.utils.stringify(value))
        end
    end

    -- Print entire metadata table
    -- print_meta_table(meta)

    -- Convert lang to string if it exists
    local toto = pandoc.utils.stringify(meta.lang or "")

    -- Check if lang contains "en"
    if toto and string.find(toto, "en") then
        -- Override title with title-en if it exists
        if meta['title-en'] then
            meta.title = meta['title-en']
            quarto.log.output("Title overridden with title-en")
        end
        if meta['description-en'] then
            meta.description = meta['description-en']
            quarto.log.output("Description overridden with description-en")
        end

    end

    return meta
end
