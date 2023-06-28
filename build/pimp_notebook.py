import glob
import re

from tweak_markdown import read_file, write_file

def transform_note_reference(re_find, content_note=False):
    num_note=re.findall(r'\d+', re_find.group())[0]
    if content_note is False:
        note_html = f"<a name=\"cite_ref-{num_note}\"></a>[<sup>[{num_note}]</sup>](#cite_note-{num_note})"
    else: 
        note_html = "```{=html}\n" +  f"<a name=\"cite_note-{num_note}\"></a>{num_note}. [^](#cite_ref-{num_note})"+ "\n```\n"
    return note_html


def replace_pattern(
        string, pattern,
        rules_general,
        rules_specific,
        box_type = "warning",
        put_in_pattern = True
    ):
    rules = rules_general + [rules_specific[box_type]]
    rules_inline = " ".join(rules)
    empty=""
    if put_in_pattern is True:
        pattern_find = pattern.format(box_type, empty)
        pattern_repl = pattern.format(box_type, f' style="{rules_inline}"')
    else:
        pattern_find = pattern.format(empty)        
        pattern_repl = pattern.format(f' style="{rules_inline}"')
    return re.sub(pattern_find, pattern_repl, string)

def box_for_jupyter(tweak_md, btype):
    rules_general_box = [
            'color: rgba(0,0,0,.8);',
            'background-color: white;',
            'margin-top: 1em;',
            'margin-bottom: 1em;',
            'margin:1.5625emauto;',
            'padding:0 .6rem .8rem!important;overflow:hidden;',
            'page-break-inside:avoid;',
            'border-radius:.25rem;',
            'box-shadow:0 .2rem .5rem rgba(0,0,0,.05),0 0 .05rem rgba(0,0,0,.1);',
            'transition:color .25s,background-color .25s,border-color .25s ;',
            'border-right: 1px solid #dee2e6 ;',
            'border-top: 1px solid #dee2e6 ;',
            'border-bottom: 1px solid #dee2e6 ;'
    ]
    rules_specific_box = {
        "danger": "border-left: .2rem solid #ff0039;",
        "warning": "border-left:.2rem solid #ffc10780;",
        "info": "border-left:.2rem solid #007bff80;",
        "success": "border-left:.2rem solid #3fb618;"
    }
    rules_general_heading = [
        "margin-bottom: 15px !important;",
        "margin-top: 0rem;",
        "font-weight:600;",
        "font-size: 1.1rem;",
        "padding-top: .2em;",
        "padding-bottom: .2em;"
    ]
    rules_specific_heading = {
        "danger": "background-color: #dc3545;",
        "warning": "background-color: #fff6dd;",
        "info": "background-color: #e7f2fa;",
        "success": "background-color: #ecf8e8;"
    }

    pattern_box = r'<div class="alert alert-{}" role="alert"{}>'
    pattern_heading = '<h3 class="alert-heading"{}>'
    old_icons = {
        "warning": "fa fa-lightbulb-o",
        "success": "fa fa-pencil",
        "info": "fa fa-comment",
        "danger": "fa fa-exclamation-triangle"
        }
    new_icons = {
        "warning": "fa-solid fa-lightbulb",
        "success": "fa-solid fa-pencil",
        "info": "fa-solid fa-comment",
        "danger": "fa-solid fa-triangle-exclamation"
        }

    tweak_md2 = replace_pattern(
        tweak_md,
        pattern=pattern_box,
        rules_general=rules_general_box,
        rules_specific=rules_specific_box,
        box_type=btype)
    #tweak_md2 = replace_pattern(
    #    tweak_md2, pattern=pattern_heading,
    #    rules_general=rules_general_heading,
    #    rules_specific=rules_specific_heading,
    #    put_in_pattern=False,
    #    box_type=btype)
    tweak_md2 = re.sub(
        new_icons[btype], old_icons[btype],
        tweak_md2
        )
    return tweak_md2

def change_box_markdown(fl):
    content = read_file(fl)
    content = re.sub(r"(“|”)",'"',content)
    print(f"File: {fl}")
    # SPOILER !
    list_rows = content.split("\n")
    list_rows = [l.replace("{{< spoiler text=\"","::: {.cell .markdown}\n```{=html}\n<details>\n<summary>").replace('\" >}}',"</summary>\n```\n") if l.startswith("{{< spoiler") else l for l in list_rows]
    list_rows = [l.replace("{{< /spoiler >}}", "\n```{=html}\n</details>\n```\n:::") if l.startswith("{{< /spoiler") else l for l in list_rows]
    # BOXES
    corresp_boxes = {
        "note": "::: {.cell .markdown}\n```{=html}\n<div class=\"alert alert-info\" role=\"alert\">\n```",
        "warning": "::: {.cell .markdown}\n```{=html}\n<div class=\"alert alert-danger\" role=\"alert\">\n```",
        "danger": "::: {.cell .markdown}\n```{=html}\n<div class=\"alert alert-danger\" role=\"alert\">\n```",
        "exercise": "::: {.cell .markdown}\n```{=html}\n<div class=\"alert alert-success\" role=\"alert\">\n```",
        "hint": "::: {.cell .markdown}\n```{=html}\n<div class=\"alert alert-warning\" role=\"alert\">\n```"}
    tweak_md = [corresp_boxes[re.search('status=\"(.*?)\"',l).group(1)] if l.startswith("{{% box") else l for l in list_rows]
    tweak_md = ["```{=html}\n</div>\n```\n:::" if l.startswith("{{% /box") else l for l in tweak_md]
    tweak_md = "\n".join(tweak_md)
    # FORCE CSS INSIDE DEFINITION 
    tweak_md = box_for_jupyter(tweak_md, "warning")
    tweak_md = box_for_jupyter(tweak_md, "info")
    tweak_md = box_for_jupyter(tweak_md, "success")
    tweak_md = box_for_jupyter(tweak_md, "danger")

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
    with open('diff') as f:
        lines = f.read().splitlines() 

    list_files = [l for l in lines if l.endswith('.qmd')]

    for fl in list_files:
        if not fl.endswith("_index.md"):
            change_box_markdown(fl)
