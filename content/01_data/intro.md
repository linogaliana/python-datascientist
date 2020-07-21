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

## Le concept d'array

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
d'array uni-dimensionnels (les variables de la table), ce qui permettra d'effectuer des opérations cohérentes
(et optimisées) avec le type de la variable.

Les données géographiques constitueront une construction un peu plus complexe. 
La dimension géographique prend la forme d'un tableau plus profond, au moins bidimensionnel
(coordonnées d'un point). 

Le fichier
[numpy.ipynb](https://github.com/linogaliana/python-datascientist/blob/pandas_intro/static/notebooks/numpy.ipynb) 
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/linogaliana/python-datascientist/pandas_intro?filepath=/static/notebooks/numpy.ipynb)
présente quelques mises en pratique des concepts développés ci-dessous


## Indexation et slicing

La structure la plus simple imaginable est l'array unidimensionnel:

```python
np.arange(10)
# array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
```

L'indexation est dans ce cas similaire à celle d'une liste: 

* le premier élément est 0
* le énième élément est acessible à la position $n-1$

La logique d'accès aux éléments est ainsi la suivante:

```python
x[start:stop:step]
```

Avec un *array* unidimensionnel, l'opération de *slicing* (garder une coupe du *array*) est très simple. 
Par exemple, pour garder les K premiers éléments d'un *array*, on fera:

```python
x[:(K-1)]
```

puisque l'indexation en Python commence à 0. 


-----

Un élément déterminant dans la performance de `numpy` par rapport aux listes, lorsqu'il est question de 
*slicing* est qu'un array ne renvoie pas une
copie de l'élément en question (copie qui coûte de la mémoire et du temps) mais simplement une vue de celui-ci
**DETAILS** 

Lorsqu'il est nécessaire d'effectuer une copie, par exemple pour ne pas altérer l'array sous-jacent, on peut 
utiliser la méthode `copy`:

```python
x2_sub_copy = x2[:2, :2].copy()
```

-----

# Vector sparse

https://chrisalbon.com/machine_learning/vectors_matrices_and_arrays/create_a_sparse_matrix/

# Le DataFrame pandas

Une Series est un objet uni-dimensionnel similaire à un tableau, une liste ou une colonne d'une table. Chaque valeur est associée à un index qui est par défaut les entiers de 0 à N−1 (avec N la longueur de la Series).