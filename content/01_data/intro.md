---
title: "Manipuler des données"
date: 2020-07-16T13:00:00Z
draft: false
weight: 30
---

Le *dataframe* est l'outil central du logiciel `R` mais il s'agit d'un objet qui, en `Python`, ne s'est
imposé que récemment, notamment grâce au package `pandas`. Il s'agit
d'une représentation particulière des données, classique 

# Retour sur numpy

`pandas` est lui-même construit à partir du package `numpy`, qu'il est utile de comprendre
pour être à l'aise avec `pandas`. `numpy` est une librairie bas-niveau 
pour stocker et manipuler des données. 
`numpy` est au coeur de l'écosystème de la *data science* car la plupart des librairies
utilisent des objets construits à partir de `numpy`

Le concept central de `numpy` est
l'**array** qui est un tableau de données multidimensionnel. Par rapport à une liste,

* un *array* ne peut contenir qu'un type de données (`integer`, `string`, etc.),
 contrairement à une liste.
* les opérations implémentées par `numpy` seront plus efficaces et demanderont moins
de mémoire

L'array numpy peut être unidimensionnel et s'apparenter à un vecteur (1d-array) ou
multidimensionnel (Nd-array). Un DataFrame sera construit à partir d'une collection
d'array unidimensionnel (les variables de la table),
ce qui permettra d'effectuer des opérations cohérentes
(et optimisées) avec le type de la variable.
Les données géographiques constitueront une construction un peu plus complexe
(la dimension géographique constitue un tableau plus profond, au moins bidimensionnel
(coordonnées d'un point)). 



D'une certaine manière, les tableaux Numpy sont comme les listes en Python, mais Numpy permet de rendre les opérations beaucoup plus efficaces, surtout sur les tableaux de large taille. Les tableaux Numpy sont au cœur de presque tout l'écosystème de data science en Python.

# Le DataFrame pandas

Une Series est un objet uni-dimensionnel similaire à un tableau, une liste ou une colonne d'une table. Chaque valeur est associée à un index qui est par défaut les entiers de 0 à N−1 (avec N la longueur de la Series).