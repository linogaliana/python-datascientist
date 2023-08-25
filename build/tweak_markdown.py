import glob
import re

def read_file(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        text = f.readlines()
        f.close()
    new_text = "".join([line for line in text])
    s = new_text
    return s

def write_file(filename, content):
    with open(filename, 'w', encoding="utf-8") as f:
        f.write(content)

