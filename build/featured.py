import yaml
import os
import shutil
from PIL import Image

#os.chdir("python-datascientist/")

with open(r'featured.yaml') as file:
    dict_featured = yaml.full_load(file)

req_width = 918
req_height = 517

locations = list(dict_featured.keys())
location=locations[0]

def resize_write_image(dict_featured, location):
    loc = dict_featured[location]
    loc = f"./content/course/{location}/{loc}"
    shutil.copy2(loc, os.path.dirname(loc) + "/featured.png")
    

#img = Image.open(loc)
#img = img.resize((req_width,req_height), Image.ANTIALIAS)
#img.save(os.path.dirname(loc) + "/featured.png")