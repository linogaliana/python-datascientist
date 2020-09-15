---
title: "Partie 1: manipuler des données"
date: 2020-07-16T13:00:00Z
draft: false
weight: 20
slug: "manipulation"
---

Le *dataframe* est l'outil central du logiciel `R` mais il s'agit d'un objet qui, en `Python`, ne s'est
imposé que récemment, notamment grâce au package `pandas`. Le concept de *dataframe* est relativement 
intuitif et il existe un grand socle d'approches, héritières notamment de la logique SQL, 
facilitant le maniement de ces données.

`pandas` est devenu incontournable dans l'écosystème `Python` pour la *data science*. 
`pandas` est lui-même construit à partir du package `numpy`, qu'il est utile de comprendre
pour être à l'aise avec `pandas`. `numpy` est une librairie bas-niveau 
pour stocker et manipuler des données. 
`numpy` est au coeur de l'écosystème de la *data science* car la plupart des librairies, même celles
qui manient des objets destructurés,
utilisent des objets construits à partir de `numpy`. 

L'approche `pandas` a été étendue aux objets géographiques avec `geopandas`.
Il est ainsi possible de manipuler des données géographiques comme s'il
s'agissait de données structurées classiques. Les données géographiques et
la représentation cartographique deviennent de plus en plus commun avec
la multiplication de données ouvertes localisées et de *big-data* géolocalisées.

Cependant, les données structurées, importées depuis des fichiers plats
ne représentent pas l'unique source de données. Les API et le *webscraping*
permettent de requêter ou d'extraire 
des données de manière très flexible. Ces données, notamment
celles obtenues par *webscraping* nécessitent souvent un peu plus de travail
de nettoyage de données, notamment des chaînes de caractère. 

## Structure de la partie

Dans un premier temps, l'apprentissage des principes de la manipulation
des données se fera de la manière suivante:

* [Une introduction à numpy](numpy) pour découvrir et pratiquer
la manipulation de données avec python ;
* [Des éléments sur pandas](pandascours) et
[un exercice complet pour pratiquer pandas](pandastp).

Ensuite, nous approfondirons différents aspects de la manipulation de données:

* [Présentation du traitement des données spatiales](geopandas) 
et [pratique de geopandas](geopandastp)
* [Pratique du webscraping](webscraping)
* [Pratique du nettoyage de données textuelles](regex)
* [Pratique du requêtage par les API](api)


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



## Pour aller plus loin

Ce cours n'aborde pas encore les questions de volumétrie ou de vitesse de 
calcul. `pandas` peut montrer ses limites dans ce domaine. 

Il est ainsi intéressant de porter attention à:

* La question des
[objets sparse](https://chrisalbon.com/machine_learning/vectors_matrices_and_arrays/create_a_sparse_matrix/)
* Le package [`dask`](https://dask.org/) pour accélérer les calculs
* [`pySpark`](https://spark.apache.org/docs/latest/api/python/index.html) pour des données très volumineuses



