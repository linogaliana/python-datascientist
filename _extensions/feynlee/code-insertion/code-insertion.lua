local function readFile(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end


local function getBlocks(file)
    local text = readFile(file)
    local doc = pandoc.read(text)
    quarto.log.debug(doc)
    return doc.blocks
end


function Pandoc(doc)
    local ins_before = doc.meta['insert-before-post']
    local ins_after = doc.meta['insert-after-post']
    quarto.log.debug(ins_before)
    quarto.log.debug(ins_after)
    local blocks = doc.blocks
    quarto.log.debug(blocks)
    if ins_before then
        before_blocks = getBlocks(pandoc.utils.stringify(ins_before))
        before_blocks:extend(blocks)
        blocks = before_blocks
    end

    if ins_after then
        after_blocks = getBlocks(pandoc.utils.stringify(ins_after))
        blocks:extend(after_blocks)
    end

    quarto.log.debug(blocks)
    local new_doc = pandoc.Pandoc(blocks, doc.meta)
    -- quarto.log.debug(new_doc)
    return new_doc
end
