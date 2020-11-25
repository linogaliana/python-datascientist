---
jupyter:
  jupytext:
    text_representation:
      extension: .Rmd
      format_name: rmarkdown
      format_version: '1.2'
      jupytext_version: 1.6.0
  kernelspec:
    display_name: Python 3
    language: python
    name: python3
title: "Natural Language Processing (NLP): quelques éléments"
date: 2020-10-15T13:00:00Z
draft: false
weight: 70
output: 
  html_document:
    keep_md: true
    self_contained: true
slug: nlp
---


{{% panel status="warning" title="Warning" icon="fa fa-exclamation-triangle" %}}
Le NLP est un domaine immense de recherche. Cette page est une introduction
fort incomplète à la question. Il s'agit de montrer la logique, quelques exemples
avec `Python` <i class="fab fa-python"></i>
et s'amuser avec comme base d'exemple un livre formidable :books: :
*Le Comte de Monte Cristo*
{{% /panel %}}

La base d'exemple est le *Comte de Monte Cristo* d'Alexandre Dumas.
Il est disponible
gratuitement sur le site
[Project Gutemberg](http://www.gutenberg.org/ebooks/author/492) comme des milliers
d'autres livres dans le domaine public. La manière la plus simple de le récupérer
est de télécharger avec le module `urllib` le fichier texte et le retravailler
légèrement pour ne conserver que le corpus du livre. 


```python
from urllib import request

url = "https://www.gutenberg.org/ebooks/17989.txt.utf-8"
response = request.urlopen(url)
raw = response.read().decode('utf8')
dumas = raw.split("Produced by Chuck Greif and www.ebooksgratuits.com")[1].split("End of the Project Gutenberg EBook")[0]
raw[10000:10500]
```

```
## " croit déjà capitaine, sur ma parole.\r\n\r\n--Et il l'est de fait, dit l'armateur.\r\n\r\n--Oui, sauf votre signature et celle de votre associé, monsieur Morrel.\r\n\r\n--Dame! pourquoi ne le laisserions-nous pas à ce poste? dit l'armateur.\r\nIl est jeune, je le sais bien, mais il me paraît tout à la chose, et\r\nfort expérimenté dans son état.»\r\n\r\nUn nuage passa sur le front de Danglars.\r\n\r\n«Pardon, monsieur Morrel, dit Dantès en s'approchant; maintenant que le\r\nnavire est mouillé, me voilà tout à vous: vous"
```



