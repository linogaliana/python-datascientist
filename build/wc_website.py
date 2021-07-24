import glob

list_files = glob.glob("./content/course/**/*.Rmd", recursive=True)

filename = list_files[0]

with open(filename, encoding='utf-8') as f:
  content = f.readlines()


content
