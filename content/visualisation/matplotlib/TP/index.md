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
## <seaborn.axisgrid.FacetGrid object at 0x000000002F0CC4A8>
```

{{<figure src="unnamed-chunk-7-1.png" >}}




Si vous désirez colorer en rouge l'axe des `x`, vous pouvez pré-définir un
style avec `sns.set_style("ticks", {"xtick.color": "red"})`


```
## <seaborn.axisgrid.FacetGrid object at 0x000000002F167CC0>
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
4. Refaire le graphique *Comptages vélo au cours des 7 derniers jours * (de l'échantillon)


```
## <seaborn.axisgrid.FacetGrid object at 0x000000002F1CAF60>
```

{{<figure src="unnamed-chunk-11-1.png" >}}



```
## <seaborn.axisgrid.FacetGrid object at 0x000000002F1DB320>
```

{{<figure src="unnamed-chunk-12-1.png" >}}


{{<figure src="unnamed-chunk-13-1.png" >}}




## `plotly`





The plotly Python package exists to create, manipulate and render graphical figures (i.e. charts, plots, maps and diagrams) represented by data structures also referred to as figures. The rendering process uses the Plotly.js JavaScript library under the hood although Python developers using this module very rarely need to interact with the Javascript library directly, if ever. Figures can be represented in Python either as dicts or as instances of the plotly.graph_objects.Figure class, and are serialized as text in JavaScript Object Notation (JSON) before being passed to Plotly.js.

    Note: the recommended entry-point into the plotly package is the high-level plotly.express module, also known as Plotly Express, which consists of Python functions which return fully-populated plotly.graph_objects.Figure objects. This page exists to document the architecture of the data structure that these objects represent, for users who wish to understand more about how to customize them, or assemble them from other plotly.graph_objects components.

https://plotly.com/python/plotly-express/




{{< rawhtml >}}
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script> 
<!--html_preserve--><html>
<head><meta charset="utf-8" /></head>
<body>
    <div>                            <div id="ce16e7f6-5a3d-43d0-bc2f-2d0ca0cf42d1" class="plotly-graph-div" style="height:100%; width:100%;"></div>            <script type="text/javascript">                                    window.PLOTLYENV=window.PLOTLYENV || {};                                    if (document.getElementById("ce16e7f6-5a3d-43d0-bc2f-2d0ca0cf42d1")) {                    Plotly.newPlot(                        "ce16e7f6-5a3d-43d0-bc2f-2d0ca0cf42d1",                        [{"alignmentgroup": "True", "hovertemplate": "Comptage horaire=%{x}<br>Nom du compteur=%{y}<extra></extra>", "legendgroup": "", "marker": {"color": "red"}, "name": "", "offsetgroup": "", "orientation": "h", "showlegend": false, "textposition": "auto", "type": "bar", "x": [109.46284691136974, 117.18064259425047, 117.73088381330685, 119.20801830481496, 124.39136490250696, 137.19387247587784, 140.21979211779993, 144.30319307669353, 147.89994441356308, 197.23860689144126], "xaxis": "x", "y": ["26 boulevard de M\u00e9nilmontant SE-NO", "35 boulevard de Menilmontant NO-SE", "21 boulevard Saint Michel S-N", "67 boulevard Voltaire SE-NO", "72 boulevard Voltaire NO-SE", "102 boulevard de Magenta SE-NO", "Totem 64 Rue de Rivoli O-E", "89 boulevard de Magenta NO-SE", "Totem 73 boulevard de S\u00e9bastopol N-S", "Totem 73 boulevard de S\u00e9bastopol S-N"], "yaxis": "y"}],                        {"barmode": "relative", "legend": {"tracegroupgap": 0}, "margin": {"t": 60}, "template": {"data": {"bar": [{"error_x": {"color": "#2a3f5f"}, "error_y": {"color": "#2a3f5f"}, "marker": {"line": {"color": "#E5ECF6", "width": 0.5}}, "type": "bar"}], "barpolar": [{"marker": {"line": {"color": "#E5ECF6", "width": 0.5}}, "type": "barpolar"}], "carpet": [{"aaxis": {"endlinecolor": "#2a3f5f", "gridcolor": "white", "linecolor": "white", "minorgridcolor": "white", "startlinecolor": "#2a3f5f"}, "baxis": {"endlinecolor": "#2a3f5f", "gridcolor": "white", "linecolor": "white", "minorgridcolor": "white", "startlinecolor": "#2a3f5f"}, "type": "carpet"}], "choropleth": [{"colorbar": {"outlinewidth": 0, "ticks": ""}, "type": "choropleth"}], "contour": [{"colorbar": {"outlinewidth": 0, "ticks": ""}, "colorscale": [[0.0, "#0d0887"], [0.1111111111111111, "#46039f"], [0.2222222222222222, "#7201a8"], [0.3333333333333333, "#9c179e"], [0.4444444444444444, "#bd3786"], [0.5555555555555556, "#d8576b"], [0.6666666666666666, "#ed7953"], [0.7777777777777778, "#fb9f3a"], [0.8888888888888888, "#fdca26"], [1.0, "#f0f921"]], "type": "contour"}], "contourcarpet": [{"colorbar": {"outlinewidth": 0, "ticks": ""}, "type": "contourcarpet"}], "heatmap": [{"colorbar": {"outlinewidth": 0, "ticks": ""}, "colorscale": [[0.0, "#0d0887"], [0.1111111111111111, "#46039f"], [0.2222222222222222, "#7201a8"], [0.3333333333333333, "#9c179e"], [0.4444444444444444, "#bd3786"], [0.5555555555555556, "#d8576b"], [0.6666666666666666, "#ed7953"], [0.7777777777777778, "#fb9f3a"], [0.8888888888888888, "#fdca26"], [1.0, "#f0f921"]], "type": "heatmap"}], "heatmapgl": [{"colorbar": {"outlinewidth": 0, "ticks": ""}, "colorscale": [[0.0, "#0d0887"], [0.1111111111111111, "#46039f"], [0.2222222222222222, "#7201a8"], [0.3333333333333333, "#9c179e"], [0.4444444444444444, "#bd3786"], [0.5555555555555556, "#d8576b"], [0.6666666666666666, "#ed7953"], [0.7777777777777778, "#fb9f3a"], [0.8888888888888888, "#fdca26"], [1.0, "#f0f921"]], "type": "heatmapgl"}], "histogram": [{"marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "histogram"}], "histogram2d": [{"colorbar": {"outlinewidth": 0, "ticks": ""}, "colorscale": [[0.0, "#0d0887"], [0.1111111111111111, "#46039f"], [0.2222222222222222, "#7201a8"], [0.3333333333333333, "#9c179e"], [0.4444444444444444, "#bd3786"], [0.5555555555555556, "#d8576b"], [0.6666666666666666, "#ed7953"], [0.7777777777777778, "#fb9f3a"], [0.8888888888888888, "#fdca26"], [1.0, "#f0f921"]], "type": "histogram2d"}], "histogram2dcontour": [{"colorbar": {"outlinewidth": 0, "ticks": ""}, "colorscale": [[0.0, "#0d0887"], [0.1111111111111111, "#46039f"], [0.2222222222222222, "#7201a8"], [0.3333333333333333, "#9c179e"], [0.4444444444444444, "#bd3786"], [0.5555555555555556, "#d8576b"], [0.6666666666666666, "#ed7953"], [0.7777777777777778, "#fb9f3a"], [0.8888888888888888, "#fdca26"], [1.0, "#f0f921"]], "type": "histogram2dcontour"}], "mesh3d": [{"colorbar": {"outlinewidth": 0, "ticks": ""}, "type": "mesh3d"}], "parcoords": [{"line": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "parcoords"}], "pie": [{"automargin": true, "type": "pie"}], "scatter": [{"marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "scatter"}], "scatter3d": [{"line": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "scatter3d"}], "scattercarpet": [{"marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "scattercarpet"}], "scattergeo": [{"marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "scattergeo"}], "scattergl": [{"marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "scattergl"}], "scattermapbox": [{"marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "scattermapbox"}], "scatterpolar": [{"marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "scatterpolar"}], "scatterpolargl": [{"marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "scatterpolargl"}], "scatterternary": [{"marker": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "type": "scatterternary"}], "surface": [{"colorbar": {"outlinewidth": 0, "ticks": ""}, "colorscale": [[0.0, "#0d0887"], [0.1111111111111111, "#46039f"], [0.2222222222222222, "#7201a8"], [0.3333333333333333, "#9c179e"], [0.4444444444444444, "#bd3786"], [0.5555555555555556, "#d8576b"], [0.6666666666666666, "#ed7953"], [0.7777777777777778, "#fb9f3a"], [0.8888888888888888, "#fdca26"], [1.0, "#f0f921"]], "type": "surface"}], "table": [{"cells": {"fill": {"color": "#EBF0F8"}, "line": {"color": "white"}}, "header": {"fill": {"color": "#C8D4E3"}, "line": {"color": "white"}}, "type": "table"}]}, "layout": {"annotationdefaults": {"arrowcolor": "#2a3f5f", "arrowhead": 0, "arrowwidth": 1}, "coloraxis": {"colorbar": {"outlinewidth": 0, "ticks": ""}}, "colorscale": {"diverging": [[0, "#8e0152"], [0.1, "#c51b7d"], [0.2, "#de77ae"], [0.3, "#f1b6da"], [0.4, "#fde0ef"], [0.5, "#f7f7f7"], [0.6, "#e6f5d0"], [0.7, "#b8e186"], [0.8, "#7fbc41"], [0.9, "#4d9221"], [1, "#276419"]], "sequential": [[0.0, "#0d0887"], [0.1111111111111111, "#46039f"], [0.2222222222222222, "#7201a8"], [0.3333333333333333, "#9c179e"], [0.4444444444444444, "#bd3786"], [0.5555555555555556, "#d8576b"], [0.6666666666666666, "#ed7953"], [0.7777777777777778, "#fb9f3a"], [0.8888888888888888, "#fdca26"], [1.0, "#f0f921"]], "sequentialminus": [[0.0, "#0d0887"], [0.1111111111111111, "#46039f"], [0.2222222222222222, "#7201a8"], [0.3333333333333333, "#9c179e"], [0.4444444444444444, "#bd3786"], [0.5555555555555556, "#d8576b"], [0.6666666666666666, "#ed7953"], [0.7777777777777778, "#fb9f3a"], [0.8888888888888888, "#fdca26"], [1.0, "#f0f921"]]}, "colorway": ["#636efa", "#EF553B", "#00cc96", "#ab63fa", "#FFA15A", "#19d3f3", "#FF6692", "#B6E880", "#FF97FF", "#FECB52"], "font": {"color": "#2a3f5f"}, "geo": {"bgcolor": "white", "lakecolor": "white", "landcolor": "#E5ECF6", "showlakes": true, "showland": true, "subunitcolor": "white"}, "hoverlabel": {"align": "left"}, "hovermode": "closest", "mapbox": {"style": "light"}, "paper_bgcolor": "white", "plot_bgcolor": "#E5ECF6", "polar": {"angularaxis": {"gridcolor": "white", "linecolor": "white", "ticks": ""}, "bgcolor": "#E5ECF6", "radialaxis": {"gridcolor": "white", "linecolor": "white", "ticks": ""}}, "scene": {"xaxis": {"backgroundcolor": "#E5ECF6", "gridcolor": "white", "gridwidth": 2, "linecolor": "white", "showbackground": true, "ticks": "", "zerolinecolor": "white"}, "yaxis": {"backgroundcolor": "#E5ECF6", "gridcolor": "white", "gridwidth": 2, "linecolor": "white", "showbackground": true, "ticks": "", "zerolinecolor": "white"}, "zaxis": {"backgroundcolor": "#E5ECF6", "gridcolor": "white", "gridwidth": 2, "linecolor": "white", "showbackground": true, "ticks": "", "zerolinecolor": "white"}}, "shapedefaults": {"line": {"color": "#2a3f5f"}}, "ternary": {"aaxis": {"gridcolor": "white", "linecolor": "white", "ticks": ""}, "baxis": {"gridcolor": "white", "linecolor": "white", "ticks": ""}, "bgcolor": "#E5ECF6", "caxis": {"gridcolor": "white", "linecolor": "white", "ticks": ""}}, "title": {"x": 0.05}, "xaxis": {"automargin": true, "gridcolor": "white", "linecolor": "white", "ticks": "", "title": {"standoff": 15}, "zerolinecolor": "white", "zerolinewidth": 2}, "yaxis": {"automargin": true, "gridcolor": "white", "linecolor": "white", "ticks": "", "title": {"standoff": 15}, "zerolinecolor": "white", "zerolinewidth": 2}}}, "xaxis": {"anchor": "y", "domain": [0.0, 1.0], "title": {"text": "Comptage horaire"}}, "yaxis": {"anchor": "x", "domain": [0.0, 1.0], "title": {"text": "Nom du compteur"}}},                        {"responsive": true}                    )                };                            </script>        </div>
</body>
</html><!--/html_preserve-->
{{< /rawhtml >}}
