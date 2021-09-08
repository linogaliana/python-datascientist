import glob
import matplotlib
import matplotlib.pyplot as plt
import wordcloud
import numpy as np
import PIL
import io
import requests
import random
list_files = glob.glob("./temp/course/**/*.Rmd", recursive=True)


filename = list_files[0]

book_mask = np.array(PIL.Image.open("./build/python_black.png"))


with open(filename, encoding='utf-8') as f:
  content = f.readlines()


def grey_color_func(word, font_size, position, orientation, random_state=None,
                    **kwargs):
    return "hsl(0, 0%%, %d%%)" % random.randint(60, 100)

def make_wordcloud(corpus):
    wc = wordcloud.WordCloud(mask=book_mask, max_words=2000, margin=10, contour_width=3, contour_color='white')
    wc.generate(corpus).recolor(color_func=grey_color_func, random_state=3)
    return wc


def clean_file(text):
    text = " ".join(text).lower()
    return text


corpus = clean_file(text = content)

fig = plt.figure()

plt.imshow(make_wordcloud(corpus), interpolation='bilinear')
plt.axis("off")
#plt.show()
plt.savefig('./content/home/word.png', bbox_inches='tight')

