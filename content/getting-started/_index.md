---
title: "Introduction"
date: 2020-07-16T13:00:00Z
draft: false
weight: 10
---

Avant de plonger dans les arcanes de la *data science*, cette partie
d'introduction propose des éléments de configuration et des
révisions pour mettre le pied à l'étrier.

En premier lieu, des notions générales sur lesquelles il ne fait pas de mal
de revenir de temps en temps:

* [Les éléments de configuration](configuration) pour avoir un environnement
propice à l'utilisation de l'écosystème python
* [Une présentation de l'écosystème de la data-science](ecosystemeDS) dont
on explorera de nombreux aspects dans ce cours
* [Les règles de bonnes pratiques](bonnespratiques) pour améliorer la qualité
d'un travail s'appuyant sur `python`

Ensuite, des rappels sur les objets structurants le langage `python`,
nécessaires pour être autonome en `python`

* [Des rappels généraux sur les objets en python](rappels2A)
* [Des rappels sur les fonctions en python](rappelsfonctions)
* [Un TD (optionnel) sur les classes en python](rappelsclasses)


Les notebooks d'exercices sont listés [ici](listetp), visualisables 
via 
<a href="https://github.com/linogaliana/python-datascientist" class="github"><i class="fab fa-github"></i></a>
ou
[![nbviewer](https://img.shields.io/badge/visualize-nbviewer-blue)](https://nbviewer.jupyter.org/github/linogaliana/python-datascientist/tree/master)
ainsi que dans les différents environnements prêts à l'emploi mis à
disposition
[![Onyxia](https://img.shields.io/badge/launch-onyxia-brightgreen)](https://spyrales.sspcloud.fr/my-lab/catalogue/inseefrlab-datascience/jupyter/deploiement)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/linogaliana/python-datascientist/master)
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](http://colab.research.google.com/github/linogaliana/python-datascientist/blob/master)


## Pourquoi faire du python pour travailler sur des données ?

[Python](https://www.python.org/), par sa grande flexibilité, est devenu un langage incontournable
dans le domaine de la *data science*.
Le succès de [scikit-learn](https://scikit-learn.org/stable/) et
de [Tensorflow](https://www.tensorflow.org/) dans la communauté
de la *Data-Science* ont beaucoup contribué à l'adoption de `Python`. Cependant,
résumer `Python` à quelques librairies serait réducteur tant il s'agit 
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

