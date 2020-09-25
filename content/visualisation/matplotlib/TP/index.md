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
title: "De beaux graphiques avec python: mise en pratique"
date: 2020-09-24T13:00:00Z
draft: false
weight: 10
output: 
  html_document:
    keep_md: true
    self_contained: true
slug: matplotlibTP
---






La pratique de la visualisation se fera, dans ce cours, en répliquant des graphiques qu'on peut trouver sur
la page de l'*open-data* de la ville de Paris 
[ici](https://opendata.paris.fr/explore/dataset/comptage-velo-donnees-compteurs/information/?disjunctive.id_compteur&disjunctive.nom_compteur&disjunctive.id&disjunctive.name).

Ce TP vise à initier:

* Aux packages [matplotlib](https://matplotlib.org/) et
[seaborn](https://seaborn.pydata.org/) pour la construction de graphiques figés
* Au package [plotly](https://plotly.com/python/) pour les graphiques 
dynamiques, au format HTML

Nous verrons par la suite la manière de construire des cartes facilement avec
des formats équivalents.

Un sous-ensemble des données de [paris open data](https://opendata.paris.fr/explore/dataset/comptage-velo-donnees-compteurs/information/?disjunctive.id_compteur&disjunctive.nom_compteur&disjunctive.id&disjunctive.name) a été mis à disposition
sur <a href="https://github.com/linogaliana/python-datascientist/blob/master/data/bike.csv" class="github"><i class="fab fa-github"></i></a> pour faciliter l'import (élimination des colonnes
qui ne nous servirons pas mais ralentissent l'import)



## Premier graphique avec l'API `matplotlib` de `pandas`

**Exercice 1: Importer les données et produire un premier graphique**

1.. Importer les données `velib`. Attention, il s'agit de données
compressées au format `gzip`, il faut donc utiliser l'option `compression`
2. En premier lieu, sans se préoccuper des éléments de style ni des labels des
graphiques, reproduire les deux premiers graphiques de la
[page d'analyse des données](https://opendata.paris.fr/explore/dataset/comptage-velo-donnees-compteurs/dataviz/?disjunctive.id_compteur&disjunctive.nom_compteur&disjunctive.id&disjunctive.name):
*Les 10 compteurs avec la moyenne horaire la plus élevée* et *Les 10 compteurs ayant comptabilisés le plus de vélos*.

*Conseil*: Pour obtenir un graphique ordonné du plus grand au plus petit, il faut avoir les données ordonnées du plus petit au
plus grand. C'est bizarre mais c'est comme ça...




{{<figure src="unnamed-chunk-4-1.png" >}}

{{<figure src="unnamed-chunk-5-1.png" >}}

On peut remarquer plusieurs éléments problématiques (par exemple les labels) mais
aussi des éléments ne correspondant pas (les titres des axes, etc.) ou 
manquants (le nom du graphique...)

Comme les graphiques produits par `pandas` suivent la logique très flexible
de `matplotlib`, il est possible de les customiser. Cependant, c'est
souvent beaucoup de travail et il peut être préférable de directement
utiliser *seaborn*, qui offre quelques arguments prêts à l'emploi


## Utiliser directement `seaborn`

Vous pouvez repartir des deux dataframes précédents. On va suppose qu'ils se
nomment `df1` et `df2`. Réinitialiser l'index pour avoir une colonne 
*'Nom du compteur'*



**Exercice 2: un peu de style**

Il y a plusieurs manières de faire un *bar* plot en `seaborn`. La plus flexible,
c'est-à-dire celle qui permet le mieux d'interagir avec `matplotlib` est
`catplot`
 
1. Refaire le graphique précédent avec la fonction adéquate de `seaborn`. Pour
contrôler la taille du graphique vous pouvez utiliser les arguments `height` et
`aspect`
2. Ajouter les titres des axes et le titre du graphique pour le premier graphique


```
## <seaborn.axisgrid.FacetGrid object at 0x000000002F12A2B0>
```

{{<figure src="unnamed-chunk-7-1.png" >}}




Si vous désirez colorer en rouge l'axe des `x`, vous pouvez pré-définir un
style avec `sns.set_style("ticks", {"xtick.color": "red"})`


```
## <seaborn.axisgrid.FacetGrid object at 0x000000002F1DC240>
```

{{<figure src="unnamed-chunk-9-1.png" >}}

**Exercice 3: refaire les graphiques**

Certaines opérations vont nécessiter un peu d'agilité dans la gestion des dates.
Avant cela, il faut créer une variable temporelle (`datetime`). Pour cela, vous
pouvez faire:


.to_period('M')

1. Refaire le graphique *Les 10 compteurs ayant comptabilisés le plus de vélos *
2. Refaire le graphique *Moyenne mensuelle des comptages vélos *. Pour cela,
vous pouvez utiliser `.dt.to_period('M')` pour transformer un timestamp 
en variable de mois
3. Refaire le graphique *Moyenne journalière des comptages vélos* (créer d'abord
une variable de jour avec `.dt.day`)
4. Refaire le graphique *Comptages vélo au cours des 7 derniers jours *


```
## <seaborn.axisgrid.FacetGrid object at 0x000000002F226668>
```

{{<figure src="unnamed-chunk-11-1.png" >}}



```
## <seaborn.axisgrid.FacetGrid object at 0x000000002F241E10>
```

{{<figure src="unnamed-chunk-12-1.png" >}}



{{<figure src="unnamed-chunk-13-1.png" >}}

## `plotly`
