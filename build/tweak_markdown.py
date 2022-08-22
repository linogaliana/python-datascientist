import glob
import re

def read_file(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        text = f.readlines()
        f.close()
    new_text = "".join([line for line in text])
    s = new_text
    return s

def replace_shortcode_tabs(content):
    content = content.replace("\<", "<")
    content = content.replace("\>", ">")
    return content

def tweak_js_plotly(content):
    content2 = re.sub(
        r'<script type="text/javascript">\n\s*window([\S\s]*)</script>\n',
        '',
        content)
    return content2


def write_file(filename, content):
    with open(filename, 'w', encoding="utf-8") as f:
        f.write(content)

def clean_write_file(fl):
    content = read_file(fl)
    content = re.sub(r"(“|”)",'"',content)
    print(f"File: {fl}")
    add_text = '\n\n<script src="https://d3js.org/d3.v7.min.js"></script>\n<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>'
    yaml, text = content.split('---\n', 2)[1:]
    if re.search("plotly: true", yaml) is not None:
        print(f"Tweaking {fl} using YAML header")
        content = "---\n"+ yaml + "---\n" \
            + add_text+"\n"+text
    else:
        print(f"File {fl}: nothing to do")
    if re.search(
        r'<script type="text/javascript">\n\s*window.P([\S\s]*)</script>\n',
        content) is not None:
        print("quarto added plotly detected: removed")
        content = tweak_js_plotly(content)
    write_file(fl, content)


def change_box_markdown(fl):
    content = read_file(fl)
    content = re.sub(r"(“|”)",'"',content)
    print(f"File: {fl}")
    list_rows = content.split("\n")
    corresp_boxes = {
        "note": "<div class=\"alert alert-info\" role=\"alert\">\n",
        "danger": "<div class=\"alert alert-danger\" role=\"alert\">\n",
        "exercise": "<div class=\"alert alert-success\" role=\"alert\">\n",
        "hint": "<div class=\"alert alert-warning\" role=\"alert\">\n"}

    tweak_md = [corresp_boxes[re.search('status=\"(.*?)\"',l).group(1)] if l.startswith("{{% box") else l for l in list_rows]
    tweak_md = ["</div>" if l.startswith("{{% /box") else l for l in tweak_md]
    tweak_md = "\n".join(tweak_md)
    write_file("test.qmd", tweak_md)


list_files = glob.glob("./content/course/**/index.md", recursive=True)
print(list_files)
[clean_write_file(fl) for fl in list_files if not fl.endswith("_index.md")]



