import glob
import re


with open('diff') as f:
    lines = f.read().splitlines() 

list_files = [l for l in lines if l.endswith('.qmd')]

def clean_overwrite_file(fl):
    with open(fl, 'r') as file_in:
        text_in = file_in.readlines()

    text_out = []
    c = 0
    for line in text_in:
        # Delimit header
        if "---" in line:
            c += 1
        if c < 2:
            line = re.sub("echo:\s?false", "echo: true", line)
        text_out.append(line)
        
    with open(fl, 'w') as file_out:
        file_out.writelines(text_out)


if __name__ == '__main__':
    for fl in list_files:
        clean_overwrite_file(fl)
