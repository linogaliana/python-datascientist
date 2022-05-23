import shutil
import glob
import sys

direction = sys.argv[1]
print(direction)

list_files = glob.glob(f"./content/**/*.ipynb", recursive=True)
list_files = [fl for fl in list_files if not fl.endswith("_index.ipynb")]
list_files = [fl for fl in list_files if fl.endswith("index.ipynb")]

print(list_files)

def hack_name(fl, direction):
    basename = fl.rsplit("/", maxsplit=1)[0]
    newname = f"{basename}.ipynb"
    newname = newname.replace("content", direction)
    return newname

corresp = {f: hack_name(f, direction) for f in list_files}
print(corresp)



[shutil.copy2(key, value) for key, value in corresp.items()]