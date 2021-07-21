---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.2'
      jupytext_version: 1.6.0
  kernelspec:
    display_name: Python 3
    language: python
    name: python3
title: "L'environnement du data-scientist en python"
date: 2020-07-22T12:00:00Z
draft: false
weight: 30
slug: "ecosystemeDS"
type: book
summary: |
  Tour d'horizon de l'éco-système python de la *data science*
---

## Les packages python essentiels pour le cours et la vie d'un ENSAE

![](https://pydsc.files.wordpress.com/2017/11/pythonenvironment.png?w=663)

Ce
[post](https://medium.com/data-science-library/ultimate-python-library-guide-for-data-science-2562148158bf),
dont l'image ci-dessus est tirée, résume la plupart des packages utiles
pour un data-scientist ou un économiste/sociologue. Nous nous bornerons
ici à évoquer ceux utilisés quotidiennement.

### `numpy`

`numpy` gère tout ce qui est calcul matriciel. Le langage Python est un des langages les plus lents qui soient[^1]. Tous les calculs rapides ne sont pas écrits en Python mais en C++, voire fortran. C’est le cas du module `numpy`, il est incontournable dès qu’on veut être rapide. Le module `scipy` est une extension où l’on peut trouver des fonctions statistiques, d’optimisation.

[^1]: `python` est un langage interprété, comme `R`. Cela le rend très
intelligible, y compris par un non-expert. C'est une des raisons de son
succès. La contrepartie est qu'il s'agit d'une superstructure à des langages
plus bas-niveau, notamment `C`. Ces derniers proposent beaucoup moins de
surcouches. En réalité, les fonctions python font appel, plus ou moins
directement, à du `C`. Une manière d'optimiser le code est ainsi d'arriver,
avec le moins de surcouche possible, à la fonction `C` sous-jacente,
beaucoup plus rapide.

La Cheat Sheet de `numpy` :
<https://s3.amazonaws.com/assets.datacamp.com/blog_assets/Numpy_Python_Cheat_Sheet.pdf>

### `pandas`

Avant tout, un bon data-scientist doit être capable de
s'approprier et manipuler des données rapidement. Dans ces domaines,
`pandas` est incontournable.
Il gère la plupart des formats de données. Il est lui aussi implémenté en C++.
Le package est rapide si on utilise les méthodes pré-implémentées sur
des données d'une taille raisonnable (par rapport à la RAM disponible). Il faut
néanmoins s'en méfier avec des données volumineuses.
En règle générale, un jeu de données nécessite
trois fois plus d’espace en mémoire que les
données n’en prennent sur le disque.

La Cheat Sheet de pandas :
<https://s3.amazonaws.com/assets.datacamp.com/blog_assets/Python_Pandas_Cheat_Sheet_2.pdf>


### `matplotlib` et `seaborn`

`matplotlib` s’occupe de tout ce qui est graphique.
Il faut également connaître `seaborn`
qui propose des graphiques étudiés pour un usage statistique.

### `scikit-learn`

`scikit-learn` est le module de *machine learning* le plus populaire pour deux raisons:

* il s'appuie sur une API extrêmement consistante (méthodes *fit*, *transform*
  et *predict*, respectivement pour apprendre des données, appliquer des transformations et prédire sur de nouvelles données) et permet de construire
  des analyses reproductibles en construisant des *pipelines* de données
* Sa documentation est un modèle à suivre.

### `TensorFlow`, `PyTorch` et `Keras`

Les librairies essentielles pour implémenter et utiliser des modèles de *deep learning* en Python. `TensorFlow` est la librairie la plus mature, mais pas nécessairement la plus facile à prendre en main. `Keras` propose une interface *high-level*, donc facile d'utilisation, mais qui n'en reste pas moins suffisante pour une grande variété d'usages. `PyTorch` est un framework plus récent mais très complet, dont la syntaxe plaira aux amateurs de programmation orienté-objet. Il est très utilisé dans certains domaines de recherche, comme le NLP.


### `statsmodels`

`statsmodels` plaira plus aux statisticiens, il implémente des modèles
similaires à scikit-learn,
il est meilleur pour tout ce qui est linéaire avec une présentation des
résultats très proche de ce qu’on trouve en `R`.

<!---
(source http://www.xavierdupre.fr/app/papierstat/helpsphinx/rappel.html)
----->

## Environnement autour de Python

Python est un langage très riche, grâce à sa logique open-source. Mais l'un
des principaux intérêts réside dans le riche écosystème avec lequel Python
s'intègre. On peut donner quelques éléments, dans un inventaire à la Prévert non exaustif.

En premier lieu, des éléments reliés au traitement des données:

* [`Spark`](https://fr.wikipedia.org/wiki/Apache_Spark),
le *framework* dominant dans le domaine du traitement des *big-data*, très bien
interfacé avec `Python` (grâce à l'API `pyspark`), qui facilite le traitement des données volumineuses. Son utilisation nécessite cependant d'avoir accès à une
infrastructure de calculs distribuée.
* [`Cython`](https://cython.org/) permet d'intégrer facilement du code `C`, très
efficace avec `Python` (équivalent de `Rcpp` pour `R`).
* [`Julia`](https://julialang.org/) est un langage récent, qui propose une syntaxe familière aux utilisateurs de languages scientifiques (Python, R, MATLAB), tout en permettant des performances proches du `C` grâce à une compilation à la volée.


Mais `Python` est également un outil privilégié pour communiquer:

* Une bonne intégration de python à `Markdown` (grâce notamment à ... `R Markdown`) qui facilite la construction de documents HTML ou PDF (via `Latex`)
* [Sphynx](https://www.sphinx-doc.org/en/master/) et [JupyterBook](https://jupyterbook.org/intro.html) proposent des modèles de documentation
très complets
* [`bokeh`](https://bokeh.org/) ou [`streamlit`](https://www.streamlit.io/) comme alternative à [shiny (R)](https://shiny.rstudio.com/)

Enfin, des éléments permettant un déploiement de résultats ou d'applications
en continu :
* Les images `Docker` de `Jupyterhub` facilitent l'usage de l'intégration continue
pour construire des modules, les tester et déployer des site web.
* Les services type `Binder`, `Google Colab` et `Kaggle` proposent des kernels
`Python`
* [`Django`](https://www.djangoproject.com/) et [`Flask`](https://flask.palletsprojects.com/en/2.0.x/) permettent de construire des applications web en `Python`

Ce n'est qu'une petite partie de l'écosystème `Python`, d'une richesse rare.
