import os
import glob
import re

def cleanblog():
    # LIST (R)MARKDOWN FILES ----------------
    root_dir = os.getcwd()
    os.chdir("./content")
    types = ('**/*.Rmd', '**/*.md')  # the tuple of file types
    files_grabbed = []
    for files in types:
        files_grabbed.extend(glob.glob(files, recursive=True))
    list_files = []
    for i in files_grabbed:
        if "_index.md" not in i:
            list_files = list_files + [i]
    # APPLY cleanyaml
    for i in list_files:
        cleanyaml(i, root_dir)


def cleanyaml(filename, root_dir):
    # READ MARKDOWN --------------
    with open(filename, 'r', encoding='utf-8') as f:
        text = f.readlines()
        new_text = "".join([line for line in text])
    # REMOVE HUGO SHORTCODES
    s = re.sub(r"(\{\{[^}]+}\})", "", new_text) 
    # EXTRACT AND CLEAN HEADER ----------
    yaml, text = new_text.split('---\n', 2)[1:]
    yaml_jupytext, yaml_rmd = yaml.split('title:')
    yaml_rmd_title, yaml_rmd_other = yaml_rmd.split('date:')
    new_md = "---\n" + yaml_jupytext.rstrip() + "\n---\n" + \
             "# " + yaml_rmd_title.replace('"', '').replace("'", "") + \
             "\n" + text
    # REMOVE R CHUNKS ------
    new_md = remove_between(new_md, "```{r", '```')
    # WRITE IN TEMPORARY LOCATION --------------
    write_dest = os.path.join(root_dir, "temp" + os.sep + filename)
    tempdir = write_dest.rsplit(os.sep, 1)[0]
    if not os.path.exists(tempdir):
        os.makedirs(tempdir)
    mode = 'a' if os.path.exists(write_dest) else 'w'
    with open(write_dest, mode, encoding='utf-8') as f:
        f.write(new_md)
    print("Done: " + filename)



def remove_chunk( s, first, last ):
    try:
        start = s.index( first ) + len( first )
        end = s.index( last, start )
        return s[:(start-5)] + s[(end+3):]
    except ValueError:
        return s



cleanblog()

