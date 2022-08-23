import glob
import re

from tweak_markdown import read_file, write_file

def change_box_markdown(fl):
    content = read_file(fl)
    content = re.sub(r"(“|”)",'"',content)
    print(f"File: {fl}")
    list_rows = content.split("\n")
#    corresp_boxes = {
#        "note": "::: {.alert .alert-info}\n",
#        "warning": "::: {.alert .alert-danger}\n",
#        "danger": "::: {.alert .alert-danger}\n",
#        "exercise": "::: {.alert .alert-success}\n",
#        "hint": "::: {.alert .alert-warning}\n"}
    corresp_boxes = {
        "note": "<div class=\"alert alert-info\" role=\"alert\">\n",
        "warning": "<div class=\"alert alert-danger\" role=\"alert\">\n",
        "danger": "<div class=\"alert alert-danger\" role=\"alert\">\n",
        "exercise": "<div class=\"alert alert-success\" role=\"alert\">\n",
        "hint": "<div class=\"alert alert-warning\" role=\"alert\">\n"}
    tweak_md = [corresp_boxes[re.search('status=\"(.*?)\"',l).group(1)] if l.startswith("{{% box") else l for l in list_rows]
    #tweak_md = [":::" if l.startswith("{{% /box") else l for l in tweak_md]
    tweak_md = ["</div>" if l.startswith("{{% /box") else l for l in tweak_md]
    tweak_md = "\n".join(tweak_md)
    write_file(fl, tweak_md)

list_files = glob.glob("./content/course/**/index.qmd", recursive=True)
print(list_files)
[change_box_markdown(fl) for fl in list_files if not fl.endswith("_index.md")]
