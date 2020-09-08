---
title: "Partie 1: manipuler des données"
date: 2020-07-16T13:00:00Z
draft: false
weight: 20
slug: "manipulation"
---

Justification de la partie

Liens vers supports + TP



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
utilisent des objets construits à partir de `numpy`

**Continuer cette intro en fonction des différents chapitres de la partie**

# Retour sur numpy


A MODIFIER

Le fichier
[numpy.ipynb](https://github.com/linogaliana/python-datascientist/blob/pandas_intro/static/notebooks/numpy.ipynb) 
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/linogaliana/python-datascientist/pandas_intro?filepath=/static/notebooks/numpy.ipynb)
présente quelques mises en pratique des concepts développés ci-dessous


## Indexation et slicing




-----

Un élément déterminant dans la performance de `numpy` par rapport aux listes, lorsqu'il est question de 
*slicing* est qu'un array ne renvoie pas une
copie de l'élément en question (copie qui coûte de la mémoire et du temps) mais simplement une vue de celui-ci
**DETAILS** 

Lorsqu'il est nécessaire d'effectuer une copie, par exemple pour ne pas altérer l'array sous-jacent, on peut 
utiliser la méthode `copy`:

```{python}
x2_sub_copy = x2[:2, :2].copy()
```

-----

# Vector sparse

https://chrisalbon.com/machine_learning/vectors_matrices_and_arrays/create_a_sparse_matrix/

# Le DataFrame pandas

Une Series est un objet uni-dimensionnel similaire à un tableau, une liste ou une colonne d'une table. Chaque valeur est associée à un index qui est par défaut les entiers de 0 à N−1 (avec N la longueur de la Series).

