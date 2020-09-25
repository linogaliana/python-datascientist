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
title: "Pratique de geopandas: données vélib"
date: 2020-07-09T13:00:00Z
draft: false
weight: 50
output: 
  html_document:
    keep_md: true
    self_contained: true
slug: geopandasTP
---








# Lire et enrichir des données spatiales

Dans cette partie, nous utiliserons la fonction suivante, qui facilite 
le téléchargement et le dézippage des données proposées sur `data.gouv`:


```python
import requests
import tempfile
import zipfile

temporary_location = tempfile.gettempdir()

def download_unzip(url, dirname = tempfile.gettempdir(), destname = "borders"):
  myfile = requests.get(url)
  open(dirname + '/' + destname + '.zip', 'wb').write(myfile.content)
  with zipfile.ZipFile(dirname + '/' + destname + '.zip', 'r') as zip_ref:
      zip_ref.extractall(dirname + '/' + destname)
```



**Exercice 1: lire et explorer la structure de fichiers géographiques**

1. Utiliser la fonction `download_unzip` avec l'url <https://www.data.gouv.fr/fr/datasets/r/07b7c9a2-d1e2-4da6-9f20-01a7b72d4b12>
pour télécharger les données communales.
2. Importer le fichier avec la package `geopandas`
(si vous avez laissé les paramètres par défaut,
le fichier devrait
être à l'emplacement `temporary_location + "/borders/communes-20190101.json"`).
Vous pouvez le nommer `communes_borders`
3. Regarder les premières lignes des données. Identifier la différence avec
un DataFrame standard. 
4. Afficher l'attribut `crs` de `communes_borders`. Ce dernier contrôle la
transformation de l'espace tridimensionnel terrestre en une surface plane. 
5. Afficher les communes de l'Aveyron (département 12) et utiliser la méthode
`plot`
6. Réprésenter la carte de Paris : quel est le problème ?








En effet, on ne dispose ainsi pas des limites des arrondissements parisiens, ce
qui appauvrit grandement la carte de Paris. On peut les récupérer directement 
depuis le site d'open data du grand Paris:


**Exercice 2: compléter des données spatiales issues de sources différentes**

1. Importer les données de découpage des arrondissements parisiens à l'adresse
<https://opendata.paris.fr/explore/dataset/arrondissements/download/?format=geojson&timezone=Europe/Berlin&lang=fr>
2. Vérifier sur une carte que les découpages des arrondissements sont bien présents
2. Vérifier l'attribut `crs`. Est-il cohérent avec celui des données communales ?
3. Retirer Paris du jeu de données communales et utiliser les arrondissements
pour enrichir (nommer l'objet obtenu `data_borders`). Ici, on peut ne pas se
soucier de la variable commune de superficie aux niveaux différents car on
va la recréer. En revanche, renommer la variable `c_arinsee` en `insee` avec
la méthode `rename` et faire attention aux types des variables
4. Créer une variable `dep` stockant le département
4. Représenter les communes de la petite couronne parisienne (75, 92, 93, 94)






# Utiliser des données géographiques comme des couches
graphiques

Souvent, le découpage communal ne sert qu'en fond de cartes, pour donner des
repères. En complément de celui-ci, on peut désirer exploiter
un autre jeu de données. On va partir des données de localisation des
stations velib, 
disponibles [sur le site d'open data de la ville de Paris](https://opendata.paris.fr/explore/dataset/velib-emplacement-des-stations/table/) et 
requêtables directement par l'url
<https://opendata.paris.fr/explore/dataset/velib-emplacement-des-stations/download/?format=geojson&timezone=Europe/Berlin&lang=fr>


**Exercice 3: importer et explorer les données velib**

1. Importer les données velib sous le nom station
2. Représenter sur une carte les 100 stations les plus importantes. Vous pouvez également afficher le fonds de carte des arrondissements en ne gardant que les départements de la petite couronne (75, 92, 93, 94).
Cette [page](https://geopandas.org/mapping.html#maps-with-layers) peut vous aider pour afficher plusieurs couches à la fois (nous irons plus loin lors du chapitre XXXX). 
3. (optionnel) Afficher également les réseaux de transport en communs, disponibles [ici](https://data.iledefrance-mobilites.fr/explore/dataset/traces-du-reseau-ferre-idf/map/?location=7,48.69717,2.33167&basemap=jawg.streets). L'url à requêter est
<https://data.iledefrance-mobilites.fr/explore/dataset/traces-du-reseau-ferre-idf/download/?format=geojson&timezone=Europe/Berlin&lang=fr>








# Jointures spatiales

Les jointures attributaires fonctionnent comme avec un DataFrame `pandas`. Pour conserver un objet spatial *in fine*, il faut faire attention à utiliser en premier (base de gauche) l'objet `geopandas`. En revanche, l'un des intérêts des objets geopandas est qu'on peut également faire une jointure sur la dimension spatiale.

La documentation à laquelle se référer est [ici](https://geopandas.org/mergingdata.html#spatial-joins). 

**Exercice 4: Associer les stations aux communes et arrondissements auxquels ils appartiennent**

1. Faire une jointure spatiale pour enrichir les données de stations d'informations sur l'environnement.
Appeler cet objet `stations_info`
2. Représenter la carte des stations du 19e arrondissement (s'aider de la variable `c_ar`).
Vous pouvez mettre en fond de carte les arrondissements parisiens. 
3. Compter le nombre de stations velib et le nombre de places velib par arrondissement ou communes (pour vous aider, vous pouvez compléter vos connaissances avec [ce tutoriel](https://pandas.pydata.org/docs/getting_started/intro_tutorials/06_calculate_statistics.html)). Représenter sur une carte chacune des informations
4. Représenter les mêmes informations mais en densité (diviser par la surface de l'arrondissement ou commune en km2)









**Exercice 5 (optionnel): Relier distance au métro et capacité d'une station**

Une aide [ici](https://pysal.org/scipy2019-intermediate-gds/deterministic/gds1-relations.html#how-about-nearest-neighbor-joins)

1. Relier chaque station velib à la station de transport en commun la plus proche. Vous pouvez
prendre les localisations des stations [ici](https://data.iledefrance-mobilites.fr/explore/dataset/traces-du-reseau-ferre-idf/download/?format=geojson&timezone=Europe/Berlin&lang=fr)
2. Quelle ligne de transport est à proximité du plus de velib ?
3. Calculer la distance de chaque station à la ligne de métro la plus proche. Faire un nuage de points reliant distance au métro et nombre de places en stations





