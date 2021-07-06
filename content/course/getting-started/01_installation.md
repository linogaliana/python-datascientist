---
title: "Configuration de Python"
date: 2020-07-16T13:00:00Z
draft: false
weight: 20
slug: "configuration"
type: book
summary: |
  Quelques conseils pour avoir un environnement Python fonctionnel.
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
à `Python`, ce cours montrera comment utiliser `Git` avec `Python` et
évoquera un
certain nombre de critères de qualité du code qui sont devenus
des standards dans la communauté *open-source*, dans l'industrie et dans
l'administration. Ces compétences ne sont pas inhérentes à Python et seront
utiles pour tout projet ultérieur.

Le projet final devra impérativement
être associé à un dépôt `Git` (nous reviendrons dessus) et répondre à
ces critères de qualité, qui serviront toute la vie.

# Installer Python

## Installation en local {#local}

Pour pouvoir travailler en local avec `Python`, il est recommandé d'utiliser
la distribution [Anaconda](https://docs.anaconda.com/anaconda/install/):

* Sous **_Windows_**, il suffit de télécharger l'exécutable puis
l'exécuter (cf. [la doc officielle](https://docs.anaconda.com/anaconda/install/windows/)
ou [ce site](https://mrmint.fr/installer-environnement-python-machine-learning-anaconda)).
* Sous **_Mac_**, se reporter à la [doc officielle](https://docs.anaconda.com/anaconda/install/mac-os/)
* Sous **_Linux_**, suivre les instructions de la [doc officielle](https://docs.anaconda.com/anaconda/install/linux/) selon sa distribution

Passer par `Anaconda` permet:

* d'installer Python
* d'installer par défaut une multitude de packages utiles
([liste ici](https://docs.anaconda.com/anaconda/packages/py3.6_win-64/))
* de pouvoir utiliser un gestionnaire de package nommé `Conda`

`JupyterHub` est pratique pour éditer des *notebook* jupyter (extension `.ipynb`).
Les *notebook* jupyter sont un outil très utilisé en *data science*, ils sont en
particulier très adaptés à la réalisation d'analyses exploratoires.
Néanmoins, passé l'étape d'exploration, il est recommandé de plutôt recourir à des
scripts au format `.py`, afin de favoriser la reproductibilité des analyses.
Ces scripts peuvent être édités à l'aide d'éditeurs de texte adaptés au code, comme
[Sublime Text](https://www.sublimetext.com), ou bien dans le cadre d'environnements de
développement intégrés (IDE), tels que
`PyCharm` (privilégier [Pycharm Community Edition](https://www.jetbrains.com/pycharm/)
)[^1], qui offrent des fonctionalités supplémentaires pratiques :

[^1]: D'autres éditeurs sont très bien faits, notamment `Visual Studio`

* nombreux *plugins* pour une pleine utilisation de l'écosystème `Python`: éditeur de `Markdown`,
interface `Git`, etc.
* fonctionalités classiques d'un IDE dont manque `Jupyter`: autocomplétion, diagnostic du code, etc.
* intégration avec les environnements `Conda`

## Exécution dans un environnement temporaire sur un serveur distant

Les technologies dominantes dans le domaine du traitement des données ont amené à une évolution des pratiques
depuis quelques années. La multiplication de données volumineuses qui dépassent les capacités en RAM
voire en stockage des machines personnelles, les progrès dans les technologies de stockage type *cloud*,
l'adhésion de la communauté aux outils de versioning (le plus connu étant `git`) sont autant de facteurs
ayant amené à repenser la manière de traiter des données.


Avec les dépôts sur `Github` ou `Gitlab`, on dissocie environnement de stockage des codes et
d'exécution de ceux-ci. Sur le
[dépôt github de ce cours](https://github.com/linogaliana/python-datascientist), on peut
naviguer dans les fichiers (et voir tout l'historique de modification de ceux-ci). Mais,
comment exécuter les scripts sans passer par un poste local ?

Depuis quelques années, des services en ligne permettant de
lancer une instance `Jupyter` à distance (analogue à celle que vous pouvez
lancer en local en utilisant `Anaconda`) ont émergé. Parmi celles-ci :

* **__Binder__** [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/linogaliana/python-datascientist/master) ;
* **Google collaboratory**
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](http://colab.research.google.com/github/linogaliana/python-datascientist/blob/pandas_intro/static/notebooks/numpy.ipynb)
;
* __onyxia__ [![Onyxia](https://img.shields.io/badge/launch-onyxia-blue)](https://datalab.sspcloud.fr/my-lab/catalogue/inseefrlab-helm-charts-datascience/jupyter/deploiement?resources.requests.memory=4096Mi) plateforme développée par l'Insee qui fournit des environnements bac à sable basés sur des technologie de conteneurisation


Il est aussi possible d'exécuter des codes sur les services d'intégration continue de
[gitlab (service gitlab CI)](https://medium.com/metro-platform/continuous-integration-for-python-3-in-gitlab-e1b4446be76b)
ou de [github (via travis)](https://docs.travis-ci.com/user/languages/python/). Il s'agit d'une approche
*bash* c'est-à-dire que les scripts sont exécutés par une console à chaque interaction avec le dépôt
distant gitlab/github, sans session ouverte pour les éditer. Cette approche est très appropriée
pour assurer la reproductibilité d'une chaîne de traitement (on peut aller jusq'au
déploiement de visualisations automatiques) mais n'est pas très pratique pour
le griffonnage.

[Kaggle](https://www.kaggle.com/notebooks) propose des compétitions de code mais
donne également la possibilité d'exécuter des notebooks,
comme les solutions précédentes.

{{% panel status="warning" title="Warning" icon="fa fa-exclamation-triangle" %}}
Attention, les performances de ces solutions peuvent être variables. Les serveurs publics mis à disposition
ne sont pas forcément des foudres de guerre. Avec ceux-ci,
on vérifie plutôt la reproductibilité des scripts avec des jeux d'exemples.

Quand on est dans une entreprise ou administration, qui dispose de serveurs propres,
on peut aller plus loin en utilisant ces outils
pour automatiser l'ensemble de la chaîne de traitement.

**Attention: il n'y a pas de garantie de perennité de service** (notamment avec `binder` où
10 minutes d'inactivité mènent à l'extinction du service). Il s'agit plus d'un service pour griffoner
dans le même environnement que celui du dépôt `Git` que de solutions durables.

{{% /panel %}}


### Binder [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/linogaliana/python-datascientist/master)

En cliquant sur cette icône
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/linogaliana/python-datascientist/master),
qu'on peut retrouver un peu partout dans ce site ou sur le dépôt
[github](https://github.com/linogaliana/python-datascientist), vous pouvez lancer un environnement propre,
disposant de toutes les dépendances nécessaires pour ce cours et disposant d'une copie
(un *clone* en langage `git`) du dépôt `Github`.



### Google collaboratory [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/googlecolab/colabtools/blob/master/notebooks/colab-github-demo.ipynb)

Google met à disposition une plateforme de calculs basée sur le format `Jupyter notebook`.
Un grand avantage de cette solution est la mise à disposition gratuite de
[GPUs](https://fr.wikipedia.org/wiki/Processeur_graphique) de qualité raisonnable,
outil quasi-indispensable dans les projets basés sur des méthodes de `deep learning`.
Il est possible de connecter les *notebooks* ouverts à Google Drive ou à
[github](https://colab.research.google.com/github/googlecolab/colabtools/blob/master/notebooks/colab-github-demo.ipynb). L'icone
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/googlecolab/colabtools/blob/master/notebooks/colab-github-demo.ipynb)
fournit un raccourci pour lancer le notebook dans un environnement dédié.


### Docker

[Docker](https://www.docker.com/) est l'outil open-source de référence en matière de
[conteneurisation](https://fr.wikipedia.org/wiki/Conteneur_(informatique)).
En pratique, une application codée en `Python` ne repose que rarement seulement sur
du code produit par son développeur, elle fait généralement intervenir des dépendances :
d'autres librairies `Python`, ainsi que des librairies liées au système d'exploitation
sur laquelle elle est développée. `Docker` va permettre d'empaqueter l'application ainsi
que toutes ses dépendances et rendre son exécution portable, c'est à dire indépendante
du système sur laquelle elle est éxécutée. Par exemple, `Docker` est utilisé dans
le cadre de cours afin d'assurer la reproductibilité des exemples (voir les détails
sur la page [GitHub](https://github.com/linogaliana/python-datascientist) du cours.)

## Installer et configurer Git

Le principe de `Git` ainsi que son usage avec `Python` sont présentés dans
une [partie dédiée](/course/git). Cette partie se concentre ainsi sur la question
de la configuration de `Git`.
