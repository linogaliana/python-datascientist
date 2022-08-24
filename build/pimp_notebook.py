import glob
import re

from tweak_markdown import read_file, write_file

def transform_note_reference(re_find, content_note=False):
    num_note=re.findall(r'\d+', re_find.group())[0]
    if content_note is False:
        note_html = f"<a name=\"cite_ref-{num_note}\"></a>[<sup>[{num_note}]</sup>](#cite_note-{num_note})" + "```"
    else: 
        note_html = "```{=html}" +  f"<a name=\"cite_note-{num_note}\"></a>{num_note}. [^](#cite_ref-{num_note})"+ "```"
    return note_html


def change_box_markdown(fl):
    content = read_file(fl)
    content = re.sub(r"(“|”)",'"',content)
    print(f"File: {fl}")
    # BOXES
    list_rows = content.split("\n")
    corresp_boxes = {
        "note": "::: {.cell .markdown}\n```{=html}\n<div class=\"alert alert-info\" role=\"alert\">\n```",
        "warning": "::: {.cell .markdown}\n```{=html}\n<div class=\"alert alert-danger\" role=\"alert\">\n```",
        "danger": "::: {.cell .markdown}\n```{=html}\n<div class=\"alert alert-danger\" role=\"alert\">\n```",
        "exercise": "::: {.cell .markdown}\n```{=html}\n<div class=\"alert alert-success\" role=\"alert\">\n```",
        "hint": "::: {.cell .markdown}\n```{=html}\n<div class=\"alert alert-warning\" role=\"alert\">\n```"}
    tweak_md = [corresp_boxes[re.search('status=\"(.*?)\"',l).group(1)] if l.startswith("{{% box") else l for l in list_rows]
    tweak_md = ["```{=html}\n</div>\n```\n:::" if l.startswith("{{% /box") else l for l in tweak_md]
    tweak_md = "\n".join(tweak_md)
    # FOOTNOTES
    p = re.compile("\[\^[0-9]+\]:")
    list_match = list(p.finditer(tweak_md))
    for i in range(0, len(list_match)):
        m = list_match[i]
        tweak_md = tweak_md.replace(m.group(0), transform_note_reference(m, content_note=True))
    # 2. REFERENCE TO THE FOOTNOTE
    p = re.compile("\[\^[0-9]+\]")
    list_match = list(p.finditer(tweak_md))
    for i in range(0, len(list_match)):
        m = list_match[i]
        tweak_md = tweak_md.replace(m.group(0), transform_note_reference(m, content_note=False))

    write_file(fl, tweak_md)

if __name__ == '__main__':
    list_files = glob.glob("./content/course/**/index.qmd", recursive=True)
    print(list_files)
    [change_box_markdown(fl) for fl in list_files if not fl.endswith("_index.md")]
