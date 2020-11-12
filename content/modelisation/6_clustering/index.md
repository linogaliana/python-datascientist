---
jupyter:
  jupytext:
    text_representation:
      extension: .Rmd
      format_name: rmarkdown
      format_version: '1.2'
      jupytext_version: 1.6.0
  kernelspec:
    display_name: Python 3
    language: python
    name: python3
title: "Clustering"
date: 2020-10-15T13:00:00Z
draft: false
weight: 50
output: 
  html_document:
    keep_md: true
    self_contained: true
slug: lasso
---






Nous allons partir du jeu de données de [résultat des élections US 2016 au niveau des comtés](https://public.opendatasoft.com/explore/dataset/usa-2016-presidential-election-by-county/download/?format=geojson&timezone=Europe/Berlin&lang=fr)

Jusqu'à présent, nous avons fait de l'apprentissage supervisé puisque nous connaissions la variable à expliquer/prédire. Ce n'est plus le cas avec l'apprentissage non supervisé.

Le *clustering* est un champ d'application de l'apprentissage non-supervisé. Il s'agit d'exploiter l'information disponible pour regrouper des observations à la structure commune ensemble. L'objectif est de créer des classes d'observations pour lesquelles:

* au sein de chaque classe, les observations sont homogènes (variance infra-classe minimale)
* les classes ont des profils hétérogènes, c'est-à-dire qu'elles se distinguent l'une de l'autre (variance inter-classes maximale)

En Machine Learning, les méthodes de classification sont très utilisées pour
faire de la recommandation. En faisant, par exemple, des classes homogènes de 
consommateur, il est plus facile d'identifier et cibler des comportements 
propres à chaque classe. 
Ces méthodes ont également un intérêt en économie et sciences sociales parce qu'elles permettent
de regrouper des observations sans *a priori* et ainsi interpréter une variable
d'intérêt à l'aune de ces résultats. Ce [travail (très) récent](https://www.insee.fr/fr/statistiques/4925200)
utilise par exemple cette approche.


Les méthodes de *clustering* sont nombreuses.
Nous allons exclusivement nous pencher sur la plus intuitive: les k-means. 

## Principe

L'objectif des kmeans est de partitioner l'espace d'observations en trouvant des points (*centroids*) qui permettent de créer des centres de gravité autour pour lesquels les observations proches peuvent être regroupés dans une classe homogène

![](https://scikit-learn.org/stable/_images/sphx_glr_plot_kmeans_assumptions_001.png)

{{% panel status="hint" title="Hint" icon="fa fa-lightbulb" %}}
L'objectif des *kmeans* est de trouver un ensemble une partition des données $S=\{S_1,...,S_K\}$ telle que 
$$
\arg\min_{S} \sum_{i=1}^K \sum_{x \in S_i} ||x - \mu_i||^2
$$
avec $\mu_i$ la moyenne des $x_i$ dans l'ensemble de points $S_i$
{{% /panel %}}



{{% panel status="exercise" title="Exercise 1: principe du kmeans" icon="fas fa-pencil-alt" %}}
1. Importer les données (l'appeler `df`) et de restreindre aux variables `'unemployment', 'median_age', 'total_population', 'black', 'asian', 'white_not_latino_population', 'median_earnings_2010_dollars'` et bien-sûr  `'rep16_frac'`
2. Faire un kmeans avec $k=4$
3. Créer une variable supplémentaire stockant le résultat de la typologie
4. Choisir deux variables et représenter le nuage de point en colorant différemment
en fonction du label obtenu
5. Représenter la distribution du vote pour chaque *cluster*

{{% /panel %}}





```
## KMeans(n_clusters=4)
```




{{<figure src="unnamed-chunk-3-1.png" >}}



```
## <seaborn.axisgrid.FacetGrid object at 0x000000000622C790>
```

Le package `yellowbrick` fournit une extension utile à `scikit`




{{<figure src="unnamed-chunk-5-1.png" >}}
