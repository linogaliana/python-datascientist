import os
import glob
import shutil

os.chdir("python-datascientist/content/")

directory = "annexes"

list_nested = glob.glob(f'{directory}/**/index.qmd', recursive=True)
list_nested = [f for f in list_nested if f != f'{directory}/index.qmd']

for f in list_nested:
    shutil.move(f, f.replace("/index.qmd", ".qmd"))