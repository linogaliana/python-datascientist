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
weight: 60
output: 
  html_document:
    keep_md: true
    self_contained: true
slug: clustering
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




{{<figure src="unnamed-chunk-4-1.png" >}}





```
## <seaborn.axisgrid.FacetGrid object at 0x000000000B1C4460>
```

{{<figure src="unnamed-chunk-6-1.png" >}}


## Choisir le nombre de classes

Le nombre de classes est fixé par hypothèse du modélisateur. Il y a un arbitrage
entre biais et variance. Un grand nombre de classes implique une variance
infra-classe très faible. Avec beaucoup de classes, on tend à sur-apprendre, ce
qui est mauvais pour la prédiction (même s'il n'est jamais possible de déterminer
le vrai type d'une observation puisqu'on est en apprentissage non supervisé). 

Si le nombre de classes à fixer est inconnu (il n'y a pas d'hypothèses de
modélisation qui justifient plus ou moins de classes), il existe des méthodes
statistiques:

* Méthode du coude (*elbow method*): on prend le point d'inflexion de la courbe
de performance du modèle. Cela représente le moment où ajouter une classe
(complexité croissante du modèle) n'apporte que des gains modérer dans la 
modélisation des données
* Score de silhouette: mesure de similarité entre un point et les autres points
du cluster par rapport aux autres clusters. Moins succinctement:

> Silhouette value is a measure of how similar an object is to its own cluster
> (cohesion) compared to other clusters (separation). The silhouette ranges
> from −1 to +1, where a high value indicates that the object is
> well matched to its own cluster and poorly matched to neighboring
> clusters. If most objects have a high value, then the clustering
> configuration is appropriate. If many points have a low or negative
> value, then the clustering configuration may have too many or too few clusters
> 
> Source: [Wikipedia](https://en.wikipedia.org/wiki/Silhouette_(clustering))

Le package `yellowbrick` fournit une extension utile à `scikit` pour représenter
facilement la performance en *clustering*.

Pour la méthode du coude, la courbe
de performance du modèle marque un coude léger à $k=4$. Le modèle initial
semblait donc approprié.


```python
from yellowbrick.cluster import KElbowVisualizer
visualizer = KElbowVisualizer(model, k=(2,12))
visualizer.fit(df2[xvars])        # Fit the data to the visualizer
```

```
## KElbowVisualizer(ax=<AxesSubplot:>, k=None, model=None)
## 
## C:\Users\W3CRK9\AppData\Local\R-MINI~1\envs\R-RETI~1\lib\site-packages\sklearn\base.py:209: FutureWarning: From version 0.24, get_params will raise an AttributeError if a parameter cannot be retrieved as an instance attribute. Previously it would return None.
##   warnings.warn('From version 0.24, get_params will raise an '
```

```python
visualizer.show()        # Finalize and render the figure
```

{{<figure src="elbow-1.png" >}}
{{<figure src="elbow-2.png" >}}

`yellowbrick` permet également de représenter des silhouettes mais 
l'interprétation en est moins aisée:
  


{{<figure src="unnamed-chunk-7-1.png" >}}
