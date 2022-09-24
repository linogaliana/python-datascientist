import glob
import re

from tweak_markdown import read_file, write_file

with open('diff') as f:
    lines = f.read().splitlines() 

list_files = [l for l in lines if l.endswith('.qmd')]

def clean_overwrite_file(fl):
    content = read_file(fl)
    content = re.sub("#\|echo: false", "", content)
    content = re.sub("#\| echo: false", "", content)
    write_file(fl, content)

if __name__ == '__main__':
    [clean_overwrite_file(fl) for fl in list_files]