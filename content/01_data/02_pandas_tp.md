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
title: "Introduction à pandas"
date: 2020-07-28T13:00:00Z
draft: false
weight: 100
---

Dans ce tutoriel `pandas`, nous allons utiliser:

* Les émissions de gaz à effet de serre estimées au niveau communal par l'ADEME. Le jeu de données est 
disponible sur [data.gouv](https://www.data.gouv.fr/fr/datasets/inventaire-de-gaz-a-effet-de-serre-territorialise/#_)
et requêtable directement dans python avec
[cet url](https://koumoul.com/s/data-fair/api/v1/datasets/igt-pouvoir-de-rechauffement-global/convert)
* Quelques données de contexte au niveau communal
[disponibles sur le site de l'Insee](https://www.insee.fr/fr/statistiques/3560121)
requêtables avec Python en utilisant cet
[url](https://www.insee.fr/fr/statistiques/fichier/3560121/filo-revenu-pauvrete-menage-2015.zip)


:warning: `pandas` offre la possibilité d'importer des données directement depuis un url. C'est l'option
prise dans ce tutoriel.
Si vous préfèrez, pour des
raisons d'accès au réseau ou de performance, importer depuis un poste local, télécharger les données et changer
les commandes d'import avec le chemin adéquat plutôt que l'url. 

### Logique de pandas

L'objet central dans la logique `pandas` est le `DataFrame`.
Il s'agit d'une structure particulière de données
à deux dimensions, structurées en alignant des lignes et colonnes. Les colonnes
peuvent être de type différent. 

Un DataFrame est composé des éléments suivants:

* l'indice de la ligne ;
* le nom de la colonne ;
* la valeur de la donnée ;

![Structuration d'un DataFrame pandas, emprunté à <https://medium.com/epfl-extension-school/selecting-data-from-a-pandas-dataframe-53917dc39953>](https://miro.medium.com/max/700/1*6p6nF4_5XpHgcrYRrLYVAw.png)


:warning: Les DataFrames sont assez rapides en Python^[1]

[1:] En `R`, les deux formes de dataframes qui se sont imposées récemment sont les `tibbles` (package `dplyr`)
et les `data.tables` (package `data.table`). `dplyr` reprend la syntaxe SQL de manière relativement
transparente ce qui rend la syntaxe très proche de celle de `pandas`. Cependant, 
alors que `dplyr` supporte très mal les données dont la volumétrie dépasse 1Go, `pandas` s'en
accomode bien. Les performances de `pandas` sont plus proches de celles de `data.table`, qui est 
connu pour être une approche efficace avec des données de taille importante. 


En fait, un DataFrame est une collection d'objets appelés `Pandas Series`. 
Ces `Series` sont des objets d'une dimension qui sont des extensions des
array-unidimensionnels `numpy`. En particulier, pour faciliter le traitement
de données catégorielles ou temporelles, des types de variables
supplémentaires sont disponibles dans `pandas` par rapport à
`numpy` (`categorical`, `datetime64` et `timedelta64`). Ces
types sont associés à des méthodes optimisées pour faciliter le traitement
de ces données. Il ne faut pas négliger l'attribut `dtype` d'un objet
`pandas.Series` car cela a une influence déterminante sur les méthodes
et fonctions pouvant être utilisés (on ne fait pas les mêmes opérations
sur une donnée temporelle et une donnée catégorielle) et le volume en
mémoire d'une variable (le type de la variable détermine le volume
d'information stocké pour chaque élément ; être trop précis est parfois
néfaste)


La différence essentielle avec un objet `numpy` est l'indexation. Dans `numpy`,
l'indexation est implicite ; elle permet d'accéder à une donnée (celle à
l'index *n*). Avec une `Series`, on peut utiliser des indices plus explicites.
Par exemple,

```python
taille = pd.Series(
    [1.,1.5,1],
    index = ['chat', 'chien', 'koala']
)
# chat     1.0
# chien    1.5
# koala    1.0
# dtype: float64
```

Cette indexation permet d'accéder à des valeurs de la `Series`
via une valeur de l'indice. Par
exemple, `taille['koala']`.

Pour transformer un objet `pandas.Series` en array `numpy`, 
on utilise la méthode `values`: `taille.values`.



### Le DataFrame pandas

Collection de pandas.Series avecx des types différents


Exo 1
Aller dans la doc pandas et trouver comment créer le dataFrame pandas suivant

```python
#	taille 	poids
#chat 	1.0 	3.0
#chien 	1.5 	5.0
#koala 	1.0 	2.5
```

Réponse 1:

```python
df = pd.DataFrame(
    {'taille': [1.,1.5,1],
    'poids' : [3, 5, 2.5]
    },
    index = ['chat', 'chien', 'koala']
)
```

Exo2: multiindex

    df2 = df1.set_index("State", drop = False)

### Les attributs et méthodes utiles

```python
df.axes
df.ndim
df.shape
df.head()
df.columns
df.count()
df.describe()
```



:warning: `head` dans un notebook avec des données confidentielles et `git`

```python
df = pd.read_csv("https://koumoul.com/s/data-fair/api/v1/datasets/igt-pouvoir-de-rechauffement-global/convert")
```

Les méthodes par défaut de graphique (approfondies dans le chapitre matplotlib/seaborn)

```python
df['Déchets'].plot()
df['Déchets'].hist()
df['Déchets'].plot(kind = 'hist', logy = True)
```

## Accéder à des éléments d'un DataFrame

df.loc
df.iloc
df[]

Pas df.ix qui est *deprecated*

## Principales manipulation de données


```python
df = pd.read_csv("https://koumoul.com/s/data-fair/api/v1/datasets/igt-pouvoir-de-rechauffement-global/convert")
```

Equivalent des 5 verbes du tidyverse + groupBy

## Import d'un fichier plat


## Calculs à partir de données / appliquer des fonctions

## Filtrer et réassigner


## Modifier un dataframe

### Créer des colonnes à partir d'autres

### Appliquer des fonctions

# Joindre

Jointure avec données communales (pour avoir population)

# Reordonner

# Indexation et performance

Ouverture sur dask?