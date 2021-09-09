import glob
import matplotlib
import matplotlib.pyplot as plt
import wordcloud
import numpy as np
import PIL
import io
import requests
import random

import nltk
from nltk.corpus import stopwords
nltk.download('stopwords')
stop_words = set(stopwords.words('french'))

list_files = glob.glob("./temp/course/**/*.Rmd", recursive=True)


book_mask = np.array(PIL.Image.open("./build/python_black.png"))


def read_file(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        text = f.readlines()
        f.close()
    new_text = " ".join([line for line in text])
    s = new_text
    return s


list_content = [read_file(fl) for fl in list_files]


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


corpus = clean_file(text = list_content)

corpus = corpus.split(" ")
corpus = [w for w in corpus if not w in stop_words]
#corpus = [word for word in corpus if word.isalpha()]
corpus = " ".join(corpus)

fig = plt.figure()

plt.imshow(make_wordcloud(corpus), interpolation='bilinear')
plt.axis("off")
plt.tight_layout()
plt.savefig('./content/home/word.png', bbox_inches='tight',  dpi=199)

