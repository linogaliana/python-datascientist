import glob
import matplotlib.pyplot as plt
import wordcloud

list_files = glob.glob("./temp/course/**/*.Rmd", recursive=True)


filename = list_files[0]


with open(filename, encoding='utf-8') as f:
  content = f.readlines()

def make_wordcloud(corpus):
    wc = wordcloud.WordCloud(background_color="white", max_words=2000, contour_width=3, contour_color='steelblue')
    wc.generate(corpus)
    return wc


def clean_file(text):
    text = " ".join(text).lower()
    return text


corpus = clean_file(text = content)

fig = plt.figure()


plt.imshow(make_wordcloud(corpus), interpolation='bilinear')
plt.axis("off")
#plt.show()
plt.savefig('word.png', bbox_inches='tight')
