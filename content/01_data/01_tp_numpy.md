---
jupyter:
  jupytext:
    formats: ipynb,md
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.2'
      jupytext_version: 1.5.2
  kernelspec:
    display_name: Python 3
    language: python
    name: python3
title: "Retour sur numpy"
date: 2020-07-16T13:00:00Z
draft: false
weight: 100
---

# Retour sur numpy

![](https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/NumPy_logo.svg/1200px-NumPy_logo.svg.png)

Il est recommandé de régulièrement se référer à
la [cheatsheet numpy](https://www.datacamp.com/community/blog/python-numpy-cheat-sheet) et à la
[doc officielle](https://numpy.org/doc/stable/) en cas de doute
sur une fonction. 

Dans ce chapitre, on ne dérogera pas à la convention qui s'est imposée d'importer `numpy` de la
manière suivante:

```python
import numpy as np
```



Si les scripts suivants sont exécutés dans un `notebook`, il est recommandé d'utiliser les paramètres suivants
pour contrôler le rendu

```python
from IPython.core.interactiveshell import InteractiveShell
InteractiveShell.ast_node_interactivity = "all"
```


## Le concept d'array

Le concept central de `NumPy` (`Numerical Python`) est
l'**`array`** qui est un tableau de données multidimensionnel.

L'array numpy peut être unidimensionnel et s'apparenter à un vecteur (1d-array),
bidimensionnel et ainsi s'apparenter à une matrice (2d-array) ou, de manière plus générale, 
prendre la forme d'un objet
multidimensionnel (Nd-array). 

Les tableaux simples (uni ou bi-dimensionnels) sont faciles à se représenter seront particulièrement
utilisés dans le paradigme des DataFrames mais 
la possibilité d'avoir des objets multidimensionnel permettra d'exploiter des
structures très complexes.

Un DataFrame sera construit à partir d'une collection
d'array uni-dimensionnels (les variables de la table), ce qui permettra d'effectuer des opérations cohérentes
(et optimisées) avec le type de la variable.


Par rapport à une liste,

* un *array* ne peut contenir qu'un type de données (`integer`, `string`, etc.),
 contrairement à une liste.
* les opérations implémentées par `numpy` seront plus efficaces et demanderont moins
de mémoire



Les données géographiques constitueront une construction un peu plus complexe qu'un DataFrame traditionnel. 
La dimension géographique prend la forme d'un tableau plus profond, au moins bidimensionnel
(coordonnées d'un point). 


## Créer un array

On peut créer un `array` de plusieurs manières. Pour créer un `array` à partir d'une liste,
il suffit d'utiliser la méthode `array`:

```python
np.array([1,2,5])
np.array([["a","z","e"],["r","t"],["y"]])
```

Il existe aussi des méthodes pratiques pour créer des array:

* séquences logiques : `np.arange` (suite) ou `np.linspace` (interpolation linéaire entre deux bornes)
* séquences ordonnées: _array_ rempli de zéros, de 1 ou d'un nombre désiré : `np.zeros`, `np.ones` ou `np.full`
* séquences aléatoires: fonctions de génération de nombres aléatoires: `np.rand.uniform`, `np.rand.normal`, etc. 
* tableau sous forme de matrice identité: `np.eye`

Il est possible d'ajouter un argument `dtype` pour contraindre le type du *array*:

```python
np.arange(0,10)
np.arange(0,10,3)
np.linspace(0, 1, 5)
np.zeros(10, dtype=int)
np.ones((3, 5), dtype=float)
np.full((3, 5), 3.14)
np.eye(3)
```

**Exercice :**

Générer:

* $X$ une variable aléatoire, 1000 répétitions d'une loi $U(0,1)$
* $Y$ une variable aléatoire, 1000 répétitions d'une loi normale de moyenne nulle et de variance égale à 2
* Vérifier la variance de $Y$ avec `np.var`


**Correction** 
```python
X = np.random.uniform(0,1,1000)
Y = np.random.normal(0,np.sqrt(2),1000)

np.var(Y)
```

## Indexation et slicing

### Logique générale

La structure la plus simple imaginable est l'array unidimensionnel:

```python
x = np.arange(10)
```

L'indexation est dans ce cas similaire à celle d'une liste: 

* le premier élément est 0
* le énième élément est accessible à la position $n-1$

La logique d'accès aux éléments est ainsi la suivante:

```python
x[start:stop:step]
```

Avec un *array* unidimensionnel, l'opération de *slicing* (garder une coupe du *array*) est très simple. 
Par exemple, pour garder les *K* premiers éléments d'un *array*, on fera:

```python
x[:(K-1)]
```

Pour sélectionner uniquement un élément, on fera ainsi:


```python
x = np.arange(10)
x[2]
```

En l'occurrence, on sélectionne le K$^{eme}$ élément en utilisant

```python
x[K-1]
```


**Exercice**

* Sélectionner les éléments 0,3,5
* Sélectionner les éléments pairs
* Sélectionner tous les éléments sauf le premier
* Sélectionner les 5 premiers éléments

Correction

```python
x[[0,3,5]]
x[::2]
x[-0]
x[:5]
# x2[0,:] # La première ligne
```


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

### Filtres logiques


On peut également sélectionner des données à partir de conditions logiques
(opération qu'on appelle un *boolean mask*), ce qui sera pratique lorsqu'il sera
nécessaire d'effectuer des opérations de filtre sur les données (`pandas` reprend cette logique).

Pour des opérations de comparaison simples, les comparateurs logiques peuvent être suffisants:

```python
x = np.arange(10)
x2 = np.array([[-1,1,-2],[-3,2,0]])
```

```python
x==2
x2<0
```

Néanmoins, `numpy` propose un certain nombre de fonctions logiques très pratiques:

* count_nonzero
* is_nan
* any ; all ; notamment avex `axis = 0`

**Exercice**

Soit
```python
x = np.random.normal(0, size=(3, 4))
```

un *array* multidimensionnel et

```python
y = np.array([np.nan, 0, 1])
```

1. Utiliser `count_nonzero` sur `y`
2. Utiliser `is_nan` sur `y` et compter le nombre de valeurs non NaN
2. Vérifier que `x` comporte au moins une valeur positive dans son ensemble, dans chaque array et en

```python
x = np.random.normal(0, size=(3, 4))
y = np.array([np.nan, 0, 1])

x
y
np.count_nonzero(y)
np.isnan(y)
np.any(x>0)
np.any(x>0, axis = 0)
```

Pour sélectionner les observations relatives à la condition logique,
il suffit d'utiliser la logique de *slicing* de `numpy` qui fonctionne avec les conditions logiques

**Exercice**

Soit 

```python
x = np.random.normal(size=10000)
```

1. Ne conserver que les valeurs dont la valeur absolue est supérieure à 1.96
2. Compter le nombre de valeurs supérieures à 1.96 en valeur absolue et leur proportion dans l'ensemble
3. Sommer les valeurs absolues de toutes les observations supérieures (en valeur absolue) à 1.96 et rapportez les à la somme des valeurs de `x` (en valeur absolue) 



```python
x = np.random.normal(size=10000)

x2 = x[np.abs(x)>=1.96]

x2.size
x2.size/x.size
np.sum(np.abs(x2))/np.sum(np.abs(x))
```

## Ordonner et partionner un array

Pour ordonner un array, on utilise `np.sort`

```python
x = np.array([7, 2, 3, 1, 6, 5, 4])

np.sort(x)
```

Si on désire faire un ré-ordonnement partiel pour trouver les _k_ valeurs les plus petites d'un `array` sans les ordonner, on utilise `partition`:

```python
np.partition(x, 3)
```

## Broadcasting

Le broadcasting désigne un ensemble de règles pour appliquer une opération qui normalement ne s'applique que sur une seule valeur à l'ensemble des membres d'un tableau Numpy. 

Le broadcasting nous permet d'appliquer ces opérations sur des tableaux de dimensions différentes.

```python
a = np.array([0, 1, 2])

b = np.array([5, 5, 5])

a + b
a + 5
```

## Application: k-nearest neighbor fait-main

L'idée de cet exercice vient de [là](https://jakevdp.github.io/PythonDataScienceHandbook/02.08-sorting.html#Example:-k-Nearest-Neighbors)


1. Utiliser 

```python
import random as rand
X = np.random.random((10, 2))
```

```python
%matplotlib inline
import matplotlib.pyplot as plt
plt.scatter(X[:, 0], X[:, 1], s=100)
```

```python
dist_sq = np.sum((X[:, np.newaxis, :] - X[np.newaxis, :, :]) ** 2, axis=-1)
dist_sq
```

This operation has a lot packed into it, and it might be a bit confusing if you're unfamiliar with NumPy's broadcasting rules. When you come across code like this, it can be useful to break it down into its component steps:

```python
# for each pair of points, compute differences in their coordinates
differences = X[:, np.newaxis, :] - X[np.newaxis, :, :]
differences.shape
```

```python
# square the coordinate differences
sq_differences = differences ** 2
sq_differences.shape
```

```python
# sum the coordinate differences to get the squared distance
dist_sq = sq_differences.sum(-1)
dist_sq.shape
```

Just to double-check what we are doing, we should see that the diagonal of this matrix (i.e., the set of distances between each point and itself) is all zero:

```python
dist_sq.diagonal()
```

```python

```

```python

```

It checks out! With the pairwise square-distances converted, we can now use np.argsort to sort along each row. The leftmost columns will then give the indices of the nearest neighbors:

```python
nearest = np.argsort(dist_sq, axis=1)
print(nearest)
```

Notice that the first column gives the numbers 0 through 9 in order: this is due to the fact that each point's closest neighbor is itself, as we would expect.


By using a full sort here, we've actually done more work than we need to in this case. If we're simply interested in the nearest k neighbors, all we need is to partition each row so that the smallest k+1

squared distances come first, with larger distances filling the remaining positions of the array. We can do this with the np.argpartition function:

K = 2
nearest_partition = np.argpartition(dist_sq, K + 1, axis=1)




Finally, I'll note that when doing very large nearest neighbor searches, there are tree-based and/or approximate algorithms that can scale as O[NlogN] or better rather than the O[N2] of the brute-force algorithm. One example of this is the KD-Tree, implemented in Scikit-learn.


Suite exercice: 
    * faire une fonction dont argument est array et k
    * faire quelques tests unitaires: diag 0, premier element matrice est élément lui-même, dimension sortie


## Restructuration, concaténation et division

* Pour restructurer un `array`, c'est-à-dire changer ses dimensions, le plus simple est d'utiliser la méthode `reshape`. Par exemple, pour 

np.reshape
np.concatenate
np.split, np.hsplit, and np.vsplit


