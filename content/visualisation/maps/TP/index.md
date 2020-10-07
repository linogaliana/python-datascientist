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
title: "De belles cartes avec python: mise en pratique"
date: 2020-10-06T13:00:00Z
draft: false
weight: 20
output: 
  html_document:
    keep_md: true
    self_contained: true
slug: matplotlibTP
---






La pratique de la cartographie se fera, dans ce cours, en répliquant des cartes qu'on peut trouver sur
la page de l'*open-data* de la ville de Paris 
[ici](https://opendata.paris.fr/explore/dataset/comptage-velo-donnees-compteurs/information/?disjunctive.id_compteur&disjunctive.nom_compteur&disjunctive.id&disjunctive.name).

{{% panel status="note" title="Note" icon="fa fa-comment" %}}
Produire de belles cartes demande du temps mais aussi du bon sens. En fonction de la structure des données, certaines représentations sont à éviter voire à exclure. L'excellent guide [disponible ici](https://juliedjidji.github.io/memocarto/semio.html) propose quelques règles et évoque les erreurs à éviter lorsqu'on désire effectuer des
représentations spatiales. 
{{% /panel %}}



Ce TP vise à initier:

* Au module graphique de [geopandas](https://geopandas.org/mapping.html) ainsi qu'aux packages [geoplot](https://residentmario.github.io/geoplot/index.html) et
[contextily](https://contextily.readthedocs.io/en/latest/intro_guide.html) pour la construction de cartes figées. `geoplot` est construit sur `seaborn` et constitue ainsi une extension des graphiques de base.
* Au package [folium](https://python-visualization.github.io/folium/) qui est un point d'accès vers la librairie JavaScript [leaflet](https://leafletjs.com/) permettant de produire des cartes interactives


Les données utilisées sont :

* Un sous-ensemble des données de [paris open data](https://opendata.paris.fr/explore/dataset/comptage-velo-donnees-compteurs/information/?disjunctive.id_compteur&disjunctive.nom_compteur&disjunctive.id&disjunctive.name) a été mis à disposition
sur <a href="https://github.com/linogaliana/python-datascientist/blob/master/data/bike.csv" class="github"><i class="fab fa-github"></i></a> pour faciliter l'import (élimination des colonnes
qui ne nous servirons pas mais ralentissent l'import)
* [La localisation précise des stations](https://parisdata.opendatasoft.com/explore/dataset/comptage-velo-compteurs/download/?format=geojson&timezone=Europe/Berlin&lang=fr)
* [Arrondissements parisiens](https://opendata.paris.fr/explore/dataset/arrondissements/download/?format=geojson&timezone=Europe/Berlin&lang=fr)

Dans la première partie, nous allons utiliser les packages suivants:


```python
import pandas as pd
import geopandas as gpd
import contextily as ctx
import geoplot
import matplotlib.pyplot as plt
import folium
```

{{% panel status="warning" title="Warning" icon="fa fa-exclamation-triangle" %}}
Certaines librairies géographiques dépendent de `rtree` qui est parfois difficile à installer. Pour installer `rtree`, le mieux est d'utiliser `anaconda`:

~~~python
conda install rtree --yes
~~~
{{% /panel %}}


## Première carte avec l'API `matplotlib` de `geopandas`

{{% panel status="exercise" title="Exercice 1: Importer les données"
icon="fas fa-pencil-alt" %}}

Importer les données de compteurs de vélos en deux temps.

1. D'abord, les comptages peuvent être trouvés à l'adresse <https://github.com/linogaliana/python-datascientist/raw/master/data/bike.csv>. :warning: Il s'agit de données
compressées au format `gzip`, il faut donc utiliser l'option `compression`. Nommer cet objet `comptages`
2. Importer les données de localisation des compteurs à partir de l'url <https://parisdata.opendatasoft.com/explore/dataset/comptage-velo-compteurs/download/?format=geojson&timezone=Europe/Berlin&lang=fr>. Nommer cet objet `compteurs`
3. On va également utiliser les données d'arrondissements de la ville de Paris. Importer ces données depuis <https://opendata.paris.fr/explore/dataset/arrondissements/download/?format=geojson&timezone=Europe/Berlin&lang=fr>
4. Utiliser la méthode `plot` pour représenter les localisations des compteurs dans l'espace. C'est, on peut l'avouer, peu informatif sans apport extérieur. Il va donc falloir travailler un peu l'esthétique
{{< /panel >}}



{{% panel status="warning" title="Warning" icon="fa fa-exclamation-triangle" %}}
On serait tenté de faire un *merge* de la base compteurs et comptages. En l'occurrence, il s'agirait d'un produit cartésien puisqu'il s'agit de faire exploser la base spatiale. Avec des données spatiales, c'est souvent une très mauvaise idée. Cela duplique les points, créant des difficultés à représenter les données mais aussi ralentit les calculs. Sauf à utiliser la méthode `dissolve` (qui va agréger *k* fois la même géométrie...), les géométries sont perdues lorsqu'on effectuer des `groupby`.  
3. 
{{% /panel %}}




Maintenant, tout est prêt pour une première carte. `matplotlib` fonctionne selon
le principe des couches. On va de la couche la plus lointaine à celle le plus
en surface. L'exception est lorsqu'on ajoute un fond de carte `contextily` via
`ctx.add_basemap`: on met cet appel en dernier. 


{{% panel status="exercise" title="Exercice 2: première carte"
icon="fas fa-pencil-alt" %}}

Représenter une carte avec le fonds de carte des arrondissements.

1. Faire attention à avoir des arrondissements dont l'intérieur est transparent (argument à utiliser: `facecolor`). Faire des bordures d'arrondissements noir. Pour obtenir un graphique plus grand, vous pouvez utiliser l'argument `figsize = (10,10)`
2. Pour les localisations, les points doivent être rouges en étant plus transparent au centre (argument à utiliser: `alpha`) 
{{< /panel >}}

Vous devriez obtenir cette carte:

{{<figure src="exo2-1.png" >}}


{{% panel status="exercise" title="Exercice 3: Ajouter un fonds de carte avec contextily"
icon="fas fa-pencil-alt" %}}

Repartir de la carte précédente.

1. Utiliser `ctx.add_basemap` pour ajouter un fonds de carte. :warning: Par défaut, `contextily` désire un système de projection (crs) qui est le *Web Mercator* (epsg: 3857). Il faut changer la valeur de l'argument `crs`. Avec les versions anciennes de l'ENSAE, il faut utiliser `.to_string` sur un objet CRS pour qu'il soit reconnu par `contextily`. Sur des versions récentes, la valeur numérique du code EPSG est suffisante. Pour ne pas afficher les axes, vous pouvez utiliser `ax.set_axis_off()`
2. Trouver un fonds de carte plus esthétique, qui permette de visualiser les grands axes, parmi ceux possibles. Pour tester l'esthétique, vous pouvez utiliser [cet url](http://leaflet-extras.github.io/leaflet-providers/preview/index.html). La documentation de référence sur les tuiles disponibles est [ici](https://contextily.readthedocs.io/en/latest/providers_deepdive.html) 
{{< /panel >}}


```
## <AxesSubplot:>
```

{{<figure src="exo3-1.png" >}}


Pour le moment, la fonction  `geoplot.kdeplot` n'incorpore pas toutes les fonctionalités de `seaborn.kdeplot`. Pour être en mesure de construire une `heatmap` avec des données pondérées (cf. [cette issue dans le dépôt seaborn](https://github.com/mwaskom/seaborn/issues/1364)), il y a une astuce. Il faut simuler *k* points de valeur 1 autour de la localisation observée. La fonction ci-dessous, qui m'a été bien utile, est pratique

~~~markdown
def expand_points(shapefile,
                  index_var = "grid_id",
                  weight_var = 'prop',
                  radius_sd = 100,
                  crs = 2154):
    """
    Multiply number of points to be able to have a weighted heatmap
    :param shapefile: Shapefile to consider
    :param index_var: Variable name to set index
    :param weight_var: Variable that should be used
    :param radius_sd: Standard deviation for the radius of the jitter
    :param crs: Projection system that should be used. Recommended option
      is Lambert 93 because points will be jitterized using meters
    :return:
      A geopandas point object with as many points by index as weight
    """

    shpcopy = shapefile
    shpcopy = shpcopy.set_index(index_var)
    shpcopy['npoints'] = np.ceil(shpcopy[weight_var])
    shpcopy['geometry'] = shpcopy['geometry'].centroid
    shpcopy['x'] = shpcopy.geometry.x
    shpcopy['y'] = shpcopy.geometry.y
    shpcopy = shpcopy.to_crs(crs)
    shpcopy = shpcopy.loc[np.repeat(shpcopy.index.values, shpcopy.npoints)]
    shpcopy['x'] = shpcopy['x'] + np.random.normal(0, radius_sd, shpcopy.shape[0])
    shpcopy['y'] = shpcopy['y'] + np.random.normal(0, radius_sd, shpcopy.shape[0])

    gdf = gpd.GeoDataFrame(
        shpcopy,
        geometry = gpd.points_from_xy(shpcopy.x, shpcopy.y),
        crs = crs)

    return gdf
~~~


{{% panel status="exercise" title="Exercice 4: Data cleaning avant de pouvoir faire une heatmap"
icon="fas fa-pencil-alt" %}}
1. Calculer le trafic moyen, pour chaque station, entre 7 heures et 10 heures (bornes incluses) et nommer cet objet `df1`. Faire la même chose, en nommant `df2`, pour le trafic entre 17 et 20 heures (bornes incluses)
1. Essayer de comprendre ce que fait la fonction `expand_points`
2. Créer une fonction qui suive les étapes suivantes:
  + Convertit un DataFrame dans le système de projection Lambert 93 (epsg: 2154)
  + Applique la fonction `expand_points` avec les noms de variable adéquats. Vous pouvez fixer la valeur de `radius_sd` à `100`. 
  + Reconvertit l'output au format WGS 84 (epsg: 4326)
3. Appliquer cette fonction à `df1` et `df2`

{{< /panel >}}






Le principe de la *heatmap* est de construire, à partir d'un nuage de point bidimensionnel, une distribution 2D lissée. La méthode repose sur les estimateurs à noyaux qui sont des méthodes de lissage local. 


{{% panel status="exercise" title="Exercice 5: Heatmap, enfin" icon="fas fa-pencil-alt" %}}

Représenter, pour ces deux moments de la journée, la `heatmap` du trafic de vélo avec `geoplot.kdeplot`. Pour cela,

1. Appliquer la fonction `geoplot.kdeplot` avec comme consigne:
    + d'utiliser les arguments `shade=True` et `shade_lowest=True` pour colorer l'intérieur des courbes de niveaux obtenues
    + d'utiliser une palette de couleur rouge avec une transparence modérée (`alpha = 0.6`)
    + d'utiliser l'argument `clip` pour ne pas déborder hors de Paris (en cas de doute, se référer à l'aide de `geoplot.kdeplot`)
    + L'argument *bandwidth* détermine le plus ou moins fort lissage spatial. La carte d'exemple est produite avec un bandwidth de `.005`. Vous pouvez utiliser celui-ci puis, dans un second temps, le faire varier pour voir l'effet sur le résultat 
2. Ne pas oublier d'ajouter les arrondissements. Avec `geoplot`, il faut utiliser `geoplot.polyplot`


{{< /panel >}}



```
## C:\Users\W3CRK9\AppData\Local\R-MINI~1\envs\R-RETI~1\lib\site-packages\seaborn\_decorators.py:36: FutureWarning: Pass the following variable as a keyword arg: y. From version 0.12, the only valid positional argument will be `data`, and passing other arguments without an explicit keyword will result in an error or misinterpretation.
##   warnings.warn(
## C:\Users\W3CRK9\AppData\Local\R-MINI~1\envs\R-RETI~1\lib\site-packages\seaborn\distributions.py:1659: FutureWarning: The `bw` parameter is deprecated in favor of `bw_method` and `bw_adjust`. Using 0.007 for `bw_method`, but please see the docs for the new parameters and update your code.
##   warnings.warn(msg, FutureWarning)
## C:\Users\W3CRK9\AppData\Local\R-MINI~1\envs\R-RETI~1\lib\site-packages\seaborn\distributions.py:1678: UserWarning: `shade_lowest` is now deprecated in favor of `thresh`. Setting `thresh=0`, but please update your code.
##   warnings.warn(msg, UserWarning)
```

{{<figure src="heatmap-1.png" >}}



## Des cartes réactives grâce à `folium`

De plus en plus de données de visualisation reposent sur la cartographie réactive. Que ce soit dans l'exploration des données ou dans la représentation finale de résultats, la cartographie réactive est très appréciable. 

`folium` offre une interface très flexible et très facile à prendre à main. Les cartes sont construites grâce à la librairie JavaScript `Leaflet.js` mais, sauf si on désire aller loin dans la customisation du résultat, il n'est pas nécessaire d'avoir des notions dans le domaine. 


Un objet folium se construit par couche. La première est l'initialisation de la carte. Les couches suivantes sont les éléments à exhiber. 

{{% panel status="exercise" title="Exercice 6: Visualiser la localisation des stations" icon="fas fa-pencil-alt" %}}

A partir des données `compteurs`, représenter la localisation des stations. Les consignes sont:

* le centre de la carte s'obtient avec le morceau de code ci-dessous qui agrège l'ensemble des géométries, calcule le centroid et récupère la valeur sous forme de liste
* ne pas afficher le fonds de carte par défaut
* un zoom de départ de 12 (vous pouvez ensuite essayer d'autres zoom)

~~~python
compteurs['temp'] = 1
point_geom = compteurs.dissolve(by = "temp")
point_geom["x"] = point_geom.centroid.x
point_geom["y"] = point_geom.centroid.y
center = [point_geom.iloc[0].y, point_geom.iloc[0].x]
~~~

{{< /panel >}}



<!--html_preserve--><!DOCTYPE html>
<head>    
    <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
    
        <script>
            L_NO_TOUCH = false;
            L_DISABLE_3D = false;
        </script>
    
    <script src="https://cdn.jsdelivr.net/npm/leaflet@1.6.0/dist/leaflet.js"></script>
    <script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Leaflet.awesome-markers/2.0.2/leaflet.awesome-markers.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/leaflet@1.6.0/dist/leaflet.css"/>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css"/>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.6.3/css/font-awesome.min.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/Leaflet.awesome-markers/2.0.2/leaflet.awesome-markers.css"/>
    <link rel="stylesheet" href="https://rawcdn.githack.com/python-visualization/folium/master/folium/templates/leaflet.awesome.rotate.css"/>
    <style>html, body {width: 100%;height: 100%;margin: 0;padding: 0;}</style>
    <style>#map {position:absolute;top:0;bottom:0;right:0;left:0;}</style>
    
            <meta name="viewport" content="width=device-width,
                initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
            <style>
                #map_a76b914e522642db828e1d354e658498 {
                    position: relative;
                    width: 100.0%;
                    height: 100.0%;
                    left: 0.0%;
                    top: 0.0%;
                }
            </style>
        
</head>
<body>    
    
            <div class="folium-map" id="map_a76b914e522642db828e1d354e658498" ></div>
        
</body>
<script>    
    
            var map_a76b914e522642db828e1d354e658498 = L.map(
                "map_a76b914e522642db828e1d354e658498",
                {
                    center: [48.856972463768095, 2.343495594202899],
                    crs: L.CRS.EPSG3857,
                    zoom: 12,
                    zoomControl: true,
                    preferCanvas: false,
                }
            );

            

        
    
            var tile_layer_3c026f7b572a4e3f898feeaf067e1fe8 = L.tileLayer(
                "https://stamen-tiles-{s}.a.ssl.fastly.net/toner/{z}/{x}/{y}.png",
                {"attribution": "Map tiles by \u003ca href=\"http://stamen.com\"\u003eStamen Design\u003c/a\u003e, under \u003ca href=\"http://creativecommons.org/licenses/by/3.0\"\u003eCC BY 3.0\u003c/a\u003e. Data by \u0026copy; \u003ca href=\"http://openstreetmap.org\"\u003eOpenStreetMap\u003c/a\u003e, under \u003ca href=\"http://www.openstreetmap.org/copyright\"\u003eODbL\u003c/a\u003e.", "detectRetina": false, "maxNativeZoom": 18, "maxZoom": 18, "minZoom": 0, "noWrap": false, "opacity": 1, "subdomains": "abc", "tms": false}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
            var marker_016cf2f1641348b5ae956f85127015e5 = L.marker(
                [48.86149, 2.37376],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_fd675a3eeed54b508b5ccc8bba36338d = L.popup({"maxWidth": "100%"});

        
            var html_c2b73ffe80c543bab8de6a38233ffc9a = $(`<div id="html_c2b73ffe80c543bab8de6a38233ffc9a" style="width: 100.0%; height: 100.0%;">67 boulevard Voltaire SE-NO</div>`)[0];
            popup_fd675a3eeed54b508b5ccc8bba36338d.setContent(html_c2b73ffe80c543bab8de6a38233ffc9a);
        

        marker_016cf2f1641348b5ae956f85127015e5.bindPopup(popup_fd675a3eeed54b508b5ccc8bba36338d)
        ;

        
    
    
            var marker_23c0f669893e4cb3906c39b70eb6d4e1 = L.marker(
                [48.830449, 2.353199],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_19e8027710d04b5088cb45c363256ff2 = L.popup({"maxWidth": "100%"});

        
            var html_a18743975f164dd18ed8a6ed6dddf6dc = $(`<div id="html_a18743975f164dd18ed8a6ed6dddf6dc" style="width: 100.0%; height: 100.0%;">21 boulevard Auguste Blanqui SO-NE</div>`)[0];
            popup_19e8027710d04b5088cb45c363256ff2.setContent(html_a18743975f164dd18ed8a6ed6dddf6dc);
        

        marker_23c0f669893e4cb3906c39b70eb6d4e1.bindPopup(popup_19e8027710d04b5088cb45c363256ff2)
        ;

        
    
    
            var marker_a2d111f1f4254fc0b700af7b243f9573 = L.marker(
                [48.83992, 2.26694],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_5aa88cb8f63249daa11af3e90b682f0c = L.popup({"maxWidth": "100%"});

        
            var html_5dfcb2aa1eb24df2a2fd85bd719f7cdc = $(`<div id="html_5dfcb2aa1eb24df2a2fd85bd719f7cdc" style="width: 100.0%; height: 100.0%;">Pont du Garigliano SE-NO SE-NO</div>`)[0];
            popup_5aa88cb8f63249daa11af3e90b682f0c.setContent(html_5dfcb2aa1eb24df2a2fd85bd719f7cdc);
        

        marker_a2d111f1f4254fc0b700af7b243f9573.bindPopup(popup_5aa88cb8f63249daa11af3e90b682f0c)
        ;

        
    
    
            var marker_7ef26762d16b46aca9faee6fdeef776e = L.marker(
                [48.840801, 2.333233],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_c2b212ba266a40eb9d701518f357c3b9 = L.popup({"maxWidth": "100%"});

        
            var html_9281aaa631ef41a69441da99f7143d87 = $(`<div id="html_9281aaa631ef41a69441da99f7143d87" style="width: 100.0%; height: 100.0%;">152 boulevard du Montparnasse O-E</div>`)[0];
            popup_c2b212ba266a40eb9d701518f357c3b9.setContent(html_9281aaa631ef41a69441da99f7143d87);
        

        marker_7ef26762d16b46aca9faee6fdeef776e.bindPopup(popup_c2b212ba266a40eb9d701518f357c3b9)
        ;

        
    
    
            var marker_af55e8c298a8455ca342ff3553c5c1a3 = L.marker(
                [48.896894, 2.344994],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_0219b9fe42dd406fb57b9a6f85074813 = L.popup({"maxWidth": "100%"});

        
            var html_7e9e3e02cbe54ccba73bc74bb9853632 = $(`<div id="html_7e9e3e02cbe54ccba73bc74bb9853632" style="width: 100.0%; height: 100.0%;">69 Boulevard Ornano N-S</div>`)[0];
            popup_0219b9fe42dd406fb57b9a6f85074813.setContent(html_7e9e3e02cbe54ccba73bc74bb9853632);
        

        marker_af55e8c298a8455ca342ff3553c5c1a3.bindPopup(popup_0219b9fe42dd406fb57b9a6f85074813)
        ;

        
    
    
            var marker_13e54ef1258b47e4877d97f2972bcc80 = L.marker(
                [48.87746, 2.35008],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_9955d916035d42b59a0096771079c8fd = L.popup({"maxWidth": "100%"});

        
            var html_9f603bfaf4e844329cccaabf02ed1618 = $(`<div id="html_9f603bfaf4e844329cccaabf02ed1618" style="width: 100.0%; height: 100.0%;">100 rue La Fayette O-E</div>`)[0];
            popup_9955d916035d42b59a0096771079c8fd.setContent(html_9f603bfaf4e844329cccaabf02ed1618);
        

        marker_13e54ef1258b47e4877d97f2972bcc80.bindPopup(popup_9955d916035d42b59a0096771079c8fd)
        ;

        
    
    
            var marker_17890ff8753143f3899484de925b955d = L.marker(
                [48.874716, 2.292439],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_e3b495c120f548ca90843d430bae62b8 = L.popup({"maxWidth": "100%"});

        
            var html_3ff55016840e4c7fb06e76f0faaf912c = $(`<div id="html_3ff55016840e4c7fb06e76f0faaf912c" style="width: 100.0%; height: 100.0%;">10 avenue de la Grande Armée SE-NO</div>`)[0];
            popup_e3b495c120f548ca90843d430bae62b8.setContent(html_3ff55016840e4c7fb06e76f0faaf912c);
        

        marker_17890ff8753143f3899484de925b955d.bindPopup(popup_e3b495c120f548ca90843d430bae62b8)
        ;

        
    
    
            var marker_7b1f0d4673fb403fa67545c8d56a57be = L.marker(
                [48.891415, 2.384954],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_ddd7353f648548de88c1a290cff9ba90 = L.popup({"maxWidth": "100%"});

        
            var html_c89a812fa22842a3938914e966494c90 = $(`<div id="html_c89a812fa22842a3938914e966494c90" style="width: 100.0%; height: 100.0%;">Face au 25 quai de l'Oise SO-NE</div>`)[0];
            popup_ddd7353f648548de88c1a290cff9ba90.setContent(html_c89a812fa22842a3938914e966494c90);
        

        marker_7b1f0d4673fb403fa67545c8d56a57be.bindPopup(popup_ddd7353f648548de88c1a290cff9ba90)
        ;

        
    
    
            var marker_2383eb2d11a740258b4aac96f3f8f682 = L.marker(
                [48.82026, 2.3592],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_fb5ab58acc85416babb5151d2b073668 = L.popup({"maxWidth": "100%"});

        
            var html_e85c42dc82cc4d2ba1da37a9a9738f0b = $(`<div id="html_e85c42dc82cc4d2ba1da37a9a9738f0b" style="width: 100.0%; height: 100.0%;">147 avenue d'Italie S-N</div>`)[0];
            popup_fb5ab58acc85416babb5151d2b073668.setContent(html_e85c42dc82cc4d2ba1da37a9a9738f0b);
        

        marker_2383eb2d11a740258b4aac96f3f8f682.bindPopup(popup_fb5ab58acc85416babb5151d2b073668)
        ;

        
    
    
            var marker_963ae2dcb45c469f8e05319e4e8d219c = L.marker(
                [48.85209, 2.28508],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_cf07c188b5e54c8685e1974d236b060b = L.popup({"maxWidth": "100%"});

        
            var html_d5c4b59f866a4c7ea24be02a87fcae6f = $(`<div id="html_d5c4b59f866a4c7ea24be02a87fcae6f" style="width: 100.0%; height: 100.0%;">36 quai de Grenelle SO-NE</div>`)[0];
            popup_cf07c188b5e54c8685e1974d236b060b.setContent(html_d5c4b59f866a4c7ea24be02a87fcae6f);
        

        marker_963ae2dcb45c469f8e05319e4e8d219c.bindPopup(popup_cf07c188b5e54c8685e1974d236b060b)
        ;

        
    
    
            var marker_9f1a6251692d45b5b08b96d5203faeea = L.marker(
                [48.83848, 2.37587],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_03b5e1f98dc2419fa40eae1a3bc13b25 = L.popup({"maxWidth": "100%"});

        
            var html_f3d3ff7d7239412db1ed90cbea4aae50 = $(`<div id="html_f3d3ff7d7239412db1ed90cbea4aae50" style="width: 100.0%; height: 100.0%;">Pont de Bercy NE-SO</div>`)[0];
            popup_03b5e1f98dc2419fa40eae1a3bc13b25.setContent(html_f3d3ff7d7239412db1ed90cbea4aae50);
        

        marker_9f1a6251692d45b5b08b96d5203faeea.bindPopup(popup_03b5e1f98dc2419fa40eae1a3bc13b25)
        ;

        
    
    
            var marker_d050b09192144cdaafb40f467d86ee85 = L.marker(
                [48.889046, 2.374872],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_705502da6e994e4abbeb368f1d473033 = L.popup({"maxWidth": "100%"});

        
            var html_9f4cc915f1a047818518b8a9960695b6 = $(`<div id="html_9f4cc915f1a047818518b8a9960695b6" style="width: 100.0%; height: 100.0%;">72 avenue de Flandre SO-NE</div>`)[0];
            popup_705502da6e994e4abbeb368f1d473033.setContent(html_9f4cc915f1a047818518b8a9960695b6);
        

        marker_d050b09192144cdaafb40f467d86ee85.bindPopup(popup_705502da6e994e4abbeb368f1d473033)
        ;

        
    
    
            var marker_5c1eff4579554b6fbbbc7c12f6e325b4 = L.marker(
                [48.86377, 2.35096],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_9f63fba9ca99425085d9508c55d94a8a = L.popup({"maxWidth": "100%"});

        
            var html_bc492b59233a4b01833add1cded96fcf = $(`<div id="html_bc492b59233a4b01833add1cded96fcf" style="width: 100.0%; height: 100.0%;">Totem 73 boulevard de Sébastopol N-S</div>`)[0];
            popup_9f63fba9ca99425085d9508c55d94a8a.setContent(html_bc492b59233a4b01833add1cded96fcf);
        

        marker_5c1eff4579554b6fbbbc7c12f6e325b4.bindPopup(popup_9f63fba9ca99425085d9508c55d94a8a)
        ;

        
    
    
            var marker_3815963f71334f12abf9c017302fbd6a = L.marker(
                [48.83521, 2.33307],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_1137aae2e0564e9095c3c79acf50b06a = L.popup({"maxWidth": "100%"});

        
            var html_8c386e8fed0f4910a85a80f9ceb5f079 = $(`<div id="html_8c386e8fed0f4910a85a80f9ceb5f079" style="width: 100.0%; height: 100.0%;">106 avenue Denfert Rochereau NE-SO</div>`)[0];
            popup_1137aae2e0564e9095c3c79acf50b06a.setContent(html_8c386e8fed0f4910a85a80f9ceb5f079);
        

        marker_3815963f71334f12abf9c017302fbd6a.bindPopup(popup_1137aae2e0564e9095c3c79acf50b06a)
        ;

        
    
    
            var marker_99af504422bd42efa0d2ae4dfb0ab4a3 = L.marker(
                [48.8484, 2.27586],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_6f022de3c4af4c3caa92c8a6a52f2379 = L.popup({"maxWidth": "100%"});

        
            var html_ccdccb52575e45c88cbcdeb3bf80296e = $(`<div id="html_ccdccb52575e45c88cbcdeb3bf80296e" style="width: 100.0%; height: 100.0%;">Voie Georges Pompidou NE-SO</div>`)[0];
            popup_6f022de3c4af4c3caa92c8a6a52f2379.setContent(html_ccdccb52575e45c88cbcdeb3bf80296e);
        

        marker_99af504422bd42efa0d2ae4dfb0ab4a3.bindPopup(popup_6f022de3c4af4c3caa92c8a6a52f2379)
        ;

        
    
    
            var marker_35f45033e9a44db086974bb845954302 = L.marker(
                [48.842091, 2.301],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_28b94345dc6741cbb072773b8f3b80af = L.popup({"maxWidth": "100%"});

        
            var html_6b0ca9b9a3914ebe9539b1c994017a53 = $(`<div id="html_6b0ca9b9a3914ebe9539b1c994017a53" style="width: 100.0%; height: 100.0%;">129 rue Lecourbe SO-NE</div>`)[0];
            popup_28b94345dc6741cbb072773b8f3b80af.setContent(html_6b0ca9b9a3914ebe9539b1c994017a53);
        

        marker_35f45033e9a44db086974bb845954302.bindPopup(popup_28b94345dc6741cbb072773b8f3b80af)
        ;

        
    
    
            var marker_a7c7a85a027d4cceb185f7cb53590a9d = L.marker(
                [48.84638, 2.31529],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_dc38eddbb5ae45fc8b9944316fcfbfee = L.popup({"maxWidth": "100%"});

        
            var html_2cc0d437f0244ab69b2055a00a502cc5 = $(`<div id="html_2cc0d437f0244ab69b2055a00a502cc5" style="width: 100.0%; height: 100.0%;">90 Rue De Sèvres SO-NE</div>`)[0];
            popup_dc38eddbb5ae45fc8b9944316fcfbfee.setContent(html_2cc0d437f0244ab69b2055a00a502cc5);
        

        marker_a7c7a85a027d4cceb185f7cb53590a9d.bindPopup(popup_dc38eddbb5ae45fc8b9944316fcfbfee)
        ;

        
    
    
            var marker_c6213debc6f44feab7398d0db40c797c = L.marker(
                [48.890457, 2.368852],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_be450d8410c44a37b7f186d33341dbd7 = L.popup({"maxWidth": "100%"});

        
            var html_72b8ef5eb5494cc7b13dbda38652d662 = $(`<div id="html_72b8ef5eb5494cc7b13dbda38652d662" style="width: 100.0%; height: 100.0%;">Face 104 rue d'Aubervilliers N-S</div>`)[0];
            popup_be450d8410c44a37b7f186d33341dbd7.setContent(html_72b8ef5eb5494cc7b13dbda38652d662);
        

        marker_c6213debc6f44feab7398d0db40c797c.bindPopup(popup_be450d8410c44a37b7f186d33341dbd7)
        ;

        
    
    
            var marker_6eb500b2caf044238b9310b465357e4b = L.marker(
                [48.86378, 2.32003],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_b4a551770e3b4ad1a19ee6098461e1bd = L.popup({"maxWidth": "100%"});

        
            var html_41a56a5f7c9d49dba8ebd0865707624b = $(`<div id="html_41a56a5f7c9d49dba8ebd0865707624b" style="width: 100.0%; height: 100.0%;">Pont de la Concorde S-N</div>`)[0];
            popup_b4a551770e3b4ad1a19ee6098461e1bd.setContent(html_41a56a5f7c9d49dba8ebd0865707624b);
        

        marker_6eb500b2caf044238b9310b465357e4b.bindPopup(popup_b4a551770e3b4ad1a19ee6098461e1bd)
        ;

        
    
    
            var marker_306a165e54214c4fbf7741bad423e97b = L.marker(
                [48.86288, 2.31179],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_e88709a4cc16447981b55610d2b4af71 = L.popup({"maxWidth": "100%"});

        
            var html_17828035aa13460f9fd39ea497594af7 = $(`<div id="html_17828035aa13460f9fd39ea497594af7" style="width: 100.0%; height: 100.0%;">Quai d'Orsay O-E</div>`)[0];
            popup_e88709a4cc16447981b55610d2b4af71.setContent(html_17828035aa13460f9fd39ea497594af7);
        

        marker_306a165e54214c4fbf7741bad423e97b.bindPopup(popup_e88709a4cc16447981b55610d2b4af71)
        ;

        
    
    
            var marker_0a0a264005df49c4983354823a6aa3e2 = L.marker(
                [48.851525, 2.343298],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_12913c364eb149f2bec0a3f3b087443f = L.popup({"maxWidth": "100%"});

        
            var html_64b40e638bd34be1af9fb16203f72ba6 = $(`<div id="html_64b40e638bd34be1af9fb16203f72ba6" style="width: 100.0%; height: 100.0%;">21 boulevard Saint Michel S-N</div>`)[0];
            popup_12913c364eb149f2bec0a3f3b087443f.setContent(html_64b40e638bd34be1af9fb16203f72ba6);
        

        marker_0a0a264005df49c4983354823a6aa3e2.bindPopup(popup_12913c364eb149f2bec0a3f3b087443f)
        ;

        
    
    
            var marker_6430593186ee498987623d9ec37c6405 = L.marker(
                [48.896825, 2.345648],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_75def626e37348ee9eac2d1ceabadb09 = L.popup({"maxWidth": "100%"});

        
            var html_33c63c8e1ed44267b4be3054e4cf93d1 = $(`<div id="html_33c63c8e1ed44267b4be3054e4cf93d1" style="width: 100.0%; height: 100.0%;">74 Boulevard Ornano S-N</div>`)[0];
            popup_75def626e37348ee9eac2d1ceabadb09.setContent(html_33c63c8e1ed44267b4be3054e4cf93d1);
        

        marker_6430593186ee498987623d9ec37c6405.bindPopup(popup_75def626e37348ee9eac2d1ceabadb09)
        ;

        
    
    
            var marker_f12576d94f8f483fb12eb4a29192e694 = L.marker(
                [48.82658, 2.38409],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_2a8ba3a77f984c829526d3c2f35f9876 = L.popup({"maxWidth": "100%"});

        
            var html_6aa0e9c23cbf41138df961f64584d475 = $(`<div id="html_6aa0e9c23cbf41138df961f64584d475" style="width: 100.0%; height: 100.0%;">Pont National SO-NE</div>`)[0];
            popup_2a8ba3a77f984c829526d3c2f35f9876.setContent(html_6aa0e9c23cbf41138df961f64584d475);
        

        marker_f12576d94f8f483fb12eb4a29192e694.bindPopup(popup_2a8ba3a77f984c829526d3c2f35f9876)
        ;

        
    
    
            var marker_ecab488476124801a6c3b0f0632a046e = L.marker(
                [48.891415, 2.384954],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_026978e6502d44ffb9d6ac09af3dca7d = L.popup({"maxWidth": "100%"});

        
            var html_3464f81a77594bbaa05669ad92aa8952 = $(`<div id="html_3464f81a77594bbaa05669ad92aa8952" style="width: 100.0%; height: 100.0%;">Face au 25 quai de l'Oise NE-SO</div>`)[0];
            popup_026978e6502d44ffb9d6ac09af3dca7d.setContent(html_3464f81a77594bbaa05669ad92aa8952);
        

        marker_ecab488476124801a6c3b0f0632a046e.bindPopup(popup_026978e6502d44ffb9d6ac09af3dca7d)
        ;

        
    
    
            var marker_bb983330b7cd4dd98779418ca5c43ec1 = L.marker(
                [48.86392, 2.31988],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_a53d72e5c8cb4d33b25594f5805c5d4f = L.popup({"maxWidth": "100%"});

        
            var html_5b796ad686294b8487bc6b9fcfbd0fa4 = $(`<div id="html_5b796ad686294b8487bc6b9fcfbd0fa4" style="width: 100.0%; height: 100.0%;">Pont de la Concorde N-S</div>`)[0];
            popup_a53d72e5c8cb4d33b25594f5805c5d4f.setContent(html_5b796ad686294b8487bc6b9fcfbd0fa4);
        

        marker_bb983330b7cd4dd98779418ca5c43ec1.bindPopup(popup_a53d72e5c8cb4d33b25594f5805c5d4f)
        ;

        
    
    
            var marker_dd842d54cf8c464c83cb59d20523780e = L.marker(
                [48.82108, 2.32537],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_78f60b3bb54e4797bc66261573a82628 = L.popup({"maxWidth": "100%"});

        
            var html_a62f94bf2212401babab8bca685f5c30 = $(`<div id="html_a62f94bf2212401babab8bca685f5c30" style="width: 100.0%; height: 100.0%;">3 avenue de la Porte D'Orléans S-N</div>`)[0];
            popup_78f60b3bb54e4797bc66261573a82628.setContent(html_a62f94bf2212401babab8bca685f5c30);
        

        marker_dd842d54cf8c464c83cb59d20523780e.bindPopup(popup_78f60b3bb54e4797bc66261573a82628)
        ;

        
    
    
            var marker_48e61c584ec042dea365eadf0c607f2e = L.marker(
                [48.86179, 2.32014],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_b29109f0a1b949f0864c9a7d9930848c = L.popup({"maxWidth": "100%"});

        
            var html_a31d4f004bc8447db2a9a0e22c2afa33 = $(`<div id="html_a31d4f004bc8447db2a9a0e22c2afa33" style="width: 100.0%; height: 100.0%;">243 boulevard Saint Germain NO-SE</div>`)[0];
            popup_b29109f0a1b949f0864c9a7d9930848c.setContent(html_a31d4f004bc8447db2a9a0e22c2afa33);
        

        marker_48e61c584ec042dea365eadf0c607f2e.bindPopup(popup_b29109f0a1b949f0864c9a7d9930848c)
        ;

        
    
    
            var marker_d90f07164bfc49128908d41131e5ba41 = L.marker(
                [48.85735, 2.35211],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_a654ea08df68474999d4396fb10c789a = L.popup({"maxWidth": "100%"});

        
            var html_5f79a4d786764d9e813cce3789e5218d = $(`<div id="html_5f79a4d786764d9e813cce3789e5218d" style="width: 100.0%; height: 100.0%;">Totem 64 Rue de Rivoli E-O</div>`)[0];
            popup_a654ea08df68474999d4396fb10c789a.setContent(html_5f79a4d786764d9e813cce3789e5218d);
        

        marker_d90f07164bfc49128908d41131e5ba41.bindPopup(popup_a654ea08df68474999d4396fb10c789a)
        ;

        
    
    
            var marker_09ddee01b1ad4a68a6a207d2e5fb9390 = L.marker(
                [48.88529, 2.32666],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_4caf3cb5289643be851ee3ba4509a211 = L.popup({"maxWidth": "100%"});

        
            var html_f5cc1551b0254cbfa3bef8f3c0409939 = $(`<div id="html_f5cc1551b0254cbfa3bef8f3c0409939" style="width: 100.0%; height: 100.0%;">20 Avenue de Clichy SE-NO</div>`)[0];
            popup_4caf3cb5289643be851ee3ba4509a211.setContent(html_f5cc1551b0254cbfa3bef8f3c0409939);
        

        marker_09ddee01b1ad4a68a6a207d2e5fb9390.bindPopup(popup_4caf3cb5289643be851ee3ba4509a211)
        ;

        
    
    
            var marker_23fff671d3df4c8e8b60bece6a352e70 = L.marker(
                [48.860852, 2.372279],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_6943a6ad29eb40fda4a8cc614444ae5f = L.popup({"maxWidth": "100%"});

        
            var html_58604e33656b4c27b7a9bd7b24d29821 = $(`<div id="html_58604e33656b4c27b7a9bd7b24d29821" style="width: 100.0%; height: 100.0%;">77 boulevard Richard Lenoir N-S</div>`)[0];
            popup_6943a6ad29eb40fda4a8cc614444ae5f.setContent(html_58604e33656b4c27b7a9bd7b24d29821);
        

        marker_23fff671d3df4c8e8b60bece6a352e70.bindPopup(popup_6943a6ad29eb40fda4a8cc614444ae5f)
        ;

        
    
    
            var marker_4d22790c2216441d83e5541c060493e0 = L.marker(
                [48.840801, 2.333233],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_dbbcd79afc1a49a389b66c767d6c7b57 = L.popup({"maxWidth": "100%"});

        
            var html_4d1ed28f177e4e578a9319daa53c8ebd = $(`<div id="html_4d1ed28f177e4e578a9319daa53c8ebd" style="width: 100.0%; height: 100.0%;">152 boulevard du Montparnasse E-O</div>`)[0];
            popup_dbbcd79afc1a49a389b66c767d6c7b57.setContent(html_4d1ed28f177e4e578a9319daa53c8ebd);
        

        marker_4d22790c2216441d83e5541c060493e0.bindPopup(popup_dbbcd79afc1a49a389b66c767d6c7b57)
        ;

        
    
    
            var marker_f524e54d93b446cfb4c40461d596daa6 = L.marker(
                [48.85735, 2.35211],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_54a52c9692f046139561915552c5034f = L.popup({"maxWidth": "100%"});

        
            var html_ab3173e134ec476588bfcffc2e804746 = $(`<div id="html_ab3173e134ec476588bfcffc2e804746" style="width: 100.0%; height: 100.0%;">Totem 64 Rue de Rivoli O-E</div>`)[0];
            popup_54a52c9692f046139561915552c5034f.setContent(html_ab3173e134ec476588bfcffc2e804746);
        

        marker_f524e54d93b446cfb4c40461d596daa6.bindPopup(popup_54a52c9692f046139561915552c5034f)
        ;

        
    
    
            var marker_cf583775d448449ba29b3f5c050978d8 = L.marker(
                [48.86284, 2.310345],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_c1bfd41b43fc4e30a448634f6258561a = L.popup({"maxWidth": "100%"});

        
            var html_02bad02805904943bb20c36cdcb9600c = $(`<div id="html_02bad02805904943bb20c36cdcb9600c" style="width: 100.0%; height: 100.0%;">Pont des Invalides N-S</div>`)[0];
            popup_c1bfd41b43fc4e30a448634f6258561a.setContent(html_02bad02805904943bb20c36cdcb9600c);
        

        marker_cf583775d448449ba29b3f5c050978d8.bindPopup(popup_c1bfd41b43fc4e30a448634f6258561a)
        ;

        
    
    
            var marker_df03d4f4918c4c6cb346c9dbe13bd2e8 = L.marker(
                [48.830331, 2.400551],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_2120f3ddd7d64404b4f9c319405b783b = L.popup({"maxWidth": "100%"});

        
            var html_5a1d2c4685c94322b3b0c86226954d6d = $(`<div id="html_5a1d2c4685c94322b3b0c86226954d6d" style="width: 100.0%; height: 100.0%;">Face au 8 avenue de la porte de Charenton SE-NO</div>`)[0];
            popup_2120f3ddd7d64404b4f9c319405b783b.setContent(html_5a1d2c4685c94322b3b0c86226954d6d);
        

        marker_df03d4f4918c4c6cb346c9dbe13bd2e8.bindPopup(popup_2120f3ddd7d64404b4f9c319405b783b)
        ;

        
    
    
            var marker_012b2c373eec486ba87684b6d51613e7 = L.marker(
                [48.84223, 2.36811],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_9cef3503d68f49e9b5c95dce397735b8 = L.popup({"maxWidth": "100%"});

        
            var html_f096d62cc9e942dd913e73fc7a14efbd = $(`<div id="html_f096d62cc9e942dd913e73fc7a14efbd" style="width: 100.0%; height: 100.0%;">Pont Charles De Gaulle NE-SO</div>`)[0];
            popup_9cef3503d68f49e9b5c95dce397735b8.setContent(html_f096d62cc9e942dd913e73fc7a14efbd);
        

        marker_012b2c373eec486ba87684b6d51613e7.bindPopup(popup_9cef3503d68f49e9b5c95dce397735b8)
        ;

        
    
    
            var marker_d5590fb4d3d0449ca1c690a534439152 = L.marker(
                [48.846028, 2.375429],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_4eb9174beb99454395e4a97b08d26b0d = L.popup({"maxWidth": "100%"});

        
            var html_4367a53ee18f4c05994ee7e33a17a650 = $(`<div id="html_4367a53ee18f4c05994ee7e33a17a650" style="width: 100.0%; height: 100.0%;">28 boulevard Diderot E-O</div>`)[0];
            popup_4eb9174beb99454395e4a97b08d26b0d.setContent(html_4367a53ee18f4c05994ee7e33a17a650);
        

        marker_d5590fb4d3d0449ca1c690a534439152.bindPopup(popup_4eb9174beb99454395e4a97b08d26b0d)
        ;

        
    
    
            var marker_10c1cfee06fd4bd2a8959668ac26525c = L.marker(
                [48.85372, 2.35702],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_b97f7537e8244f239056b1649e2587f5 = L.popup({"maxWidth": "100%"});

        
            var html_ca99d908887642b483cfec6ce0b34f1b = $(`<div id="html_ca99d908887642b483cfec6ce0b34f1b" style="width: 100.0%; height: 100.0%;">18 quai de l'hotel de ville SE-NO</div>`)[0];
            popup_b97f7537e8244f239056b1649e2587f5.setContent(html_ca99d908887642b483cfec6ce0b34f1b);
        

        marker_10c1cfee06fd4bd2a8959668ac26525c.bindPopup(popup_b97f7537e8244f239056b1649e2587f5)
        ;

        
    
    
            var marker_053450a1f6f94de6b553078b66381d61 = L.marker(
                [48.869873, 2.307419],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_ad2aa039f84d4dcf8cba0494cb37f51a = L.popup({"maxWidth": "100%"});

        
            var html_fe2b949ff1514ae68460be5b91cd2f62 = $(`<div id="html_fe2b949ff1514ae68460be5b91cd2f62" style="width: 100.0%; height: 100.0%;">44 avenue des Champs Elysées SE-NO</div>`)[0];
            popup_ad2aa039f84d4dcf8cba0494cb37f51a.setContent(html_fe2b949ff1514ae68460be5b91cd2f62);
        

        marker_053450a1f6f94de6b553078b66381d61.bindPopup(popup_ad2aa039f84d4dcf8cba0494cb37f51a)
        ;

        
    
    
            var marker_c125a3e1137e4c5e8ac39713f0f5539e = L.marker(
                [48.84216, 2.30115],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_8e7c5015b2314f3cafb677b3a38fb86d = L.popup({"maxWidth": "100%"});

        
            var html_ae7547d9e5f841179a39fac0ce2b544b = $(`<div id="html_ae7547d9e5f841179a39fac0ce2b544b" style="width: 100.0%; height: 100.0%;">132 rue Lecourbe NE-SO</div>`)[0];
            popup_8e7c5015b2314f3cafb677b3a38fb86d.setContent(html_ae7547d9e5f841179a39fac0ce2b544b);
        

        marker_c125a3e1137e4c5e8ac39713f0f5539e.bindPopup(popup_8e7c5015b2314f3cafb677b3a38fb86d)
        ;

        
    
    
            var marker_188138e8985449468a41f7bb9effec0e = L.marker(
                [48.89594, 2.35953],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_164459ee4b604074b50149a77d264483 = L.popup({"maxWidth": "100%"});

        
            var html_3629ed08470c4b05996e75299498d489 = $(`<div id="html_3629ed08470c4b05996e75299498d489" style="width: 100.0%; height: 100.0%;">72 rue de la Chapelle N-S</div>`)[0];
            popup_164459ee4b604074b50149a77d264483.setContent(html_3629ed08470c4b05996e75299498d489);
        

        marker_188138e8985449468a41f7bb9effec0e.bindPopup(popup_164459ee4b604074b50149a77d264483)
        ;

        
    
    
            var marker_ad6cb970948742efabb4603257e8935f = L.marker(
                [48.85209, 2.28508],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_7857e3c4427548e4bd9171d7be7f1e52 = L.popup({"maxWidth": "100%"});

        
            var html_8583c906631e408693be87b5ab0a54c9 = $(`<div id="html_8583c906631e408693be87b5ab0a54c9" style="width: 100.0%; height: 100.0%;">36 quai de Grenelle NE-SO</div>`)[0];
            popup_7857e3c4427548e4bd9171d7be7f1e52.setContent(html_8583c906631e408693be87b5ab0a54c9);
        

        marker_ad6cb970948742efabb4603257e8935f.bindPopup(popup_7857e3c4427548e4bd9171d7be7f1e52)
        ;

        
    
    
            var marker_fde5896c770241b184de9e252ca96c8c = L.marker(
                [48.83421, 2.26542],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_5d25613b313a4efbb48171f68329899a = L.popup({"maxWidth": "100%"});

        
            var html_5eb406ae80004f0cb62446fd1c82e377 = $(`<div id="html_5eb406ae80004f0cb62446fd1c82e377" style="width: 100.0%; height: 100.0%;">Face au 40 quai D'Issy NE-SO</div>`)[0];
            popup_5d25613b313a4efbb48171f68329899a.setContent(html_5eb406ae80004f0cb62446fd1c82e377);
        

        marker_fde5896c770241b184de9e252ca96c8c.bindPopup(popup_5d25613b313a4efbb48171f68329899a)
        ;

        
    
    
            var marker_94407efb080b4af3bcbd51b05f4cd36a = L.marker(
                [48.84201, 2.36729],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_45f50845660c405fbc15de37d1f53c18 = L.popup({"maxWidth": "100%"});

        
            var html_a2819950ecff496e9e3808623bbbe6b2 = $(`<div id="html_a2819950ecff496e9e3808623bbbe6b2" style="width: 100.0%; height: 100.0%;">Totem 85 quai d'Austerlitz NO-SE</div>`)[0];
            popup_45f50845660c405fbc15de37d1f53c18.setContent(html_a2819950ecff496e9e3808623bbbe6b2);
        

        marker_94407efb080b4af3bcbd51b05f4cd36a.bindPopup(popup_45f50845660c405fbc15de37d1f53c18)
        ;

        
    
    
            var marker_f09e8d9f8a794e93b7534fa7c4150bcd = L.marker(
                [48.86077, 2.37305],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_7ef592ab80044621b3224557bfb29e93 = L.popup({"maxWidth": "100%"});

        
            var html_7d4ab3ea82df4dbab1d8e9be17432e14 = $(`<div id="html_7d4ab3ea82df4dbab1d8e9be17432e14" style="width: 100.0%; height: 100.0%;">72 boulevard Richard Lenoir  S-N</div>`)[0];
            popup_7ef592ab80044621b3224557bfb29e93.setContent(html_7d4ab3ea82df4dbab1d8e9be17432e14);
        

        marker_f09e8d9f8a794e93b7534fa7c4150bcd.bindPopup(popup_7ef592ab80044621b3224557bfb29e93)
        ;

        
    
    
            var marker_4285a2ada741456d971341ef034ec381 = L.marker(
                [48.82636, 2.30303],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_fa5bf3faef0f4871a09eb19bba024ec5 = L.popup({"maxWidth": "100%"});

        
            var html_f6d1808d9d45463c83c493646db3aec5 = $(`<div id="html_f6d1808d9d45463c83c493646db3aec5" style="width: 100.0%; height: 100.0%;">6 rue Julia Bartet SO-NE</div>`)[0];
            popup_fa5bf3faef0f4871a09eb19bba024ec5.setContent(html_f6d1808d9d45463c83c493646db3aec5);
        

        marker_4285a2ada741456d971341ef034ec381.bindPopup(popup_fa5bf3faef0f4871a09eb19bba024ec5)
        ;

        
    
    
            var marker_8a74d6b2001d45bda8edf627ff9ed76f = L.marker(
                [48.860528, 2.388364],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_c6620d2844634b878ff471e0a77b5619 = L.popup({"maxWidth": "100%"});

        
            var html_7992b14227594be8878115781c035e1a = $(`<div id="html_7992b14227594be8878115781c035e1a" style="width: 100.0%; height: 100.0%;">35 boulevard de Menilmontant NO-SE</div>`)[0];
            popup_c6620d2844634b878ff471e0a77b5619.setContent(html_7992b14227594be8878115781c035e1a);
        

        marker_8a74d6b2001d45bda8edf627ff9ed76f.bindPopup(popup_c6620d2844634b878ff471e0a77b5619)
        ;

        
    
    
            var marker_f998f5fb702c48748a1a2fadc27a106c = L.marker(
                [48.85013, 2.35423],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_da213426998d46139fd406b8ed3319db = L.popup({"maxWidth": "100%"});

        
            var html_3119588570ae45ffa3be7bc53d653048 = $(`<div id="html_3119588570ae45ffa3be7bc53d653048" style="width: 100.0%; height: 100.0%;">27 quai de la Tournelle SE-NO</div>`)[0];
            popup_da213426998d46139fd406b8ed3319db.setContent(html_3119588570ae45ffa3be7bc53d653048);
        

        marker_f998f5fb702c48748a1a2fadc27a106c.bindPopup(popup_da213426998d46139fd406b8ed3319db)
        ;

        
    
    
            var marker_ea5b16df53dd49849210dc3fe9683a92 = L.marker(
                [48.86377, 2.35096],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_4f1f4c73b90d43089e6fdf7201498f35 = L.popup({"maxWidth": "100%"});

        
            var html_9e136d1f33d240c2becb55ea429d8453 = $(`<div id="html_9e136d1f33d240c2becb55ea429d8453" style="width: 100.0%; height: 100.0%;">Totem 73 boulevard de Sébastopol S-N</div>`)[0];
            popup_4f1f4c73b90d43089e6fdf7201498f35.setContent(html_9e136d1f33d240c2becb55ea429d8453);
        

        marker_ea5b16df53dd49849210dc3fe9683a92.bindPopup(popup_4f1f4c73b90d43089e6fdf7201498f35)
        ;

        
    
    
            var marker_e734ac1a77b54bb7ba556d7d61e9df3f = L.marker(
                [48.843435, 2.383378],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_e74aeb279b944cb99c4c7561918e147b = L.popup({"maxWidth": "100%"});

        
            var html_64505ef8209a4deba76e2e6431c1b738 = $(`<div id="html_64505ef8209a4deba76e2e6431c1b738" style="width: 100.0%; height: 100.0%;">135 avenue Daumesnil SE-NO</div>`)[0];
            popup_e74aeb279b944cb99c4c7561918e147b.setContent(html_64505ef8209a4deba76e2e6431c1b738);
        

        marker_e734ac1a77b54bb7ba556d7d61e9df3f.bindPopup(popup_e74aeb279b944cb99c4c7561918e147b)
        ;

        
    
    
            var marker_a1ac413f1e884898b24aea4057ba87e1 = L.marker(
                [48.846028, 2.375429],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_fd6037efdbca4f619c3d9726f70c07ac = L.popup({"maxWidth": "100%"});

        
            var html_bce98d785b6e4635a39ea26dd900eb09 = $(`<div id="html_bce98d785b6e4635a39ea26dd900eb09" style="width: 100.0%; height: 100.0%;">28 boulevard Diderot O-E</div>`)[0];
            popup_fd6037efdbca4f619c3d9726f70c07ac.setContent(html_bce98d785b6e4635a39ea26dd900eb09);
        

        marker_a1ac413f1e884898b24aea4057ba87e1.bindPopup(popup_fd6037efdbca4f619c3d9726f70c07ac)
        ;

        
    
    
            var marker_6c715f4e771c4d83a8a0e130d8f41269 = L.marker(
                [48.85372, 2.35702],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_235e54a7a58745ada94b83419c37088d = L.popup({"maxWidth": "100%"});

        
            var html_3216a041a70e4ebf92323ca4bf741d03 = $(`<div id="html_3216a041a70e4ebf92323ca4bf741d03" style="width: 100.0%; height: 100.0%;">18 quai de l'hotel de ville NO-SE</div>`)[0];
            popup_235e54a7a58745ada94b83419c37088d.setContent(html_3216a041a70e4ebf92323ca4bf741d03);
        

        marker_6c715f4e771c4d83a8a0e130d8f41269.bindPopup(popup_235e54a7a58745ada94b83419c37088d)
        ;

        
    
    
            var marker_6dfabfac44cb461fbe79c6e003d11f56 = L.marker(
                [48.86451, 2.40932],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_9f62034af33c45c8901bf03c6311063e = L.popup({"maxWidth": "100%"});

        
            var html_7b2c75fbf1b54fcc84bf022c53a43b4a = $(`<div id="html_7b2c75fbf1b54fcc84bf022c53a43b4a" style="width: 100.0%; height: 100.0%;">2 avenue de la Porte de Bagnolet O-E</div>`)[0];
            popup_9f62034af33c45c8901bf03c6311063e.setContent(html_7b2c75fbf1b54fcc84bf022c53a43b4a);
        

        marker_6dfabfac44cb461fbe79c6e003d11f56.bindPopup(popup_9f62034af33c45c8901bf03c6311063e)
        ;

        
    
    
            var marker_c17f3ee1e5684938a1d8e98cd20c8c42 = L.marker(
                [48.83421, 2.26542],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_af11defceae946dfb5a377840b9e35dd = L.popup({"maxWidth": "100%"});

        
            var html_86b67a05e1e84613b2701166ba1c87b1 = $(`<div id="html_86b67a05e1e84613b2701166ba1c87b1" style="width: 100.0%; height: 100.0%;">Face au 40 quai D'Issy SO-NE</div>`)[0];
            popup_af11defceae946dfb5a377840b9e35dd.setContent(html_86b67a05e1e84613b2701166ba1c87b1);
        

        marker_c17f3ee1e5684938a1d8e98cd20c8c42.bindPopup(popup_af11defceae946dfb5a377840b9e35dd)
        ;

        
    
    
            var marker_92ecdd65edf74492b903e4c61ce4a0ff = L.marker(
                [48.86521, 2.35358],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_08d9c31c469842c48e2b9cc383cc55b7 = L.popup({"maxWidth": "100%"});

        
            var html_073ddd086aae4dd8a6f3723f84c4abb9 = $(`<div id="html_073ddd086aae4dd8a6f3723f84c4abb9" style="width: 100.0%; height: 100.0%;">38 rue Turbigo NE-SO</div>`)[0];
            popup_08d9c31c469842c48e2b9cc383cc55b7.setContent(html_073ddd086aae4dd8a6f3723f84c4abb9);
        

        marker_92ecdd65edf74492b903e4c61ce4a0ff.bindPopup(popup_08d9c31c469842c48e2b9cc383cc55b7)
        ;

        
    
    
            var marker_2b03ebbb8fdc47ba8e1390a518e3c0cc = L.marker(
                [48.877667, 2.350556],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_05392d1f46584dae985795cecf41bf47 = L.popup({"maxWidth": "100%"});

        
            var html_5c736ee658eb4968b9cb633e335c1c11 = $(`<div id="html_5c736ee658eb4968b9cb633e335c1c11" style="width: 100.0%; height: 100.0%;">105 rue La Fayette E-O</div>`)[0];
            popup_05392d1f46584dae985795cecf41bf47.setContent(html_5c736ee658eb4968b9cb633e335c1c11);
        

        marker_2b03ebbb8fdc47ba8e1390a518e3c0cc.bindPopup(popup_05392d1f46584dae985795cecf41bf47)
        ;

        
    
    
            var marker_0387b253473a4a7697ae8130aca84a66 = L.marker(
                [48.83436, 2.377],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_b321d7b1e3784c93b8a3994fabd5db75 = L.popup({"maxWidth": "100%"});

        
            var html_cd87bf1d8b9845fb9c019235660fa732 = $(`<div id="html_cd87bf1d8b9845fb9c019235660fa732" style="width: 100.0%; height: 100.0%;">39 quai François Mauriac SE-NO</div>`)[0];
            popup_b321d7b1e3784c93b8a3994fabd5db75.setContent(html_cd87bf1d8b9845fb9c019235660fa732);
        

        marker_0387b253473a4a7697ae8130aca84a66.bindPopup(popup_b321d7b1e3784c93b8a3994fabd5db75)
        ;

        
    
    
            var marker_cc2725c8ac354b8b85d18ce301fc69d0 = L.marker(
                [48.83436, 2.377],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_35188acd0fe94663b0a3e74fc21da665 = L.popup({"maxWidth": "100%"});

        
            var html_93ed059cc13f4ec3ab58c5578be26ac3 = $(`<div id="html_93ed059cc13f4ec3ab58c5578be26ac3" style="width: 100.0%; height: 100.0%;">39 quai François Mauriac NO-SE</div>`)[0];
            popup_35188acd0fe94663b0a3e74fc21da665.setContent(html_93ed059cc13f4ec3ab58c5578be26ac3);
        

        marker_cc2725c8ac354b8b85d18ce301fc69d0.bindPopup(popup_35188acd0fe94663b0a3e74fc21da665)
        ;

        
    
    
            var marker_181b8c31e2ba43b280763dfd99788de0 = L.marker(
                [48.82636, 2.30303],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_17f1ea35476a4bad87ffcac27ec16cfe = L.popup({"maxWidth": "100%"});

        
            var html_b581061091874333bd41459f774eb5bd = $(`<div id="html_b581061091874333bd41459f774eb5bd" style="width: 100.0%; height: 100.0%;">6 rue Julia Bartet NE-SO</div>`)[0];
            popup_17f1ea35476a4bad87ffcac27ec16cfe.setContent(html_b581061091874333bd41459f774eb5bd);
        

        marker_181b8c31e2ba43b280763dfd99788de0.bindPopup(popup_17f1ea35476a4bad87ffcac27ec16cfe)
        ;

        
    
    
            var marker_d5c9621ee05649d59a3152cbccc5ffc6 = L.marker(
                [48.86521, 2.35358],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_558362919f8f499fa38a6c1190e6f2f7 = L.popup({"maxWidth": "100%"});

        
            var html_b1a50e45f4c943c49c3b11b5bf3ef7a9 = $(`<div id="html_b1a50e45f4c943c49c3b11b5bf3ef7a9" style="width: 100.0%; height: 100.0%;">38 rue Turbigo SO-NE</div>`)[0];
            popup_558362919f8f499fa38a6c1190e6f2f7.setContent(html_b1a50e45f4c943c49c3b11b5bf3ef7a9);
        

        marker_d5c9621ee05649d59a3152cbccc5ffc6.bindPopup(popup_558362919f8f499fa38a6c1190e6f2f7)
        ;

        
    
    
            var marker_a2a463a3810c479089ee9e641295d4e6 = L.marker(
                [48.84638, 2.31529],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_aff653830c7b487ab41dad8aec5930b6 = L.popup({"maxWidth": "100%"});

        
            var html_a8797c7a3e9441979ec204b394db2d87 = $(`<div id="html_a8797c7a3e9441979ec204b394db2d87" style="width: 100.0%; height: 100.0%;">90 Rue De Sèvres NE-SO</div>`)[0];
            popup_aff653830c7b487ab41dad8aec5930b6.setContent(html_a8797c7a3e9441979ec204b394db2d87);
        

        marker_a2a463a3810c479089ee9e641295d4e6.bindPopup(popup_aff653830c7b487ab41dad8aec5930b6)
        ;

        
    
    
            var marker_51455da4bee8420591e9eb8e781d6f09 = L.marker(
                [48.846099, 2.375456],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_72c24f0f556946c7a99bca061d99aa1e = L.popup({"maxWidth": "100%"});

        
            var html_05a994c4f0514de1b537834d20319f16 = $(`<div id="html_05a994c4f0514de1b537834d20319f16" style="width: 100.0%; height: 100.0%;">27 boulevard Diderot E-O</div>`)[0];
            popup_72c24f0f556946c7a99bca061d99aa1e.setContent(html_05a994c4f0514de1b537834d20319f16);
        

        marker_51455da4bee8420591e9eb8e781d6f09.bindPopup(popup_72c24f0f556946c7a99bca061d99aa1e)
        ;

        
    
    
            var marker_4be2789b2eb84f99bbd1302380de1022 = L.marker(
                [48.84015, 2.26733],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_c27f82a2c0e243d493ea09119b23c0f8 = L.popup({"maxWidth": "100%"});

        
            var html_14de72317d684674a10903de8ae843f3 = $(`<div id="html_14de72317d684674a10903de8ae843f3" style="width: 100.0%; height: 100.0%;">Pont du Garigliano NO-SE</div>`)[0];
            popup_c27f82a2c0e243d493ea09119b23c0f8.setContent(html_14de72317d684674a10903de8ae843f3);
        

        marker_4be2789b2eb84f99bbd1302380de1022.bindPopup(popup_c27f82a2c0e243d493ea09119b23c0f8)
        ;

        
    
    
            var marker_1603cc986e7848bba0b66265b4c89b53 = L.marker(
                [48.891215, 2.38573],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_686d14839b8a42459574f43f543376c7 = L.popup({"maxWidth": "100%"});

        
            var html_dbad62de2e5a46f9a1b3803ee3a70ace = $(`<div id="html_dbad62de2e5a46f9a1b3803ee3a70ace" style="width: 100.0%; height: 100.0%;">Face au 48 quai de la marne NE-SO</div>`)[0];
            popup_686d14839b8a42459574f43f543376c7.setContent(html_dbad62de2e5a46f9a1b3803ee3a70ace);
        

        marker_1603cc986e7848bba0b66265b4c89b53.bindPopup(popup_686d14839b8a42459574f43f543376c7)
        ;

        
    
    
            var marker_04048d9d591843cb98a371ea2ad56319 = L.marker(
                [48.82682, 2.38465],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_d99ffcfec2ac47a89fd557c40f8fb0f0 = L.popup({"maxWidth": "100%"});

        
            var html_649fd004f7324c1c96be5ac3b245a19b = $(`<div id="html_649fd004f7324c1c96be5ac3b245a19b" style="width: 100.0%; height: 100.0%;">Pont National  NE-SO</div>`)[0];
            popup_d99ffcfec2ac47a89fd557c40f8fb0f0.setContent(html_649fd004f7324c1c96be5ac3b245a19b);
        

        marker_04048d9d591843cb98a371ea2ad56319.bindPopup(popup_d99ffcfec2ac47a89fd557c40f8fb0f0)
        ;

        
    
    
            var marker_0fb4b543e93741878058f219d4d67c8d = L.marker(
                [48.869831, 2.307076],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_be9aa8cce36041d3a698d83509004473 = L.popup({"maxWidth": "100%"});

        
            var html_4f4da8b562da4d4c9c3725b8da13531f = $(`<div id="html_4f4da8b562da4d4c9c3725b8da13531f" style="width: 100.0%; height: 100.0%;">33 avenue des Champs Elysées NO-SE</div>`)[0];
            popup_be9aa8cce36041d3a698d83509004473.setContent(html_4f4da8b562da4d4c9c3725b8da13531f);
        

        marker_0fb4b543e93741878058f219d4d67c8d.bindPopup(popup_be9aa8cce36041d3a698d83509004473)
        ;

        
    
    
            var marker_eb8bb159f4b34ad6b15e431f183b9c6b = L.marker(
                [48.86282, 2.31061],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_86f0b45c54444dff9b9fb115ed787a59 = L.popup({"maxWidth": "100%"});

        
            var html_2034308aa50747829b39457c21c1bea7 = $(`<div id="html_2034308aa50747829b39457c21c1bea7" style="width: 100.0%; height: 100.0%;">Pont des Invalides S-N</div>`)[0];
            popup_86f0b45c54444dff9b9fb115ed787a59.setContent(html_2034308aa50747829b39457c21c1bea7);
        

        marker_eb8bb159f4b34ad6b15e431f183b9c6b.bindPopup(popup_86f0b45c54444dff9b9fb115ed787a59)
        ;

        
    
    
            var marker_bcf854cc5e354b879acc7a0315ac652a = L.marker(
                [48.89594, 2.35953],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_7a8e8364a65a4ea1b9f6cd77ae9cc5fe = L.popup({"maxWidth": "100%"});

        
            var html_6ca227dd115b4c448718e273b6d8e000 = $(`<div id="html_6ca227dd115b4c448718e273b6d8e000" style="width: 100.0%; height: 100.0%;">72 rue de la Chapelle S-N</div>`)[0];
            popup_7a8e8364a65a4ea1b9f6cd77ae9cc5fe.setContent(html_6ca227dd115b4c448718e273b6d8e000);
        

        marker_bcf854cc5e354b879acc7a0315ac652a.bindPopup(popup_7a8e8364a65a4ea1b9f6cd77ae9cc5fe)
        ;

        
    
    
            var marker_6f8267a19c024df0899b0f3edfbc6ed4 = L.marker(
                [48.88181, 2.281546],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_ae85654c9c7742cc81b09ddb10d8e86b = L.popup({"maxWidth": "100%"});

        
            var html_7b86c78293c3488e8d1306cb4e6a41b2 = $(`<div id="html_7b86c78293c3488e8d1306cb4e6a41b2" style="width: 100.0%; height: 100.0%;">16 avenue de la Porte des Ternes E-O</div>`)[0];
            popup_ae85654c9c7742cc81b09ddb10d8e86b.setContent(html_7b86c78293c3488e8d1306cb4e6a41b2);
        

        marker_6f8267a19c024df0899b0f3edfbc6ed4.bindPopup(popup_ae85654c9c7742cc81b09ddb10d8e86b)
        ;

        
    
    
            var marker_509397e4b7d3456f9eab48493a39abd3 = L.marker(
                [48.86462, 2.31444],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_c47d628577544c8b96d0123abe4dffd1 = L.popup({"maxWidth": "100%"});

        
            var html_8febf5b5ec02452a8e05e5334a3b757d = $(`<div id="html_8febf5b5ec02452a8e05e5334a3b757d" style="width: 100.0%; height: 100.0%;">Totem Cours la Reine E-O</div>`)[0];
            popup_c47d628577544c8b96d0123abe4dffd1.setContent(html_8febf5b5ec02452a8e05e5334a3b757d);
        

        marker_509397e4b7d3456f9eab48493a39abd3.bindPopup(popup_c47d628577544c8b96d0123abe4dffd1)
        ;

        
    
    
            var marker_5e46847c4ca2487993255fd2c80d784c = L.marker(
                [48.851131, 2.345678],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_8ac4fdbaa4ab43ad80c26f4c1e03b290 = L.popup({"maxWidth": "100%"});

        
            var html_2f264f96ad0b4ba1a5217c0109b18adb = $(`<div id="html_2f264f96ad0b4ba1a5217c0109b18adb" style="width: 100.0%; height: 100.0%;">30 rue Saint Jacques N-S</div>`)[0];
            popup_8ac4fdbaa4ab43ad80c26f4c1e03b290.setContent(html_2f264f96ad0b4ba1a5217c0109b18adb);
        

        marker_5e46847c4ca2487993255fd2c80d784c.bindPopup(popup_8ac4fdbaa4ab43ad80c26f4c1e03b290)
        ;

        
    
    
            var marker_b90c56ca4bb44bf0adc27c5c68c354d2 = L.marker(
                [48.8484, 2.27586],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_0f0e6196a6b94626941f47bc0a0f385c = L.popup({"maxWidth": "100%"});

        
            var html_498a5d4ba41245989c5643271e65437c = $(`<div id="html_498a5d4ba41245989c5643271e65437c" style="width: 100.0%; height: 100.0%;">Voie Georges Pompidou SO-NE</div>`)[0];
            popup_0f0e6196a6b94626941f47bc0a0f385c.setContent(html_498a5d4ba41245989c5643271e65437c);
        

        marker_b90c56ca4bb44bf0adc27c5c68c354d2.bindPopup(popup_0f0e6196a6b94626941f47bc0a0f385c)
        ;

        
    
    
            var marker_48c234ac3d7b46889494c3d04e0336de = L.marker(
                [48.877686, 2.354471],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_9834a07f28444618a8909b6f255ea9dc = L.popup({"maxWidth": "100%"});

        
            var html_41e9dd89c89c4de2bf7d341e74ddd1c7 = $(`<div id="html_41e9dd89c89c4de2bf7d341e74ddd1c7" style="width: 100.0%; height: 100.0%;">89 boulevard de Magenta NO-SE</div>`)[0];
            popup_9834a07f28444618a8909b6f255ea9dc.setContent(html_41e9dd89c89c4de2bf7d341e74ddd1c7);
        

        marker_48c234ac3d7b46889494c3d04e0336de.bindPopup(popup_9834a07f28444618a8909b6f255ea9dc)
        ;

        
    
    
            var marker_123907adda9642018db935a39a0dd831 = L.marker(
                [48.86461, 2.40969],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_cff9a34f299141ebb5c481d15f8f62fc = L.popup({"maxWidth": "100%"});

        
            var html_33c21c11894e4507b1e47d5628150cd1 = $(`<div id="html_33c21c11894e4507b1e47d5628150cd1" style="width: 100.0%; height: 100.0%;">Face au 4 avenue de la porte de Bagnolet O-E</div>`)[0];
            popup_cff9a34f299141ebb5c481d15f8f62fc.setContent(html_33c21c11894e4507b1e47d5628150cd1);
        

        marker_123907adda9642018db935a39a0dd831.bindPopup(popup_cff9a34f299141ebb5c481d15f8f62fc)
        ;

        
    
    
            var marker_99546a14177147379eab9d77a35e1fec = L.marker(
                [48.84201, 2.36729],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_5f7e837544ff41b6a635f48e4f26cf1e = L.popup({"maxWidth": "100%"});

        
            var html_a4b8cded06544b7283c6c75b85ad7b97 = $(`<div id="html_a4b8cded06544b7283c6c75b85ad7b97" style="width: 100.0%; height: 100.0%;">Totem 85 quai d'Austerlitz SE-NO</div>`)[0];
            popup_5f7e837544ff41b6a635f48e4f26cf1e.setContent(html_a4b8cded06544b7283c6c75b85ad7b97);
        

        marker_99546a14177147379eab9d77a35e1fec.bindPopup(popup_5f7e837544ff41b6a635f48e4f26cf1e)
        ;

        
    
    
            var marker_3abdafa3e69a435fa6d38f05625bbb40 = L.marker(
                [48.83068, 2.35348],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_be0e0c9ed0e44231bf7ebcc596850946 = L.popup({"maxWidth": "100%"});

        
            var html_a5465e2dcf8c44aba1dbee7255e62886 = $(`<div id="html_a5465e2dcf8c44aba1dbee7255e62886" style="width: 100.0%; height: 100.0%;">10 boulevard Auguste Blanqui NE-SO</div>`)[0];
            popup_be0e0c9ed0e44231bf7ebcc596850946.setContent(html_a5465e2dcf8c44aba1dbee7255e62886);
        

        marker_3abdafa3e69a435fa6d38f05625bbb40.bindPopup(popup_be0e0c9ed0e44231bf7ebcc596850946)
        ;

        
    
    
            var marker_9042f386c7b3493b9f0a3342e7381a1c = L.marker(
                [48.88926, 2.37472],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_4611ab7c67074e45bf34bb13e36cd9b9 = L.popup({"maxWidth": "100%"});

        
            var html_49955de9254946b792e5982629afff4f = $(`<div id="html_49955de9254946b792e5982629afff4f" style="width: 100.0%; height: 100.0%;">87 avenue de Flandre NE-SO</div>`)[0];
            popup_4611ab7c67074e45bf34bb13e36cd9b9.setContent(html_49955de9254946b792e5982629afff4f);
        

        marker_9042f386c7b3493b9f0a3342e7381a1c.bindPopup(popup_4611ab7c67074e45bf34bb13e36cd9b9)
        ;

        
    
    
            var marker_15604442103e4a3290bbd5dee8444884 = L.marker(
                [48.82024, 2.35902],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_1dde175a0b6840b3a960616afb4fbc36 = L.popup({"maxWidth": "100%"});

        
            var html_46364dcb9d644303a212682389ffc687 = $(`<div id="html_46364dcb9d644303a212682389ffc687" style="width: 100.0%; height: 100.0%;">180 avenue d'Italie N-S</div>`)[0];
            popup_1dde175a0b6840b3a960616afb4fbc36.setContent(html_46364dcb9d644303a212682389ffc687);
        

        marker_15604442103e4a3290bbd5dee8444884.bindPopup(popup_1dde175a0b6840b3a960616afb4fbc36)
        ;

        
    
    
            var marker_f045d9fe72db40c99facead474db7593 = L.marker(
                [48.88529, 2.32666],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_ff3d053a6305458e9cedf330ae8b7e29 = L.popup({"maxWidth": "100%"});

        
            var html_7169939575004db3b5b03b6895e6fac8 = $(`<div id="html_7169939575004db3b5b03b6895e6fac8" style="width: 100.0%; height: 100.0%;">20 Avenue de Clichy NO-SE</div>`)[0];
            popup_ff3d053a6305458e9cedf330ae8b7e29.setContent(html_7169939575004db3b5b03b6895e6fac8);
        

        marker_f045d9fe72db40c99facead474db7593.bindPopup(popup_ff3d053a6305458e9cedf330ae8b7e29)
        ;

        
    
    
            var marker_a84456fd4df3417bb133ec44c89a0544 = L.marker(
                [48.83511, 2.33338],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_da3d7be6fa4449dbaec8011489d8771d = L.popup({"maxWidth": "100%"});

        
            var html_da2239e59f3547ba81e091c364dc49ee = $(`<div id="html_da2239e59f3547ba81e091c364dc49ee" style="width: 100.0%; height: 100.0%;">97 avenue Denfert Rochereau SO-NE</div>`)[0];
            popup_da3d7be6fa4449dbaec8011489d8771d.setContent(html_da2239e59f3547ba81e091c364dc49ee);
        

        marker_a84456fd4df3417bb133ec44c89a0544.bindPopup(popup_da3d7be6fa4449dbaec8011489d8771d)
        ;

        
    
    
            var marker_1164e948421e411d98d41595df5c26ec = L.marker(
                [48.87451, 2.29215],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_78b949cde7b8453695711a0dd8d062ed = L.popup({"maxWidth": "100%"});

        
            var html_ee12451ad2bb4b0594ecd3482af53703 = $(`<div id="html_ee12451ad2bb4b0594ecd3482af53703" style="width: 100.0%; height: 100.0%;">7 avenue de la Grande Armée NO-SE</div>`)[0];
            popup_78b949cde7b8453695711a0dd8d062ed.setContent(html_ee12451ad2bb4b0594ecd3482af53703);
        

        marker_1164e948421e411d98d41595df5c26ec.bindPopup(popup_78b949cde7b8453695711a0dd8d062ed)
        ;

        
    
    
            var marker_99632a63621942a2877674a0a62fde1c = L.marker(
                [48.877726, 2.354926],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_82d464a546e54d0ca7f95e2c808d0e5a = L.popup({"maxWidth": "100%"});

        
            var html_6462fd47d5ae42fd93904e8383d2e065 = $(`<div id="html_6462fd47d5ae42fd93904e8383d2e065" style="width: 100.0%; height: 100.0%;">102 boulevard de Magenta SE-NO</div>`)[0];
            popup_82d464a546e54d0ca7f95e2c808d0e5a.setContent(html_6462fd47d5ae42fd93904e8383d2e065);
        

        marker_99632a63621942a2877674a0a62fde1c.bindPopup(popup_82d464a546e54d0ca7f95e2c808d0e5a)
        ;

        
    
    
            var marker_61decb9bc6864e38b4644891df661dfd = L.marker(
                [48.881626, 2.281203],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_130809c763524b1b8cbe08a44e382633 = L.popup({"maxWidth": "100%"});

        
            var html_23deb39c9f704ef381fbceb0984f7644 = $(`<div id="html_23deb39c9f704ef381fbceb0984f7644" style="width: 100.0%; height: 100.0%;">Face au 16 avenue de la  Porte des Ternes O-E</div>`)[0];
            popup_130809c763524b1b8cbe08a44e382633.setContent(html_23deb39c9f704ef381fbceb0984f7644);
        

        marker_61decb9bc6864e38b4644891df661dfd.bindPopup(popup_130809c763524b1b8cbe08a44e382633)
        ;

        
    
    
            var marker_c36d8bd2413d4fd586841b63e6727861 = L.marker(
                [48.890457, 2.368852],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_7a5f38e05f80499890b3be3c593de687 = L.popup({"maxWidth": "100%"});

        
            var html_8d21fbb1704f4d0eb3be4cb213c4c2a6 = $(`<div id="html_8d21fbb1704f4d0eb3be4cb213c4c2a6" style="width: 100.0%; height: 100.0%;">Face 104 rue d'Aubervilliers S-N</div>`)[0];
            popup_7a5f38e05f80499890b3be3c593de687.setContent(html_8d21fbb1704f4d0eb3be4cb213c4c2a6);
        

        marker_c36d8bd2413d4fd586841b63e6727861.bindPopup(popup_7a5f38e05f80499890b3be3c593de687)
        ;

        
    
    
            var marker_ca9d8f032dcd4bfdb9d3f37a25fadd3e = L.marker(
                [48.86461, 2.40969],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_1ae0ca47dc214940904087d4e0549801 = L.popup({"maxWidth": "100%"});

        
            var html_11d4c91043f14bdb855578ea3f06e6db = $(`<div id="html_11d4c91043f14bdb855578ea3f06e6db" style="width: 100.0%; height: 100.0%;">Face au 4 avenue de la porte de Bagnolet E-O</div>`)[0];
            popup_1ae0ca47dc214940904087d4e0549801.setContent(html_11d4c91043f14bdb855578ea3f06e6db);
        

        marker_ca9d8f032dcd4bfdb9d3f37a25fadd3e.bindPopup(popup_1ae0ca47dc214940904087d4e0549801)
        ;

        
    
    
            var marker_39d8173fe59d4eefb1c359263d6ec2f4 = L.marker(
                [48.84223, 2.36811],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_cbbc0c88f9ab4a85805dfb110f0c957f = L.popup({"maxWidth": "100%"});

        
            var html_c1ce091e05264a77a97db83685fff98d = $(`<div id="html_c1ce091e05264a77a97db83685fff98d" style="width: 100.0%; height: 100.0%;">Pont Charles De Gaulle SO-NE</div>`)[0];
            popup_cbbc0c88f9ab4a85805dfb110f0c957f.setContent(html_c1ce091e05264a77a97db83685fff98d);
        

        marker_39d8173fe59d4eefb1c359263d6ec2f4.bindPopup(popup_cbbc0c88f9ab4a85805dfb110f0c957f)
        ;

        
    
    
            var marker_9181043e8c1342c5b95ca7a89b5fca6a = L.marker(
                [48.891215, 2.38573],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_96980244c6484b0ebec07f2449be25dd = L.popup({"maxWidth": "100%"});

        
            var html_b61ea95417da4bc9b27b43d03d7aabbf = $(`<div id="html_b61ea95417da4bc9b27b43d03d7aabbf" style="width: 100.0%; height: 100.0%;">Face au 48 quai de la marne SO-NE</div>`)[0];
            popup_96980244c6484b0ebec07f2449be25dd.setContent(html_b61ea95417da4bc9b27b43d03d7aabbf);
        

        marker_9181043e8c1342c5b95ca7a89b5fca6a.bindPopup(popup_96980244c6484b0ebec07f2449be25dd)
        ;

        
    
    
            var marker_ce5b7850c5784d1ab92fbbd5994d2d41 = L.marker(
                [48.830331, 2.400551],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_43afb5403f03463492d75e4ad3effc23 = L.popup({"maxWidth": "100%"});

        
            var html_2d0848d3bc664470ab52f4977dce9d13 = $(`<div id="html_2d0848d3bc664470ab52f4977dce9d13" style="width: 100.0%; height: 100.0%;">Face au 8 avenue de la porte de Charenton NO-SE</div>`)[0];
            popup_43afb5403f03463492d75e4ad3effc23.setContent(html_2d0848d3bc664470ab52f4977dce9d13);
        

        marker_ce5b7850c5784d1ab92fbbd5994d2d41.bindPopup(popup_43afb5403f03463492d75e4ad3effc23)
        ;

        
    
    
            var marker_cb0a03eaeba64cc5afad734edc244694 = L.marker(
                [48.86462, 2.31444],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_17beabeb58a1413e9b4a43bedf00c7f4 = L.popup({"maxWidth": "100%"});

        
            var html_a21bd46ecc884000bc2855a7d1e40135 = $(`<div id="html_a21bd46ecc884000bc2855a7d1e40135" style="width: 100.0%; height: 100.0%;">Totem Cours la Reine O-E</div>`)[0];
            popup_17beabeb58a1413e9b4a43bedf00c7f4.setContent(html_a21bd46ecc884000bc2855a7d1e40135);
        

        marker_cb0a03eaeba64cc5afad734edc244694.bindPopup(popup_17beabeb58a1413e9b4a43bedf00c7f4)
        ;

        
    
    
            var marker_63a6749d820f4b2fb9b90331419e4c18 = L.marker(
                [48.86155, 2.37407],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_fe2cd03612594e59b7c25581373d8aad = L.popup({"maxWidth": "100%"});

        
            var html_ed65bb3583624f8d8c32354a1d2bad92 = $(`<div id="html_ed65bb3583624f8d8c32354a1d2bad92" style="width: 100.0%; height: 100.0%;">72 boulevard Voltaire NO-SE</div>`)[0];
            popup_fe2cd03612594e59b7c25581373d8aad.setContent(html_ed65bb3583624f8d8c32354a1d2bad92);
        

        marker_63a6749d820f4b2fb9b90331419e4c18.bindPopup(popup_fe2cd03612594e59b7c25581373d8aad)
        ;

        
    
    
            var marker_3016b07d38aa41ec80b62a894d036dd6 = L.marker(
                [48.86057, 2.38886],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_88fd50df36734f6ca61d41f33cbd3f8c = L.popup({"maxWidth": "100%"});

        
            var html_288b6b1104274fad8078aacd6aa21728 = $(`<div id="html_288b6b1104274fad8078aacd6aa21728" style="width: 100.0%; height: 100.0%;">26 boulevard de Ménilmontant SE-NO</div>`)[0];
            popup_88fd50df36734f6ca61d41f33cbd3f8c.setContent(html_288b6b1104274fad8078aacd6aa21728);
        

        marker_3016b07d38aa41ec80b62a894d036dd6.bindPopup(popup_88fd50df36734f6ca61d41f33cbd3f8c)
        ;

        
    
    
            var marker_78ffcd290de045df83dccb47c7e2139a = L.marker(
                [48.829523, 2.38699],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_6e00790d832b4114909e85d02f7b81da = L.popup({"maxWidth": "100%"});

        
            var html_b0aa14b5145840919a8fbb15a3b529ff = $(`<div id="html_b0aa14b5145840919a8fbb15a3b529ff" style="width: 100.0%; height: 100.0%;">Face au 70 quai de Bercy S-N</div>`)[0];
            popup_6e00790d832b4114909e85d02f7b81da.setContent(html_b0aa14b5145840919a8fbb15a3b529ff);
        

        marker_78ffcd290de045df83dccb47c7e2139a.bindPopup(popup_6e00790d832b4114909e85d02f7b81da)
        ;

        
    
    
            var marker_cf324f07eabf4754880ad34924f18dcf = L.marker(
                [48.829523, 2.38699],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_95e765a9114a474bb6acb9c0c8ebe8c1 = L.popup({"maxWidth": "100%"});

        
            var html_ef643d031cf44abe846034d186e03ba6 = $(`<div id="html_ef643d031cf44abe846034d186e03ba6" style="width: 100.0%; height: 100.0%;">Face au 70 quai de Bercy N-S</div>`)[0];
            popup_95e765a9114a474bb6acb9c0c8ebe8c1.setContent(html_ef643d031cf44abe846034d186e03ba6);
        

        marker_cf324f07eabf4754880ad34924f18dcf.bindPopup(popup_95e765a9114a474bb6acb9c0c8ebe8c1)
        ;

        
    
    
            var marker_3b472cb3cd8e456ea2695c34fd781f23 = L.marker(
                [48.83848, 2.37587],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_a4767fc1f5eb4ab8af7ec6d028363386 = L.popup({"maxWidth": "100%"});

        
            var html_88cd8178fd094627b6d44b7fd971b7e9 = $(`<div id="html_88cd8178fd094627b6d44b7fd971b7e9" style="width: 100.0%; height: 100.0%;">Pont de Bercy SO-NE</div>`)[0];
            popup_a4767fc1f5eb4ab8af7ec6d028363386.setContent(html_88cd8178fd094627b6d44b7fd971b7e9);
        

        marker_3b472cb3cd8e456ea2695c34fd781f23.bindPopup(popup_a4767fc1f5eb4ab8af7ec6d028363386)
        ;

        
    
    
            var marker_a5eb013abce0486bb434f1e000e411d4 = L.marker(
                [48.86288, 2.31179],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_f790e9a1ca894007a25d67c26333e16a = L.popup({"maxWidth": "100%"});

        
            var html_ab8a5f1108bc480f814f37adabfc6523 = $(`<div id="html_ab8a5f1108bc480f814f37adabfc6523" style="width: 100.0%; height: 100.0%;">Quai d'Orsay E-O</div>`)[0];
            popup_f790e9a1ca894007a25d67c26333e16a.setContent(html_ab8a5f1108bc480f814f37adabfc6523);
        

        marker_a5eb013abce0486bb434f1e000e411d4.bindPopup(popup_f790e9a1ca894007a25d67c26333e16a)
        ;

        
    
    
            var marker_418df642a4b94cca9e04f1a0f0acd9bf = L.marker(
                [48.85013, 2.35423],
                {}
            ).addTo(map_a76b914e522642db828e1d354e658498);
        
    
        var popup_915264a424dc4bdcbcbbdb80527eefcb = L.popup({"maxWidth": "100%"});

        
            var html_1916af6996c74a488ef557be320401b6 = $(`<div id="html_1916af6996c74a488ef557be320401b6" style="width: 100.0%; height: 100.0%;">27 quai de la Tournelle NO-SE</div>`)[0];
            popup_915264a424dc4bdcbcbbdb80527eefcb.setContent(html_1916af6996c74a488ef557be320401b6);
        

        marker_418df642a4b94cca9e04f1a0f0acd9bf.bindPopup(popup_915264a424dc4bdcbcbbdb80527eefcb)
        ;

        
    
</script><!--/html_preserve-->

{{% panel status="hint" title="Hint" icon="fa fa-lightbulb" %}}
Si un fond gris s'affiche, c'est qu'il y a un problème de localisation. Cela provient généralement d'un problème de projection ou d'une inversion des longitudes et latitudes. 

Les longitudes représentent les *x* (axe ouest-nord) et les latitudes *y* (axe sud-nord). `folium` attend qu'on lui fournisse les données sous la forme `[latitude, longitude]` donc `[y,x]`
{{% /panel %}}


{{% panel status="exercise" title="Exercice 7: Représenter les stations" icon="fas fa-pencil-alt" %}}

Faire une carte avec des ronds proportionnels au nombre de comptages:

  + Pour le rayon de chaque cercle, en notant vous pouvez faire `500*x/max(x)` (règle au doigt mouillé)
  + (Optionnel) Colorer les 10 plus grosses stations

{{< /panel >}}



```
## <folium.vector_layers.Circle object at 0x0000000006732400>
## <folium.vector_layers.Circle object at 0x0000000006732A00>
## <folium.vector_layers.Circle object at 0x0000000006732760>
## <folium.vector_layers.Circle object at 0x0000000006732BB0>
## <folium.vector_layers.Circle object at 0x0000000006732CD0>
## <folium.vector_layers.Circle object at 0x0000000006732E80>
## <folium.vector_layers.Circle object at 0x0000000006732EE0>
## <folium.vector_layers.Circle object at 0x0000000006732D60>
## <folium.vector_layers.Circle object at 0x0000000006732A90>
## <folium.vector_layers.Circle object at 0x0000000006746130>
## <folium.vector_layers.Circle object at 0x0000000006746250>
## <folium.vector_layers.Circle object at 0x0000000006746370>
## <folium.vector_layers.Circle object at 0x0000000006746490>
## <folium.vector_layers.Circle object at 0x00000000067465B0>
## <folium.vector_layers.Circle object at 0x00000000067324F0>
## <folium.vector_layers.Circle object at 0x0000000006746700>
## <folium.vector_layers.Circle object at 0x0000000006746850>
## <folium.vector_layers.Circle object at 0x0000000006746970>
## <folium.vector_layers.Circle object at 0x0000000006746A90>
## <folium.vector_layers.Circle object at 0x0000000006746BB0>
## <folium.vector_layers.Circle object at 0x0000000006746CD0>
## <folium.vector_layers.Circle object at 0x0000000006746DF0>
## <folium.vector_layers.Circle object at 0x0000000006746F10>
## <folium.vector_layers.Circle object at 0x0000000006746070>
## <folium.vector_layers.Circle object at 0x0000000006758190>
## <folium.vector_layers.Circle object at 0x00000000067582B0>
## <folium.vector_layers.Circle object at 0x00000000067583D0>
## <folium.vector_layers.Circle object at 0x00000000067584F0>
## <folium.vector_layers.Circle object at 0x0000000006758610>
## <folium.vector_layers.Circle object at 0x0000000006758730>
## <folium.vector_layers.Circle object at 0x0000000006758850>
## <folium.vector_layers.Circle object at 0x0000000006758970>
## <folium.vector_layers.Circle object at 0x0000000006758A90>
## <folium.vector_layers.Circle object at 0x0000000006758BB0>
## <folium.vector_layers.Circle object at 0x0000000006758CD0>
## <folium.vector_layers.Circle object at 0x0000000006758DF0>
## <folium.vector_layers.Circle object at 0x0000000006758F10>
## <folium.vector_layers.Circle object at 0x0000000006758040>
## <folium.vector_layers.Circle object at 0x0000000006817190>
## <folium.vector_layers.Circle object at 0x00000000068172B0>
## <folium.vector_layers.Circle object at 0x00000000068173D0>
## <folium.vector_layers.Circle object at 0x00000000068174F0>
## <folium.vector_layers.Circle object at 0x0000000006817640>
## <folium.vector_layers.Circle object at 0x0000000006817760>
## <folium.vector_layers.Circle object at 0x0000000006817880>
## <folium.vector_layers.Circle object at 0x00000000068179A0>
## <folium.vector_layers.Circle object at 0x0000000006817AC0>
## <folium.vector_layers.Circle object at 0x0000000006817BE0>
## <folium.vector_layers.Circle object at 0x0000000006817D00>
## <folium.vector_layers.Circle object at 0x0000000006817E20>
## <folium.vector_layers.Circle object at 0x0000000006817F40>
## <folium.vector_layers.Circle object at 0x000000000682A0A0>
## <folium.vector_layers.Circle object at 0x000000000682A1C0>
## <folium.vector_layers.Circle object at 0x000000000682A2E0>
## <folium.vector_layers.Circle object at 0x000000000682A400>
## <folium.vector_layers.Circle object at 0x000000000682A550>
## <folium.vector_layers.Circle object at 0x000000000682A670>
## <folium.vector_layers.Circle object at 0x000000000682A790>
## <folium.vector_layers.Circle object at 0x000000000682A8B0>
## <folium.vector_layers.Circle object at 0x000000000682AA00>
## <folium.vector_layers.Circle object at 0x000000000682AB20>
## <folium.vector_layers.Circle object at 0x000000000682AC40>
## <folium.vector_layers.Circle object at 0x000000000682AD60>
## <folium.vector_layers.Circle object at 0x000000000682AE80>
## <folium.vector_layers.Circle object at 0x000000000682AFA0>
## <folium.vector_layers.Circle object at 0x000000000683B100>
## <folium.vector_layers.Circle object at 0x000000000683B250>
## <folium.vector_layers.Circle object at 0x000000000683B370>
## <folium.vector_layers.Circle object at 0x000000000683B490>
## <folium.vector_layers.Circle object at 0x000000000683B5B0>
## <folium.vector_layers.Circle object at 0x000000000683B6D0>
## <folium.vector_layers.Circle object at 0x000000000683B7F0>
## <folium.vector_layers.Circle object at 0x000000000683B910>
## <folium.vector_layers.Circle object at 0x000000000683BA30>
## <folium.vector_layers.Circle object at 0x000000000683BB50>
## <folium.vector_layers.Circle object at 0x000000000683BC70>
## <folium.vector_layers.Circle object at 0x000000000683BD90>
## <folium.vector_layers.Circle object at 0x000000000683BEB0>
## <folium.vector_layers.Circle object at 0x000000000683B0A0>
## <folium.vector_layers.Circle object at 0x000000000684B160>
## <folium.vector_layers.Circle object at 0x000000000684B280>
## <folium.vector_layers.Circle object at 0x000000000684B3A0>
## <folium.vector_layers.Circle object at 0x000000000684B4C0>
## <folium.vector_layers.Circle object at 0x000000000684B5E0>
## <folium.vector_layers.Circle object at 0x000000000684B700>
## <folium.vector_layers.Circle object at 0x000000000684B820>
## <folium.vector_layers.Circle object at 0x000000000684B940>
## <folium.vector_layers.Circle object at 0x000000000684BA60>
## <folium.vector_layers.Circle object at 0x000000000684BB80>
## <folium.vector_layers.Circle object at 0x000000000684BCA0>
## <folium.vector_layers.Circle object at 0x000000000684BDC0>
## <folium.vector_layers.Circle object at 0x000000000684BEE0>
## <folium.vector_layers.Circle object at 0x000000000684B040>
## <folium.vector_layers.Circle object at 0x000000000685D160>
## <folium.vector_layers.Circle object at 0x000000000685D280>
```

<!--html_preserve--><!DOCTYPE html>
<head>    
    <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
    
        <script>
            L_NO_TOUCH = false;
            L_DISABLE_3D = false;
        </script>
    
    <script src="https://cdn.jsdelivr.net/npm/leaflet@1.6.0/dist/leaflet.js"></script>
    <script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Leaflet.awesome-markers/2.0.2/leaflet.awesome-markers.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/leaflet@1.6.0/dist/leaflet.css"/>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css"/>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.6.3/css/font-awesome.min.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/Leaflet.awesome-markers/2.0.2/leaflet.awesome-markers.css"/>
    <link rel="stylesheet" href="https://rawcdn.githack.com/python-visualization/folium/master/folium/templates/leaflet.awesome.rotate.css"/>
    <style>html, body {width: 100%;height: 100%;margin: 0;padding: 0;}</style>
    <style>#map {position:absolute;top:0;bottom:0;right:0;left:0;}</style>
    
            <meta name="viewport" content="width=device-width,
                initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
            <style>
                #map_b6e309cf326f424ba5f127e505b86afd {
                    position: relative;
                    width: 100.0%;
                    height: 100.0%;
                    left: 0.0%;
                    top: 0.0%;
                }
            </style>
        
</head>
<body>    
    
            <div class="folium-map" id="map_b6e309cf326f424ba5f127e505b86afd" ></div>
        
</body>
<script>    
    
            var map_b6e309cf326f424ba5f127e505b86afd = L.map(
                "map_b6e309cf326f424ba5f127e505b86afd",
                {
                    center: [48.856972463768095, 2.343495594202899],
                    crs: L.CRS.EPSG3857,
                    zoom: 12,
                    zoomControl: true,
                    preferCanvas: false,
                }
            );

            

        
    
            var tile_layer_89a15a1239844e478e4731bfe0553c40 = L.tileLayer(
                "https://stamen-tiles-{s}.a.ssl.fastly.net/toner/{z}/{x}/{y}.png",
                {"attribution": "Map tiles by \u003ca href=\"http://stamen.com\"\u003eStamen Design\u003c/a\u003e, under \u003ca href=\"http://creativecommons.org/licenses/by/3.0\"\u003eCC BY 3.0\u003c/a\u003e. Data by \u0026copy; \u003ca href=\"http://openstreetmap.org\"\u003eOpenStreetMap\u003c/a\u003e, under \u003ca href=\"http://www.openstreetmap.org/copyright\"\u003eODbL\u003c/a\u003e.", "detectRetina": false, "maxNativeZoom": 18, "maxZoom": 18, "minZoom": 0, "noWrap": false, "opacity": 1, "subdomains": "abc", "tms": false}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
            var circle_2b4131a7a20a4fa7bab08c14b5519faf = L.circle(
                [48.86149, 2.37376],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_19821d14e65145778b4b731a1e9f84e1 = L.popup({"maxWidth": "100%"});

        
            var html_8fbcf5e2c61047d9a583d9e3a993d141 = $(`<div id="html_8fbcf5e2c61047d9a583d9e3a993d141" style="width: 100.0%; height: 100.0%;">67 boulevard Voltaire SE-NO</div>`)[0];
            popup_19821d14e65145778b4b731a1e9f84e1.setContent(html_8fbcf5e2c61047d9a583d9e3a993d141);
        

        circle_2b4131a7a20a4fa7bab08c14b5519faf.bindPopup(popup_19821d14e65145778b4b731a1e9f84e1)
        ;

        
    
    
            var circle_d3ac13fe3b5444a2b57a55cf2e512910 = L.circle(
                [48.830449, 2.353199],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.00000000000006, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_21f2cd328cc945f881bedfdb2591963d = L.popup({"maxWidth": "100%"});

        
            var html_923990d006f2431481ff75127ee6fb60 = $(`<div id="html_923990d006f2431481ff75127ee6fb60" style="width: 100.0%; height: 100.0%;">21 boulevard Auguste Blanqui SO-NE</div>`)[0];
            popup_21f2cd328cc945f881bedfdb2591963d.setContent(html_923990d006f2431481ff75127ee6fb60);
        

        circle_d3ac13fe3b5444a2b57a55cf2e512910.bindPopup(popup_21f2cd328cc945f881bedfdb2591963d)
        ;

        
    
    
            var circle_1d280e1421204703b2a5d493c3fb389c = L.circle(
                [48.83992, 2.26694],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_641bb9057c1b4fdcbbfbbc3ea4e81b8a = L.popup({"maxWidth": "100%"});

        
            var html_0c66716264de43cf8cbe793bd5fa4027 = $(`<div id="html_0c66716264de43cf8cbe793bd5fa4027" style="width: 100.0%; height: 100.0%;">Pont du Garigliano SE-NO SE-NO</div>`)[0];
            popup_641bb9057c1b4fdcbbfbbc3ea4e81b8a.setContent(html_0c66716264de43cf8cbe793bd5fa4027);
        

        circle_1d280e1421204703b2a5d493c3fb389c.bindPopup(popup_641bb9057c1b4fdcbbfbbc3ea4e81b8a)
        ;

        
    
    
            var circle_28e3d598a9734b408fe174607ba383cd = L.circle(
                [48.840801, 2.333233],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_5d0e9e5ce98d40588de3d2b6a8a9b2a1 = L.popup({"maxWidth": "100%"});

        
            var html_24f7235b7d0d4484a488c2562c986f78 = $(`<div id="html_24f7235b7d0d4484a488c2562c986f78" style="width: 100.0%; height: 100.0%;">152 boulevard du Montparnasse O-E</div>`)[0];
            popup_5d0e9e5ce98d40588de3d2b6a8a9b2a1.setContent(html_24f7235b7d0d4484a488c2562c986f78);
        

        circle_28e3d598a9734b408fe174607ba383cd.bindPopup(popup_5d0e9e5ce98d40588de3d2b6a8a9b2a1)
        ;

        
    
    
            var circle_e9718a27ac8d4bfda01e281273b75ea7 = L.circle(
                [48.896894, 2.344994],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.00000000000006, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_ece43806b6d442a7bbaabc76b9ca99d5 = L.popup({"maxWidth": "100%"});

        
            var html_19e1b570a7db4426a0e106c4f11580a7 = $(`<div id="html_19e1b570a7db4426a0e106c4f11580a7" style="width: 100.0%; height: 100.0%;">69 Boulevard Ornano N-S</div>`)[0];
            popup_ece43806b6d442a7bbaabc76b9ca99d5.setContent(html_19e1b570a7db4426a0e106c4f11580a7);
        

        circle_e9718a27ac8d4bfda01e281273b75ea7.bindPopup(popup_ece43806b6d442a7bbaabc76b9ca99d5)
        ;

        
    
    
            var circle_598bba313732435bbda39ce1fdfecd85 = L.circle(
                [48.87746, 2.35008],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_e42ed9aab499453bb4a6399635bfd443 = L.popup({"maxWidth": "100%"});

        
            var html_cf53138cbfce4352a73f81a29f05885d = $(`<div id="html_cf53138cbfce4352a73f81a29f05885d" style="width: 100.0%; height: 100.0%;">100 rue La Fayette O-E</div>`)[0];
            popup_e42ed9aab499453bb4a6399635bfd443.setContent(html_cf53138cbfce4352a73f81a29f05885d);
        

        circle_598bba313732435bbda39ce1fdfecd85.bindPopup(popup_e42ed9aab499453bb4a6399635bfd443)
        ;

        
    
    
            var circle_c03f699cc88540aa89524158ee112b41 = L.circle(
                [48.874716, 2.292439],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_778808b4660340a6958e78025adf4b20 = L.popup({"maxWidth": "100%"});

        
            var html_2aa17bd3e7dd4113b40202c45e921d57 = $(`<div id="html_2aa17bd3e7dd4113b40202c45e921d57" style="width: 100.0%; height: 100.0%;">10 avenue de la Grande Armée SE-NO</div>`)[0];
            popup_778808b4660340a6958e78025adf4b20.setContent(html_2aa17bd3e7dd4113b40202c45e921d57);
        

        circle_c03f699cc88540aa89524158ee112b41.bindPopup(popup_778808b4660340a6958e78025adf4b20)
        ;

        
    
    
            var circle_7da953256bc8471dab59622d2143e396 = L.circle(
                [48.891415, 2.384954],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_f355d38ac1b743719aa07e744e4d0149 = L.popup({"maxWidth": "100%"});

        
            var html_d451b47402fd49f6b57def45120a8b49 = $(`<div id="html_d451b47402fd49f6b57def45120a8b49" style="width: 100.0%; height: 100.0%;">Face au 25 quai de l'Oise SO-NE</div>`)[0];
            popup_f355d38ac1b743719aa07e744e4d0149.setContent(html_d451b47402fd49f6b57def45120a8b49);
        

        circle_7da953256bc8471dab59622d2143e396.bindPopup(popup_f355d38ac1b743719aa07e744e4d0149)
        ;

        
    
    
            var circle_df2c443e7d9a48b7ab629b78ff49e459 = L.circle(
                [48.82026, 2.3592],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_d0428206ca994f4bb5afc91658ef55f0 = L.popup({"maxWidth": "100%"});

        
            var html_42b8f05c71ed45b78711aa0cfb06ef0f = $(`<div id="html_42b8f05c71ed45b78711aa0cfb06ef0f" style="width: 100.0%; height: 100.0%;">147 avenue d'Italie S-N</div>`)[0];
            popup_d0428206ca994f4bb5afc91658ef55f0.setContent(html_42b8f05c71ed45b78711aa0cfb06ef0f);
        

        circle_df2c443e7d9a48b7ab629b78ff49e459.bindPopup(popup_d0428206ca994f4bb5afc91658ef55f0)
        ;

        
    
    
            var circle_8e91c70e287e4bc38111e41cabee3e3d = L.circle(
                [48.85209, 2.28508],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_08d90f4d727147ba98c1deec1db48d34 = L.popup({"maxWidth": "100%"});

        
            var html_00cdfd88112b4fbb9c3f4db89fea5658 = $(`<div id="html_00cdfd88112b4fbb9c3f4db89fea5658" style="width: 100.0%; height: 100.0%;">36 quai de Grenelle SO-NE</div>`)[0];
            popup_08d90f4d727147ba98c1deec1db48d34.setContent(html_00cdfd88112b4fbb9c3f4db89fea5658);
        

        circle_8e91c70e287e4bc38111e41cabee3e3d.bindPopup(popup_08d90f4d727147ba98c1deec1db48d34)
        ;

        
    
    
            var circle_360ef86877994382b41195dc98ccd7d2 = L.circle(
                [48.83848, 2.37587],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_9924cd5f39e541b19d5c724c6f75a0b4 = L.popup({"maxWidth": "100%"});

        
            var html_16d3992398b84814a28d76cdfd8784fb = $(`<div id="html_16d3992398b84814a28d76cdfd8784fb" style="width: 100.0%; height: 100.0%;">Pont de Bercy NE-SO</div>`)[0];
            popup_9924cd5f39e541b19d5c724c6f75a0b4.setContent(html_16d3992398b84814a28d76cdfd8784fb);
        

        circle_360ef86877994382b41195dc98ccd7d2.bindPopup(popup_9924cd5f39e541b19d5c724c6f75a0b4)
        ;

        
    
    
            var circle_441d9cdadbcf4b6c8677753feff37994 = L.circle(
                [48.889046, 2.374872],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_22bc030f297e4c5bb1b2ae8461aefc50 = L.popup({"maxWidth": "100%"});

        
            var html_501ee349956d47a18dd6e4c07bc026b0 = $(`<div id="html_501ee349956d47a18dd6e4c07bc026b0" style="width: 100.0%; height: 100.0%;">72 avenue de Flandre SO-NE</div>`)[0];
            popup_22bc030f297e4c5bb1b2ae8461aefc50.setContent(html_501ee349956d47a18dd6e4c07bc026b0);
        

        circle_441d9cdadbcf4b6c8677753feff37994.bindPopup(popup_22bc030f297e4c5bb1b2ae8461aefc50)
        ;

        
    
    
            var circle_61864981ce264e1cb6439c938bb8be96 = L.circle(
                [48.86377, 2.35096],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_9934f1ae2e7d4e01b95ac59c7910b6ef = L.popup({"maxWidth": "100%"});

        
            var html_f855220e2a2e48b580c4b9924443183c = $(`<div id="html_f855220e2a2e48b580c4b9924443183c" style="width: 100.0%; height: 100.0%;">Totem 73 boulevard de Sébastopol N-S</div>`)[0];
            popup_9934f1ae2e7d4e01b95ac59c7910b6ef.setContent(html_f855220e2a2e48b580c4b9924443183c);
        

        circle_61864981ce264e1cb6439c938bb8be96.bindPopup(popup_9934f1ae2e7d4e01b95ac59c7910b6ef)
        ;

        
    
    
            var circle_1baf6991027a4b9a89650aba96a9e372 = L.circle(
                [48.83521, 2.33307],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.00000000000006, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_61fb6d0b9132416e84c7c61e265cf5b2 = L.popup({"maxWidth": "100%"});

        
            var html_cc635b4f671f4d0ab4b2b6925d0c5f50 = $(`<div id="html_cc635b4f671f4d0ab4b2b6925d0c5f50" style="width: 100.0%; height: 100.0%;">106 avenue Denfert Rochereau NE-SO</div>`)[0];
            popup_61fb6d0b9132416e84c7c61e265cf5b2.setContent(html_cc635b4f671f4d0ab4b2b6925d0c5f50);
        

        circle_1baf6991027a4b9a89650aba96a9e372.bindPopup(popup_61fb6d0b9132416e84c7c61e265cf5b2)
        ;

        
    
    
            var circle_65fbbfa37e29484c9c70a1d4a41307d8 = L.circle(
                [48.8484, 2.27586],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 499.99999999999994, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_a87e012811574bf49731bc5fc6cb226f = L.popup({"maxWidth": "100%"});

        
            var html_2e1f3f304535476ab4f1a196084d3579 = $(`<div id="html_2e1f3f304535476ab4f1a196084d3579" style="width: 100.0%; height: 100.0%;">Voie Georges Pompidou NE-SO</div>`)[0];
            popup_a87e012811574bf49731bc5fc6cb226f.setContent(html_2e1f3f304535476ab4f1a196084d3579);
        

        circle_65fbbfa37e29484c9c70a1d4a41307d8.bindPopup(popup_a87e012811574bf49731bc5fc6cb226f)
        ;

        
    
    
            var circle_7655d03f97734657b5689744484eef28 = L.circle(
                [48.842091, 2.301],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_81934dfd0e804f07b525dbe379f4879a = L.popup({"maxWidth": "100%"});

        
            var html_b743848fcc5e4cd99a772ba1d2988f16 = $(`<div id="html_b743848fcc5e4cd99a772ba1d2988f16" style="width: 100.0%; height: 100.0%;">129 rue Lecourbe SO-NE</div>`)[0];
            popup_81934dfd0e804f07b525dbe379f4879a.setContent(html_b743848fcc5e4cd99a772ba1d2988f16);
        

        circle_7655d03f97734657b5689744484eef28.bindPopup(popup_81934dfd0e804f07b525dbe379f4879a)
        ;

        
    
    
            var circle_9a158928ee014c199108989b04e956b9 = L.circle(
                [48.84638, 2.31529],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_63c739b887324aa980f5fee68b56e56c = L.popup({"maxWidth": "100%"});

        
            var html_c12fe088f77348248a5dd952180a2002 = $(`<div id="html_c12fe088f77348248a5dd952180a2002" style="width: 100.0%; height: 100.0%;">90 Rue De Sèvres SO-NE</div>`)[0];
            popup_63c739b887324aa980f5fee68b56e56c.setContent(html_c12fe088f77348248a5dd952180a2002);
        

        circle_9a158928ee014c199108989b04e956b9.bindPopup(popup_63c739b887324aa980f5fee68b56e56c)
        ;

        
    
    
            var circle_99899381ca0a437284c61e88949b0944 = L.circle(
                [48.890457, 2.368852],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_b6caf0412bf94a279a8a62c8df2bdf1b = L.popup({"maxWidth": "100%"});

        
            var html_33433d21573b486f88e5df332f392e6c = $(`<div id="html_33433d21573b486f88e5df332f392e6c" style="width: 100.0%; height: 100.0%;">Face 104 rue d'Aubervilliers N-S</div>`)[0];
            popup_b6caf0412bf94a279a8a62c8df2bdf1b.setContent(html_33433d21573b486f88e5df332f392e6c);
        

        circle_99899381ca0a437284c61e88949b0944.bindPopup(popup_b6caf0412bf94a279a8a62c8df2bdf1b)
        ;

        
    
    
            var circle_368bd15cf4d84ee6bd591e389ea34b41 = L.circle(
                [48.86378, 2.32003],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.00000000000006, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_10f2f2b215ec4e16b8017b8a654b9116 = L.popup({"maxWidth": "100%"});

        
            var html_7a0feaa9a5dc46e589f1c67c78eca860 = $(`<div id="html_7a0feaa9a5dc46e589f1c67c78eca860" style="width: 100.0%; height: 100.0%;">Pont de la Concorde S-N</div>`)[0];
            popup_10f2f2b215ec4e16b8017b8a654b9116.setContent(html_7a0feaa9a5dc46e589f1c67c78eca860);
        

        circle_368bd15cf4d84ee6bd591e389ea34b41.bindPopup(popup_10f2f2b215ec4e16b8017b8a654b9116)
        ;

        
    
    
            var circle_97f73ebf0c884026b557f46688b53b9e = L.circle(
                [48.86288, 2.31179],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_6dfdf7a6eaf949159afe3341d3d9ce66 = L.popup({"maxWidth": "100%"});

        
            var html_f1e26103a57542c892a3bb16cfa49623 = $(`<div id="html_f1e26103a57542c892a3bb16cfa49623" style="width: 100.0%; height: 100.0%;">Quai d'Orsay O-E</div>`)[0];
            popup_6dfdf7a6eaf949159afe3341d3d9ce66.setContent(html_f1e26103a57542c892a3bb16cfa49623);
        

        circle_97f73ebf0c884026b557f46688b53b9e.bindPopup(popup_6dfdf7a6eaf949159afe3341d3d9ce66)
        ;

        
    
    
            var circle_73cefbddc70d4fdc94b5b0e860a82bbd = L.circle(
                [48.851525, 2.343298],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_a4f3dbfb47ed48eb9ea1ddb9073ed4ad = L.popup({"maxWidth": "100%"});

        
            var html_9a66bc1b72ec4eeb8daa230032bd3c03 = $(`<div id="html_9a66bc1b72ec4eeb8daa230032bd3c03" style="width: 100.0%; height: 100.0%;">21 boulevard Saint Michel S-N</div>`)[0];
            popup_a4f3dbfb47ed48eb9ea1ddb9073ed4ad.setContent(html_9a66bc1b72ec4eeb8daa230032bd3c03);
        

        circle_73cefbddc70d4fdc94b5b0e860a82bbd.bindPopup(popup_a4f3dbfb47ed48eb9ea1ddb9073ed4ad)
        ;

        
    
    
            var circle_10d1be43c94e44089d29c8cb6660718a = L.circle(
                [48.896825, 2.345648],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_a5f12014293a475fa32275429ff23b2a = L.popup({"maxWidth": "100%"});

        
            var html_4109322e1a3544febe08c2674be764d3 = $(`<div id="html_4109322e1a3544febe08c2674be764d3" style="width: 100.0%; height: 100.0%;">74 Boulevard Ornano S-N</div>`)[0];
            popup_a5f12014293a475fa32275429ff23b2a.setContent(html_4109322e1a3544febe08c2674be764d3);
        

        circle_10d1be43c94e44089d29c8cb6660718a.bindPopup(popup_a5f12014293a475fa32275429ff23b2a)
        ;

        
    
    
            var circle_0b66fde4e4b441d0b831b3a2e65d3b2a = L.circle(
                [48.82658, 2.38409],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.00000000000006, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_5122eec7f6c94d85bdc1fdd68e37da24 = L.popup({"maxWidth": "100%"});

        
            var html_ce2ff54e9b5d435b879d817f2c2e99da = $(`<div id="html_ce2ff54e9b5d435b879d817f2c2e99da" style="width: 100.0%; height: 100.0%;">Pont National SO-NE</div>`)[0];
            popup_5122eec7f6c94d85bdc1fdd68e37da24.setContent(html_ce2ff54e9b5d435b879d817f2c2e99da);
        

        circle_0b66fde4e4b441d0b831b3a2e65d3b2a.bindPopup(popup_5122eec7f6c94d85bdc1fdd68e37da24)
        ;

        
    
    
            var circle_576744a5198b4de09b7a6792df806f41 = L.circle(
                [48.891415, 2.384954],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_771fc8aed3724802ba958d59eb616f44 = L.popup({"maxWidth": "100%"});

        
            var html_b51704941b664d9f9fe2a7bd9f746fc9 = $(`<div id="html_b51704941b664d9f9fe2a7bd9f746fc9" style="width: 100.0%; height: 100.0%;">Face au 25 quai de l'Oise NE-SO</div>`)[0];
            popup_771fc8aed3724802ba958d59eb616f44.setContent(html_b51704941b664d9f9fe2a7bd9f746fc9);
        

        circle_576744a5198b4de09b7a6792df806f41.bindPopup(popup_771fc8aed3724802ba958d59eb616f44)
        ;

        
    
    
            var circle_892a5e10eb3249e6ba65112d36df47d7 = L.circle(
                [48.86392, 2.31988],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_0e6cada2df274fc4a3d28640aaa5d3b9 = L.popup({"maxWidth": "100%"});

        
            var html_4060d3dd3ea740f49094cd58f0ad0fcf = $(`<div id="html_4060d3dd3ea740f49094cd58f0ad0fcf" style="width: 100.0%; height: 100.0%;">Pont de la Concorde N-S</div>`)[0];
            popup_0e6cada2df274fc4a3d28640aaa5d3b9.setContent(html_4060d3dd3ea740f49094cd58f0ad0fcf);
        

        circle_892a5e10eb3249e6ba65112d36df47d7.bindPopup(popup_0e6cada2df274fc4a3d28640aaa5d3b9)
        ;

        
    
    
            var circle_5bf5dfd5ccbe4133a167627f0f13f95e = L.circle(
                [48.82108, 2.32537],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_98c7119de7bc40708b7b122515dd9c26 = L.popup({"maxWidth": "100%"});

        
            var html_ffc5c557129e4e84916dd6af581ac03a = $(`<div id="html_ffc5c557129e4e84916dd6af581ac03a" style="width: 100.0%; height: 100.0%;">3 avenue de la Porte D'Orléans S-N</div>`)[0];
            popup_98c7119de7bc40708b7b122515dd9c26.setContent(html_ffc5c557129e4e84916dd6af581ac03a);
        

        circle_5bf5dfd5ccbe4133a167627f0f13f95e.bindPopup(popup_98c7119de7bc40708b7b122515dd9c26)
        ;

        
    
    
            var circle_dc21865484c94887a2227a60feaa4c90 = L.circle(
                [48.86179, 2.32014],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_840556c2f0554d04b9d0bfbe0a2e49b5 = L.popup({"maxWidth": "100%"});

        
            var html_479cd934c5ec47a48dcfa8fade4b3006 = $(`<div id="html_479cd934c5ec47a48dcfa8fade4b3006" style="width: 100.0%; height: 100.0%;">243 boulevard Saint Germain NO-SE</div>`)[0];
            popup_840556c2f0554d04b9d0bfbe0a2e49b5.setContent(html_479cd934c5ec47a48dcfa8fade4b3006);
        

        circle_dc21865484c94887a2227a60feaa4c90.bindPopup(popup_840556c2f0554d04b9d0bfbe0a2e49b5)
        ;

        
    
    
            var circle_d785a78cec0d463bb4c7f09125d7d564 = L.circle(
                [48.85735, 2.35211],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_52aa9abe6f2f45b0becce8795ed40f58 = L.popup({"maxWidth": "100%"});

        
            var html_e57f0e87d0b54877923c28494a415e38 = $(`<div id="html_e57f0e87d0b54877923c28494a415e38" style="width: 100.0%; height: 100.0%;">Totem 64 Rue de Rivoli E-O</div>`)[0];
            popup_52aa9abe6f2f45b0becce8795ed40f58.setContent(html_e57f0e87d0b54877923c28494a415e38);
        

        circle_d785a78cec0d463bb4c7f09125d7d564.bindPopup(popup_52aa9abe6f2f45b0becce8795ed40f58)
        ;

        
    
    
            var circle_6e69ae7b50dd4e4c8c76a748fbeb67d3 = L.circle(
                [48.88529, 2.32666],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_6861aab6fd534d1d93e071aa8d7f9e1a = L.popup({"maxWidth": "100%"});

        
            var html_082ad773f58e4d2e9c7ee394975b4ad7 = $(`<div id="html_082ad773f58e4d2e9c7ee394975b4ad7" style="width: 100.0%; height: 100.0%;">20 Avenue de Clichy SE-NO</div>`)[0];
            popup_6861aab6fd534d1d93e071aa8d7f9e1a.setContent(html_082ad773f58e4d2e9c7ee394975b4ad7);
        

        circle_6e69ae7b50dd4e4c8c76a748fbeb67d3.bindPopup(popup_6861aab6fd534d1d93e071aa8d7f9e1a)
        ;

        
    
    
            var circle_e0fc644e43be4a068fa25649aaf97196 = L.circle(
                [48.860852, 2.372279],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_3b46c5796c224321b1a0f640f49782bf = L.popup({"maxWidth": "100%"});

        
            var html_332ff6645c3d4fe5abad10c454133d78 = $(`<div id="html_332ff6645c3d4fe5abad10c454133d78" style="width: 100.0%; height: 100.0%;">77 boulevard Richard Lenoir N-S</div>`)[0];
            popup_3b46c5796c224321b1a0f640f49782bf.setContent(html_332ff6645c3d4fe5abad10c454133d78);
        

        circle_e0fc644e43be4a068fa25649aaf97196.bindPopup(popup_3b46c5796c224321b1a0f640f49782bf)
        ;

        
    
    
            var circle_40d0c40f1df24e20aad8377e4f8fe890 = L.circle(
                [48.840801, 2.333233],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_d8dd7638cde744e8b6157bac211b7469 = L.popup({"maxWidth": "100%"});

        
            var html_3ee9df47268f43bb9afd4c83f571ba65 = $(`<div id="html_3ee9df47268f43bb9afd4c83f571ba65" style="width: 100.0%; height: 100.0%;">152 boulevard du Montparnasse E-O</div>`)[0];
            popup_d8dd7638cde744e8b6157bac211b7469.setContent(html_3ee9df47268f43bb9afd4c83f571ba65);
        

        circle_40d0c40f1df24e20aad8377e4f8fe890.bindPopup(popup_d8dd7638cde744e8b6157bac211b7469)
        ;

        
    
    
            var circle_9b910d68ccc7485aa4b8af259edffad4 = L.circle(
                [48.85735, 2.35211],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_0760409126814fc2a4728cd61fbf5bf7 = L.popup({"maxWidth": "100%"});

        
            var html_481e378dc6cd4108b27bec757efb8387 = $(`<div id="html_481e378dc6cd4108b27bec757efb8387" style="width: 100.0%; height: 100.0%;">Totem 64 Rue de Rivoli O-E</div>`)[0];
            popup_0760409126814fc2a4728cd61fbf5bf7.setContent(html_481e378dc6cd4108b27bec757efb8387);
        

        circle_9b910d68ccc7485aa4b8af259edffad4.bindPopup(popup_0760409126814fc2a4728cd61fbf5bf7)
        ;

        
    
    
            var circle_3d6c8b4be45d463eb674948f858e5601 = L.circle(
                [48.86284, 2.310345],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_71cbcaaf1a894d8ebb57b751291b7939 = L.popup({"maxWidth": "100%"});

        
            var html_e95acc7d58d04abe9377811e80251e5b = $(`<div id="html_e95acc7d58d04abe9377811e80251e5b" style="width: 100.0%; height: 100.0%;">Pont des Invalides N-S</div>`)[0];
            popup_71cbcaaf1a894d8ebb57b751291b7939.setContent(html_e95acc7d58d04abe9377811e80251e5b);
        

        circle_3d6c8b4be45d463eb674948f858e5601.bindPopup(popup_71cbcaaf1a894d8ebb57b751291b7939)
        ;

        
    
    
            var circle_ca85bd82a7514fa2b5ef894e8e060262 = L.circle(
                [48.830331, 2.400551],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_d341ed9302704e1ea1fcfd619622044f = L.popup({"maxWidth": "100%"});

        
            var html_846b0ecbcfa54fed88e8d210b89bdd4f = $(`<div id="html_846b0ecbcfa54fed88e8d210b89bdd4f" style="width: 100.0%; height: 100.0%;">Face au 8 avenue de la porte de Charenton SE-NO</div>`)[0];
            popup_d341ed9302704e1ea1fcfd619622044f.setContent(html_846b0ecbcfa54fed88e8d210b89bdd4f);
        

        circle_ca85bd82a7514fa2b5ef894e8e060262.bindPopup(popup_d341ed9302704e1ea1fcfd619622044f)
        ;

        
    
    
            var circle_236bebbd3d1742ac91aa74a99824126c = L.circle(
                [48.84223, 2.36811],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_470883b89aed4f2cba795bcbc162ad4c = L.popup({"maxWidth": "100%"});

        
            var html_71e94dd2f4b44698831b9ad214e71d7f = $(`<div id="html_71e94dd2f4b44698831b9ad214e71d7f" style="width: 100.0%; height: 100.0%;">Pont Charles De Gaulle NE-SO</div>`)[0];
            popup_470883b89aed4f2cba795bcbc162ad4c.setContent(html_71e94dd2f4b44698831b9ad214e71d7f);
        

        circle_236bebbd3d1742ac91aa74a99824126c.bindPopup(popup_470883b89aed4f2cba795bcbc162ad4c)
        ;

        
    
    
            var circle_0c3246dc73ea4e44a41fae90b344eef1 = L.circle(
                [48.846028, 2.375429],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_9b6959729a8f45b18f980df313085f7e = L.popup({"maxWidth": "100%"});

        
            var html_820ec1643ea043e3b31645f9a811589e = $(`<div id="html_820ec1643ea043e3b31645f9a811589e" style="width: 100.0%; height: 100.0%;">28 boulevard Diderot E-O</div>`)[0];
            popup_9b6959729a8f45b18f980df313085f7e.setContent(html_820ec1643ea043e3b31645f9a811589e);
        

        circle_0c3246dc73ea4e44a41fae90b344eef1.bindPopup(popup_9b6959729a8f45b18f980df313085f7e)
        ;

        
    
    
            var circle_b87f1b119cdf4a9fa31c887f199efbab = L.circle(
                [48.85372, 2.35702],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_a6df26e47e25474a919282b392c24e8b = L.popup({"maxWidth": "100%"});

        
            var html_7050cf56671946ab9fe03824637ec1c6 = $(`<div id="html_7050cf56671946ab9fe03824637ec1c6" style="width: 100.0%; height: 100.0%;">18 quai de l'hotel de ville SE-NO</div>`)[0];
            popup_a6df26e47e25474a919282b392c24e8b.setContent(html_7050cf56671946ab9fe03824637ec1c6);
        

        circle_b87f1b119cdf4a9fa31c887f199efbab.bindPopup(popup_a6df26e47e25474a919282b392c24e8b)
        ;

        
    
    
            var circle_01b472b8754f49c480b7aee438e34181 = L.circle(
                [48.869873, 2.307419],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_b433e4a5f5c940998ffdc582f372cf82 = L.popup({"maxWidth": "100%"});

        
            var html_46f79f4f5a9845108a15854ca1b713e8 = $(`<div id="html_46f79f4f5a9845108a15854ca1b713e8" style="width: 100.0%; height: 100.0%;">44 avenue des Champs Elysées SE-NO</div>`)[0];
            popup_b433e4a5f5c940998ffdc582f372cf82.setContent(html_46f79f4f5a9845108a15854ca1b713e8);
        

        circle_01b472b8754f49c480b7aee438e34181.bindPopup(popup_b433e4a5f5c940998ffdc582f372cf82)
        ;

        
    
    
            var circle_98613ece78b143448eaf5150b78cce4f = L.circle(
                [48.84216, 2.30115],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_9e3c5cfc1aea43e599020fb23f22d252 = L.popup({"maxWidth": "100%"});

        
            var html_c84efa2e589e4f709354682bbd4f49af = $(`<div id="html_c84efa2e589e4f709354682bbd4f49af" style="width: 100.0%; height: 100.0%;">132 rue Lecourbe NE-SO</div>`)[0];
            popup_9e3c5cfc1aea43e599020fb23f22d252.setContent(html_c84efa2e589e4f709354682bbd4f49af);
        

        circle_98613ece78b143448eaf5150b78cce4f.bindPopup(popup_9e3c5cfc1aea43e599020fb23f22d252)
        ;

        
    
    
            var circle_0b9ed7405c2b424eb62cb90a5c049c15 = L.circle(
                [48.89594, 2.35953],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_96001ee9c15a48029b15e93fe416bd81 = L.popup({"maxWidth": "100%"});

        
            var html_8b15cc1b12e34a69ba82aaa17ae3a2c0 = $(`<div id="html_8b15cc1b12e34a69ba82aaa17ae3a2c0" style="width: 100.0%; height: 100.0%;">72 rue de la Chapelle N-S</div>`)[0];
            popup_96001ee9c15a48029b15e93fe416bd81.setContent(html_8b15cc1b12e34a69ba82aaa17ae3a2c0);
        

        circle_0b9ed7405c2b424eb62cb90a5c049c15.bindPopup(popup_96001ee9c15a48029b15e93fe416bd81)
        ;

        
    
    
            var circle_0e21e0018dd14774b870bac78be855a0 = L.circle(
                [48.85209, 2.28508],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_6cbfa5ac5c314ffba83a85f76bcb6fde = L.popup({"maxWidth": "100%"});

        
            var html_18c8b2b4ce7a4bdfbdc6fe79daeb03d2 = $(`<div id="html_18c8b2b4ce7a4bdfbdc6fe79daeb03d2" style="width: 100.0%; height: 100.0%;">36 quai de Grenelle NE-SO</div>`)[0];
            popup_6cbfa5ac5c314ffba83a85f76bcb6fde.setContent(html_18c8b2b4ce7a4bdfbdc6fe79daeb03d2);
        

        circle_0e21e0018dd14774b870bac78be855a0.bindPopup(popup_6cbfa5ac5c314ffba83a85f76bcb6fde)
        ;

        
    
    
            var circle_7bb61270d84d41b99b12b2d7babc92df = L.circle(
                [48.83421, 2.26542],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_397cd01619fb4d93b8d4e04a5a57872b = L.popup({"maxWidth": "100%"});

        
            var html_916820249b4c41ce878d83401e281894 = $(`<div id="html_916820249b4c41ce878d83401e281894" style="width: 100.0%; height: 100.0%;">Face au 40 quai D'Issy NE-SO</div>`)[0];
            popup_397cd01619fb4d93b8d4e04a5a57872b.setContent(html_916820249b4c41ce878d83401e281894);
        

        circle_7bb61270d84d41b99b12b2d7babc92df.bindPopup(popup_397cd01619fb4d93b8d4e04a5a57872b)
        ;

        
    
    
            var circle_99a7059462df468e87bf65c21b893f62 = L.circle(
                [48.84201, 2.36729],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 499.99999999999994, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_f54a6c7adb8846b9bba0308977676c89 = L.popup({"maxWidth": "100%"});

        
            var html_7bdf029b837c4d42941caf8acaa3adf8 = $(`<div id="html_7bdf029b837c4d42941caf8acaa3adf8" style="width: 100.0%; height: 100.0%;">Totem 85 quai d'Austerlitz NO-SE</div>`)[0];
            popup_f54a6c7adb8846b9bba0308977676c89.setContent(html_7bdf029b837c4d42941caf8acaa3adf8);
        

        circle_99a7059462df468e87bf65c21b893f62.bindPopup(popup_f54a6c7adb8846b9bba0308977676c89)
        ;

        
    
    
            var circle_7395325113f14f94856aab9083659221 = L.circle(
                [48.86077, 2.37305],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_6a3ef9aaade34e9c9b7c5e8624c67f19 = L.popup({"maxWidth": "100%"});

        
            var html_b5054434c74a4975a26481baf376f9a6 = $(`<div id="html_b5054434c74a4975a26481baf376f9a6" style="width: 100.0%; height: 100.0%;">72 boulevard Richard Lenoir  S-N</div>`)[0];
            popup_6a3ef9aaade34e9c9b7c5e8624c67f19.setContent(html_b5054434c74a4975a26481baf376f9a6);
        

        circle_7395325113f14f94856aab9083659221.bindPopup(popup_6a3ef9aaade34e9c9b7c5e8624c67f19)
        ;

        
    
    
            var circle_32e70ef778ef4c449b60a3e55337c58c = L.circle(
                [48.82636, 2.30303],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_485acfedf94b4e5e828ad8434f9fe01e = L.popup({"maxWidth": "100%"});

        
            var html_2b793ace96354a66ae33e2a9cb7e3572 = $(`<div id="html_2b793ace96354a66ae33e2a9cb7e3572" style="width: 100.0%; height: 100.0%;">6 rue Julia Bartet SO-NE</div>`)[0];
            popup_485acfedf94b4e5e828ad8434f9fe01e.setContent(html_2b793ace96354a66ae33e2a9cb7e3572);
        

        circle_32e70ef778ef4c449b60a3e55337c58c.bindPopup(popup_485acfedf94b4e5e828ad8434f9fe01e)
        ;

        
    
    
            var circle_11a15d1c203742c5a256ee8a59ed5672 = L.circle(
                [48.860528, 2.388364],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_dbf8b5aa3f12459cba326a206fe27fe8 = L.popup({"maxWidth": "100%"});

        
            var html_81d56a5f650d400098ab4113dbef7871 = $(`<div id="html_81d56a5f650d400098ab4113dbef7871" style="width: 100.0%; height: 100.0%;">35 boulevard de Menilmontant NO-SE</div>`)[0];
            popup_dbf8b5aa3f12459cba326a206fe27fe8.setContent(html_81d56a5f650d400098ab4113dbef7871);
        

        circle_11a15d1c203742c5a256ee8a59ed5672.bindPopup(popup_dbf8b5aa3f12459cba326a206fe27fe8)
        ;

        
    
    
            var circle_c07d5027be1c4f58b780920d863dc863 = L.circle(
                [48.85013, 2.35423],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_d33d2ce06dfa4369849e9fab433d34ce = L.popup({"maxWidth": "100%"});

        
            var html_15662c2f9ba644fe8cd7b8ec2d689b79 = $(`<div id="html_15662c2f9ba644fe8cd7b8ec2d689b79" style="width: 100.0%; height: 100.0%;">27 quai de la Tournelle SE-NO</div>`)[0];
            popup_d33d2ce06dfa4369849e9fab433d34ce.setContent(html_15662c2f9ba644fe8cd7b8ec2d689b79);
        

        circle_c07d5027be1c4f58b780920d863dc863.bindPopup(popup_d33d2ce06dfa4369849e9fab433d34ce)
        ;

        
    
    
            var circle_85ab45cd801d4d1684f9edb886863503 = L.circle(
                [48.86377, 2.35096],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 499.99999999999994, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_1d63bec0ec9a4cc7828cf72a3b89f8ac = L.popup({"maxWidth": "100%"});

        
            var html_74ea8aeefd144ef48e1db2b692ea212e = $(`<div id="html_74ea8aeefd144ef48e1db2b692ea212e" style="width: 100.0%; height: 100.0%;">Totem 73 boulevard de Sébastopol S-N</div>`)[0];
            popup_1d63bec0ec9a4cc7828cf72a3b89f8ac.setContent(html_74ea8aeefd144ef48e1db2b692ea212e);
        

        circle_85ab45cd801d4d1684f9edb886863503.bindPopup(popup_1d63bec0ec9a4cc7828cf72a3b89f8ac)
        ;

        
    
    
            var circle_5fc0769d5bb14de5b9b0798a89632808 = L.circle(
                [48.843435, 2.383378],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_cbf424c995384213832ee542542ba58c = L.popup({"maxWidth": "100%"});

        
            var html_47bd4f1b6e2448a09bda14ef5da0bb49 = $(`<div id="html_47bd4f1b6e2448a09bda14ef5da0bb49" style="width: 100.0%; height: 100.0%;">135 avenue Daumesnil SE-NO</div>`)[0];
            popup_cbf424c995384213832ee542542ba58c.setContent(html_47bd4f1b6e2448a09bda14ef5da0bb49);
        

        circle_5fc0769d5bb14de5b9b0798a89632808.bindPopup(popup_cbf424c995384213832ee542542ba58c)
        ;

        
    
    
            var circle_b184b250090b4e878a317aa07312c039 = L.circle(
                [48.846028, 2.375429],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_33d6ec3885b84632aa7cc181417065d0 = L.popup({"maxWidth": "100%"});

        
            var html_6450f88905d84c4f84f8d2018653338e = $(`<div id="html_6450f88905d84c4f84f8d2018653338e" style="width: 100.0%; height: 100.0%;">28 boulevard Diderot O-E</div>`)[0];
            popup_33d6ec3885b84632aa7cc181417065d0.setContent(html_6450f88905d84c4f84f8d2018653338e);
        

        circle_b184b250090b4e878a317aa07312c039.bindPopup(popup_33d6ec3885b84632aa7cc181417065d0)
        ;

        
    
    
            var circle_ec8d9e4d663249a39a9567486690e68b = L.circle(
                [48.85372, 2.35702],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_54c8c57f78ea46d0b5bb1205bf080a89 = L.popup({"maxWidth": "100%"});

        
            var html_86cb6b8fe678421b84ab2dbc17fcc4ba = $(`<div id="html_86cb6b8fe678421b84ab2dbc17fcc4ba" style="width: 100.0%; height: 100.0%;">18 quai de l'hotel de ville NO-SE</div>`)[0];
            popup_54c8c57f78ea46d0b5bb1205bf080a89.setContent(html_86cb6b8fe678421b84ab2dbc17fcc4ba);
        

        circle_ec8d9e4d663249a39a9567486690e68b.bindPopup(popup_54c8c57f78ea46d0b5bb1205bf080a89)
        ;

        
    
    
            var circle_f83eb1936b8c48918a8ccdf557df5a62 = L.circle(
                [48.86451, 2.40932],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 499.99999999999994, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_cf40f06da5114bf381ef1c39294c7d84 = L.popup({"maxWidth": "100%"});

        
            var html_e52a5b8155a0442e95f8c2c4996205c4 = $(`<div id="html_e52a5b8155a0442e95f8c2c4996205c4" style="width: 100.0%; height: 100.0%;">2 avenue de la Porte de Bagnolet O-E</div>`)[0];
            popup_cf40f06da5114bf381ef1c39294c7d84.setContent(html_e52a5b8155a0442e95f8c2c4996205c4);
        

        circle_f83eb1936b8c48918a8ccdf557df5a62.bindPopup(popup_cf40f06da5114bf381ef1c39294c7d84)
        ;

        
    
    
            var circle_2c53d1173db4492a828eb400214883b1 = L.circle(
                [48.83421, 2.26542],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.00000000000006, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_61177cec4bf5460186397b449312e937 = L.popup({"maxWidth": "100%"});

        
            var html_ff5bf0190d9b4308823062cfe809d44b = $(`<div id="html_ff5bf0190d9b4308823062cfe809d44b" style="width: 100.0%; height: 100.0%;">Face au 40 quai D'Issy SO-NE</div>`)[0];
            popup_61177cec4bf5460186397b449312e937.setContent(html_ff5bf0190d9b4308823062cfe809d44b);
        

        circle_2c53d1173db4492a828eb400214883b1.bindPopup(popup_61177cec4bf5460186397b449312e937)
        ;

        
    
    
            var circle_b47bafe607964759a95bf09f08557162 = L.circle(
                [48.86521, 2.35358],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_b6dd1b78bbb04feb8dfa3f4a0b3c232a = L.popup({"maxWidth": "100%"});

        
            var html_cd88f1d2861741a89740bf9ceec7be82 = $(`<div id="html_cd88f1d2861741a89740bf9ceec7be82" style="width: 100.0%; height: 100.0%;">38 rue Turbigo NE-SO</div>`)[0];
            popup_b6dd1b78bbb04feb8dfa3f4a0b3c232a.setContent(html_cd88f1d2861741a89740bf9ceec7be82);
        

        circle_b47bafe607964759a95bf09f08557162.bindPopup(popup_b6dd1b78bbb04feb8dfa3f4a0b3c232a)
        ;

        
    
    
            var circle_2df1da451a594cf6aa9c007337042904 = L.circle(
                [48.877667, 2.350556],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_fc0bcac222f14fbda50d0a2f1c4bd8fd = L.popup({"maxWidth": "100%"});

        
            var html_9dc02d27ff67457bbba3915422f6b7f0 = $(`<div id="html_9dc02d27ff67457bbba3915422f6b7f0" style="width: 100.0%; height: 100.0%;">105 rue La Fayette E-O</div>`)[0];
            popup_fc0bcac222f14fbda50d0a2f1c4bd8fd.setContent(html_9dc02d27ff67457bbba3915422f6b7f0);
        

        circle_2df1da451a594cf6aa9c007337042904.bindPopup(popup_fc0bcac222f14fbda50d0a2f1c4bd8fd)
        ;

        
    
    
            var circle_8cdea67cab014a7f8418b4e1d55c30b1 = L.circle(
                [48.83436, 2.377],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_2c2b0a0983104350899110fabf7a3aa6 = L.popup({"maxWidth": "100%"});

        
            var html_d99131ad518c401592955f2030a30b43 = $(`<div id="html_d99131ad518c401592955f2030a30b43" style="width: 100.0%; height: 100.0%;">39 quai François Mauriac SE-NO</div>`)[0];
            popup_2c2b0a0983104350899110fabf7a3aa6.setContent(html_d99131ad518c401592955f2030a30b43);
        

        circle_8cdea67cab014a7f8418b4e1d55c30b1.bindPopup(popup_2c2b0a0983104350899110fabf7a3aa6)
        ;

        
    
    
            var circle_0d52b261262e4ce7a84e80da4884b6a4 = L.circle(
                [48.83436, 2.377],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_baabd0e4bc1f45b094733953e9b8fbdd = L.popup({"maxWidth": "100%"});

        
            var html_37dbb4abf96c49db80cfe314ddcc0d65 = $(`<div id="html_37dbb4abf96c49db80cfe314ddcc0d65" style="width: 100.0%; height: 100.0%;">39 quai François Mauriac NO-SE</div>`)[0];
            popup_baabd0e4bc1f45b094733953e9b8fbdd.setContent(html_37dbb4abf96c49db80cfe314ddcc0d65);
        

        circle_0d52b261262e4ce7a84e80da4884b6a4.bindPopup(popup_baabd0e4bc1f45b094733953e9b8fbdd)
        ;

        
    
    
            var circle_a2230ccd017f4dd2a135cd2ea82c5b4b = L.circle(
                [48.82636, 2.30303],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_3b893e3550084a65ad130f50d6f8f69e = L.popup({"maxWidth": "100%"});

        
            var html_74bddff8e14a487c8500e820dd21c272 = $(`<div id="html_74bddff8e14a487c8500e820dd21c272" style="width: 100.0%; height: 100.0%;">6 rue Julia Bartet NE-SO</div>`)[0];
            popup_3b893e3550084a65ad130f50d6f8f69e.setContent(html_74bddff8e14a487c8500e820dd21c272);
        

        circle_a2230ccd017f4dd2a135cd2ea82c5b4b.bindPopup(popup_3b893e3550084a65ad130f50d6f8f69e)
        ;

        
    
    
            var circle_1826203de440457088567af1a83bb5c2 = L.circle(
                [48.86521, 2.35358],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_f357700c89aa4956baf94918200d9689 = L.popup({"maxWidth": "100%"});

        
            var html_49a5295178b74b07bad5989496dee930 = $(`<div id="html_49a5295178b74b07bad5989496dee930" style="width: 100.0%; height: 100.0%;">38 rue Turbigo SO-NE</div>`)[0];
            popup_f357700c89aa4956baf94918200d9689.setContent(html_49a5295178b74b07bad5989496dee930);
        

        circle_1826203de440457088567af1a83bb5c2.bindPopup(popup_f357700c89aa4956baf94918200d9689)
        ;

        
    
    
            var circle_db447d9b9b4f4744bafc49eb917cf4ca = L.circle(
                [48.84638, 2.31529],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_9f126d1ce5e5499ba4fc2f7e032a2037 = L.popup({"maxWidth": "100%"});

        
            var html_16c15b35886a4abc9aa771c6f21ad45a = $(`<div id="html_16c15b35886a4abc9aa771c6f21ad45a" style="width: 100.0%; height: 100.0%;">90 Rue De Sèvres NE-SO</div>`)[0];
            popup_9f126d1ce5e5499ba4fc2f7e032a2037.setContent(html_16c15b35886a4abc9aa771c6f21ad45a);
        

        circle_db447d9b9b4f4744bafc49eb917cf4ca.bindPopup(popup_9f126d1ce5e5499ba4fc2f7e032a2037)
        ;

        
    
    
            var circle_f284351954884c9da1fe0b03c74f3221 = L.circle(
                [48.846099, 2.375456],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_cf660f87aabe4dc686c39648c0ea7d70 = L.popup({"maxWidth": "100%"});

        
            var html_1c0c67d1558b45c28c8992307632f313 = $(`<div id="html_1c0c67d1558b45c28c8992307632f313" style="width: 100.0%; height: 100.0%;">27 boulevard Diderot E-O</div>`)[0];
            popup_cf660f87aabe4dc686c39648c0ea7d70.setContent(html_1c0c67d1558b45c28c8992307632f313);
        

        circle_f284351954884c9da1fe0b03c74f3221.bindPopup(popup_cf660f87aabe4dc686c39648c0ea7d70)
        ;

        
    
    
            var circle_30849e4242404f61a6208774f0b7128c = L.circle(
                [48.84015, 2.26733],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_30c496a765964026952cd2844908e8d7 = L.popup({"maxWidth": "100%"});

        
            var html_fa48c7ec8b1c42d397e03a02b2f48e2b = $(`<div id="html_fa48c7ec8b1c42d397e03a02b2f48e2b" style="width: 100.0%; height: 100.0%;">Pont du Garigliano NO-SE</div>`)[0];
            popup_30c496a765964026952cd2844908e8d7.setContent(html_fa48c7ec8b1c42d397e03a02b2f48e2b);
        

        circle_30849e4242404f61a6208774f0b7128c.bindPopup(popup_30c496a765964026952cd2844908e8d7)
        ;

        
    
    
            var circle_0e3d0dd475c643ae84084616157d1f1c = L.circle(
                [48.891215, 2.38573],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_c581d605cd334553be9425d6c94e4694 = L.popup({"maxWidth": "100%"});

        
            var html_564be3076cbf46279dae962e18290670 = $(`<div id="html_564be3076cbf46279dae962e18290670" style="width: 100.0%; height: 100.0%;">Face au 48 quai de la marne NE-SO</div>`)[0];
            popup_c581d605cd334553be9425d6c94e4694.setContent(html_564be3076cbf46279dae962e18290670);
        

        circle_0e3d0dd475c643ae84084616157d1f1c.bindPopup(popup_c581d605cd334553be9425d6c94e4694)
        ;

        
    
    
            var circle_43e1ebc3e6dc49d2921be7714130676f = L.circle(
                [48.82682, 2.38465],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_1587dea155664f8b84650b54ea247d43 = L.popup({"maxWidth": "100%"});

        
            var html_0a0250c19d474445a451028d59ef6b47 = $(`<div id="html_0a0250c19d474445a451028d59ef6b47" style="width: 100.0%; height: 100.0%;">Pont National  NE-SO</div>`)[0];
            popup_1587dea155664f8b84650b54ea247d43.setContent(html_0a0250c19d474445a451028d59ef6b47);
        

        circle_43e1ebc3e6dc49d2921be7714130676f.bindPopup(popup_1587dea155664f8b84650b54ea247d43)
        ;

        
    
    
            var circle_ae3c5b1d2bc64a5aafbf4e40e9cf6233 = L.circle(
                [48.869831, 2.307076],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_98cbd1385c6147d0bdfd33d45fdbf120 = L.popup({"maxWidth": "100%"});

        
            var html_b17535990f624dcc967076031272d888 = $(`<div id="html_b17535990f624dcc967076031272d888" style="width: 100.0%; height: 100.0%;">33 avenue des Champs Elysées NO-SE</div>`)[0];
            popup_98cbd1385c6147d0bdfd33d45fdbf120.setContent(html_b17535990f624dcc967076031272d888);
        

        circle_ae3c5b1d2bc64a5aafbf4e40e9cf6233.bindPopup(popup_98cbd1385c6147d0bdfd33d45fdbf120)
        ;

        
    
    
            var circle_8f24b3905b70492db7f1502948aade34 = L.circle(
                [48.86282, 2.31061],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_c8668d358fed456dbec4ccb813b84c3e = L.popup({"maxWidth": "100%"});

        
            var html_a4853713f9234adc99bcfae97a5d5ec3 = $(`<div id="html_a4853713f9234adc99bcfae97a5d5ec3" style="width: 100.0%; height: 100.0%;">Pont des Invalides S-N</div>`)[0];
            popup_c8668d358fed456dbec4ccb813b84c3e.setContent(html_a4853713f9234adc99bcfae97a5d5ec3);
        

        circle_8f24b3905b70492db7f1502948aade34.bindPopup(popup_c8668d358fed456dbec4ccb813b84c3e)
        ;

        
    
    
            var circle_c6f57b0e11b04c34836ce0d839b8bbba = L.circle(
                [48.89594, 2.35953],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_a907ed581c6e4f878edfb23eeff09dac = L.popup({"maxWidth": "100%"});

        
            var html_9b1b085a8fe04245853862afa24a6f46 = $(`<div id="html_9b1b085a8fe04245853862afa24a6f46" style="width: 100.0%; height: 100.0%;">72 rue de la Chapelle S-N</div>`)[0];
            popup_a907ed581c6e4f878edfb23eeff09dac.setContent(html_9b1b085a8fe04245853862afa24a6f46);
        

        circle_c6f57b0e11b04c34836ce0d839b8bbba.bindPopup(popup_a907ed581c6e4f878edfb23eeff09dac)
        ;

        
    
    
            var circle_ebd0dbdf7c7f404e95b2a643c8ac39ac = L.circle(
                [48.88181, 2.281546],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_8c54581004c4448082f1338a23571a4f = L.popup({"maxWidth": "100%"});

        
            var html_5a15268769ac4756b2c5b2481f262cc6 = $(`<div id="html_5a15268769ac4756b2c5b2481f262cc6" style="width: 100.0%; height: 100.0%;">16 avenue de la Porte des Ternes E-O</div>`)[0];
            popup_8c54581004c4448082f1338a23571a4f.setContent(html_5a15268769ac4756b2c5b2481f262cc6);
        

        circle_ebd0dbdf7c7f404e95b2a643c8ac39ac.bindPopup(popup_8c54581004c4448082f1338a23571a4f)
        ;

        
    
    
            var circle_96be70f421a546f486b3223c78d78a52 = L.circle(
                [48.86462, 2.31444],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_307b6eddc14c45d08f11bfc1043e89a7 = L.popup({"maxWidth": "100%"});

        
            var html_a82c9a4759dd48c695b75c28fffe9656 = $(`<div id="html_a82c9a4759dd48c695b75c28fffe9656" style="width: 100.0%; height: 100.0%;">Totem Cours la Reine E-O</div>`)[0];
            popup_307b6eddc14c45d08f11bfc1043e89a7.setContent(html_a82c9a4759dd48c695b75c28fffe9656);
        

        circle_96be70f421a546f486b3223c78d78a52.bindPopup(popup_307b6eddc14c45d08f11bfc1043e89a7)
        ;

        
    
    
            var circle_81546280a7c34d50b8ac37f207222718 = L.circle(
                [48.851131, 2.345678],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_8d5a8660f3d54ddcad34030b70709561 = L.popup({"maxWidth": "100%"});

        
            var html_c54e0331ee3f45d6826fcdf058e04bb5 = $(`<div id="html_c54e0331ee3f45d6826fcdf058e04bb5" style="width: 100.0%; height: 100.0%;">30 rue Saint Jacques N-S</div>`)[0];
            popup_8d5a8660f3d54ddcad34030b70709561.setContent(html_c54e0331ee3f45d6826fcdf058e04bb5);
        

        circle_81546280a7c34d50b8ac37f207222718.bindPopup(popup_8d5a8660f3d54ddcad34030b70709561)
        ;

        
    
    
            var circle_d6e662d2648346cda8c9e53452b68bf7 = L.circle(
                [48.8484, 2.27586],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_01d8ca4858d04ba1b31b0d1be8c5bfa3 = L.popup({"maxWidth": "100%"});

        
            var html_d6d705e9f38c44e8b8ff19cf1800494c = $(`<div id="html_d6d705e9f38c44e8b8ff19cf1800494c" style="width: 100.0%; height: 100.0%;">Voie Georges Pompidou SO-NE</div>`)[0];
            popup_01d8ca4858d04ba1b31b0d1be8c5bfa3.setContent(html_d6d705e9f38c44e8b8ff19cf1800494c);
        

        circle_d6e662d2648346cda8c9e53452b68bf7.bindPopup(popup_01d8ca4858d04ba1b31b0d1be8c5bfa3)
        ;

        
    
    
            var circle_226df9fca1cb4c28baf4e5ecda4569a9 = L.circle(
                [48.877686, 2.354471],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_a93f7078836e486fb2e5f9155684417f = L.popup({"maxWidth": "100%"});

        
            var html_020759d2a04949bf8db9b532749862d7 = $(`<div id="html_020759d2a04949bf8db9b532749862d7" style="width: 100.0%; height: 100.0%;">89 boulevard de Magenta NO-SE</div>`)[0];
            popup_a93f7078836e486fb2e5f9155684417f.setContent(html_020759d2a04949bf8db9b532749862d7);
        

        circle_226df9fca1cb4c28baf4e5ecda4569a9.bindPopup(popup_a93f7078836e486fb2e5f9155684417f)
        ;

        
    
    
            var circle_70b98cb98bc844a8b7d9088fe2bb68f9 = L.circle(
                [48.86461, 2.40969],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_9907e2813cd8460e909b0ca53a762a0b = L.popup({"maxWidth": "100%"});

        
            var html_9e155dcf5764491fa46db0a1e6310e10 = $(`<div id="html_9e155dcf5764491fa46db0a1e6310e10" style="width: 100.0%; height: 100.0%;">Face au 4 avenue de la porte de Bagnolet O-E</div>`)[0];
            popup_9907e2813cd8460e909b0ca53a762a0b.setContent(html_9e155dcf5764491fa46db0a1e6310e10);
        

        circle_70b98cb98bc844a8b7d9088fe2bb68f9.bindPopup(popup_9907e2813cd8460e909b0ca53a762a0b)
        ;

        
    
    
            var circle_f4955f2ae03f4cfe85ef6bee66727abf = L.circle(
                [48.84201, 2.36729],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_ae4e47e4c3554f3ea5b57ec4658b6e1f = L.popup({"maxWidth": "100%"});

        
            var html_d0918619d9af4506b793763fc483cd43 = $(`<div id="html_d0918619d9af4506b793763fc483cd43" style="width: 100.0%; height: 100.0%;">Totem 85 quai d'Austerlitz SE-NO</div>`)[0];
            popup_ae4e47e4c3554f3ea5b57ec4658b6e1f.setContent(html_d0918619d9af4506b793763fc483cd43);
        

        circle_f4955f2ae03f4cfe85ef6bee66727abf.bindPopup(popup_ae4e47e4c3554f3ea5b57ec4658b6e1f)
        ;

        
    
    
            var circle_ed84a1e8a4464b749c44c373d4e16070 = L.circle(
                [48.83068, 2.35348],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_9e319b8311ae4275909c669704156c62 = L.popup({"maxWidth": "100%"});

        
            var html_61e07be832ca4733827b9df5f4119036 = $(`<div id="html_61e07be832ca4733827b9df5f4119036" style="width: 100.0%; height: 100.0%;">10 boulevard Auguste Blanqui NE-SO</div>`)[0];
            popup_9e319b8311ae4275909c669704156c62.setContent(html_61e07be832ca4733827b9df5f4119036);
        

        circle_ed84a1e8a4464b749c44c373d4e16070.bindPopup(popup_9e319b8311ae4275909c669704156c62)
        ;

        
    
    
            var circle_1e2077b90222415d801b1769ee0eca28 = L.circle(
                [48.88926, 2.37472],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.00000000000006, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_045e85c31d6c4c16b9a24091118e2e51 = L.popup({"maxWidth": "100%"});

        
            var html_720e82646e7f49628fd9018a78b3b9a8 = $(`<div id="html_720e82646e7f49628fd9018a78b3b9a8" style="width: 100.0%; height: 100.0%;">87 avenue de Flandre NE-SO</div>`)[0];
            popup_045e85c31d6c4c16b9a24091118e2e51.setContent(html_720e82646e7f49628fd9018a78b3b9a8);
        

        circle_1e2077b90222415d801b1769ee0eca28.bindPopup(popup_045e85c31d6c4c16b9a24091118e2e51)
        ;

        
    
    
            var circle_1dca1a15787b4ad88dacaf840f41db02 = L.circle(
                [48.82024, 2.35902],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 499.99999999999994, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_bf17764dd80140d786c54c2b765d7e13 = L.popup({"maxWidth": "100%"});

        
            var html_f5509d8e8e4944d3ba33a58cfbe1f888 = $(`<div id="html_f5509d8e8e4944d3ba33a58cfbe1f888" style="width: 100.0%; height: 100.0%;">180 avenue d'Italie N-S</div>`)[0];
            popup_bf17764dd80140d786c54c2b765d7e13.setContent(html_f5509d8e8e4944d3ba33a58cfbe1f888);
        

        circle_1dca1a15787b4ad88dacaf840f41db02.bindPopup(popup_bf17764dd80140d786c54c2b765d7e13)
        ;

        
    
    
            var circle_26490efe82554a46a737b0b309b368c8 = L.circle(
                [48.88529, 2.32666],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_fe5c0c97a674423daf4b1875eabc4578 = L.popup({"maxWidth": "100%"});

        
            var html_7bd4fec75ad5445d89a3b2acf76ca11b = $(`<div id="html_7bd4fec75ad5445d89a3b2acf76ca11b" style="width: 100.0%; height: 100.0%;">20 Avenue de Clichy NO-SE</div>`)[0];
            popup_fe5c0c97a674423daf4b1875eabc4578.setContent(html_7bd4fec75ad5445d89a3b2acf76ca11b);
        

        circle_26490efe82554a46a737b0b309b368c8.bindPopup(popup_fe5c0c97a674423daf4b1875eabc4578)
        ;

        
    
    
            var circle_6d8d65bf27b640e79d861dedad903b7e = L.circle(
                [48.83511, 2.33338],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_f7e28f14fc82457ba8f397fac138e38a = L.popup({"maxWidth": "100%"});

        
            var html_89bea08b98fc4324bf0d8d47c8103346 = $(`<div id="html_89bea08b98fc4324bf0d8d47c8103346" style="width: 100.0%; height: 100.0%;">97 avenue Denfert Rochereau SO-NE</div>`)[0];
            popup_f7e28f14fc82457ba8f397fac138e38a.setContent(html_89bea08b98fc4324bf0d8d47c8103346);
        

        circle_6d8d65bf27b640e79d861dedad903b7e.bindPopup(popup_f7e28f14fc82457ba8f397fac138e38a)
        ;

        
    
    
            var circle_a199503ec7c6492dab5c767c8d421318 = L.circle(
                [48.87451, 2.29215],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_42ef854479ca4635b34fba0b58c1df38 = L.popup({"maxWidth": "100%"});

        
            var html_050a01ac0fcf4acba9a492594ad15692 = $(`<div id="html_050a01ac0fcf4acba9a492594ad15692" style="width: 100.0%; height: 100.0%;">7 avenue de la Grande Armée NO-SE</div>`)[0];
            popup_42ef854479ca4635b34fba0b58c1df38.setContent(html_050a01ac0fcf4acba9a492594ad15692);
        

        circle_a199503ec7c6492dab5c767c8d421318.bindPopup(popup_42ef854479ca4635b34fba0b58c1df38)
        ;

        
    
    
            var circle_096777dc55d140e5b3608c1cca9621c5 = L.circle(
                [48.877726, 2.354926],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.00000000000006, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_3b4385fe836a47b68f8082b366eaef4c = L.popup({"maxWidth": "100%"});

        
            var html_818514c76dea48eebe454f1edd197e17 = $(`<div id="html_818514c76dea48eebe454f1edd197e17" style="width: 100.0%; height: 100.0%;">102 boulevard de Magenta SE-NO</div>`)[0];
            popup_3b4385fe836a47b68f8082b366eaef4c.setContent(html_818514c76dea48eebe454f1edd197e17);
        

        circle_096777dc55d140e5b3608c1cca9621c5.bindPopup(popup_3b4385fe836a47b68f8082b366eaef4c)
        ;

        
    
    
            var circle_167f660018944afb844e456850797cf3 = L.circle(
                [48.881626, 2.281203],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_cdbec82029e948c3920dc1d3f8f0dd50 = L.popup({"maxWidth": "100%"});

        
            var html_fd95513df78c446d9538472577494bdb = $(`<div id="html_fd95513df78c446d9538472577494bdb" style="width: 100.0%; height: 100.0%;">Face au 16 avenue de la  Porte des Ternes O-E</div>`)[0];
            popup_cdbec82029e948c3920dc1d3f8f0dd50.setContent(html_fd95513df78c446d9538472577494bdb);
        

        circle_167f660018944afb844e456850797cf3.bindPopup(popup_cdbec82029e948c3920dc1d3f8f0dd50)
        ;

        
    
    
            var circle_e0a2534ffbae45db8d72b1e7882f3844 = L.circle(
                [48.890457, 2.368852],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_36a1bee517374d76bfdaa9ac1f1884d8 = L.popup({"maxWidth": "100%"});

        
            var html_c03cdd918e9c41269239e29a3d186d48 = $(`<div id="html_c03cdd918e9c41269239e29a3d186d48" style="width: 100.0%; height: 100.0%;">Face 104 rue d'Aubervilliers S-N</div>`)[0];
            popup_36a1bee517374d76bfdaa9ac1f1884d8.setContent(html_c03cdd918e9c41269239e29a3d186d48);
        

        circle_e0a2534ffbae45db8d72b1e7882f3844.bindPopup(popup_36a1bee517374d76bfdaa9ac1f1884d8)
        ;

        
    
    
            var circle_94671f9c9b3540bebbdc9ddf53c59e7f = L.circle(
                [48.86461, 2.40969],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.00000000000006, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_d0393d36b4c047a0a64e9259c7700d89 = L.popup({"maxWidth": "100%"});

        
            var html_82437a48f2b4418c8b4c97e6c21b8b42 = $(`<div id="html_82437a48f2b4418c8b4c97e6c21b8b42" style="width: 100.0%; height: 100.0%;">Face au 4 avenue de la porte de Bagnolet E-O</div>`)[0];
            popup_d0393d36b4c047a0a64e9259c7700d89.setContent(html_82437a48f2b4418c8b4c97e6c21b8b42);
        

        circle_94671f9c9b3540bebbdc9ddf53c59e7f.bindPopup(popup_d0393d36b4c047a0a64e9259c7700d89)
        ;

        
    
    
            var circle_36a70db2fec34e2aaaf3d01cbf5d3b11 = L.circle(
                [48.84223, 2.36811],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_2162a3eed50045b6817e34ef6504c4ea = L.popup({"maxWidth": "100%"});

        
            var html_831329b180c74e6885ea10bf3589a1ad = $(`<div id="html_831329b180c74e6885ea10bf3589a1ad" style="width: 100.0%; height: 100.0%;">Pont Charles De Gaulle SO-NE</div>`)[0];
            popup_2162a3eed50045b6817e34ef6504c4ea.setContent(html_831329b180c74e6885ea10bf3589a1ad);
        

        circle_36a70db2fec34e2aaaf3d01cbf5d3b11.bindPopup(popup_2162a3eed50045b6817e34ef6504c4ea)
        ;

        
    
    
            var circle_4492ff21560d4177a915c74ecd68421b = L.circle(
                [48.891215, 2.38573],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 499.99999999999994, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_6f0f2d14077f45c783de8db94359a285 = L.popup({"maxWidth": "100%"});

        
            var html_b2c200ff779b41628b41dfae4b5cd285 = $(`<div id="html_b2c200ff779b41628b41dfae4b5cd285" style="width: 100.0%; height: 100.0%;">Face au 48 quai de la marne SO-NE</div>`)[0];
            popup_6f0f2d14077f45c783de8db94359a285.setContent(html_b2c200ff779b41628b41dfae4b5cd285);
        

        circle_4492ff21560d4177a915c74ecd68421b.bindPopup(popup_6f0f2d14077f45c783de8db94359a285)
        ;

        
    
    
            var circle_a660ff6567834508bb699e320d1b40b8 = L.circle(
                [48.830331, 2.400551],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_3ef516f6c1a24476a8aac706a304cf04 = L.popup({"maxWidth": "100%"});

        
            var html_3e7f94bc9a0a42809d7c4960b0917531 = $(`<div id="html_3e7f94bc9a0a42809d7c4960b0917531" style="width: 100.0%; height: 100.0%;">Face au 8 avenue de la porte de Charenton NO-SE</div>`)[0];
            popup_3ef516f6c1a24476a8aac706a304cf04.setContent(html_3e7f94bc9a0a42809d7c4960b0917531);
        

        circle_a660ff6567834508bb699e320d1b40b8.bindPopup(popup_3ef516f6c1a24476a8aac706a304cf04)
        ;

        
    
    
            var circle_142b1209482642a986129bfb481b74d2 = L.circle(
                [48.86462, 2.31444],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_0f32364baab94afdbafad437854b0027 = L.popup({"maxWidth": "100%"});

        
            var html_d8b5dcc286e048ec9063c5d2ebf5606c = $(`<div id="html_d8b5dcc286e048ec9063c5d2ebf5606c" style="width: 100.0%; height: 100.0%;">Totem Cours la Reine O-E</div>`)[0];
            popup_0f32364baab94afdbafad437854b0027.setContent(html_d8b5dcc286e048ec9063c5d2ebf5606c);
        

        circle_142b1209482642a986129bfb481b74d2.bindPopup(popup_0f32364baab94afdbafad437854b0027)
        ;

        
    
    
            var circle_694071806b7b477d9a66b53540161887 = L.circle(
                [48.86155, 2.37407],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_11ee8dcf901a42269d1e80caf40887a4 = L.popup({"maxWidth": "100%"});

        
            var html_5925c1af5c9341a6adf8ced020fd833d = $(`<div id="html_5925c1af5c9341a6adf8ced020fd833d" style="width: 100.0%; height: 100.0%;">72 boulevard Voltaire NO-SE</div>`)[0];
            popup_11ee8dcf901a42269d1e80caf40887a4.setContent(html_5925c1af5c9341a6adf8ced020fd833d);
        

        circle_694071806b7b477d9a66b53540161887.bindPopup(popup_11ee8dcf901a42269d1e80caf40887a4)
        ;

        
    
    
            var circle_61830b095001413e865dfd5585e4b9c1 = L.circle(
                [48.86057, 2.38886],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_be78239109024f4f8c37dd45f73a6dd7 = L.popup({"maxWidth": "100%"});

        
            var html_60d358f1638b4945b67c31002d82bb75 = $(`<div id="html_60d358f1638b4945b67c31002d82bb75" style="width: 100.0%; height: 100.0%;">26 boulevard de Ménilmontant SE-NO</div>`)[0];
            popup_be78239109024f4f8c37dd45f73a6dd7.setContent(html_60d358f1638b4945b67c31002d82bb75);
        

        circle_61830b095001413e865dfd5585e4b9c1.bindPopup(popup_be78239109024f4f8c37dd45f73a6dd7)
        ;

        
    
    
            var circle_54355fcc479c4792b7e071cf02657344 = L.circle(
                [48.829523, 2.38699],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_10605da239bc4ddb85d0400d8f2f26c6 = L.popup({"maxWidth": "100%"});

        
            var html_5b9682e8f51f46d4acd3cf4e668ccf1e = $(`<div id="html_5b9682e8f51f46d4acd3cf4e668ccf1e" style="width: 100.0%; height: 100.0%;">Face au 70 quai de Bercy S-N</div>`)[0];
            popup_10605da239bc4ddb85d0400d8f2f26c6.setContent(html_5b9682e8f51f46d4acd3cf4e668ccf1e);
        

        circle_54355fcc479c4792b7e071cf02657344.bindPopup(popup_10605da239bc4ddb85d0400d8f2f26c6)
        ;

        
    
    
            var circle_b24b8ec4ecf241c9803f1a4cbc6378d5 = L.circle(
                [48.829523, 2.38699],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_b97b3b7eef7a4846af116bac97963d7b = L.popup({"maxWidth": "100%"});

        
            var html_e423f51f15d14953a55847a64704c60b = $(`<div id="html_e423f51f15d14953a55847a64704c60b" style="width: 100.0%; height: 100.0%;">Face au 70 quai de Bercy N-S</div>`)[0];
            popup_b97b3b7eef7a4846af116bac97963d7b.setContent(html_e423f51f15d14953a55847a64704c60b);
        

        circle_b24b8ec4ecf241c9803f1a4cbc6378d5.bindPopup(popup_b97b3b7eef7a4846af116bac97963d7b)
        ;

        
    
    
            var circle_0ceab09827674c509f02148f1f39c664 = L.circle(
                [48.83848, 2.37587],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_369e2724db37441b8d5a3cabbcbe0743 = L.popup({"maxWidth": "100%"});

        
            var html_40a0620ed57744ea8cba26b913d62d40 = $(`<div id="html_40a0620ed57744ea8cba26b913d62d40" style="width: 100.0%; height: 100.0%;">Pont de Bercy SO-NE</div>`)[0];
            popup_369e2724db37441b8d5a3cabbcbe0743.setContent(html_40a0620ed57744ea8cba26b913d62d40);
        

        circle_0ceab09827674c509f02148f1f39c664.bindPopup(popup_369e2724db37441b8d5a3cabbcbe0743)
        ;

        
    
    
            var circle_d27f77dd92f64265b92999a349033974 = L.circle(
                [48.86288, 2.31179],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 499.99999999999994, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_2fc36c0c40ef4e20ab24ae478bd4a35b = L.popup({"maxWidth": "100%"});

        
            var html_b24f61cc350746a39e9e73cae78b3f3d = $(`<div id="html_b24f61cc350746a39e9e73cae78b3f3d" style="width: 100.0%; height: 100.0%;">Quai d'Orsay E-O</div>`)[0];
            popup_2fc36c0c40ef4e20ab24ae478bd4a35b.setContent(html_b24f61cc350746a39e9e73cae78b3f3d);
        

        circle_d27f77dd92f64265b92999a349033974.bindPopup(popup_2fc36c0c40ef4e20ab24ae478bd4a35b)
        ;

        
    
    
            var circle_5feb258cb7b44f1faa5510eb1a802589 = L.circle(
                [48.85013, 2.35423],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_b6e309cf326f424ba5f127e505b86afd);
        
    
        var popup_d85f48f376ec45e9ad5cde694e745c86 = L.popup({"maxWidth": "100%"});

        
            var html_7cbde7b97d42484b90284253e868f8e5 = $(`<div id="html_7cbde7b97d42484b90284253e868f8e5" style="width: 100.0%; height: 100.0%;">27 quai de la Tournelle NO-SE</div>`)[0];
            popup_d85f48f376ec45e9ad5cde694e745c86.setContent(html_7cbde7b97d42484b90284253e868f8e5);
        

        circle_5feb258cb7b44f1faa5510eb1a802589.bindPopup(popup_d85f48f376ec45e9ad5cde694e745c86)
        ;

        
    
</script><!--/html_preserve-->
