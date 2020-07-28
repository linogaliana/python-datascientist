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
* 

:warning: `pandas` offre la possibilité d'importer des données directement depuis un url. C'est l'option
prise dans ce tutoriel.
Si vous préfèrez, pour des
raisons d'accès au réseau ou de performance, importer depuis un poste local, télécharger les données et changer
les commandes d'import avec le chemin adéquat plutôt que l'url. 


## Propriétés d'un DataFrame pandas

```python
df = pd.read_csv("https://koumoul.com/s/data-fair/api/v1/datasets/igt-pouvoir-de-rechauffement-global/convert")
```

### Logique de pandas

Concept de `Series`

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