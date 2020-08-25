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

![](https://miro.medium.com/max/700/1*6p6nF4_5XpHgcrYRrLYVAw.png)

En fait, un DataFrame est une collection d'objets appelés `Pandas Series`. 
Ces `Series` sont des objets d'une dimension qui sont des extensions des
array-unidimensionnels `numpy`. En particulier, pour faciliter le traitement
de données catégorielles ou temporelles, des types de variables
supplémentaires sont disponibles dans `pandas` par rapport à
`numpy` (`categorical`, `datetime64` et `timedelta64`). Ces
types sont associés à des méthodes optimisées pour faciliter le traitement
de ces données. 

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
on utilise la méthode `values`: `taille.values`


### Créer un DataFrame pandas

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


## Propriétés d'un DataFrame pandas

```python
df = pd.read_csv("https://koumoul.com/s/data-fair/api/v1/datasets/igt-pouvoir-de-rechauffement-global/convert")
```


### Les attributs et méthodes utiles

```python
df.shape
df.head()
df.columns
df.count()
df.describe()
```

+ dtype

:warning: `head` dans un notebook avec des données confidentielles et `git`


Les méthodes par défaut de graphique (approfondies dans le chapitre matplotlib/seaborn)

```python
df['Déchets'].plot()
df['Déchets'].hist()
df['Déchets'].plot(kind = 'hist', logy = True)
```

## Principales manipulation de données

Equivalent des 5 verbes du tidyverse + groupBy

## Import d'un fichier plat


## Calculs à partir de données

## Filtrer et réassigner


## Modifier un dataframe

### Créer des colonnes à partir d'autres

### Appliquer des fonctions

# Joindre

Jointure avec données communales (pour avoir population)

# Reordonner

# Indexation et performance

Ouverture sur dask?