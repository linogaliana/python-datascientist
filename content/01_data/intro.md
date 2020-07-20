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


Boolean masks (e.g., arr[arr > 0])

## Reshaping

```python
Another useful type of operation is reshaping of arrays. The most flexible way of doing this is with the reshape method. For example, if you want to put the numbers 1 through 9 in a 3×3

grid, you can do the following:

grid = np.arange(1, 10).reshape((3, 3))
print(grid)

[[1 2 3]
 [4 5 6]
 [7 8 9]]
```

<!-----

```python
import numpy as np
x[0]
x[:2]
x1[::-1]
```

On peut accéder de la même façon aux éléments d'un tableau multi-dimensionnel.
Par exemple, on a souvent besoin d'accéder à une ligne ou une colonne d'une matrice.
print(x2)

```python
x2[0,:] # La première ligne
```

## Concaténation

```python
x = np.array([1, 2, 3])

y = np.array([3, 2, 1])

np.concatenate([x, y])
```

The opposite of concatenation is splitting, which is implemented by the functions np.split, np.hsplit, and np.vsplit. For each of these, we can pass a list of indices giving the split points:

## Opérations

But: éviter les boucles (lentes!)

x = np.arange(4)
np.where(x > 2)
np.log(np.abs(x)))

np.sum(L)
%timeit sum(tableau_large)
%timeit np.sum(tableau_large)


Les fonctions d'agrégation peuvent optionnellement ne s'appliquer qu'à une dimension d'un tableau multidimensionnel. Par exemple, nous pouvons avoir besoin de la somme des éléments de chaque colonne d'une matrice (nous avons vu un cas d'utilisation dans le chapitre 3 de la première partie de ce cours). Pour cela nous utilisons l'argument optionnel  axis
M = np.random.random((3, 4))
print(M)
# Notez la syntax variable.fonction au lieu de 
# np.fonction(variable). Les deux sont possibles si
# la variable est un tableau Numpy.
print("La somme de tous les éléments de M: ", M.sum())
print("Les sommes des colonnes de M: ", M.sum(axis=0))


Parmi les nombreuses fonctions disponibles, notons :
-  np.std  pour calculer l'écart type
-  np.argmin  pour trouver l'index de l'élément minimum
-  np.percentile  pour calculer des statistiques sur les éléments.

Bouts de code à mettre dans notebook:

## Créer des array

# Un tableau de longueur 10, rempli d'entiers qui valent 0
np.zeros(10, dtype=int)

# Un tableau de taille 3x5 rempli de nombres à virgule flottante de valeur 1
np.ones((3, 5), dtype=float)

# Un tableau 3x5 rempli de 3,14
np.full((3, 5), 3.14)

# Un tableau rempli d'une séquence linéaire
# commençant à 0 et qui se termine à 20, avec un pas de 2
np.arange(0, 20, 2)

# Un tableau de 5 valeurs, espacées uniformément entre 0 et 1
np.linspace(0, 1, 5)

# Celle-ci vous la conaissez déjà! Essayez aussi "randint" et "normal"
np.random.random((3, 3))

# La matrice identité de taille 3x3 
# (matrice identité : https://fr.wikipedia.org/wiki/Matrice_identit%C3%A9)
np.eye(3)

## Manipuler des arrays



## Théorème central-limite


------>

## Sorting

Although Python has built-in sort and sorted functions to work with lists, we won't discuss them here because NumPy's np.sort function turns out to be much more efficient and useful for our purposes. By default np.sort uses an O[NlogN], quicksort algorithm, though mergesort and heapsort are also available. For most applications, the default quicksort is more than sufficient.

rand = np.random.RandomState(42)
X = rand.randint(0, 10, (4, 6))
print(X)

Sometimes we're not interested in sorting the entire array, but simply want to find the k smallest values in the array. NumPy provides this in the np.partition function. np.partition takes an array and a number K; the result is a new array with the smallest K values to the left of the partition, and the remaining values to the right, in arbitrary order:

x = np.array([7, 2, 3, 1, 6, 5, 4])
np.partition(x, 3)

Reprendre: 
https://jakevdp.github.io/PythonDataScienceHandbook/02.08-sorting.html#Example:-k-Nearest-Neighbors

# Le DataFrame pandas

Une Series est un objet uni-dimensionnel similaire à un tableau, une liste ou une colonne d'une table. Chaque valeur est associée à un index qui est par défaut les entiers de 0 à N−1 (avec N la longueur de la Series).