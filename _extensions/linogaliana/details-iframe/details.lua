return {
  ["details-iframe"] = function(args, kwargs, meta)
    local summary_md = kwargs["summary"] or ""
    local src = pandoc.utils.stringify(kwargs["src"] or "")
    local is_open = pandoc.utils.stringify(kwargs["open"] or "")
    local extra_md = kwargs["text"] or nil

    local open_attr = ""
    if is_open == "true" then
      open_attr = " open"
    end

    -- Render summary Markdown to HTML
    local summary_blocks = pandoc.read(summary_md, "markdown").blocks
    local summary_html = pandoc.write(pandoc.Pandoc(summary_blocks), "html"):gsub("\n$", "")

    -- Optional extra Markdown content after the iframe
    local extra_html = ""
    if extra_md then
      local extra_blocks = pandoc.read(extra_md, "markdown").blocks
      extra_html = pandoc.write(pandoc.Pandoc(extra_blocks), "html")
    end

    local html = string.format([[
<details%s>
<summary>%s</summary>
<div class="sourceCode">
<iframe class="sourceCode" src="%s"></iframe>
%s
</div>
</details>
]], open_attr, summary_html, src, extra_html)

    return pandoc.RawBlock("html", html)
  end
}
