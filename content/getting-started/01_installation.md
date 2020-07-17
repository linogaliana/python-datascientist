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
des standards dans la communauté *open-source* et dans l'industrie. 
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
)^[D'autres éditeurs sont très bien faits, notamment `Visual Studio`]: 

* nombreux *plugins* pour une pleine utilisation de l'écosystème `Python`: éditeur de `Markdown`, 
interface `git`, etc. 
* fonctionalités classiques d'un éditeur dont manque `Jupyter`: autocomplétion, diagnostic du code, etc.
* intégration avec les environnements `Conda`

## Exécution dans un environnement temporaire

* Binder [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/linogaliana/python-datascientist/master)
* Google
* Kaggle

## Docker

 
# Installer et configurer git
