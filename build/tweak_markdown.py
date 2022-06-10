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
        r'<script type="text/javascript">\n([\S\s]*)</script>\n',
        '',
        content)
    return content2


def write_file(filename, content):
    with open(filename, 'w', encoding="utf-8") as f:
        f.write(content)

def clean_write_file(fl):
    content = read_file(fl)
    print(f"File: {fl}")
    add_text = '\n\n<script src="https://d3js.org/d3.v7.min.js"></script>\n<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>'
    yaml, text = content.split('---\n', 2)[1:]
    if re.search("plotly: true", yaml) is not None:
        print(f"Tweaking {fl}")
        content = "---\n"+ yaml + "---\n" \
            + add_text+"\n"+text
    else:
        print(f"File {fl}: nothing to do")
#    if re.search(
#        r'<script type="text/javascript">\n([\S\s]*)</script>\n',
#        content) is not None:
#        print("plotly detected")
#        content = tweak_js_plotly(content)
    write_file(fl, content)

list_files = glob.glob("./content/course/**/index.md", recursive=True)
print(list_files)
[clean_write_file(fl) for fl in list_files if not fl.endswith("_index.md")]
