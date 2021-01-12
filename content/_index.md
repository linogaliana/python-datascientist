---
title: "Homepage"
date: 2020-07-16T12:00:00Z
draft: false
weight: 10
---

:warning: :construction: **Ce site est en construction** :construction:

Ce site web rend public le contenu du cours de 
deuxième année (Master 1) de l'ENSAE:
*Python pour les data-scientists et économistes* :snake:. 

Le cours est structuré sous la forme du présent site web et de notebooks
jupyter proposant des exercices plus approfondis. L'ensemble
des codes sources est stocké sous
[github à cette adresse](https://github.com/linogaliana/python-datascientist).

Sur l'ensemble du site web,
il est possible de cliquer sur la petite icone
<a href="https://github.com/linogaliana/python-datascientist" class="github"><i class="fab fa-github"></i></a>
pour être redirigé vers le dépôt. Pour visualiser sous une forme plus
ergonomique les notebooks (fichiers `.ipynb`)
que ne le permet ce site *web*, vous trouverez
parfois des liens
[![nbviewer](https://img.shields.io/badge/visualize-nbviewer-blue)](https://nbviewer.jupyter.org/github/linogaliana/python-datascientist/tree/master)
qui utilisent
[nbviewer](https://github.com/jupyter/nbviewer) une application de visualisation
dédiée aux jupyter notebooks.

Des environnements temporaires d'exécution des notebooks sont proposés
avec les icones suivantes 
[![Onyxia](https://img.shields.io/badge/launch-onyxia-brightgreen)](https://spyrales.sspcloud.fr/my-lab/catalogue/inseefrlab-datascience/jupyter/deploiement)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/linogaliana/python-datascientist/master)
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](http://colab.research.google.com/github/linogaliana/python-datascientist/blob/master)


Vous pouvez naviguer dans l'architecture du site via la table des matières
ou par les liens vers le contenu antérieur ou postérieur à la fin de chaque
page. 


# Introduction: pourquoi faire du python pour travailler sur des données ?

[Python](https://www.python.org/), par sa grande flexibilité, est devenu un langage incontournable
dans le domaine de la *data science*.
Le succès de [Tensorflow](https://www.tensorflow.org/) dans la communauté
de la *Data-Science* a beaucoup contribué à l'adoption de `python`. Cependant,
réduire `python` à quelques librairies serait réducteur tant il s'agit 
d'un véritable couteau-suisse pour le *data-scientist*, *social scientist*
ou économiste. 
Comme pour `R`, l'intérêt de Python est son rôle central dans un
écosystème plus large autour d'outils puissants, flexibles et *open-source*. 
 
L'intérêt de Python pour un *data scientist* ou *data economist* va au-delà du champ du *Machine Learning*. 
Python concurrence très bien `R` dans son domaine de prédilection, à
savoir l'analyse statistique sur des
objets type *dataframes*. `python` est bien plus complet dans certains domaines
car, outre le *Machine Learning*, `Python` est mieux adapté aux données volumineuses que `R`. `Python` est également meilleur que `R` pour faire
du *webscraping*. Dans le domaine de l'économétrie, `python` offre
l'avantage de la simplicité avec un nombre restreint de packages (`scikit` et
`statsmodels`) permettant d'avoir des modèles très généraux
(les [generalized estimating equations](https://www.statsmodels.org/stable/gee.html)) alors qu'il faut
choisir parmi une grande variété de packages en `R` pour obtenir les
modèles équivalents. 
Au contraire, dans certains domaines, `R` reste meilleur. Par exemple,
`R` est très bien intégré au langage de publication `Markdown` ce qui,
dans certains cas, comme la construction de ce site *web* basée sur 
`R Markdown`, est fort appréciable. 
Un des avantages comparatifs de `Python` par rapport à d'autres langages (notamment `R` et `Julia`) est sa dynamique,
ce que montre [l'explosion du nombre de questions
sur `Stack Overflow`](https://towardsdatascience.com/python-vs-r-for-data-science-6a83e4541000).

Cependant, il ne s'agit pas bêtement d'enterrer `R` ; au contraire, outre leur logique très proche,
les deux langages sont dans une phase de convergence avec des initiatives comme
[`reticulate`](https://rstudio.github.io/reticulate/). Ce dernier package
permet d'exécuter des commandes python dans un document `R Markdown` mais
crée également une correspondance entre les objets `python` et `R`. Les bonnes
pratiques peuvent être transposées de manière presque transparente d'un
langage à l'autre. A terme, les data-scientists et économistes utiliseront
de manière presque indifférente, et en alternance, `python` et `R`. Ce cours
présentera ainsi régulièrement des analogies avec `R`.





# Principes du cours

Le but de ce cours est de rendre autonome sur l'utilisation de Python
dans un contexte de travail d'un ENSAE, c'est-à-dire une utilisation intensive
des données dans un cadre statistique rigoureux.
Nous partirons de l'hypothèse que les notions de statistiques et d'économétrie pour lesquels nous verrons des applications informatiques, vous sont connues. 

Les éléments relatifs à l'évaluation du cours sont disponibles dans la
Section [Evaluation](evaluation)




