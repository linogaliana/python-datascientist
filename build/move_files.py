import shutil
import glob
import os
import argparse

# Set up argument parsing
parser = argparse.ArgumentParser(
    description="Copy .ipynb files from source to target directory"
)
parser.add_argument(
    "--direction",
    help="The target direction to copy files to",
    default="temp_notebooks/corrections",
)
args = parser.parse_args()

direction = args.direction
print(direction)

# Find all .ipynb files in the specified directories
list_files = glob.glob(f"_site/content/**/*.ipynb", recursive=True) + glob.glob(
    f"_site/en/content/**/*.ipynb", recursive=True
)
list_files = [fl for fl in list_files if not fl.endswith("_index.ipynb")]

print(list_files)


def hack_name(fl, direction):
    if "en/content" in fl:
        newname = fl.replace("en/content", f"{direction}/en")
    else:
        newname = fl.replace("content", direction)
    newname = newname.replace("_site", ".")
    return newname


corresp = {f: hack_name(f, direction) for f in list_files}
print(corresp)

internal_dirs = [os.path.dirname(value) for value in corresp.values()]
internal_dirs = list(set(internal_dirs))
[os.makedirs(path, exist_ok=True) for path in internal_dirs]

[shutil.copy2(key, value) for key, value in corresp.items()]

print("Done!")
