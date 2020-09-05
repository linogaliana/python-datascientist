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
de privilégier `PyCharm` pour la pratique quotidienne de `Python`

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
* __onyxia__ [![Onyxia](https://img.shields.io/badge/launch-onyxia-blue)](https://spyrales.sspcloud.fr/my-lab/catalogue/inseefrlab-datascience/jupyter/deploiement) plateforme développée par l'Insee qui fournit des environnements bac à sable basés sur des technologie de conteneurisation


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


Attention, les performances de ces solutions peuvent être variables. Les serveurs publics mis à disposition
ne sont pas forcément des foudres de guerre. Avec ceux-ci,
on vérifie plutôt la reproductibilité des scripts avec des jeux d'exemples.
Quand on est dans une entreprise ou administration, qui dispose de serveurs propres,
on peut aller plus loin en utilisant ces outils 
pour automatiser l'ensemble de la chaîne de traitement. 

**Attention: il n'y a pas de garantie de perennité de service** (notamment avec `binder` où
10 minutes d'inactivité mènent à l'extinction du service). Il s'agit plus d'un service pour griffoner
dans le même environnement que celui du dépôt `git` que de solutions durables.

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

Derrière ces outils pour exécuter de manière simple des scripts Python sur un serveur temporaire se cache
`Docker`. `Docker` est une technologie qui vise à permettre la construction de machines autosuffisantes
(que l'on nomme containeurs) répliquant un environnement contrôlé (que l'on nomme image).
 
# Installer et configurer git

## Pourquoi utiliser la gestion de version ?

Nos travaux statistiques évoluent constamment (productions annuelles, nouvelles enquêtes, etc.) et nous travaillons souvent à plusieurs. En outre, le maintien de la qualité de nos chaînes de traitement nécessite un archivage détaillé et facilement accessible. 

Tous les statisticiens se sont déjà demandé (ou à leurs collègues) : 

* quelle était la bonne version d'un programme 
* qui était l'auteur d'un bout de code en particulier
* si un changement était important ou juste un essai
* comment fusionner des programmes
* etc.

Il existe un outil informatique puissant afin de répondre à tous ces besoins : la gestion de version (*version control system* (VCS) en anglais). Ses avantages sont incontestables et permettent de facilement :

* enregistrer l'historique des modifications d'un ensemble de fichiers 
* revenir à des versions précédentes d'un ou plusieurs fichiers
* rechercher les modifications qui ont pu créer des erreurs
* partager ses modifications et récupérer celles des autres
* proposer des modifications, les discuter, sans pour autant modifier la dernière version existante
* identifier les auteurs et la date des modifications

En outre, ces outils fonctionnent avec tous les langages informatiques
(texte, R, Python, SAS, $\LaTeX$, Java, etc.) car reposent sur la comparaison des lignes
et des caractères des programmes.

L'intérêt de `git` dépasse le cadre collaboratif. Même dans une utilisation personnelle de `python` utiliser 
`git` rend ***


## git, kesako ? {{< rawhtml >}} <img src="https://www.linuxjournal.com/sites/default/files/styles/360_250/public/nodeimage/story/git-icon.png?itok=w7zB9vuE" width="100"> {{< /rawhtml >}}

`git` est un système de contrôle de version dont la vocation est de permettre de tracer les modifications faites
entre deux versions d'un fichier. Il s'agit d'un outil particulièrement adapté à la programmation puisque `git` permet
un suivi ligne à ligne des modifications faites à un fichier. 

Les modifications sont visibles par tout membre d'un projet et de manière très fine. Il est ainsi possible de
visualiser à quel moment chaque ligne d'un fichier a été modifiée:

![Exemple sur la page d'entrée du cours [ici](https://github.com/linogaliana/python-datascientist/blame/master/content/_index.md)](static/pictures/intro/gitblame.png)

Et il est possible de comparer l'évolution de l'état d'un fichier entre deux versions:

![Exemple sur la page d'entrée du cours [ici](https://github.com/linogaliana/python-datascientist/blame/master/content/_index.md)](static/pictures/intro/sidebyside.png)

L'utilisation de `git` devient une norme dans les administrations, les entreprises et le monde académique. 
Des éléments supplémentaires, avec exemples via `Rstudio` (très peu de différences avec `Pycharm`),
peuvent être trouvés
[ici](https://linogaliana.gitlab.io/collaboratif/git.html) 



## Installer et tester git bash

`git` est un langage en tant que  tel qui mériterait un cours à part entière.
L'utilisation qu'on va en faire sera relativement modeste et se bornera à valider des modifications
d'un script en local (opérations qu'on appelle `add` et `commit`), intéragir avec un dépôt distant
(`pull` et `push`). Le projet final amènera à collaborer en groupe, ce qui peut amener à résoudre des
conflits (l'une des forces de `git`). 

Le meilleur moyen d'utiliser `git` est, en premier lieu, d'installer [git bash](https://git-scm.com/downloads). Une fois
installé, lancer le logiciel ; une ligne de commande s'ouvre qu'on peut tester (les pluggins `git` de
jupyter et pycharm ne rendent pas indispensable l'usage de la ligne de commande mais il est toujours bon
de savoir l'utiliser).

Se placer avec la commande `cd` dans un dossier de travail, par exemple `Mes Documents\testgit`, où on va
récupérer automatiquement le dépôt du cours disponible sur
[github](https://github.com/linogaliana/python-datascientist). La commande pour récupérer un dépôt distant
est `git clone` (on crée un clone local, qu'on est ensuite libre de faire évoluer):

![Récupération d'un dépôt sur github via git bash](./pictures/gitbash2.png)

Le contenu du dépôt est maintenant disponible dans le dossier désiré. 
 
## Configurer pycharm pour utiliser le plugin git

Aller dans `File > Settings > Version Control > Git` pour définir le chemin vers lequel `Pycharm` doit trouver
l'exécutable `git`. Si `git` a été installé dans un chemin standard, `Pycharm` le trouve ; sinon, 
il faut lui donner (dans le dossier d'installation `git`, bien choisir l'exécutable présent dans 
le sous-dossier `cmd/git.exe`) ^[2]

![Récupération d'un dépôt sur github via git bash](./pictures/vcspycharm2.png)

^[2:] Si la case `Use credential helper` est cochée, il est recommandé de la décocher car en cas
de mot de passe tapé trop vite, les tentatives de connexion au dépôt distant seront
systématiquement refusées 


## Configurer jupyter pour utiliser le plugin git

https://github.com/jupyterlab/jupyterlab-git

## Présentation des fonctionalités de github et gitlab

## Pratiquer git

Faire un petit notebook