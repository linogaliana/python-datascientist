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
l'administration. Ces compétences ne sont pas adhérentes à Python et seront
utiles pour tout projet ultérieur.
 
Le projet final devra impérativement
être associé à un dépôt `Git` (nous reviendrons dessus) et répondre à 
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
interface `Git`, etc. 
* fonctionalités classiques d'un éditeur dont manque `Jupyter`: autocomplétion, diagnostic du code, etc.
* intégration avec les environnements `Conda`


{{% panel status="hint" title="Conseil" icon="fa fa-exclamation-triangle" %}}
Au-delà de l'utilisation de Jupyter à des fins pédagogiques et à des fins de publicisation, je recommande
de privilégier `PyCharm` ou `Visual Studio` pour la pratique quotidienne de `Python`
{{% /panel %}}

## Exécution dans un environnement temporaire sur un serveur distant

Les technologies dominantes dans le domaine du traitement des données ont amené à une évolution des pratiques
depuis quelques années. La multiplication de données volumineuses qui dépassent les capacités en RAM
voire en stockage de machines personnelles, les progrès dans les technologies de stockage type *cloud*,
l'adhésion de la communauté aux outils de versionning (le plus connu étant `git`) sont autant de facteurs
ayant amené à repenser la manière de traiter des données. 


Avec les dépôts sur `Github` ou `Gitlab`, on dissocie environnement de stockage des codes et
d'exécution de ceux-ci. Sur le
[dépôt github de ce cours](https://github.com/linogaliana/python-datascientist), on peut
naviguer dans les fichiers (et voir tout l'historique de modification de ceux-ci). Mais,
comment exécuter les scripts sans passer par un poste local ? 

Depuis quelques années, des services en ligne permettant de
lancer une instance `Jupyter` en ligne (analogue à celle que vous pouvez
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

Il s'agit d'un mélange de notebook jupyter et de Google docs. Il est possible de connecter les
*notebooks* ouverts à Google Drive ou à
[github](https://colab.research.google.com/github/googlecolab/colabtools/blob/master/notebooks/colab-github-demo.ipynb),
la deuxième solution étant préférable. L'icone
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/googlecolab/colabtools/blob/master/notebooks/colab-github-demo.ipynb)
fournit un raccourci pour lancer le notebook dans un environnement dédié.


### Docker

**TO DO**
 
## Installer et configurer Git

Le principe de `Git` ainsi que son usage avec `Python` est présenté dans 
une [partie dédiée](git). Cette partie se concentre ainsi sur la question
de la configuration de `Git`.


### Configurer pycharm pour utiliser le plugin git

Aller dans `File > Settings > Version Control > Git` pour définir le
chemin vers lequel `Pycharm` doit trouver
l'exécutable `git`. Si `Git` a été installé dans un chemin standard,
`Pycharm` le trouve ; sinon, 
il faut lui donner (dans le dossier d'installation `git`,
bien choisir l'exécutable présent dans 
le sous-dossier `cmd/git.exe`) ^[2]

![Récupération d'un dépôt sur github via git bash](./pictures/vcspycharm2.png)

^[2:] Si la case `Use credential helper` est cochée, il est recommandé de la décocher car en cas
de mot de passe tapé trop vite, les tentatives de connexion au dépôt distant seront
systématiquement refusées 


### Configurer Jupyter pour utiliser le plugin git

La marche à suivre est présentée
[sur cette page](https://github.com/jupyterlab/jupyterlab-git)

### Configuration Visual Studio pour utiliser `Git`

