import os
import glob
import re


def cleanblog():
    # LIST (R)MARKDOWN FILES ----------------
    root_dir = os.getcwd()
    os.chdir("./content")
    types = ('course/**/*.Rmd', 'course/**/*.md')  # the tuple of file types
    files_grabbed = []
    for files in types:
        files_grabbed.extend(glob.glob(files, recursive=True))
    list_files = []
    for i in files_grabbed:
        if (i.endswith(("_index.md", "_index.Rmd"))) is False :
            list_files += [i]
    # APPLY cleanyaml
    for i in list_files:
        cleanfile(i, root_dir)
    #back to initial working directory
    os.chdir(root_dir)



def cleanfile(filename, root_dir = None, show_code = False, hide_all_code = True):
    if root_dir is None:
        root_dir = os.getcwd()
    print("Processing {}".format(filename))
    # READ MARKDOWN --------------
    with open(filename, 'r', encoding='utf-8') as f:
        text = f.readlines()
        new_text = "".join([line for line in text])
    # REMOVE HUGO SHORTCODES
    # s = re.sub(r"(\{\{[^}]+}\})", "", new_text)
    s = keep_text_within_shortword(new_text)
    # REMOVE R CHUNKS ------
    s = re.sub(r'(?s)(```\{r)(.*?)(```)', "", s)
    # PRINT ALL PYTHON CODE FOR CORRECTIONS
    if show_code is True:
        s = override_echo_FALSE(s)
    if hide_all_code:
        s = re.sub(r'(?s)(```\{python)(.*?)(```)', "", s)
    # EXTRACT AND CLEAN HEADER ----------
    yaml, text = s.split('---\n', 2)[1:]
    yaml_jupytext, yaml_rmd = yaml.split('title:')
    yaml_rmd_title, yaml_rmd_other = yaml_rmd.split('date:')
    new_md = "---\n" + yaml_jupytext.rstrip() + "\n---\n" + \
             "# " + yaml_rmd_title.replace('"', '').replace("'", "") + \
             "\n" + text
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

def keep_text_within_shortword(shortcode):
    return re.sub(re.compile("(\{\{).*(\}\}\\n)|(\\n\{\{).*(\}\})"),"",shortcode)


def override_echo_FALSE(text):
    text = re.sub(r'echo = FALSE', 'echo = TRUE', text)
    text = re.sub(r'echo=FALSE', 'echo=TRUE', text)
    return text

def override_include_FALSE(text):
    text = re.sub(r'include = FALSE', 'include = TRUE', text)
    text = re.sub(r'include=FALSE', 'include=TRUE', text)
    return text

def override_eval_FALSE(text):
    text = re.sub(r'eval = FALSE', 'eval = TRUE', text)
    text = re.sub(r'eval=FALSE', 'eval=TRUE', text)
    return text

# shell
#cd "temp/course/NLP"
#jupytext --to ipynb "02_exoclean.Rmd"
#jupytext --to ipynb "02_exoclean.Rmd" --execute

# TATONNEMENT ------


#os.chdir("./temp/content")
#cleanfile('course/NLP/02_exoclean.Rmd', None, True)

cleanblog()
#shortcode = '{{% panel status="exercise" title="Exercise (pour ceux ayant envie de tester leurs connaissances en pandas)" icon="fas fa-pencil-alt" %}}{{% panel status="hint" title="Hint" icon="fa fa-lightbulb" %}}\nL\'approche *bag of words* est présentée de\nmanière plus extensive dans le [chapitre précédent](#nlp).\n\nL\'idée est d\'étudier la fréquence des mots d\'un document et la\nsurreprésentation des mots par rapport à un document de\nréférence (appelé *corpus*). Cette approche un peu simpliste mais très\nefficace : on peut calculer des scores permettant par exemple de faire\nde classification automatique de document par thème, de comparer la\nsimilarité de deux documents. Elle est souvent utilisée en première analyse,\net elle reste la référence pour l\'analyse de textes mal\nstructurés (tweets, dialogue tchat, etc.). \n\nLes analyses tf-idf (*term frequency-inverse document frequency*) ou les\nconstructions d\'indices de similarité cosine reposent sur ce type d\'approche\n{{% /panel %}}'

def inject_shortcode(status, title, icon, inner):    
    x = '<div class="panel panel-{}">'.format(status)
    x += '<div class="panel-header-{}">'.format(status)
    x += '<h3><i class="{}"></i>{}</h3>'.format(icon, title)
    x += '</div><div class="panel-body-{}">'.format(status)
    x += '<p>{}</p>'.format(inner)
    x += '</div></div>'
    return x

#def identify_replace_shortcode(shortcode):
    # groups = re.findall(r'(status=|title=|icon=)"(.+?)"', shortcode)
    # essai = inject_shortcode("exercise","Exercise (pour ceux ayant envie de tester leurs connaissances en pandas)", "fas fa-pencil-alt", "grere" )

