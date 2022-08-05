import yaml
import os
import shutil
import glob
import imageio.v2 as imageio


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
    

list_images = glob.glob("./content/course/**/**/featured.png")
list_images = ["./content/home/word.png"] + list_images
with imageio.get_writer('animation.gif', mode='I', fps = 1) as writer:
    for filename in list_images:
        image = imageio.imread(filename)
        writer.append_data(image)


#img = Image.open(loc)
#img = img.resize((req_width,req_height), Image.ANTIALIAS)
#img.save(os.path.dirname(loc) + "/featured.png")