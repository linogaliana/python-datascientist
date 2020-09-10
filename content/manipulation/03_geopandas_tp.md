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

1. Utiliser la fonction `download_unzip` avec l'url <'https://www.data.gouv.fr/fr/datasets/r/07b7c9a2-d1e2-4da6-9f20-01a7b72d4b12'>
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


```python
download_unzip(url)
communes_borders = gpd.read_file(temporary_location + "/borders/communes-20190101.json")
communes_borders.head()
communes_borders.crs
```



```python
communes_borders[communes_borders.insee.str.startswith("12")].plot()
```


```python
communes_borders[communes_borders.insee.str.startswith("75")].plot()
```

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



```python
arrondissements = gpd.read_file("https://opendata.paris.fr/explore/dataset/arrondissements/download/?format=geojson&timezone=Europe/Berlin&lang=fr")
arrondissements.plot()
communes_borders.crs == arrondissements.crs
arrondissements = arrondissements.rename(columns = {"c_arinsee": "insee"})
data_paris = communes_borders[~communes_borders.insee.str.startswith("75")].append(arrondissements)
```


```python
data_paris['dep'] = data_paris.insee.str[:2]
data_paris[data_paris['dep'].isin(['75','92','93','94'])].plot()
```



