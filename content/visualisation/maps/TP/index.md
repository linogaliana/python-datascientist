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



{{< rawhtml >}}
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
                #map_0a4e128e2eb64929aea7af8431bd4038 {
                    position: relative;
                    width: 100.0%;
                    height: 100.0%;
                    left: 0.0%;
                    top: 0.0%;
                }
            </style>
        
</head>
<body>    
    
            <div class="folium-map" id="map_0a4e128e2eb64929aea7af8431bd4038" ></div>
        
</body>
<script>    
    
            var map_0a4e128e2eb64929aea7af8431bd4038 = L.map(
                "map_0a4e128e2eb64929aea7af8431bd4038",
                {
                    center: [48.856972463768095, 2.343495594202899],
                    crs: L.CRS.EPSG3857,
                    zoom: 12,
                    zoomControl: true,
                    preferCanvas: false,
                }
            );

            

        
    
            var tile_layer_a0bd3fcb9d0e4c0ba2a67e778186558e = L.tileLayer(
                "https://stamen-tiles-{s}.a.ssl.fastly.net/toner/{z}/{x}/{y}.png",
                {"attribution": "Map tiles by \u003ca href=\"http://stamen.com\"\u003eStamen Design\u003c/a\u003e, under \u003ca href=\"http://creativecommons.org/licenses/by/3.0\"\u003eCC BY 3.0\u003c/a\u003e. Data by \u0026copy; \u003ca href=\"http://openstreetmap.org\"\u003eOpenStreetMap\u003c/a\u003e, under \u003ca href=\"http://www.openstreetmap.org/copyright\"\u003eODbL\u003c/a\u003e.", "detectRetina": false, "maxNativeZoom": 18, "maxZoom": 18, "minZoom": 0, "noWrap": false, "opacity": 1, "subdomains": "abc", "tms": false}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
            var marker_67ac4e6daa5746158dc9e157fa084d87 = L.marker(
                [48.86149, 2.37376],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_95af9faec5ea4e14b8b7a32eb9ba5860 = L.popup({"maxWidth": "100%"});

        
            var html_8f65e4dfceeb4eae83dd43bf37404192 = $(`<div id="html_8f65e4dfceeb4eae83dd43bf37404192" style="width: 100.0%; height: 100.0%;">67 boulevard Voltaire SE-NO</div>`)[0];
            popup_95af9faec5ea4e14b8b7a32eb9ba5860.setContent(html_8f65e4dfceeb4eae83dd43bf37404192);
        

        marker_67ac4e6daa5746158dc9e157fa084d87.bindPopup(popup_95af9faec5ea4e14b8b7a32eb9ba5860)
        ;

        
    
    
            var marker_a518700aefbe49119d419cc308ed6d7b = L.marker(
                [48.830449, 2.353199],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_c042c74c040948578967b0364c1a80e0 = L.popup({"maxWidth": "100%"});

        
            var html_7d2afa8b8ab643b289e229944c566629 = $(`<div id="html_7d2afa8b8ab643b289e229944c566629" style="width: 100.0%; height: 100.0%;">21 boulevard Auguste Blanqui SO-NE</div>`)[0];
            popup_c042c74c040948578967b0364c1a80e0.setContent(html_7d2afa8b8ab643b289e229944c566629);
        

        marker_a518700aefbe49119d419cc308ed6d7b.bindPopup(popup_c042c74c040948578967b0364c1a80e0)
        ;

        
    
    
            var marker_fb621d44ae1046ebb643288254981eaa = L.marker(
                [48.83992, 2.26694],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_31aec6c02cc5413e8f05d6e9b805491f = L.popup({"maxWidth": "100%"});

        
            var html_a321048045de4a779a5024b21235b31f = $(`<div id="html_a321048045de4a779a5024b21235b31f" style="width: 100.0%; height: 100.0%;">Pont du Garigliano SE-NO SE-NO</div>`)[0];
            popup_31aec6c02cc5413e8f05d6e9b805491f.setContent(html_a321048045de4a779a5024b21235b31f);
        

        marker_fb621d44ae1046ebb643288254981eaa.bindPopup(popup_31aec6c02cc5413e8f05d6e9b805491f)
        ;

        
    
    
            var marker_e05b569b617549ee87d32f25ce9deaa6 = L.marker(
                [48.840801, 2.333233],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_a091d8c961ae44fb891a88ab61c63ba1 = L.popup({"maxWidth": "100%"});

        
            var html_87b154e030454f75a419ee8ffb342da2 = $(`<div id="html_87b154e030454f75a419ee8ffb342da2" style="width: 100.0%; height: 100.0%;">152 boulevard du Montparnasse O-E</div>`)[0];
            popup_a091d8c961ae44fb891a88ab61c63ba1.setContent(html_87b154e030454f75a419ee8ffb342da2);
        

        marker_e05b569b617549ee87d32f25ce9deaa6.bindPopup(popup_a091d8c961ae44fb891a88ab61c63ba1)
        ;

        
    
    
            var marker_71778e0dfc6849f0b173e8e7a8966c4d = L.marker(
                [48.896894, 2.344994],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_6f992b03d66d4cbba10332a8a695ff1d = L.popup({"maxWidth": "100%"});

        
            var html_1fe092f660474181b486bcdfea3caffa = $(`<div id="html_1fe092f660474181b486bcdfea3caffa" style="width: 100.0%; height: 100.0%;">69 Boulevard Ornano N-S</div>`)[0];
            popup_6f992b03d66d4cbba10332a8a695ff1d.setContent(html_1fe092f660474181b486bcdfea3caffa);
        

        marker_71778e0dfc6849f0b173e8e7a8966c4d.bindPopup(popup_6f992b03d66d4cbba10332a8a695ff1d)
        ;

        
    
    
            var marker_4402d96a01fa46b9bd4c927ec35e959e = L.marker(
                [48.87746, 2.35008],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_49710fcdbabd4ae08787333d6c7bd2f5 = L.popup({"maxWidth": "100%"});

        
            var html_802acac5db3143cc97119906a3cea7c9 = $(`<div id="html_802acac5db3143cc97119906a3cea7c9" style="width: 100.0%; height: 100.0%;">100 rue La Fayette O-E</div>`)[0];
            popup_49710fcdbabd4ae08787333d6c7bd2f5.setContent(html_802acac5db3143cc97119906a3cea7c9);
        

        marker_4402d96a01fa46b9bd4c927ec35e959e.bindPopup(popup_49710fcdbabd4ae08787333d6c7bd2f5)
        ;

        
    
    
            var marker_b7fc5e8b1f684b06ba4b91de7bfb2fb1 = L.marker(
                [48.874716, 2.292439],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_e49664b68f424311907941c82cc0d53a = L.popup({"maxWidth": "100%"});

        
            var html_77400089902841beb8904b5fa2fe0b37 = $(`<div id="html_77400089902841beb8904b5fa2fe0b37" style="width: 100.0%; height: 100.0%;">10 avenue de la Grande Armée SE-NO</div>`)[0];
            popup_e49664b68f424311907941c82cc0d53a.setContent(html_77400089902841beb8904b5fa2fe0b37);
        

        marker_b7fc5e8b1f684b06ba4b91de7bfb2fb1.bindPopup(popup_e49664b68f424311907941c82cc0d53a)
        ;

        
    
    
            var marker_485c02c48886481584ab138c49c04283 = L.marker(
                [48.891415, 2.384954],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_8fbdb66346d14d7c8740e6ac937aca41 = L.popup({"maxWidth": "100%"});

        
            var html_20e1bc57eb194cc9905a0ed4a5a083f1 = $(`<div id="html_20e1bc57eb194cc9905a0ed4a5a083f1" style="width: 100.0%; height: 100.0%;">Face au 25 quai de l'Oise SO-NE</div>`)[0];
            popup_8fbdb66346d14d7c8740e6ac937aca41.setContent(html_20e1bc57eb194cc9905a0ed4a5a083f1);
        

        marker_485c02c48886481584ab138c49c04283.bindPopup(popup_8fbdb66346d14d7c8740e6ac937aca41)
        ;

        
    
    
            var marker_ea0167f0f5eb494ca7293c2c1e12c61a = L.marker(
                [48.82026, 2.3592],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_68506ed83cc44d8ba68c40bb4bec0b84 = L.popup({"maxWidth": "100%"});

        
            var html_7f6d0bebc5f0472b8c22606b7d70ae02 = $(`<div id="html_7f6d0bebc5f0472b8c22606b7d70ae02" style="width: 100.0%; height: 100.0%;">147 avenue d'Italie S-N</div>`)[0];
            popup_68506ed83cc44d8ba68c40bb4bec0b84.setContent(html_7f6d0bebc5f0472b8c22606b7d70ae02);
        

        marker_ea0167f0f5eb494ca7293c2c1e12c61a.bindPopup(popup_68506ed83cc44d8ba68c40bb4bec0b84)
        ;

        
    
    
            var marker_f9c23c02e67f4e498565aea84da7acc0 = L.marker(
                [48.85209, 2.28508],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_88c35b9d685248bcb7ea575d1d50271e = L.popup({"maxWidth": "100%"});

        
            var html_7f11a2e733244fcebe3f68af200685d6 = $(`<div id="html_7f11a2e733244fcebe3f68af200685d6" style="width: 100.0%; height: 100.0%;">36 quai de Grenelle SO-NE</div>`)[0];
            popup_88c35b9d685248bcb7ea575d1d50271e.setContent(html_7f11a2e733244fcebe3f68af200685d6);
        

        marker_f9c23c02e67f4e498565aea84da7acc0.bindPopup(popup_88c35b9d685248bcb7ea575d1d50271e)
        ;

        
    
    
            var marker_d2c9ed01af50470aae49bdf0dcb44ec8 = L.marker(
                [48.83848, 2.37587],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_58df29d255ab470f8dcda473644b4fb0 = L.popup({"maxWidth": "100%"});

        
            var html_0f346c9833894d6e821d732d4aef0751 = $(`<div id="html_0f346c9833894d6e821d732d4aef0751" style="width: 100.0%; height: 100.0%;">Pont de Bercy NE-SO</div>`)[0];
            popup_58df29d255ab470f8dcda473644b4fb0.setContent(html_0f346c9833894d6e821d732d4aef0751);
        

        marker_d2c9ed01af50470aae49bdf0dcb44ec8.bindPopup(popup_58df29d255ab470f8dcda473644b4fb0)
        ;

        
    
    
            var marker_143b878d34294be0a31a1fbd9082440f = L.marker(
                [48.889046, 2.374872],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_8d86d2b8d83f406ca44643d9e5f6b107 = L.popup({"maxWidth": "100%"});

        
            var html_6a6e4b3c954947fbb11150a09bd37e91 = $(`<div id="html_6a6e4b3c954947fbb11150a09bd37e91" style="width: 100.0%; height: 100.0%;">72 avenue de Flandre SO-NE</div>`)[0];
            popup_8d86d2b8d83f406ca44643d9e5f6b107.setContent(html_6a6e4b3c954947fbb11150a09bd37e91);
        

        marker_143b878d34294be0a31a1fbd9082440f.bindPopup(popup_8d86d2b8d83f406ca44643d9e5f6b107)
        ;

        
    
    
            var marker_5892257fc9c34cd1b09551769548d4dd = L.marker(
                [48.86377, 2.35096],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_70299a5a46374ebc9a2e6acfbfd956ef = L.popup({"maxWidth": "100%"});

        
            var html_e62d35c9eadc43fb9b9b81ec9c50b000 = $(`<div id="html_e62d35c9eadc43fb9b9b81ec9c50b000" style="width: 100.0%; height: 100.0%;">Totem 73 boulevard de Sébastopol N-S</div>`)[0];
            popup_70299a5a46374ebc9a2e6acfbfd956ef.setContent(html_e62d35c9eadc43fb9b9b81ec9c50b000);
        

        marker_5892257fc9c34cd1b09551769548d4dd.bindPopup(popup_70299a5a46374ebc9a2e6acfbfd956ef)
        ;

        
    
    
            var marker_06230fd30d3d4032881b10c0c749b401 = L.marker(
                [48.83521, 2.33307],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_51d5f68c57e344afabd09f07010b8065 = L.popup({"maxWidth": "100%"});

        
            var html_05780637e92d401ca96495dd4d6203d5 = $(`<div id="html_05780637e92d401ca96495dd4d6203d5" style="width: 100.0%; height: 100.0%;">106 avenue Denfert Rochereau NE-SO</div>`)[0];
            popup_51d5f68c57e344afabd09f07010b8065.setContent(html_05780637e92d401ca96495dd4d6203d5);
        

        marker_06230fd30d3d4032881b10c0c749b401.bindPopup(popup_51d5f68c57e344afabd09f07010b8065)
        ;

        
    
    
            var marker_c3e5b659028a422dbe492ca54772d2d8 = L.marker(
                [48.8484, 2.27586],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_a400c79b27664150b09816224aad89a0 = L.popup({"maxWidth": "100%"});

        
            var html_077cae774b094a64a91ab39e5a931537 = $(`<div id="html_077cae774b094a64a91ab39e5a931537" style="width: 100.0%; height: 100.0%;">Voie Georges Pompidou NE-SO</div>`)[0];
            popup_a400c79b27664150b09816224aad89a0.setContent(html_077cae774b094a64a91ab39e5a931537);
        

        marker_c3e5b659028a422dbe492ca54772d2d8.bindPopup(popup_a400c79b27664150b09816224aad89a0)
        ;

        
    
    
            var marker_d2fb6ef87a4c4823ae37881a855c7141 = L.marker(
                [48.842091, 2.301],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_d2bcbc89afe44002b60e1f2adfba9477 = L.popup({"maxWidth": "100%"});

        
            var html_ef5086a7f64c4f3c9681bdd2fba2d7d4 = $(`<div id="html_ef5086a7f64c4f3c9681bdd2fba2d7d4" style="width: 100.0%; height: 100.0%;">129 rue Lecourbe SO-NE</div>`)[0];
            popup_d2bcbc89afe44002b60e1f2adfba9477.setContent(html_ef5086a7f64c4f3c9681bdd2fba2d7d4);
        

        marker_d2fb6ef87a4c4823ae37881a855c7141.bindPopup(popup_d2bcbc89afe44002b60e1f2adfba9477)
        ;

        
    
    
            var marker_a02b6c04b5274fb1bc12ab77cb56e5a9 = L.marker(
                [48.84638, 2.31529],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_8c24a1244bc94a3b89f73e3dfd400094 = L.popup({"maxWidth": "100%"});

        
            var html_2f771fafd57d4b6d8a2e437eae3ea07d = $(`<div id="html_2f771fafd57d4b6d8a2e437eae3ea07d" style="width: 100.0%; height: 100.0%;">90 Rue De Sèvres SO-NE</div>`)[0];
            popup_8c24a1244bc94a3b89f73e3dfd400094.setContent(html_2f771fafd57d4b6d8a2e437eae3ea07d);
        

        marker_a02b6c04b5274fb1bc12ab77cb56e5a9.bindPopup(popup_8c24a1244bc94a3b89f73e3dfd400094)
        ;

        
    
    
            var marker_4a93c8867ffd4a6b86ea6ff8eec57066 = L.marker(
                [48.890457, 2.368852],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_f6513a7f5edd4009b6bb262ccbf8985e = L.popup({"maxWidth": "100%"});

        
            var html_6d2ea5575e8149a8a6940ab6b987c2f1 = $(`<div id="html_6d2ea5575e8149a8a6940ab6b987c2f1" style="width: 100.0%; height: 100.0%;">Face 104 rue d'Aubervilliers N-S</div>`)[0];
            popup_f6513a7f5edd4009b6bb262ccbf8985e.setContent(html_6d2ea5575e8149a8a6940ab6b987c2f1);
        

        marker_4a93c8867ffd4a6b86ea6ff8eec57066.bindPopup(popup_f6513a7f5edd4009b6bb262ccbf8985e)
        ;

        
    
    
            var marker_7db35e9ed36f46049a211270454fdabf = L.marker(
                [48.86378, 2.32003],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_a7ba0dd34881429186e09c6bd4a9cd6c = L.popup({"maxWidth": "100%"});

        
            var html_e9c701eadafd4cbc84b34299ef57b245 = $(`<div id="html_e9c701eadafd4cbc84b34299ef57b245" style="width: 100.0%; height: 100.0%;">Pont de la Concorde S-N</div>`)[0];
            popup_a7ba0dd34881429186e09c6bd4a9cd6c.setContent(html_e9c701eadafd4cbc84b34299ef57b245);
        

        marker_7db35e9ed36f46049a211270454fdabf.bindPopup(popup_a7ba0dd34881429186e09c6bd4a9cd6c)
        ;

        
    
    
            var marker_c3287f58a41b4c05b20ec5c3778e3aad = L.marker(
                [48.86288, 2.31179],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_c8e470fa78684b248aa44f5534aa8aaa = L.popup({"maxWidth": "100%"});

        
            var html_b1cf3509a85743028c0ee3b8d8af173a = $(`<div id="html_b1cf3509a85743028c0ee3b8d8af173a" style="width: 100.0%; height: 100.0%;">Quai d'Orsay O-E</div>`)[0];
            popup_c8e470fa78684b248aa44f5534aa8aaa.setContent(html_b1cf3509a85743028c0ee3b8d8af173a);
        

        marker_c3287f58a41b4c05b20ec5c3778e3aad.bindPopup(popup_c8e470fa78684b248aa44f5534aa8aaa)
        ;

        
    
    
            var marker_f7f92d65ca344d6799f183d3728d988c = L.marker(
                [48.851525, 2.343298],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_e2b9da191d824683b21ca453eac639f7 = L.popup({"maxWidth": "100%"});

        
            var html_62f78e1ec74145b9bc65100d622104cb = $(`<div id="html_62f78e1ec74145b9bc65100d622104cb" style="width: 100.0%; height: 100.0%;">21 boulevard Saint Michel S-N</div>`)[0];
            popup_e2b9da191d824683b21ca453eac639f7.setContent(html_62f78e1ec74145b9bc65100d622104cb);
        

        marker_f7f92d65ca344d6799f183d3728d988c.bindPopup(popup_e2b9da191d824683b21ca453eac639f7)
        ;

        
    
    
            var marker_3a8aa3ace6b745549bc3b7f08198ada0 = L.marker(
                [48.896825, 2.345648],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_07eac4280e894b42ad1b8eaeb111dd2a = L.popup({"maxWidth": "100%"});

        
            var html_b43bd3fde8d54ccfaf6dbf24f2bbdc5b = $(`<div id="html_b43bd3fde8d54ccfaf6dbf24f2bbdc5b" style="width: 100.0%; height: 100.0%;">74 Boulevard Ornano S-N</div>`)[0];
            popup_07eac4280e894b42ad1b8eaeb111dd2a.setContent(html_b43bd3fde8d54ccfaf6dbf24f2bbdc5b);
        

        marker_3a8aa3ace6b745549bc3b7f08198ada0.bindPopup(popup_07eac4280e894b42ad1b8eaeb111dd2a)
        ;

        
    
    
            var marker_975d540d62e94d4aa6a2f4df0a043ab4 = L.marker(
                [48.82658, 2.38409],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_330b9df472fc46659bfd3225289c5953 = L.popup({"maxWidth": "100%"});

        
            var html_b53bd6775d294681bc432305f6bafea8 = $(`<div id="html_b53bd6775d294681bc432305f6bafea8" style="width: 100.0%; height: 100.0%;">Pont National SO-NE</div>`)[0];
            popup_330b9df472fc46659bfd3225289c5953.setContent(html_b53bd6775d294681bc432305f6bafea8);
        

        marker_975d540d62e94d4aa6a2f4df0a043ab4.bindPopup(popup_330b9df472fc46659bfd3225289c5953)
        ;

        
    
    
            var marker_60bbeda94f7f4f32a78b337324357ca9 = L.marker(
                [48.891415, 2.384954],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_f59b4e21613943b8bb7b9e22d5d94d30 = L.popup({"maxWidth": "100%"});

        
            var html_9e178cac9c6f46d1b9a1202cdc7cd6ef = $(`<div id="html_9e178cac9c6f46d1b9a1202cdc7cd6ef" style="width: 100.0%; height: 100.0%;">Face au 25 quai de l'Oise NE-SO</div>`)[0];
            popup_f59b4e21613943b8bb7b9e22d5d94d30.setContent(html_9e178cac9c6f46d1b9a1202cdc7cd6ef);
        

        marker_60bbeda94f7f4f32a78b337324357ca9.bindPopup(popup_f59b4e21613943b8bb7b9e22d5d94d30)
        ;

        
    
    
            var marker_ae9b16a6e166436cb6850ee8d8d70087 = L.marker(
                [48.86392, 2.31988],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_9332c000b454493280e69765eb3aa283 = L.popup({"maxWidth": "100%"});

        
            var html_525dbbb1f0d2497e9f6d19c298d7086d = $(`<div id="html_525dbbb1f0d2497e9f6d19c298d7086d" style="width: 100.0%; height: 100.0%;">Pont de la Concorde N-S</div>`)[0];
            popup_9332c000b454493280e69765eb3aa283.setContent(html_525dbbb1f0d2497e9f6d19c298d7086d);
        

        marker_ae9b16a6e166436cb6850ee8d8d70087.bindPopup(popup_9332c000b454493280e69765eb3aa283)
        ;

        
    
    
            var marker_103060715e93409dac3b65efdaba9edf = L.marker(
                [48.82108, 2.32537],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_51bd4b97b9f04c66a46c9a0791430fb5 = L.popup({"maxWidth": "100%"});

        
            var html_8dd27f6626ff4cb6bf9a6c072b271d8e = $(`<div id="html_8dd27f6626ff4cb6bf9a6c072b271d8e" style="width: 100.0%; height: 100.0%;">3 avenue de la Porte D'Orléans S-N</div>`)[0];
            popup_51bd4b97b9f04c66a46c9a0791430fb5.setContent(html_8dd27f6626ff4cb6bf9a6c072b271d8e);
        

        marker_103060715e93409dac3b65efdaba9edf.bindPopup(popup_51bd4b97b9f04c66a46c9a0791430fb5)
        ;

        
    
    
            var marker_234ef7407e7f4c6eba0d7adfc7b46a8d = L.marker(
                [48.86179, 2.32014],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_b513b31a90014dbebd4a87f775be5594 = L.popup({"maxWidth": "100%"});

        
            var html_dd352ab5e5fe4303b82dd5f934a94592 = $(`<div id="html_dd352ab5e5fe4303b82dd5f934a94592" style="width: 100.0%; height: 100.0%;">243 boulevard Saint Germain NO-SE</div>`)[0];
            popup_b513b31a90014dbebd4a87f775be5594.setContent(html_dd352ab5e5fe4303b82dd5f934a94592);
        

        marker_234ef7407e7f4c6eba0d7adfc7b46a8d.bindPopup(popup_b513b31a90014dbebd4a87f775be5594)
        ;

        
    
    
            var marker_65c836d2d23e4df1abdb8e43a36f5573 = L.marker(
                [48.85735, 2.35211],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_77c4f32db2514cd58bef8b4381571c2b = L.popup({"maxWidth": "100%"});

        
            var html_d07b63d16a2b4d499631456e73263d8a = $(`<div id="html_d07b63d16a2b4d499631456e73263d8a" style="width: 100.0%; height: 100.0%;">Totem 64 Rue de Rivoli E-O</div>`)[0];
            popup_77c4f32db2514cd58bef8b4381571c2b.setContent(html_d07b63d16a2b4d499631456e73263d8a);
        

        marker_65c836d2d23e4df1abdb8e43a36f5573.bindPopup(popup_77c4f32db2514cd58bef8b4381571c2b)
        ;

        
    
    
            var marker_10578ed724954dcb8814f466de82515f = L.marker(
                [48.88529, 2.32666],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_fb6e91da4425446999b502c887a142ef = L.popup({"maxWidth": "100%"});

        
            var html_f2ac7efc69da44f8a1e663159c791a06 = $(`<div id="html_f2ac7efc69da44f8a1e663159c791a06" style="width: 100.0%; height: 100.0%;">20 Avenue de Clichy SE-NO</div>`)[0];
            popup_fb6e91da4425446999b502c887a142ef.setContent(html_f2ac7efc69da44f8a1e663159c791a06);
        

        marker_10578ed724954dcb8814f466de82515f.bindPopup(popup_fb6e91da4425446999b502c887a142ef)
        ;

        
    
    
            var marker_e2dae2768bed45b9abd6035e6ba7ebb3 = L.marker(
                [48.860852, 2.372279],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_be609e915e8d4d97a17b43fd3ee68b8d = L.popup({"maxWidth": "100%"});

        
            var html_894b331e45ea4fbb917fde8bd8408d94 = $(`<div id="html_894b331e45ea4fbb917fde8bd8408d94" style="width: 100.0%; height: 100.0%;">77 boulevard Richard Lenoir N-S</div>`)[0];
            popup_be609e915e8d4d97a17b43fd3ee68b8d.setContent(html_894b331e45ea4fbb917fde8bd8408d94);
        

        marker_e2dae2768bed45b9abd6035e6ba7ebb3.bindPopup(popup_be609e915e8d4d97a17b43fd3ee68b8d)
        ;

        
    
    
            var marker_8e8820639b974ed29b9d7c30affa9026 = L.marker(
                [48.840801, 2.333233],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_8e487d5b8db342d18dc52ca97a85c847 = L.popup({"maxWidth": "100%"});

        
            var html_3dda9f42837d4962a274143dfac04764 = $(`<div id="html_3dda9f42837d4962a274143dfac04764" style="width: 100.0%; height: 100.0%;">152 boulevard du Montparnasse E-O</div>`)[0];
            popup_8e487d5b8db342d18dc52ca97a85c847.setContent(html_3dda9f42837d4962a274143dfac04764);
        

        marker_8e8820639b974ed29b9d7c30affa9026.bindPopup(popup_8e487d5b8db342d18dc52ca97a85c847)
        ;

        
    
    
            var marker_086c2a34865841369a3db461d56f8221 = L.marker(
                [48.85735, 2.35211],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_da6317971ddc406ab3744f1fe7bcd062 = L.popup({"maxWidth": "100%"});

        
            var html_e0986dfd58b04ad5ac078b938c6ea6e0 = $(`<div id="html_e0986dfd58b04ad5ac078b938c6ea6e0" style="width: 100.0%; height: 100.0%;">Totem 64 Rue de Rivoli O-E</div>`)[0];
            popup_da6317971ddc406ab3744f1fe7bcd062.setContent(html_e0986dfd58b04ad5ac078b938c6ea6e0);
        

        marker_086c2a34865841369a3db461d56f8221.bindPopup(popup_da6317971ddc406ab3744f1fe7bcd062)
        ;

        
    
    
            var marker_6dbdb299b250481399b4fb56d4413530 = L.marker(
                [48.86284, 2.310345],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_f0c33e7814b54f69b3273232f4b765f1 = L.popup({"maxWidth": "100%"});

        
            var html_2d04cbedc183484493e137949553f281 = $(`<div id="html_2d04cbedc183484493e137949553f281" style="width: 100.0%; height: 100.0%;">Pont des Invalides N-S</div>`)[0];
            popup_f0c33e7814b54f69b3273232f4b765f1.setContent(html_2d04cbedc183484493e137949553f281);
        

        marker_6dbdb299b250481399b4fb56d4413530.bindPopup(popup_f0c33e7814b54f69b3273232f4b765f1)
        ;

        
    
    
            var marker_5b4592ca6bb24d37911570e07b120cb0 = L.marker(
                [48.830331, 2.400551],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_c7b97e6ce14f47a39572d8456700cab8 = L.popup({"maxWidth": "100%"});

        
            var html_f3c63170314245f38b911dab4b81dc91 = $(`<div id="html_f3c63170314245f38b911dab4b81dc91" style="width: 100.0%; height: 100.0%;">Face au 8 avenue de la porte de Charenton SE-NO</div>`)[0];
            popup_c7b97e6ce14f47a39572d8456700cab8.setContent(html_f3c63170314245f38b911dab4b81dc91);
        

        marker_5b4592ca6bb24d37911570e07b120cb0.bindPopup(popup_c7b97e6ce14f47a39572d8456700cab8)
        ;

        
    
    
            var marker_fc6b197f208644aaa7d4775221a3c414 = L.marker(
                [48.84223, 2.36811],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_433be57f92f54395bb1d204a11b20190 = L.popup({"maxWidth": "100%"});

        
            var html_51c4d6e2310f4cf8b44aeaf676cdd5bd = $(`<div id="html_51c4d6e2310f4cf8b44aeaf676cdd5bd" style="width: 100.0%; height: 100.0%;">Pont Charles De Gaulle NE-SO</div>`)[0];
            popup_433be57f92f54395bb1d204a11b20190.setContent(html_51c4d6e2310f4cf8b44aeaf676cdd5bd);
        

        marker_fc6b197f208644aaa7d4775221a3c414.bindPopup(popup_433be57f92f54395bb1d204a11b20190)
        ;

        
    
    
            var marker_bdc256fa9a3e4ff78ccceeda07d2caa1 = L.marker(
                [48.846028, 2.375429],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_71d6bc6e1b204bb1870c34e11f8ceb6d = L.popup({"maxWidth": "100%"});

        
            var html_0992c37c4b7f49d6803502ad5bc728c2 = $(`<div id="html_0992c37c4b7f49d6803502ad5bc728c2" style="width: 100.0%; height: 100.0%;">28 boulevard Diderot E-O</div>`)[0];
            popup_71d6bc6e1b204bb1870c34e11f8ceb6d.setContent(html_0992c37c4b7f49d6803502ad5bc728c2);
        

        marker_bdc256fa9a3e4ff78ccceeda07d2caa1.bindPopup(popup_71d6bc6e1b204bb1870c34e11f8ceb6d)
        ;

        
    
    
            var marker_19bc6ed62df34872a82d6812667bc6ea = L.marker(
                [48.85372, 2.35702],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_f676e3f3a12a4637b9a4dc357e07397f = L.popup({"maxWidth": "100%"});

        
            var html_3403083285674bcf8138fbe6d3f55180 = $(`<div id="html_3403083285674bcf8138fbe6d3f55180" style="width: 100.0%; height: 100.0%;">18 quai de l'hotel de ville SE-NO</div>`)[0];
            popup_f676e3f3a12a4637b9a4dc357e07397f.setContent(html_3403083285674bcf8138fbe6d3f55180);
        

        marker_19bc6ed62df34872a82d6812667bc6ea.bindPopup(popup_f676e3f3a12a4637b9a4dc357e07397f)
        ;

        
    
    
            var marker_f93ef492b3d74852a91168baa359f092 = L.marker(
                [48.869873, 2.307419],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_d987fe4c07aa47889d9dec668acb2db9 = L.popup({"maxWidth": "100%"});

        
            var html_dcb55ff92ff044cb990ed1efb63a2559 = $(`<div id="html_dcb55ff92ff044cb990ed1efb63a2559" style="width: 100.0%; height: 100.0%;">44 avenue des Champs Elysées SE-NO</div>`)[0];
            popup_d987fe4c07aa47889d9dec668acb2db9.setContent(html_dcb55ff92ff044cb990ed1efb63a2559);
        

        marker_f93ef492b3d74852a91168baa359f092.bindPopup(popup_d987fe4c07aa47889d9dec668acb2db9)
        ;

        
    
    
            var marker_f3a7dfd5d35f49b0bf9314f1c903b343 = L.marker(
                [48.84216, 2.30115],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_a097dd9eba2b497aaf4adb08ccc56a28 = L.popup({"maxWidth": "100%"});

        
            var html_dac735a6b246405ab7cfca3f4da9deb7 = $(`<div id="html_dac735a6b246405ab7cfca3f4da9deb7" style="width: 100.0%; height: 100.0%;">132 rue Lecourbe NE-SO</div>`)[0];
            popup_a097dd9eba2b497aaf4adb08ccc56a28.setContent(html_dac735a6b246405ab7cfca3f4da9deb7);
        

        marker_f3a7dfd5d35f49b0bf9314f1c903b343.bindPopup(popup_a097dd9eba2b497aaf4adb08ccc56a28)
        ;

        
    
    
            var marker_a7ddf1a4ec3941949a60558a96fe6015 = L.marker(
                [48.89594, 2.35953],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_2cb1472fde2b4ae7b4aa96404f581f77 = L.popup({"maxWidth": "100%"});

        
            var html_8e83ff45868c49b8b0cfc8d3ea93fe76 = $(`<div id="html_8e83ff45868c49b8b0cfc8d3ea93fe76" style="width: 100.0%; height: 100.0%;">72 rue de la Chapelle N-S</div>`)[0];
            popup_2cb1472fde2b4ae7b4aa96404f581f77.setContent(html_8e83ff45868c49b8b0cfc8d3ea93fe76);
        

        marker_a7ddf1a4ec3941949a60558a96fe6015.bindPopup(popup_2cb1472fde2b4ae7b4aa96404f581f77)
        ;

        
    
    
            var marker_2034ee0519464bcca9891ab83348d4d1 = L.marker(
                [48.85209, 2.28508],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_7ddb78db674b4bbbb7346e8ad9880e4a = L.popup({"maxWidth": "100%"});

        
            var html_b5f90fa4e98142e49fde918038474a59 = $(`<div id="html_b5f90fa4e98142e49fde918038474a59" style="width: 100.0%; height: 100.0%;">36 quai de Grenelle NE-SO</div>`)[0];
            popup_7ddb78db674b4bbbb7346e8ad9880e4a.setContent(html_b5f90fa4e98142e49fde918038474a59);
        

        marker_2034ee0519464bcca9891ab83348d4d1.bindPopup(popup_7ddb78db674b4bbbb7346e8ad9880e4a)
        ;

        
    
    
            var marker_4cf746be6bb24f299e9ac88379b00b31 = L.marker(
                [48.83421, 2.26542],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_8a7e05602e1242829b588982b2221e0f = L.popup({"maxWidth": "100%"});

        
            var html_0c5aa5da58bb4ac7b59860e6638541d9 = $(`<div id="html_0c5aa5da58bb4ac7b59860e6638541d9" style="width: 100.0%; height: 100.0%;">Face au 40 quai D'Issy NE-SO</div>`)[0];
            popup_8a7e05602e1242829b588982b2221e0f.setContent(html_0c5aa5da58bb4ac7b59860e6638541d9);
        

        marker_4cf746be6bb24f299e9ac88379b00b31.bindPopup(popup_8a7e05602e1242829b588982b2221e0f)
        ;

        
    
    
            var marker_d8f32da4eb18417ea0fba02a210e22c5 = L.marker(
                [48.84201, 2.36729],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_7d06df91272b4439b8850001e667d29d = L.popup({"maxWidth": "100%"});

        
            var html_8487e14866b64ff0b4732efde481ffb2 = $(`<div id="html_8487e14866b64ff0b4732efde481ffb2" style="width: 100.0%; height: 100.0%;">Totem 85 quai d'Austerlitz NO-SE</div>`)[0];
            popup_7d06df91272b4439b8850001e667d29d.setContent(html_8487e14866b64ff0b4732efde481ffb2);
        

        marker_d8f32da4eb18417ea0fba02a210e22c5.bindPopup(popup_7d06df91272b4439b8850001e667d29d)
        ;

        
    
    
            var marker_7ee0468abcfc4bfca55101bd7e3d61d4 = L.marker(
                [48.86077, 2.37305],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_6950e2e0143a458a95557568eba6c013 = L.popup({"maxWidth": "100%"});

        
            var html_b7ff5fc96b0d4771ba09d84eb0993df7 = $(`<div id="html_b7ff5fc96b0d4771ba09d84eb0993df7" style="width: 100.0%; height: 100.0%;">72 boulevard Richard Lenoir  S-N</div>`)[0];
            popup_6950e2e0143a458a95557568eba6c013.setContent(html_b7ff5fc96b0d4771ba09d84eb0993df7);
        

        marker_7ee0468abcfc4bfca55101bd7e3d61d4.bindPopup(popup_6950e2e0143a458a95557568eba6c013)
        ;

        
    
    
            var marker_2fafc52cc22541ff8b2d7c32b14aa17e = L.marker(
                [48.82636, 2.30303],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_0eab6fd54811452b82c01abdbd08aefb = L.popup({"maxWidth": "100%"});

        
            var html_49d370c44ef74b958dcea741220ebb30 = $(`<div id="html_49d370c44ef74b958dcea741220ebb30" style="width: 100.0%; height: 100.0%;">6 rue Julia Bartet SO-NE</div>`)[0];
            popup_0eab6fd54811452b82c01abdbd08aefb.setContent(html_49d370c44ef74b958dcea741220ebb30);
        

        marker_2fafc52cc22541ff8b2d7c32b14aa17e.bindPopup(popup_0eab6fd54811452b82c01abdbd08aefb)
        ;

        
    
    
            var marker_77a1e8ff7016431cb7568c7a6965c618 = L.marker(
                [48.860528, 2.388364],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_44123802ece64075a97cf4ded5f128fb = L.popup({"maxWidth": "100%"});

        
            var html_4bb6a7bfb95a4c00a3a162f856e551f3 = $(`<div id="html_4bb6a7bfb95a4c00a3a162f856e551f3" style="width: 100.0%; height: 100.0%;">35 boulevard de Menilmontant NO-SE</div>`)[0];
            popup_44123802ece64075a97cf4ded5f128fb.setContent(html_4bb6a7bfb95a4c00a3a162f856e551f3);
        

        marker_77a1e8ff7016431cb7568c7a6965c618.bindPopup(popup_44123802ece64075a97cf4ded5f128fb)
        ;

        
    
    
            var marker_9192306020964492aa4107081095a927 = L.marker(
                [48.85013, 2.35423],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_d68827b0de7b4f019f65d44010471dfb = L.popup({"maxWidth": "100%"});

        
            var html_c365c889b5f44bbba828eacefb318f73 = $(`<div id="html_c365c889b5f44bbba828eacefb318f73" style="width: 100.0%; height: 100.0%;">27 quai de la Tournelle SE-NO</div>`)[0];
            popup_d68827b0de7b4f019f65d44010471dfb.setContent(html_c365c889b5f44bbba828eacefb318f73);
        

        marker_9192306020964492aa4107081095a927.bindPopup(popup_d68827b0de7b4f019f65d44010471dfb)
        ;

        
    
    
            var marker_c9508a385ede418d82a00283a05492eb = L.marker(
                [48.86377, 2.35096],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_cc328d04a9b5483089e0155815755ab8 = L.popup({"maxWidth": "100%"});

        
            var html_59375edf25614a0a91a99b64f11199d7 = $(`<div id="html_59375edf25614a0a91a99b64f11199d7" style="width: 100.0%; height: 100.0%;">Totem 73 boulevard de Sébastopol S-N</div>`)[0];
            popup_cc328d04a9b5483089e0155815755ab8.setContent(html_59375edf25614a0a91a99b64f11199d7);
        

        marker_c9508a385ede418d82a00283a05492eb.bindPopup(popup_cc328d04a9b5483089e0155815755ab8)
        ;

        
    
    
            var marker_b77fd7f6839d408f9349975bdd9de7d2 = L.marker(
                [48.843435, 2.383378],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_fef92af272e24e01a2262bcd234dc6dc = L.popup({"maxWidth": "100%"});

        
            var html_2329bf174d804ad6a7aad8d02eb19439 = $(`<div id="html_2329bf174d804ad6a7aad8d02eb19439" style="width: 100.0%; height: 100.0%;">135 avenue Daumesnil SE-NO</div>`)[0];
            popup_fef92af272e24e01a2262bcd234dc6dc.setContent(html_2329bf174d804ad6a7aad8d02eb19439);
        

        marker_b77fd7f6839d408f9349975bdd9de7d2.bindPopup(popup_fef92af272e24e01a2262bcd234dc6dc)
        ;

        
    
    
            var marker_aaf9e377acfc488cbd3b453346283013 = L.marker(
                [48.846028, 2.375429],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_d4fe02b5d0a04a6ea9fb98bd2429cdf6 = L.popup({"maxWidth": "100%"});

        
            var html_9af61cb942b5485d8964eb6a71fb25cc = $(`<div id="html_9af61cb942b5485d8964eb6a71fb25cc" style="width: 100.0%; height: 100.0%;">28 boulevard Diderot O-E</div>`)[0];
            popup_d4fe02b5d0a04a6ea9fb98bd2429cdf6.setContent(html_9af61cb942b5485d8964eb6a71fb25cc);
        

        marker_aaf9e377acfc488cbd3b453346283013.bindPopup(popup_d4fe02b5d0a04a6ea9fb98bd2429cdf6)
        ;

        
    
    
            var marker_7f3efa524a394905bf94fea8a9ab5b4d = L.marker(
                [48.85372, 2.35702],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_8cdf74afba5e4ec1a793bd2e58984979 = L.popup({"maxWidth": "100%"});

        
            var html_a958f3fd46444b5196958edd677d69f0 = $(`<div id="html_a958f3fd46444b5196958edd677d69f0" style="width: 100.0%; height: 100.0%;">18 quai de l'hotel de ville NO-SE</div>`)[0];
            popup_8cdf74afba5e4ec1a793bd2e58984979.setContent(html_a958f3fd46444b5196958edd677d69f0);
        

        marker_7f3efa524a394905bf94fea8a9ab5b4d.bindPopup(popup_8cdf74afba5e4ec1a793bd2e58984979)
        ;

        
    
    
            var marker_58a28c43c5644ba993562c0afaa59cf8 = L.marker(
                [48.86451, 2.40932],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_ed39a549b4544500adcc8700b056a53d = L.popup({"maxWidth": "100%"});

        
            var html_49756fb7985a43b5b9f87d4792fcbfc0 = $(`<div id="html_49756fb7985a43b5b9f87d4792fcbfc0" style="width: 100.0%; height: 100.0%;">2 avenue de la Porte de Bagnolet O-E</div>`)[0];
            popup_ed39a549b4544500adcc8700b056a53d.setContent(html_49756fb7985a43b5b9f87d4792fcbfc0);
        

        marker_58a28c43c5644ba993562c0afaa59cf8.bindPopup(popup_ed39a549b4544500adcc8700b056a53d)
        ;

        
    
    
            var marker_23ecb30a73164cb093b8a8050b68482d = L.marker(
                [48.83421, 2.26542],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_f4f4784017714e01b7890c460956e537 = L.popup({"maxWidth": "100%"});

        
            var html_54b4e1825c2343af9bb88f8017ce9431 = $(`<div id="html_54b4e1825c2343af9bb88f8017ce9431" style="width: 100.0%; height: 100.0%;">Face au 40 quai D'Issy SO-NE</div>`)[0];
            popup_f4f4784017714e01b7890c460956e537.setContent(html_54b4e1825c2343af9bb88f8017ce9431);
        

        marker_23ecb30a73164cb093b8a8050b68482d.bindPopup(popup_f4f4784017714e01b7890c460956e537)
        ;

        
    
    
            var marker_c9694f038dd841d991a85947f324cd23 = L.marker(
                [48.86521, 2.35358],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_33ea8e735b4f4591928629c204e1ef79 = L.popup({"maxWidth": "100%"});

        
            var html_d8eb47159e7b4c208e14edba2b3518be = $(`<div id="html_d8eb47159e7b4c208e14edba2b3518be" style="width: 100.0%; height: 100.0%;">38 rue Turbigo NE-SO</div>`)[0];
            popup_33ea8e735b4f4591928629c204e1ef79.setContent(html_d8eb47159e7b4c208e14edba2b3518be);
        

        marker_c9694f038dd841d991a85947f324cd23.bindPopup(popup_33ea8e735b4f4591928629c204e1ef79)
        ;

        
    
    
            var marker_7a81d97e37d1428095d9df60954edd4b = L.marker(
                [48.877667, 2.350556],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_bc83314ff0a348c38fe49cb2cd8c8a41 = L.popup({"maxWidth": "100%"});

        
            var html_278b7ce91b184812923a19542ff8c930 = $(`<div id="html_278b7ce91b184812923a19542ff8c930" style="width: 100.0%; height: 100.0%;">105 rue La Fayette E-O</div>`)[0];
            popup_bc83314ff0a348c38fe49cb2cd8c8a41.setContent(html_278b7ce91b184812923a19542ff8c930);
        

        marker_7a81d97e37d1428095d9df60954edd4b.bindPopup(popup_bc83314ff0a348c38fe49cb2cd8c8a41)
        ;

        
    
    
            var marker_56e9adcabeb94b1fbf84d5991943f6e7 = L.marker(
                [48.83436, 2.377],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_9426b43aadd24549b0a28ad2588d01d1 = L.popup({"maxWidth": "100%"});

        
            var html_00f105783c1643188b20bf0020a333f2 = $(`<div id="html_00f105783c1643188b20bf0020a333f2" style="width: 100.0%; height: 100.0%;">39 quai François Mauriac SE-NO</div>`)[0];
            popup_9426b43aadd24549b0a28ad2588d01d1.setContent(html_00f105783c1643188b20bf0020a333f2);
        

        marker_56e9adcabeb94b1fbf84d5991943f6e7.bindPopup(popup_9426b43aadd24549b0a28ad2588d01d1)
        ;

        
    
    
            var marker_60bb8e7c84314ceabdd968ed1f079bc1 = L.marker(
                [48.83436, 2.377],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_2a00bfd6ede24f4aa1e2fe8075d33e03 = L.popup({"maxWidth": "100%"});

        
            var html_efe1de9da3e44464a3f224e612a938a1 = $(`<div id="html_efe1de9da3e44464a3f224e612a938a1" style="width: 100.0%; height: 100.0%;">39 quai François Mauriac NO-SE</div>`)[0];
            popup_2a00bfd6ede24f4aa1e2fe8075d33e03.setContent(html_efe1de9da3e44464a3f224e612a938a1);
        

        marker_60bb8e7c84314ceabdd968ed1f079bc1.bindPopup(popup_2a00bfd6ede24f4aa1e2fe8075d33e03)
        ;

        
    
    
            var marker_ac14ff5c7bc54a969035b0f35fb07e94 = L.marker(
                [48.82636, 2.30303],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_0870811478f94f19b9dabf991e8b7086 = L.popup({"maxWidth": "100%"});

        
            var html_e682383246c644b8b3a7a7b6e7cfa63c = $(`<div id="html_e682383246c644b8b3a7a7b6e7cfa63c" style="width: 100.0%; height: 100.0%;">6 rue Julia Bartet NE-SO</div>`)[0];
            popup_0870811478f94f19b9dabf991e8b7086.setContent(html_e682383246c644b8b3a7a7b6e7cfa63c);
        

        marker_ac14ff5c7bc54a969035b0f35fb07e94.bindPopup(popup_0870811478f94f19b9dabf991e8b7086)
        ;

        
    
    
            var marker_93e37fb5ae8f4f459e019abc3271c52f = L.marker(
                [48.86521, 2.35358],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_163164d94474465b8a785dd01c40e2dd = L.popup({"maxWidth": "100%"});

        
            var html_698a5ce227ca488db7cdca974861023c = $(`<div id="html_698a5ce227ca488db7cdca974861023c" style="width: 100.0%; height: 100.0%;">38 rue Turbigo SO-NE</div>`)[0];
            popup_163164d94474465b8a785dd01c40e2dd.setContent(html_698a5ce227ca488db7cdca974861023c);
        

        marker_93e37fb5ae8f4f459e019abc3271c52f.bindPopup(popup_163164d94474465b8a785dd01c40e2dd)
        ;

        
    
    
            var marker_98cb41a9bf2c47cd878844a4ea11996f = L.marker(
                [48.84638, 2.31529],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_eb754c72e5e34eb3b8e2ba84468eb874 = L.popup({"maxWidth": "100%"});

        
            var html_77cb26d36c6e419ba8ea96c9f12278a3 = $(`<div id="html_77cb26d36c6e419ba8ea96c9f12278a3" style="width: 100.0%; height: 100.0%;">90 Rue De Sèvres NE-SO</div>`)[0];
            popup_eb754c72e5e34eb3b8e2ba84468eb874.setContent(html_77cb26d36c6e419ba8ea96c9f12278a3);
        

        marker_98cb41a9bf2c47cd878844a4ea11996f.bindPopup(popup_eb754c72e5e34eb3b8e2ba84468eb874)
        ;

        
    
    
            var marker_7628d747665b4f98b30c14a4d8aba84b = L.marker(
                [48.846099, 2.375456],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_1ec715684c2e4b04873249b3d21dcad5 = L.popup({"maxWidth": "100%"});

        
            var html_48a0716a0ace4485a907f0aea259ff9a = $(`<div id="html_48a0716a0ace4485a907f0aea259ff9a" style="width: 100.0%; height: 100.0%;">27 boulevard Diderot E-O</div>`)[0];
            popup_1ec715684c2e4b04873249b3d21dcad5.setContent(html_48a0716a0ace4485a907f0aea259ff9a);
        

        marker_7628d747665b4f98b30c14a4d8aba84b.bindPopup(popup_1ec715684c2e4b04873249b3d21dcad5)
        ;

        
    
    
            var marker_b0a0c4bc6edd4a569b4cb5ffcfd6d157 = L.marker(
                [48.84015, 2.26733],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_1ff558374ac64d43b974724a6e5663e3 = L.popup({"maxWidth": "100%"});

        
            var html_e961711fa7364f92bd3f9085e6af6b6d = $(`<div id="html_e961711fa7364f92bd3f9085e6af6b6d" style="width: 100.0%; height: 100.0%;">Pont du Garigliano NO-SE</div>`)[0];
            popup_1ff558374ac64d43b974724a6e5663e3.setContent(html_e961711fa7364f92bd3f9085e6af6b6d);
        

        marker_b0a0c4bc6edd4a569b4cb5ffcfd6d157.bindPopup(popup_1ff558374ac64d43b974724a6e5663e3)
        ;

        
    
    
            var marker_9f434d03a7d7408da8417b660a18df4b = L.marker(
                [48.891215, 2.38573],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_836b440f52f64faab39ef4c79e94fef4 = L.popup({"maxWidth": "100%"});

        
            var html_962ac815cce24988b22cfcba26cf5b24 = $(`<div id="html_962ac815cce24988b22cfcba26cf5b24" style="width: 100.0%; height: 100.0%;">Face au 48 quai de la marne NE-SO</div>`)[0];
            popup_836b440f52f64faab39ef4c79e94fef4.setContent(html_962ac815cce24988b22cfcba26cf5b24);
        

        marker_9f434d03a7d7408da8417b660a18df4b.bindPopup(popup_836b440f52f64faab39ef4c79e94fef4)
        ;

        
    
    
            var marker_a785a11e102847608921b817dae6e16a = L.marker(
                [48.82682, 2.38465],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_2b4117e88715445fa062488ac5802d84 = L.popup({"maxWidth": "100%"});

        
            var html_8f31cc63ddc74fa99149fb622bca5cb3 = $(`<div id="html_8f31cc63ddc74fa99149fb622bca5cb3" style="width: 100.0%; height: 100.0%;">Pont National  NE-SO</div>`)[0];
            popup_2b4117e88715445fa062488ac5802d84.setContent(html_8f31cc63ddc74fa99149fb622bca5cb3);
        

        marker_a785a11e102847608921b817dae6e16a.bindPopup(popup_2b4117e88715445fa062488ac5802d84)
        ;

        
    
    
            var marker_6bea265f18f64049b2a59d84c9ce631a = L.marker(
                [48.869831, 2.307076],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_91e16a8b9a7a4b35862e96194a7c51f2 = L.popup({"maxWidth": "100%"});

        
            var html_1ad6bdd598574b1ca608bc6be0ca097b = $(`<div id="html_1ad6bdd598574b1ca608bc6be0ca097b" style="width: 100.0%; height: 100.0%;">33 avenue des Champs Elysées NO-SE</div>`)[0];
            popup_91e16a8b9a7a4b35862e96194a7c51f2.setContent(html_1ad6bdd598574b1ca608bc6be0ca097b);
        

        marker_6bea265f18f64049b2a59d84c9ce631a.bindPopup(popup_91e16a8b9a7a4b35862e96194a7c51f2)
        ;

        
    
    
            var marker_7c08da9a047045b7aa69ff3fa445b4ab = L.marker(
                [48.86282, 2.31061],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_4efc98289ff14103ac1e53e8e63f174d = L.popup({"maxWidth": "100%"});

        
            var html_a1570aecc247476282f6edcacd939bb3 = $(`<div id="html_a1570aecc247476282f6edcacd939bb3" style="width: 100.0%; height: 100.0%;">Pont des Invalides S-N</div>`)[0];
            popup_4efc98289ff14103ac1e53e8e63f174d.setContent(html_a1570aecc247476282f6edcacd939bb3);
        

        marker_7c08da9a047045b7aa69ff3fa445b4ab.bindPopup(popup_4efc98289ff14103ac1e53e8e63f174d)
        ;

        
    
    
            var marker_232a620de751468892e0b48af192156e = L.marker(
                [48.89594, 2.35953],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_c67111e48ef045dd91382e507ab4a563 = L.popup({"maxWidth": "100%"});

        
            var html_6a98cfd2516f4807bea47b751e7e659f = $(`<div id="html_6a98cfd2516f4807bea47b751e7e659f" style="width: 100.0%; height: 100.0%;">72 rue de la Chapelle S-N</div>`)[0];
            popup_c67111e48ef045dd91382e507ab4a563.setContent(html_6a98cfd2516f4807bea47b751e7e659f);
        

        marker_232a620de751468892e0b48af192156e.bindPopup(popup_c67111e48ef045dd91382e507ab4a563)
        ;

        
    
    
            var marker_449af4d3068042dc80c437718e186fb0 = L.marker(
                [48.88181, 2.281546],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_a789b2170a1a4d74b6e1bccb810957f5 = L.popup({"maxWidth": "100%"});

        
            var html_0b3195036dd54e00ae4fc221fc337936 = $(`<div id="html_0b3195036dd54e00ae4fc221fc337936" style="width: 100.0%; height: 100.0%;">16 avenue de la Porte des Ternes E-O</div>`)[0];
            popup_a789b2170a1a4d74b6e1bccb810957f5.setContent(html_0b3195036dd54e00ae4fc221fc337936);
        

        marker_449af4d3068042dc80c437718e186fb0.bindPopup(popup_a789b2170a1a4d74b6e1bccb810957f5)
        ;

        
    
    
            var marker_722ce845aeb24f9c8919c9fd96596f6f = L.marker(
                [48.86462, 2.31444],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_be32ae3a79eb4002a9d9fd94c0b12329 = L.popup({"maxWidth": "100%"});

        
            var html_f7038a50d75945fd9d950d148030f8d7 = $(`<div id="html_f7038a50d75945fd9d950d148030f8d7" style="width: 100.0%; height: 100.0%;">Totem Cours la Reine E-O</div>`)[0];
            popup_be32ae3a79eb4002a9d9fd94c0b12329.setContent(html_f7038a50d75945fd9d950d148030f8d7);
        

        marker_722ce845aeb24f9c8919c9fd96596f6f.bindPopup(popup_be32ae3a79eb4002a9d9fd94c0b12329)
        ;

        
    
    
            var marker_02a68fed0f694c2daef3c36872aa5a4d = L.marker(
                [48.851131, 2.345678],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_1e45587f23cb41d2979e8ef432be27fe = L.popup({"maxWidth": "100%"});

        
            var html_e50cf8ec916f4669b4a98664560f2188 = $(`<div id="html_e50cf8ec916f4669b4a98664560f2188" style="width: 100.0%; height: 100.0%;">30 rue Saint Jacques N-S</div>`)[0];
            popup_1e45587f23cb41d2979e8ef432be27fe.setContent(html_e50cf8ec916f4669b4a98664560f2188);
        

        marker_02a68fed0f694c2daef3c36872aa5a4d.bindPopup(popup_1e45587f23cb41d2979e8ef432be27fe)
        ;

        
    
    
            var marker_c52dc2f2b6ac425c87afecd3257fc8d8 = L.marker(
                [48.8484, 2.27586],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_6046f1d14ffb4a238130c0ddfefbd191 = L.popup({"maxWidth": "100%"});

        
            var html_6b7709e334dd4c16871c83c201d14958 = $(`<div id="html_6b7709e334dd4c16871c83c201d14958" style="width: 100.0%; height: 100.0%;">Voie Georges Pompidou SO-NE</div>`)[0];
            popup_6046f1d14ffb4a238130c0ddfefbd191.setContent(html_6b7709e334dd4c16871c83c201d14958);
        

        marker_c52dc2f2b6ac425c87afecd3257fc8d8.bindPopup(popup_6046f1d14ffb4a238130c0ddfefbd191)
        ;

        
    
    
            var marker_f74a482837a84287a2d0c0be73636e56 = L.marker(
                [48.877686, 2.354471],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_494007f86e98446d8cc84536998995d7 = L.popup({"maxWidth": "100%"});

        
            var html_49c6530200144496be418e9f4eb00220 = $(`<div id="html_49c6530200144496be418e9f4eb00220" style="width: 100.0%; height: 100.0%;">89 boulevard de Magenta NO-SE</div>`)[0];
            popup_494007f86e98446d8cc84536998995d7.setContent(html_49c6530200144496be418e9f4eb00220);
        

        marker_f74a482837a84287a2d0c0be73636e56.bindPopup(popup_494007f86e98446d8cc84536998995d7)
        ;

        
    
    
            var marker_d23a01e976c449678275fe0da47b5902 = L.marker(
                [48.86461, 2.40969],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_72cb076ffedb407ea92e06bc939176db = L.popup({"maxWidth": "100%"});

        
            var html_81c97c427b614ab495bd0b03d8fc5019 = $(`<div id="html_81c97c427b614ab495bd0b03d8fc5019" style="width: 100.0%; height: 100.0%;">Face au 4 avenue de la porte de Bagnolet O-E</div>`)[0];
            popup_72cb076ffedb407ea92e06bc939176db.setContent(html_81c97c427b614ab495bd0b03d8fc5019);
        

        marker_d23a01e976c449678275fe0da47b5902.bindPopup(popup_72cb076ffedb407ea92e06bc939176db)
        ;

        
    
    
            var marker_f6022351baec4ffe8cb74367e70b7900 = L.marker(
                [48.84201, 2.36729],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_d64a1d4135ac4e6fbcdb04070ba5ec4a = L.popup({"maxWidth": "100%"});

        
            var html_711b1843c57a49ada91c5cf73176dcab = $(`<div id="html_711b1843c57a49ada91c5cf73176dcab" style="width: 100.0%; height: 100.0%;">Totem 85 quai d'Austerlitz SE-NO</div>`)[0];
            popup_d64a1d4135ac4e6fbcdb04070ba5ec4a.setContent(html_711b1843c57a49ada91c5cf73176dcab);
        

        marker_f6022351baec4ffe8cb74367e70b7900.bindPopup(popup_d64a1d4135ac4e6fbcdb04070ba5ec4a)
        ;

        
    
    
            var marker_a402e938c6604ecdbc7060adf303695f = L.marker(
                [48.83068, 2.35348],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_e5e4d932bc634ef884668ce0cc9d6f1e = L.popup({"maxWidth": "100%"});

        
            var html_ecd602ceaf9e4a228d96c1881527589e = $(`<div id="html_ecd602ceaf9e4a228d96c1881527589e" style="width: 100.0%; height: 100.0%;">10 boulevard Auguste Blanqui NE-SO</div>`)[0];
            popup_e5e4d932bc634ef884668ce0cc9d6f1e.setContent(html_ecd602ceaf9e4a228d96c1881527589e);
        

        marker_a402e938c6604ecdbc7060adf303695f.bindPopup(popup_e5e4d932bc634ef884668ce0cc9d6f1e)
        ;

        
    
    
            var marker_e5b6c26992e34404805e7633d7273da6 = L.marker(
                [48.88926, 2.37472],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_cf2ef5da48f34856be771867c4e1e1a9 = L.popup({"maxWidth": "100%"});

        
            var html_d525240ac643418f822bb04156417b8a = $(`<div id="html_d525240ac643418f822bb04156417b8a" style="width: 100.0%; height: 100.0%;">87 avenue de Flandre NE-SO</div>`)[0];
            popup_cf2ef5da48f34856be771867c4e1e1a9.setContent(html_d525240ac643418f822bb04156417b8a);
        

        marker_e5b6c26992e34404805e7633d7273da6.bindPopup(popup_cf2ef5da48f34856be771867c4e1e1a9)
        ;

        
    
    
            var marker_3380e6d286404d628c64ea6a91f5a983 = L.marker(
                [48.82024, 2.35902],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_0e8dab34fd514b8e84eed6d663d49bb9 = L.popup({"maxWidth": "100%"});

        
            var html_6b292d8d7f6e48cc89f7dfc05e4241e3 = $(`<div id="html_6b292d8d7f6e48cc89f7dfc05e4241e3" style="width: 100.0%; height: 100.0%;">180 avenue d'Italie N-S</div>`)[0];
            popup_0e8dab34fd514b8e84eed6d663d49bb9.setContent(html_6b292d8d7f6e48cc89f7dfc05e4241e3);
        

        marker_3380e6d286404d628c64ea6a91f5a983.bindPopup(popup_0e8dab34fd514b8e84eed6d663d49bb9)
        ;

        
    
    
            var marker_344fba2c896941e884127ae5bceca6ce = L.marker(
                [48.88529, 2.32666],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_2ed628c0bc6943389451f5e10b16d382 = L.popup({"maxWidth": "100%"});

        
            var html_68b7abd3d69e4ba4a495dc181712ae5a = $(`<div id="html_68b7abd3d69e4ba4a495dc181712ae5a" style="width: 100.0%; height: 100.0%;">20 Avenue de Clichy NO-SE</div>`)[0];
            popup_2ed628c0bc6943389451f5e10b16d382.setContent(html_68b7abd3d69e4ba4a495dc181712ae5a);
        

        marker_344fba2c896941e884127ae5bceca6ce.bindPopup(popup_2ed628c0bc6943389451f5e10b16d382)
        ;

        
    
    
            var marker_3d87cbe727d6421b85de61ad4563c527 = L.marker(
                [48.83511, 2.33338],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_956a2c23f318487dad4c2cb7c18087c7 = L.popup({"maxWidth": "100%"});

        
            var html_77e3d115597a405fb9cfb7307854c37a = $(`<div id="html_77e3d115597a405fb9cfb7307854c37a" style="width: 100.0%; height: 100.0%;">97 avenue Denfert Rochereau SO-NE</div>`)[0];
            popup_956a2c23f318487dad4c2cb7c18087c7.setContent(html_77e3d115597a405fb9cfb7307854c37a);
        

        marker_3d87cbe727d6421b85de61ad4563c527.bindPopup(popup_956a2c23f318487dad4c2cb7c18087c7)
        ;

        
    
    
            var marker_f4a78167a5a74de4bd48589c66072a1f = L.marker(
                [48.87451, 2.29215],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_be2fac2dc38b4c859982165b0a5cc5de = L.popup({"maxWidth": "100%"});

        
            var html_2ea0a85f59244651813fffcf66d1fc12 = $(`<div id="html_2ea0a85f59244651813fffcf66d1fc12" style="width: 100.0%; height: 100.0%;">7 avenue de la Grande Armée NO-SE</div>`)[0];
            popup_be2fac2dc38b4c859982165b0a5cc5de.setContent(html_2ea0a85f59244651813fffcf66d1fc12);
        

        marker_f4a78167a5a74de4bd48589c66072a1f.bindPopup(popup_be2fac2dc38b4c859982165b0a5cc5de)
        ;

        
    
    
            var marker_7403db24237b4d44b0c001ec414dd01b = L.marker(
                [48.877726, 2.354926],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_9cbc1ecd818a4c218a2bb2334991e8ef = L.popup({"maxWidth": "100%"});

        
            var html_aa948478d1184089989b2568759aa594 = $(`<div id="html_aa948478d1184089989b2568759aa594" style="width: 100.0%; height: 100.0%;">102 boulevard de Magenta SE-NO</div>`)[0];
            popup_9cbc1ecd818a4c218a2bb2334991e8ef.setContent(html_aa948478d1184089989b2568759aa594);
        

        marker_7403db24237b4d44b0c001ec414dd01b.bindPopup(popup_9cbc1ecd818a4c218a2bb2334991e8ef)
        ;

        
    
    
            var marker_6a43f06aca5f489a979bb08e18a0581d = L.marker(
                [48.881626, 2.281203],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_5b77cae285ba49e29e38ef4f82b4ef61 = L.popup({"maxWidth": "100%"});

        
            var html_3dc9f64d11584bbd85654176fe303158 = $(`<div id="html_3dc9f64d11584bbd85654176fe303158" style="width: 100.0%; height: 100.0%;">Face au 16 avenue de la  Porte des Ternes O-E</div>`)[0];
            popup_5b77cae285ba49e29e38ef4f82b4ef61.setContent(html_3dc9f64d11584bbd85654176fe303158);
        

        marker_6a43f06aca5f489a979bb08e18a0581d.bindPopup(popup_5b77cae285ba49e29e38ef4f82b4ef61)
        ;

        
    
    
            var marker_3abe86060c5e4e6b9418a2634548fbb8 = L.marker(
                [48.890457, 2.368852],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_96df06bf5c1f4801b4f4e89b52c8d50e = L.popup({"maxWidth": "100%"});

        
            var html_5a7ef496b76b4a45aafde08dab6fa437 = $(`<div id="html_5a7ef496b76b4a45aafde08dab6fa437" style="width: 100.0%; height: 100.0%;">Face 104 rue d'Aubervilliers S-N</div>`)[0];
            popup_96df06bf5c1f4801b4f4e89b52c8d50e.setContent(html_5a7ef496b76b4a45aafde08dab6fa437);
        

        marker_3abe86060c5e4e6b9418a2634548fbb8.bindPopup(popup_96df06bf5c1f4801b4f4e89b52c8d50e)
        ;

        
    
    
            var marker_53300bf722324a32b4d2b0a54225cc30 = L.marker(
                [48.86461, 2.40969],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_7f122f8a7ea24f2eb2298b99dfc8a0d4 = L.popup({"maxWidth": "100%"});

        
            var html_4554baed620d4680a7808e6afc196fb5 = $(`<div id="html_4554baed620d4680a7808e6afc196fb5" style="width: 100.0%; height: 100.0%;">Face au 4 avenue de la porte de Bagnolet E-O</div>`)[0];
            popup_7f122f8a7ea24f2eb2298b99dfc8a0d4.setContent(html_4554baed620d4680a7808e6afc196fb5);
        

        marker_53300bf722324a32b4d2b0a54225cc30.bindPopup(popup_7f122f8a7ea24f2eb2298b99dfc8a0d4)
        ;

        
    
    
            var marker_aa2cf1f54d904bbda09cd9c4a1dff686 = L.marker(
                [48.84223, 2.36811],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_7830574884ac488687ce0f0fe757cf22 = L.popup({"maxWidth": "100%"});

        
            var html_7d3c0ddc8591490386e3e241bd97221d = $(`<div id="html_7d3c0ddc8591490386e3e241bd97221d" style="width: 100.0%; height: 100.0%;">Pont Charles De Gaulle SO-NE</div>`)[0];
            popup_7830574884ac488687ce0f0fe757cf22.setContent(html_7d3c0ddc8591490386e3e241bd97221d);
        

        marker_aa2cf1f54d904bbda09cd9c4a1dff686.bindPopup(popup_7830574884ac488687ce0f0fe757cf22)
        ;

        
    
    
            var marker_cd22bd0f7c8040a4b61ecc0b60b7695f = L.marker(
                [48.891215, 2.38573],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_f60c74f108aa4346bc4a775d66b58066 = L.popup({"maxWidth": "100%"});

        
            var html_66f9152c429f46d4875dfe7ef64676be = $(`<div id="html_66f9152c429f46d4875dfe7ef64676be" style="width: 100.0%; height: 100.0%;">Face au 48 quai de la marne SO-NE</div>`)[0];
            popup_f60c74f108aa4346bc4a775d66b58066.setContent(html_66f9152c429f46d4875dfe7ef64676be);
        

        marker_cd22bd0f7c8040a4b61ecc0b60b7695f.bindPopup(popup_f60c74f108aa4346bc4a775d66b58066)
        ;

        
    
    
            var marker_6ec2545400b44bcd9fd3f3e5dbc3a903 = L.marker(
                [48.830331, 2.400551],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_b0a31eaa87264b0fab1d2c5f82c19b58 = L.popup({"maxWidth": "100%"});

        
            var html_e335b97f3368408184791e0f5e4bc0b1 = $(`<div id="html_e335b97f3368408184791e0f5e4bc0b1" style="width: 100.0%; height: 100.0%;">Face au 8 avenue de la porte de Charenton NO-SE</div>`)[0];
            popup_b0a31eaa87264b0fab1d2c5f82c19b58.setContent(html_e335b97f3368408184791e0f5e4bc0b1);
        

        marker_6ec2545400b44bcd9fd3f3e5dbc3a903.bindPopup(popup_b0a31eaa87264b0fab1d2c5f82c19b58)
        ;

        
    
    
            var marker_833823abbde44eecbf995854a9f1751f = L.marker(
                [48.86462, 2.31444],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_f942bf8b48e14f4e81083a265d7ad159 = L.popup({"maxWidth": "100%"});

        
            var html_32da57f8296444139c949ff0a9b620b9 = $(`<div id="html_32da57f8296444139c949ff0a9b620b9" style="width: 100.0%; height: 100.0%;">Totem Cours la Reine O-E</div>`)[0];
            popup_f942bf8b48e14f4e81083a265d7ad159.setContent(html_32da57f8296444139c949ff0a9b620b9);
        

        marker_833823abbde44eecbf995854a9f1751f.bindPopup(popup_f942bf8b48e14f4e81083a265d7ad159)
        ;

        
    
    
            var marker_0b93fb6969474807af07d6ca48ad8bb7 = L.marker(
                [48.86155, 2.37407],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_aaf458566f794e17b1df9e72e58dca66 = L.popup({"maxWidth": "100%"});

        
            var html_ac4677c716974b38b5a58831e0868b10 = $(`<div id="html_ac4677c716974b38b5a58831e0868b10" style="width: 100.0%; height: 100.0%;">72 boulevard Voltaire NO-SE</div>`)[0];
            popup_aaf458566f794e17b1df9e72e58dca66.setContent(html_ac4677c716974b38b5a58831e0868b10);
        

        marker_0b93fb6969474807af07d6ca48ad8bb7.bindPopup(popup_aaf458566f794e17b1df9e72e58dca66)
        ;

        
    
    
            var marker_cf9330c588594bd2a61d5cae972373a0 = L.marker(
                [48.86057, 2.38886],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_6e03c31cc08244daa4162e5687ad4d27 = L.popup({"maxWidth": "100%"});

        
            var html_c513de3e2a9f457f9697fd4b4a8bc007 = $(`<div id="html_c513de3e2a9f457f9697fd4b4a8bc007" style="width: 100.0%; height: 100.0%;">26 boulevard de Ménilmontant SE-NO</div>`)[0];
            popup_6e03c31cc08244daa4162e5687ad4d27.setContent(html_c513de3e2a9f457f9697fd4b4a8bc007);
        

        marker_cf9330c588594bd2a61d5cae972373a0.bindPopup(popup_6e03c31cc08244daa4162e5687ad4d27)
        ;

        
    
    
            var marker_735b5b99c0c143fa8223decf2a6bd00e = L.marker(
                [48.829523, 2.38699],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_5cc9ed1932a34d9fbd31bd7d08682da1 = L.popup({"maxWidth": "100%"});

        
            var html_cdf83f9ed4e5467ea08d8faefcd996a9 = $(`<div id="html_cdf83f9ed4e5467ea08d8faefcd996a9" style="width: 100.0%; height: 100.0%;">Face au 70 quai de Bercy S-N</div>`)[0];
            popup_5cc9ed1932a34d9fbd31bd7d08682da1.setContent(html_cdf83f9ed4e5467ea08d8faefcd996a9);
        

        marker_735b5b99c0c143fa8223decf2a6bd00e.bindPopup(popup_5cc9ed1932a34d9fbd31bd7d08682da1)
        ;

        
    
    
            var marker_930602c15f0348e291ff50ed32b385a0 = L.marker(
                [48.829523, 2.38699],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_02d240e35c054f52bbe82cb7b1187998 = L.popup({"maxWidth": "100%"});

        
            var html_acd0d0a2722b469a93504fac6e74874d = $(`<div id="html_acd0d0a2722b469a93504fac6e74874d" style="width: 100.0%; height: 100.0%;">Face au 70 quai de Bercy N-S</div>`)[0];
            popup_02d240e35c054f52bbe82cb7b1187998.setContent(html_acd0d0a2722b469a93504fac6e74874d);
        

        marker_930602c15f0348e291ff50ed32b385a0.bindPopup(popup_02d240e35c054f52bbe82cb7b1187998)
        ;

        
    
    
            var marker_eb04cf5b3e354ee59904897041ac23d7 = L.marker(
                [48.83848, 2.37587],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_722c778f3c284593a01ad292107fc75f = L.popup({"maxWidth": "100%"});

        
            var html_7e48048a892547b39ff0e0597f88fd7c = $(`<div id="html_7e48048a892547b39ff0e0597f88fd7c" style="width: 100.0%; height: 100.0%;">Pont de Bercy SO-NE</div>`)[0];
            popup_722c778f3c284593a01ad292107fc75f.setContent(html_7e48048a892547b39ff0e0597f88fd7c);
        

        marker_eb04cf5b3e354ee59904897041ac23d7.bindPopup(popup_722c778f3c284593a01ad292107fc75f)
        ;

        
    
    
            var marker_a5cf24bc48f54dff8c4324486bff4082 = L.marker(
                [48.86288, 2.31179],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_2cf7c31d263747abba4df840aced7504 = L.popup({"maxWidth": "100%"});

        
            var html_e620651b4c4d4a56ada38c797e47e825 = $(`<div id="html_e620651b4c4d4a56ada38c797e47e825" style="width: 100.0%; height: 100.0%;">Quai d'Orsay E-O</div>`)[0];
            popup_2cf7c31d263747abba4df840aced7504.setContent(html_e620651b4c4d4a56ada38c797e47e825);
        

        marker_a5cf24bc48f54dff8c4324486bff4082.bindPopup(popup_2cf7c31d263747abba4df840aced7504)
        ;

        
    
    
            var marker_7408c9db51564aaab286046cb780c687 = L.marker(
                [48.85013, 2.35423],
                {}
            ).addTo(map_0a4e128e2eb64929aea7af8431bd4038);
        
    
        var popup_89b052a8f6264556a24b01b855faf487 = L.popup({"maxWidth": "100%"});

        
            var html_fc7f586e633a42a89ba3a833b412025a = $(`<div id="html_fc7f586e633a42a89ba3a833b412025a" style="width: 100.0%; height: 100.0%;">27 quai de la Tournelle NO-SE</div>`)[0];
            popup_89b052a8f6264556a24b01b855faf487.setContent(html_fc7f586e633a42a89ba3a833b412025a);
        

        marker_7408c9db51564aaab286046cb780c687.bindPopup(popup_89b052a8f6264556a24b01b855faf487)
        ;

        
    
</script><!--/html_preserve-->
{{< /rawhtml >}}


{{% panel status="hint" title="Hint" icon="fa fa-lightbulb" %}}
Si un fond gris s'affiche, c'est qu'il y a un problème de localisation. Cela provient généralement d'un problème de projection ou d'une inversion des longitudes et latitudes. 

Les longitudes représentent les *x* (axe ouest-nord) et les latitudes *y* (axe sud-nord). `folium` attend qu'on lui fournisse les données sous la forme `[latitude, longitude]` donc `[y,x]`
{{% /panel %}}


{{% panel status="exercise" title="Exercice 7: Représenter les stations" icon="fas fa-pencil-alt" %}}

Faire une carte avec des ronds proportionnels au nombre de comptages:

  + Pour le rayon de chaque cercle, en notant vous pouvez faire `500*x/max(x)` (règle au doigt mouillé)
  + (Optionnel) Colorer les 10 plus grosses stations

{{< /panel >}}




{{< rawhtml >}}
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
                #map_2c04939eeab341fa821676e86dba57de {
                    position: relative;
                    width: 100.0%;
                    height: 100.0%;
                    left: 0.0%;
                    top: 0.0%;
                }
            </style>
        
</head>
<body>    
    
            <div class="folium-map" id="map_2c04939eeab341fa821676e86dba57de" ></div>
        
</body>
<script>    
    
            var map_2c04939eeab341fa821676e86dba57de = L.map(
                "map_2c04939eeab341fa821676e86dba57de",
                {
                    center: [48.856972463768095, 2.343495594202899],
                    crs: L.CRS.EPSG3857,
                    zoom: 12,
                    zoomControl: true,
                    preferCanvas: false,
                }
            );

            

        
    
            var tile_layer_1c6ee3a6a34b4bcc98ba35475d361a31 = L.tileLayer(
                "https://stamen-tiles-{s}.a.ssl.fastly.net/toner/{z}/{x}/{y}.png",
                {"attribution": "Map tiles by \u003ca href=\"http://stamen.com\"\u003eStamen Design\u003c/a\u003e, under \u003ca href=\"http://creativecommons.org/licenses/by/3.0\"\u003eCC BY 3.0\u003c/a\u003e. Data by \u0026copy; \u003ca href=\"http://openstreetmap.org\"\u003eOpenStreetMap\u003c/a\u003e, under \u003ca href=\"http://www.openstreetmap.org/copyright\"\u003eODbL\u003c/a\u003e.", "detectRetina": false, "maxNativeZoom": 18, "maxZoom": 18, "minZoom": 0, "noWrap": false, "opacity": 1, "subdomains": "abc", "tms": false}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
            var circle_cbc3a68641f441aaafba804083a35e71 = L.circle(
                [48.86149, 2.37376],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_0c8240512eb54a0592d6fd758bbf15ef = L.popup({"maxWidth": "100%"});

        
            var html_63f0b71de3944157b553c5c841919b2a = $(`<div id="html_63f0b71de3944157b553c5c841919b2a" style="width: 100.0%; height: 100.0%;">67 boulevard Voltaire SE-NO</div>`)[0];
            popup_0c8240512eb54a0592d6fd758bbf15ef.setContent(html_63f0b71de3944157b553c5c841919b2a);
        

        circle_cbc3a68641f441aaafba804083a35e71.bindPopup(popup_0c8240512eb54a0592d6fd758bbf15ef)
        ;

        
    
    
            var circle_e245be697fb34a2fa8f0c9d3fc1ad1df = L.circle(
                [48.830449, 2.353199],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.00000000000006, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_617cdb642818413989976023a8b2025d = L.popup({"maxWidth": "100%"});

        
            var html_e4b822fc120b4a2894be0048c18fd730 = $(`<div id="html_e4b822fc120b4a2894be0048c18fd730" style="width: 100.0%; height: 100.0%;">21 boulevard Auguste Blanqui SO-NE</div>`)[0];
            popup_617cdb642818413989976023a8b2025d.setContent(html_e4b822fc120b4a2894be0048c18fd730);
        

        circle_e245be697fb34a2fa8f0c9d3fc1ad1df.bindPopup(popup_617cdb642818413989976023a8b2025d)
        ;

        
    
    
            var circle_7777f27ab71b40d4bf48a90e30f729a5 = L.circle(
                [48.83992, 2.26694],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_73d20c4dff4b420f86be21ce208cc0dd = L.popup({"maxWidth": "100%"});

        
            var html_5154dc5f2bc540e996a0f3d3894df4f1 = $(`<div id="html_5154dc5f2bc540e996a0f3d3894df4f1" style="width: 100.0%; height: 100.0%;">Pont du Garigliano SE-NO SE-NO</div>`)[0];
            popup_73d20c4dff4b420f86be21ce208cc0dd.setContent(html_5154dc5f2bc540e996a0f3d3894df4f1);
        

        circle_7777f27ab71b40d4bf48a90e30f729a5.bindPopup(popup_73d20c4dff4b420f86be21ce208cc0dd)
        ;

        
    
    
            var circle_342528f13eb343fa9671627c1c99fac1 = L.circle(
                [48.840801, 2.333233],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_f78d1886015e47758aa5d7903a3ff01d = L.popup({"maxWidth": "100%"});

        
            var html_9b09371e4b324b01b7893275c13aa3b6 = $(`<div id="html_9b09371e4b324b01b7893275c13aa3b6" style="width: 100.0%; height: 100.0%;">152 boulevard du Montparnasse O-E</div>`)[0];
            popup_f78d1886015e47758aa5d7903a3ff01d.setContent(html_9b09371e4b324b01b7893275c13aa3b6);
        

        circle_342528f13eb343fa9671627c1c99fac1.bindPopup(popup_f78d1886015e47758aa5d7903a3ff01d)
        ;

        
    
    
            var circle_7492fa1e562b41aca843e03fc1ec8b9b = L.circle(
                [48.896894, 2.344994],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.00000000000006, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_325f081afbef4824b32b34f1b551e948 = L.popup({"maxWidth": "100%"});

        
            var html_c4d0693ada2443cd861eba4e47086f6b = $(`<div id="html_c4d0693ada2443cd861eba4e47086f6b" style="width: 100.0%; height: 100.0%;">69 Boulevard Ornano N-S</div>`)[0];
            popup_325f081afbef4824b32b34f1b551e948.setContent(html_c4d0693ada2443cd861eba4e47086f6b);
        

        circle_7492fa1e562b41aca843e03fc1ec8b9b.bindPopup(popup_325f081afbef4824b32b34f1b551e948)
        ;

        
    
    
            var circle_e7f3f49659fb486b80906f9c354b7ac5 = L.circle(
                [48.87746, 2.35008],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_bb48e205d01d41c8bce734c41850c601 = L.popup({"maxWidth": "100%"});

        
            var html_94a9eb2b21ba4879b584c548e388adc8 = $(`<div id="html_94a9eb2b21ba4879b584c548e388adc8" style="width: 100.0%; height: 100.0%;">100 rue La Fayette O-E</div>`)[0];
            popup_bb48e205d01d41c8bce734c41850c601.setContent(html_94a9eb2b21ba4879b584c548e388adc8);
        

        circle_e7f3f49659fb486b80906f9c354b7ac5.bindPopup(popup_bb48e205d01d41c8bce734c41850c601)
        ;

        
    
    
            var circle_f56633c0bd44486eb98142070ee5a752 = L.circle(
                [48.874716, 2.292439],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_84058a9da3b14c0a83b5cf94f04170f6 = L.popup({"maxWidth": "100%"});

        
            var html_f6c43aac83ec436fb94898f84807350d = $(`<div id="html_f6c43aac83ec436fb94898f84807350d" style="width: 100.0%; height: 100.0%;">10 avenue de la Grande Armée SE-NO</div>`)[0];
            popup_84058a9da3b14c0a83b5cf94f04170f6.setContent(html_f6c43aac83ec436fb94898f84807350d);
        

        circle_f56633c0bd44486eb98142070ee5a752.bindPopup(popup_84058a9da3b14c0a83b5cf94f04170f6)
        ;

        
    
    
            var circle_d451aae2ba4a4669a556a796cbfdad8c = L.circle(
                [48.891415, 2.384954],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_dcb13fc7d2b545d1a38cc3bc0e5c790c = L.popup({"maxWidth": "100%"});

        
            var html_8efd4423c09447738c73a2716f91823e = $(`<div id="html_8efd4423c09447738c73a2716f91823e" style="width: 100.0%; height: 100.0%;">Face au 25 quai de l'Oise SO-NE</div>`)[0];
            popup_dcb13fc7d2b545d1a38cc3bc0e5c790c.setContent(html_8efd4423c09447738c73a2716f91823e);
        

        circle_d451aae2ba4a4669a556a796cbfdad8c.bindPopup(popup_dcb13fc7d2b545d1a38cc3bc0e5c790c)
        ;

        
    
    
            var circle_20c51403b0b04575868013739db409b2 = L.circle(
                [48.82026, 2.3592],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_016d3e40206a41028a29bce5d1dbb2e3 = L.popup({"maxWidth": "100%"});

        
            var html_8fb8912172e346dfb7807b40d3c6a2fe = $(`<div id="html_8fb8912172e346dfb7807b40d3c6a2fe" style="width: 100.0%; height: 100.0%;">147 avenue d'Italie S-N</div>`)[0];
            popup_016d3e40206a41028a29bce5d1dbb2e3.setContent(html_8fb8912172e346dfb7807b40d3c6a2fe);
        

        circle_20c51403b0b04575868013739db409b2.bindPopup(popup_016d3e40206a41028a29bce5d1dbb2e3)
        ;

        
    
    
            var circle_8d516d326ce24b219aa21f4e76691a6b = L.circle(
                [48.85209, 2.28508],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_3fa4726d2b2543b1b48820241ddcb736 = L.popup({"maxWidth": "100%"});

        
            var html_d988191eca11498bbf7d2e2994a00da7 = $(`<div id="html_d988191eca11498bbf7d2e2994a00da7" style="width: 100.0%; height: 100.0%;">36 quai de Grenelle SO-NE</div>`)[0];
            popup_3fa4726d2b2543b1b48820241ddcb736.setContent(html_d988191eca11498bbf7d2e2994a00da7);
        

        circle_8d516d326ce24b219aa21f4e76691a6b.bindPopup(popup_3fa4726d2b2543b1b48820241ddcb736)
        ;

        
    
    
            var circle_4b780cac2c03402d9e0f0d2fb86b7dc4 = L.circle(
                [48.83848, 2.37587],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_f17f28232ef3435dbaa2e97dca1265fc = L.popup({"maxWidth": "100%"});

        
            var html_93e5adf98c2547fb8f855618dc41065c = $(`<div id="html_93e5adf98c2547fb8f855618dc41065c" style="width: 100.0%; height: 100.0%;">Pont de Bercy NE-SO</div>`)[0];
            popup_f17f28232ef3435dbaa2e97dca1265fc.setContent(html_93e5adf98c2547fb8f855618dc41065c);
        

        circle_4b780cac2c03402d9e0f0d2fb86b7dc4.bindPopup(popup_f17f28232ef3435dbaa2e97dca1265fc)
        ;

        
    
    
            var circle_a9c2109747a143c9b8583e11e0f4da13 = L.circle(
                [48.889046, 2.374872],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_66f39f90b48d46fe895ad7beed84a407 = L.popup({"maxWidth": "100%"});

        
            var html_6bc7ee1d3a3243eebfe8aaff5d46eec3 = $(`<div id="html_6bc7ee1d3a3243eebfe8aaff5d46eec3" style="width: 100.0%; height: 100.0%;">72 avenue de Flandre SO-NE</div>`)[0];
            popup_66f39f90b48d46fe895ad7beed84a407.setContent(html_6bc7ee1d3a3243eebfe8aaff5d46eec3);
        

        circle_a9c2109747a143c9b8583e11e0f4da13.bindPopup(popup_66f39f90b48d46fe895ad7beed84a407)
        ;

        
    
    
            var circle_968561f313224227ad094919f9889fc6 = L.circle(
                [48.86377, 2.35096],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_89b0a2336d4a41d6ab189bd9b9888d41 = L.popup({"maxWidth": "100%"});

        
            var html_2e54e009841f4662889a317c460d6ad4 = $(`<div id="html_2e54e009841f4662889a317c460d6ad4" style="width: 100.0%; height: 100.0%;">Totem 73 boulevard de Sébastopol N-S</div>`)[0];
            popup_89b0a2336d4a41d6ab189bd9b9888d41.setContent(html_2e54e009841f4662889a317c460d6ad4);
        

        circle_968561f313224227ad094919f9889fc6.bindPopup(popup_89b0a2336d4a41d6ab189bd9b9888d41)
        ;

        
    
    
            var circle_142c544142ed46a8a37d1a0c928039b0 = L.circle(
                [48.83521, 2.33307],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.00000000000006, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_8bea81521a674473a72f12f67deeab80 = L.popup({"maxWidth": "100%"});

        
            var html_695f27f0d5e240328af6b320a8f03845 = $(`<div id="html_695f27f0d5e240328af6b320a8f03845" style="width: 100.0%; height: 100.0%;">106 avenue Denfert Rochereau NE-SO</div>`)[0];
            popup_8bea81521a674473a72f12f67deeab80.setContent(html_695f27f0d5e240328af6b320a8f03845);
        

        circle_142c544142ed46a8a37d1a0c928039b0.bindPopup(popup_8bea81521a674473a72f12f67deeab80)
        ;

        
    
    
            var circle_41e55afdbecd422ea87a3615cc7016bf = L.circle(
                [48.8484, 2.27586],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 499.99999999999994, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_4316839cca904b879a489ac0650ae510 = L.popup({"maxWidth": "100%"});

        
            var html_790e5ead9e4643b7935718522ffd53dc = $(`<div id="html_790e5ead9e4643b7935718522ffd53dc" style="width: 100.0%; height: 100.0%;">Voie Georges Pompidou NE-SO</div>`)[0];
            popup_4316839cca904b879a489ac0650ae510.setContent(html_790e5ead9e4643b7935718522ffd53dc);
        

        circle_41e55afdbecd422ea87a3615cc7016bf.bindPopup(popup_4316839cca904b879a489ac0650ae510)
        ;

        
    
    
            var circle_25f99fd93f644a078d28395dd35685be = L.circle(
                [48.842091, 2.301],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_09d61c7c846b4cec82ec4d0046130d6e = L.popup({"maxWidth": "100%"});

        
            var html_523dec1fef864aa98b064e8a1a42076a = $(`<div id="html_523dec1fef864aa98b064e8a1a42076a" style="width: 100.0%; height: 100.0%;">129 rue Lecourbe SO-NE</div>`)[0];
            popup_09d61c7c846b4cec82ec4d0046130d6e.setContent(html_523dec1fef864aa98b064e8a1a42076a);
        

        circle_25f99fd93f644a078d28395dd35685be.bindPopup(popup_09d61c7c846b4cec82ec4d0046130d6e)
        ;

        
    
    
            var circle_7adedf23d02a427c8e1ebdc2283146e7 = L.circle(
                [48.84638, 2.31529],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_ef4c6d9ed7884403a044c310cc9e016c = L.popup({"maxWidth": "100%"});

        
            var html_48ac16380acc4b13aa2bc15bf19d7e39 = $(`<div id="html_48ac16380acc4b13aa2bc15bf19d7e39" style="width: 100.0%; height: 100.0%;">90 Rue De Sèvres SO-NE</div>`)[0];
            popup_ef4c6d9ed7884403a044c310cc9e016c.setContent(html_48ac16380acc4b13aa2bc15bf19d7e39);
        

        circle_7adedf23d02a427c8e1ebdc2283146e7.bindPopup(popup_ef4c6d9ed7884403a044c310cc9e016c)
        ;

        
    
    
            var circle_00d76d8187aa4850a04c7b8e6c8e0bf8 = L.circle(
                [48.890457, 2.368852],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_3598adee88c8488eb0bc4b85ffce9f25 = L.popup({"maxWidth": "100%"});

        
            var html_a431909115df4233868a83b76e2f09d7 = $(`<div id="html_a431909115df4233868a83b76e2f09d7" style="width: 100.0%; height: 100.0%;">Face 104 rue d'Aubervilliers N-S</div>`)[0];
            popup_3598adee88c8488eb0bc4b85ffce9f25.setContent(html_a431909115df4233868a83b76e2f09d7);
        

        circle_00d76d8187aa4850a04c7b8e6c8e0bf8.bindPopup(popup_3598adee88c8488eb0bc4b85ffce9f25)
        ;

        
    
    
            var circle_86e5a391d13541d8982d6cf53c177987 = L.circle(
                [48.86378, 2.32003],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.00000000000006, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_ad07681fe205448488bcfb1de9d57472 = L.popup({"maxWidth": "100%"});

        
            var html_3ba71003d89f48d6a560f2509c59bcd7 = $(`<div id="html_3ba71003d89f48d6a560f2509c59bcd7" style="width: 100.0%; height: 100.0%;">Pont de la Concorde S-N</div>`)[0];
            popup_ad07681fe205448488bcfb1de9d57472.setContent(html_3ba71003d89f48d6a560f2509c59bcd7);
        

        circle_86e5a391d13541d8982d6cf53c177987.bindPopup(popup_ad07681fe205448488bcfb1de9d57472)
        ;

        
    
    
            var circle_e837b88bc46e492cba3814948ae225d5 = L.circle(
                [48.86288, 2.31179],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_8f35d6c4341147beb1f5a7ae5aef92a4 = L.popup({"maxWidth": "100%"});

        
            var html_be6222ce21f84c55b16231bbed691cf9 = $(`<div id="html_be6222ce21f84c55b16231bbed691cf9" style="width: 100.0%; height: 100.0%;">Quai d'Orsay O-E</div>`)[0];
            popup_8f35d6c4341147beb1f5a7ae5aef92a4.setContent(html_be6222ce21f84c55b16231bbed691cf9);
        

        circle_e837b88bc46e492cba3814948ae225d5.bindPopup(popup_8f35d6c4341147beb1f5a7ae5aef92a4)
        ;

        
    
    
            var circle_b342afc173434ad688b331e07a73a102 = L.circle(
                [48.851525, 2.343298],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_240b944a70274c0998c31e28d118284e = L.popup({"maxWidth": "100%"});

        
            var html_ff0ee10ccbd74442bdeae33926daaf00 = $(`<div id="html_ff0ee10ccbd74442bdeae33926daaf00" style="width: 100.0%; height: 100.0%;">21 boulevard Saint Michel S-N</div>`)[0];
            popup_240b944a70274c0998c31e28d118284e.setContent(html_ff0ee10ccbd74442bdeae33926daaf00);
        

        circle_b342afc173434ad688b331e07a73a102.bindPopup(popup_240b944a70274c0998c31e28d118284e)
        ;

        
    
    
            var circle_d24e59971621401486c933c1a26e8288 = L.circle(
                [48.896825, 2.345648],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_c440b4abea5c49c6a17bfa7ee24d56fa = L.popup({"maxWidth": "100%"});

        
            var html_0cb9e8551b314148ae487ad4c5395a4e = $(`<div id="html_0cb9e8551b314148ae487ad4c5395a4e" style="width: 100.0%; height: 100.0%;">74 Boulevard Ornano S-N</div>`)[0];
            popup_c440b4abea5c49c6a17bfa7ee24d56fa.setContent(html_0cb9e8551b314148ae487ad4c5395a4e);
        

        circle_d24e59971621401486c933c1a26e8288.bindPopup(popup_c440b4abea5c49c6a17bfa7ee24d56fa)
        ;

        
    
    
            var circle_aed5637a227c49f7ab48fec7dd4fdf09 = L.circle(
                [48.82658, 2.38409],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.00000000000006, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_79dee7adf2614be9af6658ff9f95627c = L.popup({"maxWidth": "100%"});

        
            var html_a575dcc2f61e460b9611a360e478851c = $(`<div id="html_a575dcc2f61e460b9611a360e478851c" style="width: 100.0%; height: 100.0%;">Pont National SO-NE</div>`)[0];
            popup_79dee7adf2614be9af6658ff9f95627c.setContent(html_a575dcc2f61e460b9611a360e478851c);
        

        circle_aed5637a227c49f7ab48fec7dd4fdf09.bindPopup(popup_79dee7adf2614be9af6658ff9f95627c)
        ;

        
    
    
            var circle_e26d34a5dfbe4645bdb44a5546fc8314 = L.circle(
                [48.891415, 2.384954],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_70e66cdfa2cd4ac1afd54c52b15f8e3c = L.popup({"maxWidth": "100%"});

        
            var html_d24294c11f8a40d18e362b2da306e141 = $(`<div id="html_d24294c11f8a40d18e362b2da306e141" style="width: 100.0%; height: 100.0%;">Face au 25 quai de l'Oise NE-SO</div>`)[0];
            popup_70e66cdfa2cd4ac1afd54c52b15f8e3c.setContent(html_d24294c11f8a40d18e362b2da306e141);
        

        circle_e26d34a5dfbe4645bdb44a5546fc8314.bindPopup(popup_70e66cdfa2cd4ac1afd54c52b15f8e3c)
        ;

        
    
    
            var circle_c754237b27704ac9961384fac2ae11d9 = L.circle(
                [48.86392, 2.31988],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_03e03c91549b4cb581dbba1c5389522f = L.popup({"maxWidth": "100%"});

        
            var html_af7e9caa83a0473fa680ba4e5d9c44d8 = $(`<div id="html_af7e9caa83a0473fa680ba4e5d9c44d8" style="width: 100.0%; height: 100.0%;">Pont de la Concorde N-S</div>`)[0];
            popup_03e03c91549b4cb581dbba1c5389522f.setContent(html_af7e9caa83a0473fa680ba4e5d9c44d8);
        

        circle_c754237b27704ac9961384fac2ae11d9.bindPopup(popup_03e03c91549b4cb581dbba1c5389522f)
        ;

        
    
    
            var circle_5c7d43585988414dafc173313003719d = L.circle(
                [48.82108, 2.32537],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_6361d99b4d9d4e9c809c41272733b35c = L.popup({"maxWidth": "100%"});

        
            var html_7e45539511da4a23adf809e30e8e62fc = $(`<div id="html_7e45539511da4a23adf809e30e8e62fc" style="width: 100.0%; height: 100.0%;">3 avenue de la Porte D'Orléans S-N</div>`)[0];
            popup_6361d99b4d9d4e9c809c41272733b35c.setContent(html_7e45539511da4a23adf809e30e8e62fc);
        

        circle_5c7d43585988414dafc173313003719d.bindPopup(popup_6361d99b4d9d4e9c809c41272733b35c)
        ;

        
    
    
            var circle_8213c49b5ce9451f94efc55401286640 = L.circle(
                [48.86179, 2.32014],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_f845da511535470badf60dcd07fd4d45 = L.popup({"maxWidth": "100%"});

        
            var html_2a4f74ba3e63492a91fa3b41acc7f925 = $(`<div id="html_2a4f74ba3e63492a91fa3b41acc7f925" style="width: 100.0%; height: 100.0%;">243 boulevard Saint Germain NO-SE</div>`)[0];
            popup_f845da511535470badf60dcd07fd4d45.setContent(html_2a4f74ba3e63492a91fa3b41acc7f925);
        

        circle_8213c49b5ce9451f94efc55401286640.bindPopup(popup_f845da511535470badf60dcd07fd4d45)
        ;

        
    
    
            var circle_b0c6668c383c4ef4bbecb4d2dd3d8182 = L.circle(
                [48.85735, 2.35211],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_a2fc801fb1eb463a890837b3c8b78788 = L.popup({"maxWidth": "100%"});

        
            var html_f0758e5ebc5e4589b81fdf29b81ee924 = $(`<div id="html_f0758e5ebc5e4589b81fdf29b81ee924" style="width: 100.0%; height: 100.0%;">Totem 64 Rue de Rivoli E-O</div>`)[0];
            popup_a2fc801fb1eb463a890837b3c8b78788.setContent(html_f0758e5ebc5e4589b81fdf29b81ee924);
        

        circle_b0c6668c383c4ef4bbecb4d2dd3d8182.bindPopup(popup_a2fc801fb1eb463a890837b3c8b78788)
        ;

        
    
    
            var circle_4cc9315a673c4f6b92b20267f79581fe = L.circle(
                [48.88529, 2.32666],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_ab8a5d6b3607491b947dd0a084e1eb28 = L.popup({"maxWidth": "100%"});

        
            var html_72f701b885514c4ba33850bc0fc168b2 = $(`<div id="html_72f701b885514c4ba33850bc0fc168b2" style="width: 100.0%; height: 100.0%;">20 Avenue de Clichy SE-NO</div>`)[0];
            popup_ab8a5d6b3607491b947dd0a084e1eb28.setContent(html_72f701b885514c4ba33850bc0fc168b2);
        

        circle_4cc9315a673c4f6b92b20267f79581fe.bindPopup(popup_ab8a5d6b3607491b947dd0a084e1eb28)
        ;

        
    
    
            var circle_35150a078660482fbad59f41fe421f3d = L.circle(
                [48.860852, 2.372279],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_f8620310a4814abeb6b315eb5bc5762c = L.popup({"maxWidth": "100%"});

        
            var html_10cc0b2c615b4c0d80cb7a2bafcf8f62 = $(`<div id="html_10cc0b2c615b4c0d80cb7a2bafcf8f62" style="width: 100.0%; height: 100.0%;">77 boulevard Richard Lenoir N-S</div>`)[0];
            popup_f8620310a4814abeb6b315eb5bc5762c.setContent(html_10cc0b2c615b4c0d80cb7a2bafcf8f62);
        

        circle_35150a078660482fbad59f41fe421f3d.bindPopup(popup_f8620310a4814abeb6b315eb5bc5762c)
        ;

        
    
    
            var circle_51fa5a69e5cf4f5287cbf0189c5f5af0 = L.circle(
                [48.840801, 2.333233],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_928dbc76ce6e493da5ac9839e83ccc02 = L.popup({"maxWidth": "100%"});

        
            var html_1e2477ad0d79423f803f602f3c6d212a = $(`<div id="html_1e2477ad0d79423f803f602f3c6d212a" style="width: 100.0%; height: 100.0%;">152 boulevard du Montparnasse E-O</div>`)[0];
            popup_928dbc76ce6e493da5ac9839e83ccc02.setContent(html_1e2477ad0d79423f803f602f3c6d212a);
        

        circle_51fa5a69e5cf4f5287cbf0189c5f5af0.bindPopup(popup_928dbc76ce6e493da5ac9839e83ccc02)
        ;

        
    
    
            var circle_d69a15ba6d79465ca36dcbba38665b84 = L.circle(
                [48.85735, 2.35211],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_acb572f191f14f2aa04d23962873e7d4 = L.popup({"maxWidth": "100%"});

        
            var html_0171605d5c344870b7fb66a962e503ba = $(`<div id="html_0171605d5c344870b7fb66a962e503ba" style="width: 100.0%; height: 100.0%;">Totem 64 Rue de Rivoli O-E</div>`)[0];
            popup_acb572f191f14f2aa04d23962873e7d4.setContent(html_0171605d5c344870b7fb66a962e503ba);
        

        circle_d69a15ba6d79465ca36dcbba38665b84.bindPopup(popup_acb572f191f14f2aa04d23962873e7d4)
        ;

        
    
    
            var circle_0ecd2a54f5c940bab7f3add193085dcf = L.circle(
                [48.86284, 2.310345],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_ef4570758b144337a001d3ea5658c95c = L.popup({"maxWidth": "100%"});

        
            var html_9a85f42980ec430dbec9361eb331e329 = $(`<div id="html_9a85f42980ec430dbec9361eb331e329" style="width: 100.0%; height: 100.0%;">Pont des Invalides N-S</div>`)[0];
            popup_ef4570758b144337a001d3ea5658c95c.setContent(html_9a85f42980ec430dbec9361eb331e329);
        

        circle_0ecd2a54f5c940bab7f3add193085dcf.bindPopup(popup_ef4570758b144337a001d3ea5658c95c)
        ;

        
    
    
            var circle_2d04db909d344c55b149485d455a2705 = L.circle(
                [48.830331, 2.400551],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_f5635d64d5d64c3ead29a95cf89b5473 = L.popup({"maxWidth": "100%"});

        
            var html_ffbdadad9dd548a2a918f8752e74d109 = $(`<div id="html_ffbdadad9dd548a2a918f8752e74d109" style="width: 100.0%; height: 100.0%;">Face au 8 avenue de la porte de Charenton SE-NO</div>`)[0];
            popup_f5635d64d5d64c3ead29a95cf89b5473.setContent(html_ffbdadad9dd548a2a918f8752e74d109);
        

        circle_2d04db909d344c55b149485d455a2705.bindPopup(popup_f5635d64d5d64c3ead29a95cf89b5473)
        ;

        
    
    
            var circle_73efd8c3119e44b98e8bc94b18b8d938 = L.circle(
                [48.84223, 2.36811],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_c52019c178ca499e80d76e9c574c7e32 = L.popup({"maxWidth": "100%"});

        
            var html_e18a4c27bc2d4310862008a5adf1e0f9 = $(`<div id="html_e18a4c27bc2d4310862008a5adf1e0f9" style="width: 100.0%; height: 100.0%;">Pont Charles De Gaulle NE-SO</div>`)[0];
            popup_c52019c178ca499e80d76e9c574c7e32.setContent(html_e18a4c27bc2d4310862008a5adf1e0f9);
        

        circle_73efd8c3119e44b98e8bc94b18b8d938.bindPopup(popup_c52019c178ca499e80d76e9c574c7e32)
        ;

        
    
    
            var circle_12a4734ed085412690fd502d5889bfa9 = L.circle(
                [48.846028, 2.375429],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_bf5000d499c64798824ba2fe45203939 = L.popup({"maxWidth": "100%"});

        
            var html_e1406d9586274a9eb5b87bd6cdec3918 = $(`<div id="html_e1406d9586274a9eb5b87bd6cdec3918" style="width: 100.0%; height: 100.0%;">28 boulevard Diderot E-O</div>`)[0];
            popup_bf5000d499c64798824ba2fe45203939.setContent(html_e1406d9586274a9eb5b87bd6cdec3918);
        

        circle_12a4734ed085412690fd502d5889bfa9.bindPopup(popup_bf5000d499c64798824ba2fe45203939)
        ;

        
    
    
            var circle_bcfaa89bcccb4f85b03e8d5b4218f375 = L.circle(
                [48.85372, 2.35702],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_c1f89ee1b8944da3b18bc817b79ff878 = L.popup({"maxWidth": "100%"});

        
            var html_7701555ac2cb4ac9a6011fa853424968 = $(`<div id="html_7701555ac2cb4ac9a6011fa853424968" style="width: 100.0%; height: 100.0%;">18 quai de l'hotel de ville SE-NO</div>`)[0];
            popup_c1f89ee1b8944da3b18bc817b79ff878.setContent(html_7701555ac2cb4ac9a6011fa853424968);
        

        circle_bcfaa89bcccb4f85b03e8d5b4218f375.bindPopup(popup_c1f89ee1b8944da3b18bc817b79ff878)
        ;

        
    
    
            var circle_79669548da314ceabb8e1fd3caa38e76 = L.circle(
                [48.869873, 2.307419],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_69f4cd1c37c64e4d9e84142f9273d784 = L.popup({"maxWidth": "100%"});

        
            var html_3e58173438584c6dbdc3a5589b1808c4 = $(`<div id="html_3e58173438584c6dbdc3a5589b1808c4" style="width: 100.0%; height: 100.0%;">44 avenue des Champs Elysées SE-NO</div>`)[0];
            popup_69f4cd1c37c64e4d9e84142f9273d784.setContent(html_3e58173438584c6dbdc3a5589b1808c4);
        

        circle_79669548da314ceabb8e1fd3caa38e76.bindPopup(popup_69f4cd1c37c64e4d9e84142f9273d784)
        ;

        
    
    
            var circle_4f6e65ca95274fcd93b6239e8c751e9c = L.circle(
                [48.84216, 2.30115],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_cf1a29b18dd54bbfa22df2f05ec95b24 = L.popup({"maxWidth": "100%"});

        
            var html_ac50cf005b8c455e992c18d508a36273 = $(`<div id="html_ac50cf005b8c455e992c18d508a36273" style="width: 100.0%; height: 100.0%;">132 rue Lecourbe NE-SO</div>`)[0];
            popup_cf1a29b18dd54bbfa22df2f05ec95b24.setContent(html_ac50cf005b8c455e992c18d508a36273);
        

        circle_4f6e65ca95274fcd93b6239e8c751e9c.bindPopup(popup_cf1a29b18dd54bbfa22df2f05ec95b24)
        ;

        
    
    
            var circle_69496fd6379547e8ac5496caf13d7bb6 = L.circle(
                [48.89594, 2.35953],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_76cdfc2cc77f48d5934208d180aa8fc0 = L.popup({"maxWidth": "100%"});

        
            var html_29262ef64dd2404c804301b78151443c = $(`<div id="html_29262ef64dd2404c804301b78151443c" style="width: 100.0%; height: 100.0%;">72 rue de la Chapelle N-S</div>`)[0];
            popup_76cdfc2cc77f48d5934208d180aa8fc0.setContent(html_29262ef64dd2404c804301b78151443c);
        

        circle_69496fd6379547e8ac5496caf13d7bb6.bindPopup(popup_76cdfc2cc77f48d5934208d180aa8fc0)
        ;

        
    
    
            var circle_7f2dc677c67f487cbe42bf458c639b80 = L.circle(
                [48.85209, 2.28508],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_fec4643f377f4f73b9888af858babead = L.popup({"maxWidth": "100%"});

        
            var html_b5a698cc7b104ef6b15ac81a44c50ff1 = $(`<div id="html_b5a698cc7b104ef6b15ac81a44c50ff1" style="width: 100.0%; height: 100.0%;">36 quai de Grenelle NE-SO</div>`)[0];
            popup_fec4643f377f4f73b9888af858babead.setContent(html_b5a698cc7b104ef6b15ac81a44c50ff1);
        

        circle_7f2dc677c67f487cbe42bf458c639b80.bindPopup(popup_fec4643f377f4f73b9888af858babead)
        ;

        
    
    
            var circle_5e0bf4831c944a4c9effd36bf8a84a50 = L.circle(
                [48.83421, 2.26542],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_dbda550ead654d8e92b64a488cae3cdd = L.popup({"maxWidth": "100%"});

        
            var html_373eda8154434b4396a2dd3e3ac90aeb = $(`<div id="html_373eda8154434b4396a2dd3e3ac90aeb" style="width: 100.0%; height: 100.0%;">Face au 40 quai D'Issy NE-SO</div>`)[0];
            popup_dbda550ead654d8e92b64a488cae3cdd.setContent(html_373eda8154434b4396a2dd3e3ac90aeb);
        

        circle_5e0bf4831c944a4c9effd36bf8a84a50.bindPopup(popup_dbda550ead654d8e92b64a488cae3cdd)
        ;

        
    
    
            var circle_b4a14e7534cb414e809b37bfc371e6db = L.circle(
                [48.84201, 2.36729],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 499.99999999999994, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_f430f137fcdc4ca2b13df0e5f4dd88e6 = L.popup({"maxWidth": "100%"});

        
            var html_8827ca4f4db74bedba2b66eb7750f7b1 = $(`<div id="html_8827ca4f4db74bedba2b66eb7750f7b1" style="width: 100.0%; height: 100.0%;">Totem 85 quai d'Austerlitz NO-SE</div>`)[0];
            popup_f430f137fcdc4ca2b13df0e5f4dd88e6.setContent(html_8827ca4f4db74bedba2b66eb7750f7b1);
        

        circle_b4a14e7534cb414e809b37bfc371e6db.bindPopup(popup_f430f137fcdc4ca2b13df0e5f4dd88e6)
        ;

        
    
    
            var circle_8c6d6d402698473a9f1562ce9ccbaa92 = L.circle(
                [48.86077, 2.37305],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_9850f6758aa44e7dbf75acdbc621f9fa = L.popup({"maxWidth": "100%"});

        
            var html_cd949a9417d8460bafe2014326fd4a44 = $(`<div id="html_cd949a9417d8460bafe2014326fd4a44" style="width: 100.0%; height: 100.0%;">72 boulevard Richard Lenoir  S-N</div>`)[0];
            popup_9850f6758aa44e7dbf75acdbc621f9fa.setContent(html_cd949a9417d8460bafe2014326fd4a44);
        

        circle_8c6d6d402698473a9f1562ce9ccbaa92.bindPopup(popup_9850f6758aa44e7dbf75acdbc621f9fa)
        ;

        
    
    
            var circle_857c64234b13420bb8ec290ae48df711 = L.circle(
                [48.82636, 2.30303],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_f3f892871be746ed8b7fecedc3191d4b = L.popup({"maxWidth": "100%"});

        
            var html_ee85911550da49f8bb7d8d8a48654b4b = $(`<div id="html_ee85911550da49f8bb7d8d8a48654b4b" style="width: 100.0%; height: 100.0%;">6 rue Julia Bartet SO-NE</div>`)[0];
            popup_f3f892871be746ed8b7fecedc3191d4b.setContent(html_ee85911550da49f8bb7d8d8a48654b4b);
        

        circle_857c64234b13420bb8ec290ae48df711.bindPopup(popup_f3f892871be746ed8b7fecedc3191d4b)
        ;

        
    
    
            var circle_65b318167f3c4f4d91e035b8de6ccd6e = L.circle(
                [48.860528, 2.388364],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_bc5670fd390d4ef486c228a93bfba295 = L.popup({"maxWidth": "100%"});

        
            var html_f02d93a2ada34f1a89be296bb71ce928 = $(`<div id="html_f02d93a2ada34f1a89be296bb71ce928" style="width: 100.0%; height: 100.0%;">35 boulevard de Menilmontant NO-SE</div>`)[0];
            popup_bc5670fd390d4ef486c228a93bfba295.setContent(html_f02d93a2ada34f1a89be296bb71ce928);
        

        circle_65b318167f3c4f4d91e035b8de6ccd6e.bindPopup(popup_bc5670fd390d4ef486c228a93bfba295)
        ;

        
    
    
            var circle_10ad10255b634678957c76cf667fdb0d = L.circle(
                [48.85013, 2.35423],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_984115833c074ccc9233169353291f93 = L.popup({"maxWidth": "100%"});

        
            var html_ee43f697907c4dcd80a8c88620311338 = $(`<div id="html_ee43f697907c4dcd80a8c88620311338" style="width: 100.0%; height: 100.0%;">27 quai de la Tournelle SE-NO</div>`)[0];
            popup_984115833c074ccc9233169353291f93.setContent(html_ee43f697907c4dcd80a8c88620311338);
        

        circle_10ad10255b634678957c76cf667fdb0d.bindPopup(popup_984115833c074ccc9233169353291f93)
        ;

        
    
    
            var circle_cadf8a17d8f2406d8e6ec0ccae4796a7 = L.circle(
                [48.86377, 2.35096],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 499.99999999999994, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_6c44ba0a493547259aaa3b2541ab32a9 = L.popup({"maxWidth": "100%"});

        
            var html_fef4c193a43147aeb353028e957fa03c = $(`<div id="html_fef4c193a43147aeb353028e957fa03c" style="width: 100.0%; height: 100.0%;">Totem 73 boulevard de Sébastopol S-N</div>`)[0];
            popup_6c44ba0a493547259aaa3b2541ab32a9.setContent(html_fef4c193a43147aeb353028e957fa03c);
        

        circle_cadf8a17d8f2406d8e6ec0ccae4796a7.bindPopup(popup_6c44ba0a493547259aaa3b2541ab32a9)
        ;

        
    
    
            var circle_d291bbdc089b41ddaea1fb38477601da = L.circle(
                [48.843435, 2.383378],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_f0b1b2e25ee34b2bbc3edbad9dbe599b = L.popup({"maxWidth": "100%"});

        
            var html_f7ffba92aa7c45bf9ebdd8b56de366e1 = $(`<div id="html_f7ffba92aa7c45bf9ebdd8b56de366e1" style="width: 100.0%; height: 100.0%;">135 avenue Daumesnil SE-NO</div>`)[0];
            popup_f0b1b2e25ee34b2bbc3edbad9dbe599b.setContent(html_f7ffba92aa7c45bf9ebdd8b56de366e1);
        

        circle_d291bbdc089b41ddaea1fb38477601da.bindPopup(popup_f0b1b2e25ee34b2bbc3edbad9dbe599b)
        ;

        
    
    
            var circle_f5f74322c0db4a1dadb02c81dd407a89 = L.circle(
                [48.846028, 2.375429],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_fa8e8a5ebeb3414fae0439fbd44b7b35 = L.popup({"maxWidth": "100%"});

        
            var html_27bc606ce1a64773883b2674925a55a1 = $(`<div id="html_27bc606ce1a64773883b2674925a55a1" style="width: 100.0%; height: 100.0%;">28 boulevard Diderot O-E</div>`)[0];
            popup_fa8e8a5ebeb3414fae0439fbd44b7b35.setContent(html_27bc606ce1a64773883b2674925a55a1);
        

        circle_f5f74322c0db4a1dadb02c81dd407a89.bindPopup(popup_fa8e8a5ebeb3414fae0439fbd44b7b35)
        ;

        
    
    
            var circle_39ff318bb1d64e399e3088f8cd10d774 = L.circle(
                [48.85372, 2.35702],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_294e14300fdb438b9a9eff7b1d19fe4e = L.popup({"maxWidth": "100%"});

        
            var html_c27e8f5a84d24291b3163e2a79ec4766 = $(`<div id="html_c27e8f5a84d24291b3163e2a79ec4766" style="width: 100.0%; height: 100.0%;">18 quai de l'hotel de ville NO-SE</div>`)[0];
            popup_294e14300fdb438b9a9eff7b1d19fe4e.setContent(html_c27e8f5a84d24291b3163e2a79ec4766);
        

        circle_39ff318bb1d64e399e3088f8cd10d774.bindPopup(popup_294e14300fdb438b9a9eff7b1d19fe4e)
        ;

        
    
    
            var circle_c07e800ca76d45ba97b17ba28b2c4319 = L.circle(
                [48.86451, 2.40932],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 499.99999999999994, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_d122c7152a3847e386d4ba8cf0ccfd6e = L.popup({"maxWidth": "100%"});

        
            var html_cac51aaad40d49c7a08453a9461c11b5 = $(`<div id="html_cac51aaad40d49c7a08453a9461c11b5" style="width: 100.0%; height: 100.0%;">2 avenue de la Porte de Bagnolet O-E</div>`)[0];
            popup_d122c7152a3847e386d4ba8cf0ccfd6e.setContent(html_cac51aaad40d49c7a08453a9461c11b5);
        

        circle_c07e800ca76d45ba97b17ba28b2c4319.bindPopup(popup_d122c7152a3847e386d4ba8cf0ccfd6e)
        ;

        
    
    
            var circle_1116735a836d45ad828b21deef0a385f = L.circle(
                [48.83421, 2.26542],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.00000000000006, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_6c643ac83c424d3490b57c046937c872 = L.popup({"maxWidth": "100%"});

        
            var html_c7876899126c4d29993056846ad1176b = $(`<div id="html_c7876899126c4d29993056846ad1176b" style="width: 100.0%; height: 100.0%;">Face au 40 quai D'Issy SO-NE</div>`)[0];
            popup_6c643ac83c424d3490b57c046937c872.setContent(html_c7876899126c4d29993056846ad1176b);
        

        circle_1116735a836d45ad828b21deef0a385f.bindPopup(popup_6c643ac83c424d3490b57c046937c872)
        ;

        
    
    
            var circle_4a56c8e1a8f14655896f11e46f7edc59 = L.circle(
                [48.86521, 2.35358],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_1ec6c4b44ead4a2e93ab3c365ce984d2 = L.popup({"maxWidth": "100%"});

        
            var html_b70e6e3be6b14c3cb446015e0a4d7edc = $(`<div id="html_b70e6e3be6b14c3cb446015e0a4d7edc" style="width: 100.0%; height: 100.0%;">38 rue Turbigo NE-SO</div>`)[0];
            popup_1ec6c4b44ead4a2e93ab3c365ce984d2.setContent(html_b70e6e3be6b14c3cb446015e0a4d7edc);
        

        circle_4a56c8e1a8f14655896f11e46f7edc59.bindPopup(popup_1ec6c4b44ead4a2e93ab3c365ce984d2)
        ;

        
    
    
            var circle_99324570f04249788bdf955e09f0a1d1 = L.circle(
                [48.877667, 2.350556],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_034e60819a7d4cd88193540bcea1afd5 = L.popup({"maxWidth": "100%"});

        
            var html_4a8d7a114bf648a087ff1f8a1c6d843d = $(`<div id="html_4a8d7a114bf648a087ff1f8a1c6d843d" style="width: 100.0%; height: 100.0%;">105 rue La Fayette E-O</div>`)[0];
            popup_034e60819a7d4cd88193540bcea1afd5.setContent(html_4a8d7a114bf648a087ff1f8a1c6d843d);
        

        circle_99324570f04249788bdf955e09f0a1d1.bindPopup(popup_034e60819a7d4cd88193540bcea1afd5)
        ;

        
    
    
            var circle_5de6ff20384d4420befe9fce9efced42 = L.circle(
                [48.83436, 2.377],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_62d178820826404d8f8d9ca9d707bdd1 = L.popup({"maxWidth": "100%"});

        
            var html_63177b71b3ac411882c21823325e8c6d = $(`<div id="html_63177b71b3ac411882c21823325e8c6d" style="width: 100.0%; height: 100.0%;">39 quai François Mauriac SE-NO</div>`)[0];
            popup_62d178820826404d8f8d9ca9d707bdd1.setContent(html_63177b71b3ac411882c21823325e8c6d);
        

        circle_5de6ff20384d4420befe9fce9efced42.bindPopup(popup_62d178820826404d8f8d9ca9d707bdd1)
        ;

        
    
    
            var circle_2244f8f52ed14143a6ce635c98cd599c = L.circle(
                [48.83436, 2.377],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_a17209b73a1547e29a52d7f063db6f31 = L.popup({"maxWidth": "100%"});

        
            var html_fb1edb5117ba46a7a72a127aa5f9aa5c = $(`<div id="html_fb1edb5117ba46a7a72a127aa5f9aa5c" style="width: 100.0%; height: 100.0%;">39 quai François Mauriac NO-SE</div>`)[0];
            popup_a17209b73a1547e29a52d7f063db6f31.setContent(html_fb1edb5117ba46a7a72a127aa5f9aa5c);
        

        circle_2244f8f52ed14143a6ce635c98cd599c.bindPopup(popup_a17209b73a1547e29a52d7f063db6f31)
        ;

        
    
    
            var circle_3b28610a66bd4695bea619db1bdce1af = L.circle(
                [48.82636, 2.30303],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_3ac41b77dfa7404ba4f2777ce3a2775b = L.popup({"maxWidth": "100%"});

        
            var html_b6601f1c28794d49a9b8eb49574d4aff = $(`<div id="html_b6601f1c28794d49a9b8eb49574d4aff" style="width: 100.0%; height: 100.0%;">6 rue Julia Bartet NE-SO</div>`)[0];
            popup_3ac41b77dfa7404ba4f2777ce3a2775b.setContent(html_b6601f1c28794d49a9b8eb49574d4aff);
        

        circle_3b28610a66bd4695bea619db1bdce1af.bindPopup(popup_3ac41b77dfa7404ba4f2777ce3a2775b)
        ;

        
    
    
            var circle_fd99f68568c04e649d8b0b90d6732bf7 = L.circle(
                [48.86521, 2.35358],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_763e4f89655c4662b7722eaf72e3449a = L.popup({"maxWidth": "100%"});

        
            var html_858522ffbfbc4d2394f74a125dd1e6fc = $(`<div id="html_858522ffbfbc4d2394f74a125dd1e6fc" style="width: 100.0%; height: 100.0%;">38 rue Turbigo SO-NE</div>`)[0];
            popup_763e4f89655c4662b7722eaf72e3449a.setContent(html_858522ffbfbc4d2394f74a125dd1e6fc);
        

        circle_fd99f68568c04e649d8b0b90d6732bf7.bindPopup(popup_763e4f89655c4662b7722eaf72e3449a)
        ;

        
    
    
            var circle_d29bff9c55384787b4745d9a365d8ac6 = L.circle(
                [48.84638, 2.31529],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_939340957c9f49c0a05c8997633ff171 = L.popup({"maxWidth": "100%"});

        
            var html_8e95fe9b1f174ab5aaf23e037ca50a3f = $(`<div id="html_8e95fe9b1f174ab5aaf23e037ca50a3f" style="width: 100.0%; height: 100.0%;">90 Rue De Sèvres NE-SO</div>`)[0];
            popup_939340957c9f49c0a05c8997633ff171.setContent(html_8e95fe9b1f174ab5aaf23e037ca50a3f);
        

        circle_d29bff9c55384787b4745d9a365d8ac6.bindPopup(popup_939340957c9f49c0a05c8997633ff171)
        ;

        
    
    
            var circle_72dbf94357e84a6e9ccc0d1ca2276006 = L.circle(
                [48.846099, 2.375456],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_e8788a06f7d2489784478a3acef721da = L.popup({"maxWidth": "100%"});

        
            var html_2be1f082aa6b4665953739d6784f394d = $(`<div id="html_2be1f082aa6b4665953739d6784f394d" style="width: 100.0%; height: 100.0%;">27 boulevard Diderot E-O</div>`)[0];
            popup_e8788a06f7d2489784478a3acef721da.setContent(html_2be1f082aa6b4665953739d6784f394d);
        

        circle_72dbf94357e84a6e9ccc0d1ca2276006.bindPopup(popup_e8788a06f7d2489784478a3acef721da)
        ;

        
    
    
            var circle_4ea1c2c9c4db488babd4e213b141c547 = L.circle(
                [48.84015, 2.26733],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_56f3e6485a3344a6ac4c144cc2d63020 = L.popup({"maxWidth": "100%"});

        
            var html_b827222f038240d881853c9295bd484e = $(`<div id="html_b827222f038240d881853c9295bd484e" style="width: 100.0%; height: 100.0%;">Pont du Garigliano NO-SE</div>`)[0];
            popup_56f3e6485a3344a6ac4c144cc2d63020.setContent(html_b827222f038240d881853c9295bd484e);
        

        circle_4ea1c2c9c4db488babd4e213b141c547.bindPopup(popup_56f3e6485a3344a6ac4c144cc2d63020)
        ;

        
    
    
            var circle_815f3b5d7cde40fcbf371197a9ee6d93 = L.circle(
                [48.891215, 2.38573],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_3053fd40d0e64e6d91e31224a2ddcc86 = L.popup({"maxWidth": "100%"});

        
            var html_c5dcb68afccd4a83a9df64848cc87f14 = $(`<div id="html_c5dcb68afccd4a83a9df64848cc87f14" style="width: 100.0%; height: 100.0%;">Face au 48 quai de la marne NE-SO</div>`)[0];
            popup_3053fd40d0e64e6d91e31224a2ddcc86.setContent(html_c5dcb68afccd4a83a9df64848cc87f14);
        

        circle_815f3b5d7cde40fcbf371197a9ee6d93.bindPopup(popup_3053fd40d0e64e6d91e31224a2ddcc86)
        ;

        
    
    
            var circle_9c506cb77b5847d49ea89f59e0c4a91c = L.circle(
                [48.82682, 2.38465],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_80909343bab34a2c8d32679b9ec76e90 = L.popup({"maxWidth": "100%"});

        
            var html_812bc184fd354eae8ef13dfa3c5cf36e = $(`<div id="html_812bc184fd354eae8ef13dfa3c5cf36e" style="width: 100.0%; height: 100.0%;">Pont National  NE-SO</div>`)[0];
            popup_80909343bab34a2c8d32679b9ec76e90.setContent(html_812bc184fd354eae8ef13dfa3c5cf36e);
        

        circle_9c506cb77b5847d49ea89f59e0c4a91c.bindPopup(popup_80909343bab34a2c8d32679b9ec76e90)
        ;

        
    
    
            var circle_1e863f7a2c3c48adb8d9393e023b2bc9 = L.circle(
                [48.869831, 2.307076],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_76146302bf6a401195be4dcff640e283 = L.popup({"maxWidth": "100%"});

        
            var html_1ec85a30397b45d2ac15c03036207d91 = $(`<div id="html_1ec85a30397b45d2ac15c03036207d91" style="width: 100.0%; height: 100.0%;">33 avenue des Champs Elysées NO-SE</div>`)[0];
            popup_76146302bf6a401195be4dcff640e283.setContent(html_1ec85a30397b45d2ac15c03036207d91);
        

        circle_1e863f7a2c3c48adb8d9393e023b2bc9.bindPopup(popup_76146302bf6a401195be4dcff640e283)
        ;

        
    
    
            var circle_c355695b1b4440bc843a5ace448eab5c = L.circle(
                [48.86282, 2.31061],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_81dead5c59b943e0b569c09d2d236cdf = L.popup({"maxWidth": "100%"});

        
            var html_fae437c9d0c94c839f3bd8b843a1c29d = $(`<div id="html_fae437c9d0c94c839f3bd8b843a1c29d" style="width: 100.0%; height: 100.0%;">Pont des Invalides S-N</div>`)[0];
            popup_81dead5c59b943e0b569c09d2d236cdf.setContent(html_fae437c9d0c94c839f3bd8b843a1c29d);
        

        circle_c355695b1b4440bc843a5ace448eab5c.bindPopup(popup_81dead5c59b943e0b569c09d2d236cdf)
        ;

        
    
    
            var circle_892a44452a65448c972721981dc821d8 = L.circle(
                [48.89594, 2.35953],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_6cef772f851f44a38e9928a1ed554916 = L.popup({"maxWidth": "100%"});

        
            var html_25b55472845a4f16a577ab6d3a5a4ceb = $(`<div id="html_25b55472845a4f16a577ab6d3a5a4ceb" style="width: 100.0%; height: 100.0%;">72 rue de la Chapelle S-N</div>`)[0];
            popup_6cef772f851f44a38e9928a1ed554916.setContent(html_25b55472845a4f16a577ab6d3a5a4ceb);
        

        circle_892a44452a65448c972721981dc821d8.bindPopup(popup_6cef772f851f44a38e9928a1ed554916)
        ;

        
    
    
            var circle_496e74d4a9de460f855f0948662cffb0 = L.circle(
                [48.88181, 2.281546],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_45e17f3c5bf949b082fb64f386672035 = L.popup({"maxWidth": "100%"});

        
            var html_e9eb01cd0829426380805bfa9fd8a10f = $(`<div id="html_e9eb01cd0829426380805bfa9fd8a10f" style="width: 100.0%; height: 100.0%;">16 avenue de la Porte des Ternes E-O</div>`)[0];
            popup_45e17f3c5bf949b082fb64f386672035.setContent(html_e9eb01cd0829426380805bfa9fd8a10f);
        

        circle_496e74d4a9de460f855f0948662cffb0.bindPopup(popup_45e17f3c5bf949b082fb64f386672035)
        ;

        
    
    
            var circle_487906c9864b407da7a1899a8c65e508 = L.circle(
                [48.86462, 2.31444],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_8c6fd07855384a399002182e8e636720 = L.popup({"maxWidth": "100%"});

        
            var html_c08c7bd3ebad4dbd80b10a4582788be6 = $(`<div id="html_c08c7bd3ebad4dbd80b10a4582788be6" style="width: 100.0%; height: 100.0%;">Totem Cours la Reine E-O</div>`)[0];
            popup_8c6fd07855384a399002182e8e636720.setContent(html_c08c7bd3ebad4dbd80b10a4582788be6);
        

        circle_487906c9864b407da7a1899a8c65e508.bindPopup(popup_8c6fd07855384a399002182e8e636720)
        ;

        
    
    
            var circle_b3e9e46983c54deeb338557b387451aa = L.circle(
                [48.851131, 2.345678],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_614dc2ec41634da9a368471c3a2aaed2 = L.popup({"maxWidth": "100%"});

        
            var html_8445fff405d54aa1bd5459d1c344d1ff = $(`<div id="html_8445fff405d54aa1bd5459d1c344d1ff" style="width: 100.0%; height: 100.0%;">30 rue Saint Jacques N-S</div>`)[0];
            popup_614dc2ec41634da9a368471c3a2aaed2.setContent(html_8445fff405d54aa1bd5459d1c344d1ff);
        

        circle_b3e9e46983c54deeb338557b387451aa.bindPopup(popup_614dc2ec41634da9a368471c3a2aaed2)
        ;

        
    
    
            var circle_64cfa1c6fc9a44a092c72a5c95312542 = L.circle(
                [48.8484, 2.27586],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_f23efdb23e6f43cdad3e3425191ceac1 = L.popup({"maxWidth": "100%"});

        
            var html_2d6ba90c26014e12a4072c0fbdfe7ed7 = $(`<div id="html_2d6ba90c26014e12a4072c0fbdfe7ed7" style="width: 100.0%; height: 100.0%;">Voie Georges Pompidou SO-NE</div>`)[0];
            popup_f23efdb23e6f43cdad3e3425191ceac1.setContent(html_2d6ba90c26014e12a4072c0fbdfe7ed7);
        

        circle_64cfa1c6fc9a44a092c72a5c95312542.bindPopup(popup_f23efdb23e6f43cdad3e3425191ceac1)
        ;

        
    
    
            var circle_37cf8b85dbfc4008bf562e97078656fc = L.circle(
                [48.877686, 2.354471],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_d321f7753e68447682aa24e5107fce95 = L.popup({"maxWidth": "100%"});

        
            var html_7bf616dd1bf140df8492cfa7450b3076 = $(`<div id="html_7bf616dd1bf140df8492cfa7450b3076" style="width: 100.0%; height: 100.0%;">89 boulevard de Magenta NO-SE</div>`)[0];
            popup_d321f7753e68447682aa24e5107fce95.setContent(html_7bf616dd1bf140df8492cfa7450b3076);
        

        circle_37cf8b85dbfc4008bf562e97078656fc.bindPopup(popup_d321f7753e68447682aa24e5107fce95)
        ;

        
    
    
            var circle_db7c9e281ccd4993b48ccec081acadf7 = L.circle(
                [48.86461, 2.40969],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_a975b4d669ac46ee86813d74f8c0234e = L.popup({"maxWidth": "100%"});

        
            var html_d032484cf6c34ddc87dda02817f066a3 = $(`<div id="html_d032484cf6c34ddc87dda02817f066a3" style="width: 100.0%; height: 100.0%;">Face au 4 avenue de la porte de Bagnolet O-E</div>`)[0];
            popup_a975b4d669ac46ee86813d74f8c0234e.setContent(html_d032484cf6c34ddc87dda02817f066a3);
        

        circle_db7c9e281ccd4993b48ccec081acadf7.bindPopup(popup_a975b4d669ac46ee86813d74f8c0234e)
        ;

        
    
    
            var circle_b578ede898c64b10af8918fb6ad774b0 = L.circle(
                [48.84201, 2.36729],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_5ffb0b7309d44023a3a46a7836a88918 = L.popup({"maxWidth": "100%"});

        
            var html_9263d4037289453bb1e918b088563715 = $(`<div id="html_9263d4037289453bb1e918b088563715" style="width: 100.0%; height: 100.0%;">Totem 85 quai d'Austerlitz SE-NO</div>`)[0];
            popup_5ffb0b7309d44023a3a46a7836a88918.setContent(html_9263d4037289453bb1e918b088563715);
        

        circle_b578ede898c64b10af8918fb6ad774b0.bindPopup(popup_5ffb0b7309d44023a3a46a7836a88918)
        ;

        
    
    
            var circle_182096a3af09416f8de4b25f6f6e6e6a = L.circle(
                [48.83068, 2.35348],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_2d484fae540547f1b9157f682ca98649 = L.popup({"maxWidth": "100%"});

        
            var html_39f213659fde47189022e2da6cb69aac = $(`<div id="html_39f213659fde47189022e2da6cb69aac" style="width: 100.0%; height: 100.0%;">10 boulevard Auguste Blanqui NE-SO</div>`)[0];
            popup_2d484fae540547f1b9157f682ca98649.setContent(html_39f213659fde47189022e2da6cb69aac);
        

        circle_182096a3af09416f8de4b25f6f6e6e6a.bindPopup(popup_2d484fae540547f1b9157f682ca98649)
        ;

        
    
    
            var circle_8ebff4f02f5b4f96acae705b10cf1693 = L.circle(
                [48.88926, 2.37472],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.00000000000006, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_5b11605e9cc645bc8ee94afd02b6fcf7 = L.popup({"maxWidth": "100%"});

        
            var html_4bb0e7d01ce44788bfedd4c4b0048497 = $(`<div id="html_4bb0e7d01ce44788bfedd4c4b0048497" style="width: 100.0%; height: 100.0%;">87 avenue de Flandre NE-SO</div>`)[0];
            popup_5b11605e9cc645bc8ee94afd02b6fcf7.setContent(html_4bb0e7d01ce44788bfedd4c4b0048497);
        

        circle_8ebff4f02f5b4f96acae705b10cf1693.bindPopup(popup_5b11605e9cc645bc8ee94afd02b6fcf7)
        ;

        
    
    
            var circle_5e030487cef54dfa86ed4e90172b17ec = L.circle(
                [48.82024, 2.35902],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 499.99999999999994, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_4f7fa37cad9b47f4a2f1424ba5eef55f = L.popup({"maxWidth": "100%"});

        
            var html_f37df7d3191b49c9ae4337f242d979f7 = $(`<div id="html_f37df7d3191b49c9ae4337f242d979f7" style="width: 100.0%; height: 100.0%;">180 avenue d'Italie N-S</div>`)[0];
            popup_4f7fa37cad9b47f4a2f1424ba5eef55f.setContent(html_f37df7d3191b49c9ae4337f242d979f7);
        

        circle_5e030487cef54dfa86ed4e90172b17ec.bindPopup(popup_4f7fa37cad9b47f4a2f1424ba5eef55f)
        ;

        
    
    
            var circle_1aab561c97be44e7bea467d4e8c10c76 = L.circle(
                [48.88529, 2.32666],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "red", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_67a25d5f710b4d03a3ce7abaa2dc8a1c = L.popup({"maxWidth": "100%"});

        
            var html_0bb60b7ddc5b4f4f825f60525a0a1ad2 = $(`<div id="html_0bb60b7ddc5b4f4f825f60525a0a1ad2" style="width: 100.0%; height: 100.0%;">20 Avenue de Clichy NO-SE</div>`)[0];
            popup_67a25d5f710b4d03a3ce7abaa2dc8a1c.setContent(html_0bb60b7ddc5b4f4f825f60525a0a1ad2);
        

        circle_1aab561c97be44e7bea467d4e8c10c76.bindPopup(popup_67a25d5f710b4d03a3ce7abaa2dc8a1c)
        ;

        
    
    
            var circle_c0434d0857404569b17a971188b55637 = L.circle(
                [48.83511, 2.33338],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_7ba7236a18d34fe8ae6397bb0c158c00 = L.popup({"maxWidth": "100%"});

        
            var html_b1e5dd0fd578403d8edb7bd3f20b077d = $(`<div id="html_b1e5dd0fd578403d8edb7bd3f20b077d" style="width: 100.0%; height: 100.0%;">97 avenue Denfert Rochereau SO-NE</div>`)[0];
            popup_7ba7236a18d34fe8ae6397bb0c158c00.setContent(html_b1e5dd0fd578403d8edb7bd3f20b077d);
        

        circle_c0434d0857404569b17a971188b55637.bindPopup(popup_7ba7236a18d34fe8ae6397bb0c158c00)
        ;

        
    
    
            var circle_ccc942b9f4924580a799cdbc65ebc3fd = L.circle(
                [48.87451, 2.29215],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_684c45e0137d4aa98f4fd05a87bde1f4 = L.popup({"maxWidth": "100%"});

        
            var html_df9dc061f7c14aa5906648cec3fdca40 = $(`<div id="html_df9dc061f7c14aa5906648cec3fdca40" style="width: 100.0%; height: 100.0%;">7 avenue de la Grande Armée NO-SE</div>`)[0];
            popup_684c45e0137d4aa98f4fd05a87bde1f4.setContent(html_df9dc061f7c14aa5906648cec3fdca40);
        

        circle_ccc942b9f4924580a799cdbc65ebc3fd.bindPopup(popup_684c45e0137d4aa98f4fd05a87bde1f4)
        ;

        
    
    
            var circle_671a410f94144e66911cb6e1ac44f0be = L.circle(
                [48.877726, 2.354926],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.00000000000006, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_1a8be5430a99469bbe2c8d0f474f697b = L.popup({"maxWidth": "100%"});

        
            var html_a931bebd3c1041d890427f107da458a6 = $(`<div id="html_a931bebd3c1041d890427f107da458a6" style="width: 100.0%; height: 100.0%;">102 boulevard de Magenta SE-NO</div>`)[0];
            popup_1a8be5430a99469bbe2c8d0f474f697b.setContent(html_a931bebd3c1041d890427f107da458a6);
        

        circle_671a410f94144e66911cb6e1ac44f0be.bindPopup(popup_1a8be5430a99469bbe2c8d0f474f697b)
        ;

        
    
    
            var circle_4bdeaec977d44eb8942fd093866d2393 = L.circle(
                [48.881626, 2.281203],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_485244cb95be4d4198628c8ca1edd266 = L.popup({"maxWidth": "100%"});

        
            var html_b8bd3e2cab854feca52e6784e1bbc0d4 = $(`<div id="html_b8bd3e2cab854feca52e6784e1bbc0d4" style="width: 100.0%; height: 100.0%;">Face au 16 avenue de la  Porte des Ternes O-E</div>`)[0];
            popup_485244cb95be4d4198628c8ca1edd266.setContent(html_b8bd3e2cab854feca52e6784e1bbc0d4);
        

        circle_4bdeaec977d44eb8942fd093866d2393.bindPopup(popup_485244cb95be4d4198628c8ca1edd266)
        ;

        
    
    
            var circle_65663faed23c43f7a8449dadea6576b1 = L.circle(
                [48.890457, 2.368852],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_d1be5e3fe68341eb868f8774541fcee6 = L.popup({"maxWidth": "100%"});

        
            var html_da84000c7d0d461bbf26805da97e02b7 = $(`<div id="html_da84000c7d0d461bbf26805da97e02b7" style="width: 100.0%; height: 100.0%;">Face 104 rue d'Aubervilliers S-N</div>`)[0];
            popup_d1be5e3fe68341eb868f8774541fcee6.setContent(html_da84000c7d0d461bbf26805da97e02b7);
        

        circle_65663faed23c43f7a8449dadea6576b1.bindPopup(popup_d1be5e3fe68341eb868f8774541fcee6)
        ;

        
    
    
            var circle_bf7ff55e339b443bb7e29b857f452447 = L.circle(
                [48.86461, 2.40969],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.00000000000006, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_7d4dc3312ef94c1d902b4091cecd73ba = L.popup({"maxWidth": "100%"});

        
            var html_699b402cb2284e5ca1546eca58b51f5f = $(`<div id="html_699b402cb2284e5ca1546eca58b51f5f" style="width: 100.0%; height: 100.0%;">Face au 4 avenue de la porte de Bagnolet E-O</div>`)[0];
            popup_7d4dc3312ef94c1d902b4091cecd73ba.setContent(html_699b402cb2284e5ca1546eca58b51f5f);
        

        circle_bf7ff55e339b443bb7e29b857f452447.bindPopup(popup_7d4dc3312ef94c1d902b4091cecd73ba)
        ;

        
    
    
            var circle_79dcfe32c48040a7991bdb9ed30e062f = L.circle(
                [48.84223, 2.36811],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_9d3bcbd8d0a040f99c49b60e7f4df52f = L.popup({"maxWidth": "100%"});

        
            var html_666e5bd4589444e6a099d8b22707ae30 = $(`<div id="html_666e5bd4589444e6a099d8b22707ae30" style="width: 100.0%; height: 100.0%;">Pont Charles De Gaulle SO-NE</div>`)[0];
            popup_9d3bcbd8d0a040f99c49b60e7f4df52f.setContent(html_666e5bd4589444e6a099d8b22707ae30);
        

        circle_79dcfe32c48040a7991bdb9ed30e062f.bindPopup(popup_9d3bcbd8d0a040f99c49b60e7f4df52f)
        ;

        
    
    
            var circle_f68321274b3841bdbfa8b532b99fa640 = L.circle(
                [48.891215, 2.38573],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 499.99999999999994, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_7a6507d26b4749f3a5dd97f2988bf92e = L.popup({"maxWidth": "100%"});

        
            var html_ed724866813d4c08894d427ab2fb61dc = $(`<div id="html_ed724866813d4c08894d427ab2fb61dc" style="width: 100.0%; height: 100.0%;">Face au 48 quai de la marne SO-NE</div>`)[0];
            popup_7a6507d26b4749f3a5dd97f2988bf92e.setContent(html_ed724866813d4c08894d427ab2fb61dc);
        

        circle_f68321274b3841bdbfa8b532b99fa640.bindPopup(popup_7a6507d26b4749f3a5dd97f2988bf92e)
        ;

        
    
    
            var circle_6a34f7cd6a624d60843f3285df37a354 = L.circle(
                [48.830331, 2.400551],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_d6c86f0b144f4002b93942de90cb84dc = L.popup({"maxWidth": "100%"});

        
            var html_201e845fa3364b7faf27d5b7e43c806a = $(`<div id="html_201e845fa3364b7faf27d5b7e43c806a" style="width: 100.0%; height: 100.0%;">Face au 8 avenue de la porte de Charenton NO-SE</div>`)[0];
            popup_d6c86f0b144f4002b93942de90cb84dc.setContent(html_201e845fa3364b7faf27d5b7e43c806a);
        

        circle_6a34f7cd6a624d60843f3285df37a354.bindPopup(popup_d6c86f0b144f4002b93942de90cb84dc)
        ;

        
    
    
            var circle_f1b740ca310044aa839c8d95d8be98f6 = L.circle(
                [48.86462, 2.31444],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_d8b0befa1af34486b1a20c18731ffe8a = L.popup({"maxWidth": "100%"});

        
            var html_a323a07c8ccd40caa650044ef21c1425 = $(`<div id="html_a323a07c8ccd40caa650044ef21c1425" style="width: 100.0%; height: 100.0%;">Totem Cours la Reine O-E</div>`)[0];
            popup_d8b0befa1af34486b1a20c18731ffe8a.setContent(html_a323a07c8ccd40caa650044ef21c1425);
        

        circle_f1b740ca310044aa839c8d95d8be98f6.bindPopup(popup_d8b0befa1af34486b1a20c18731ffe8a)
        ;

        
    
    
            var circle_a6281320e9a941998c92cef01f224beb = L.circle(
                [48.86155, 2.37407],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_2b135a826787409aad7de8462e8f50ce = L.popup({"maxWidth": "100%"});

        
            var html_d4a95c0dec2946a7912ddc7b7bbf4420 = $(`<div id="html_d4a95c0dec2946a7912ddc7b7bbf4420" style="width: 100.0%; height: 100.0%;">72 boulevard Voltaire NO-SE</div>`)[0];
            popup_2b135a826787409aad7de8462e8f50ce.setContent(html_d4a95c0dec2946a7912ddc7b7bbf4420);
        

        circle_a6281320e9a941998c92cef01f224beb.bindPopup(popup_2b135a826787409aad7de8462e8f50ce)
        ;

        
    
    
            var circle_78aae230bd37485693f6df364c44ea3b = L.circle(
                [48.86057, 2.38886],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_c211d8c6dbad4f6e9dedd21febe4416a = L.popup({"maxWidth": "100%"});

        
            var html_17aceb11316f4bc7ab3a148afbcdfd81 = $(`<div id="html_17aceb11316f4bc7ab3a148afbcdfd81" style="width: 100.0%; height: 100.0%;">26 boulevard de Ménilmontant SE-NO</div>`)[0];
            popup_c211d8c6dbad4f6e9dedd21febe4416a.setContent(html_17aceb11316f4bc7ab3a148afbcdfd81);
        

        circle_78aae230bd37485693f6df364c44ea3b.bindPopup(popup_c211d8c6dbad4f6e9dedd21febe4416a)
        ;

        
    
    
            var circle_59b694fb226c4ee7bc1e4507a6ea8121 = L.circle(
                [48.829523, 2.38699],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_9399aca48c744e8c9dbe8391f48e4078 = L.popup({"maxWidth": "100%"});

        
            var html_3e1f1b9d42e84ff0ba65e397d812b7ab = $(`<div id="html_3e1f1b9d42e84ff0ba65e397d812b7ab" style="width: 100.0%; height: 100.0%;">Face au 70 quai de Bercy S-N</div>`)[0];
            popup_9399aca48c744e8c9dbe8391f48e4078.setContent(html_3e1f1b9d42e84ff0ba65e397d812b7ab);
        

        circle_59b694fb226c4ee7bc1e4507a6ea8121.bindPopup(popup_9399aca48c744e8c9dbe8391f48e4078)
        ;

        
    
    
            var circle_5912d1eb26ad4daa8f6ae6e107331d19 = L.circle(
                [48.829523, 2.38699],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_0e95f433b371403db8c0ca3a9c8d5541 = L.popup({"maxWidth": "100%"});

        
            var html_23063ead90c145d5aad3310bcac2e343 = $(`<div id="html_23063ead90c145d5aad3310bcac2e343" style="width: 100.0%; height: 100.0%;">Face au 70 quai de Bercy N-S</div>`)[0];
            popup_0e95f433b371403db8c0ca3a9c8d5541.setContent(html_23063ead90c145d5aad3310bcac2e343);
        

        circle_5912d1eb26ad4daa8f6ae6e107331d19.bindPopup(popup_0e95f433b371403db8c0ca3a9c8d5541)
        ;

        
    
    
            var circle_6906461a36e443c39ed43b100bc97eab = L.circle(
                [48.83848, 2.37587],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_81a0b83ae87e48c08876bab290a1af60 = L.popup({"maxWidth": "100%"});

        
            var html_d284990667c949a8bcd5a87568c06a2f = $(`<div id="html_d284990667c949a8bcd5a87568c06a2f" style="width: 100.0%; height: 100.0%;">Pont de Bercy SO-NE</div>`)[0];
            popup_81a0b83ae87e48c08876bab290a1af60.setContent(html_d284990667c949a8bcd5a87568c06a2f);
        

        circle_6906461a36e443c39ed43b100bc97eab.bindPopup(popup_81a0b83ae87e48c08876bab290a1af60)
        ;

        
    
    
            var circle_2449b0455f4349cea48d7058f23720a1 = L.circle(
                [48.86288, 2.31179],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 499.99999999999994, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_cd3843b481034e6285731981f09086d8 = L.popup({"maxWidth": "100%"});

        
            var html_369c20f49a1647c2bef29dbf3b4e57dc = $(`<div id="html_369c20f49a1647c2bef29dbf3b4e57dc" style="width: 100.0%; height: 100.0%;">Quai d'Orsay E-O</div>`)[0];
            popup_cd3843b481034e6285731981f09086d8.setContent(html_369c20f49a1647c2bef29dbf3b4e57dc);
        

        circle_2449b0455f4349cea48d7058f23720a1.bindPopup(popup_cd3843b481034e6285731981f09086d8)
        ;

        
    
    
            var circle_5fa37d257f7b41ff8df864228e46b4ba = L.circle(
                [48.85013, 2.35423],
                {"bubblingMouseEvents": true, "color": "grey", "dashArray": null, "dashOffset": null, "fill": true, "fillColor": "green", "fillOpacity": 0.2, "fillRule": "evenodd", "lineCap": "round", "lineJoin": "round", "opacity": 1.0, "radius": 500.0, "stroke": true, "weight": 3}
            ).addTo(map_2c04939eeab341fa821676e86dba57de);
        
    
        var popup_ef12024a7987467b8dfd65189aaf3a9f = L.popup({"maxWidth": "100%"});

        
            var html_a127669b2e3c472dba8e6d4f0bec0f86 = $(`<div id="html_a127669b2e3c472dba8e6d4f0bec0f86" style="width: 100.0%; height: 100.0%;">27 quai de la Tournelle NO-SE</div>`)[0];
            popup_ef12024a7987467b8dfd65189aaf3a9f.setContent(html_a127669b2e3c472dba8e6d4f0bec0f86);
        

        circle_5fa37d257f7b41ff8df864228e46b4ba.bindPopup(popup_ef12024a7987467b8dfd65189aaf3a9f)
        ;

        
    
</script><!--/html_preserve-->
{{< /rawhtml >}}

