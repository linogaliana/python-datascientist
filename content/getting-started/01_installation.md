---
title: "Configuration de Python"
date: 2020-07-16T13:00:00Z
draft: false
weight: 20
---

Les exercices sont présentés sous la
forme de [notebook jupyter](https://jupyter-notebook.readthedocs.io/en/stable/). Ils peuvent être exécutés
dans plusieurs environnement, au gré des préférences:

* Sur une installation personnelle ([voir ici](#local))
* Sur un environnement temporaire
* Dans un containeur docker

Quelque soit l'environnement d'exécution des scripts, l'un des objectifs
de ce cours est d'adopter un environnement favorable à la reproductibilité 
des traitements.

Pour cette raison, en supplément des notions relatives 
à `Python`, ce cours montrera comment utiliser `git` avec `python` et 
évoquera un
certain nombre de critères de qualité du code qui sont devenus
des standards dans la communauté *open-source*, dans l'industrie et dans
l'administration. Ces compétences ne sont pas adhérentes à Python et seront
utiles pour tout projet ultérieur.
 
Le projet final devra impérativement
être associé à un dépôt `git` (nous reviendrons dessus) et répondre à 
ces critères de qualité, qui serviront toute la vie.

# Installer Python

## Installation en local {#local}

Pour pouvoir travailler en local avec `Python`, la manière la plus simple (et la plus fiable) est d'utiliser
la distribution [Anaconda](https://docs.anaconda.com/anaconda/install/):

* Sous **_Windows_**, il suffit de télécharger l'exécutable puis
l'exécuter (cf. [la doc officielle](https://docs.anaconda.com/anaconda/install/windows/)
ou [ce site](https://mrmint.fr/installer-environnement-python-machine-learning-anaconda)). 
* Sous **_Mac_**, se reporter à la [doc officielle](https://docs.anaconda.com/anaconda/install/mac-os/)
* Sous **_Linux_**, [ce tutoriel](https://linuxize.com/post/how-to-install-anaconda-on-ubuntu-18-04/) détaille
la procédure

Passer par `Anaconda` permet:

* d'installer Python
* d'installer par défaut une multitude de packages
([liste ici](https://docs.anaconda.com/anaconda/packages/py3.6_win-64/))
* de pouvoir utiliser un gestionnaire de package nommé `Conda`
* d'installer `jupyter` pour exécuter des notebooks 

`JupyterHub` est pratique pour éditer des *notebook* jupyter (extension `.ipynb`). Néanmoins, pour un usage
plus développé de Python, il est recommandé d'installer un éditeur plus complet et d'éditer des 
scripts au format `.py` plutôt que des notebooks. L'éditeur le plus complet est 
`PyCharm` (privilégier [Pycharm Community Edition](https://www.jetbrains.com/pycharm/)
)[^1]: 

[^1]: D'autres éditeurs sont très bien faits, notamment `Visual Studio`

* nombreux *plugins* pour une pleine utilisation de l'écosystème `Python`: éditeur de `Markdown`, 
interface `git`, etc. 
* fonctionalités classiques d'un éditeur dont manque `Jupyter`: autocomplétion, diagnostic du code, etc.
* intégration avec les environnements `Conda`

Au-delà de l'utilisation de Jupyter à des fins pédagogiques et à des fins de publicisation, je recommande
d'utiliser privilégier `PyCharm`

## Exécution dans un environnement temporaire

Avec les dépôts sur `Github` ou `Gitlab`, on dissocie environnement de stockage des codes et
d'exécution de ceux-ci. Sur le
[dépôt github de ce cours](https://github.com/linogaliana/python-datascientist), on peut
naviguer dans les fichiers (et voir tout l'historique de modification de ceux-ci). Mais,
comment exécuter les scripts sans passer par un poste local ? 

Depuis quelques années, des services en ligne permettant de
lancer une instance `Jupyter` en ligne (analogue à celle que vous pouvez
lancer en local en utilisant `Anaconda`) ont émergé. Parmi celles-ci :

* **__Binder__** [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/linogaliana/python-datascientist/master) ;
* [Google collaboratory](https://colab.research.google.com/notebooks/welcome.ipynb) ;
* [Kaggle](https://www.kaggle.com/notebooks) ;

Attention, les performances de ces solutions peuvent être variables. Par défaut, 

### Binder [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/linogaliana/python-datascientist/master)

En cliquant sur cette icône
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/linogaliana/python-datascientist/master),
qu'on peut retrouver un peu partout dans ce site ou sur le dépôt
[github](https://github.com/linogaliana/python-datascientist), vous pouvez lancer un environnement propre,
disposant de toutes les dépendances nécessaires pour ce cours et disposant d'une copie
(un *clone* en langage `git`) du dépôt `Github`.

**Attention: il n'y a pas de garantie de perennité de service** (notamment avec `binder` où
10 minutes d'inactivité mènent à l'extinction du service). Il s'agit plus d'un service pour griffoner
dans le même environnement que celui du dépôt `git` que de solutions durables.

### Google collaboratory

Il s'agit d'un mélange de notebook jupyter et de Google docs, possiblement connectés à Google Drive
(ou mieux à
[github](https://colab.research.google.com/github/googlecolab/colabtools/blob/master/notebooks/colab-github-demo.ipynb)). 


### Kaggle

`Kaggle` n'héberge pas que des compétitions de code mais donne la possibilité d'exécuter des notebooks, 
comme les solutions précédentes.

Interface avec github? 

## Docker

**TODO**
 
# Installer et configurer git



