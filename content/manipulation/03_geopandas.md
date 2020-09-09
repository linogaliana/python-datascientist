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
title: "Pratique de pandas: un exemple complet"
date: 2020-07-09T13:00:00Z
draft: false
weight: 100
output: 
  html_document:
    keep_md: true
    self_contained: true
slug: geopandas
---





Dans ce tutoriel, nous allons utiliser:

* [Réseau de pistes cyclables de la ville de Paris](https://opendata.paris.fr/explore/dataset/reseau-cyclable/table/?disjunctive.typologie_simple&disjunctive.bidirectionnel&disjunctive.statut&disjunctive.sens_velo&disjunctive.voie&disjunctive.arrdt&disjunctive.bois&disjunctive.position&disjunctive.circulation&disjunctive.piste&disjunctive.couloir_bus&disjunctive.type_continuite&disjunctive.reseau&basemap=jawg.streets&location=12,48.85943,2.3493)
* [Carte des limites administratives françaises]()

La représentation des données, notamment la cartographie, est présentée plus
amplement dans la partie [visualiser](visualiser). 


```python
import geopandas as gpd
```


## Données spatiales: quelle différence avec des données traditionnelles ?

Par rapport à un DataFrame standard, un objet `geopandas` comporte
une colonne supplémentaire: `geometry`. Elle stocke les contours des
objets géographiques. Un objet `geopandas` hérite des propriétés d'un 
DataFrame pandas mais propose des méthodes adaptées au traitement des données
spatiales


## Importer des données spatiales

### Préliminaire: récupérer les découpages territoriaux

Les données des limites administratives demandent un peu de travail pour être
importées car elles sont zippées. Le code suivant, dont les 
détails apparaîtront plus clairs après la lecture de la partie
*[webscraping](webscraping)* permet

1. Télécharger les données avec `requests` dans un dossier temporaire
2. Les dézipper avec le module `zipfile`

La fonction suivante automatise un peu le processus:


```python
import requests
import tempfile
import zipfile

url = 'https://www.data.gouv.fr/fr/datasets/r/07b7c9a2-d1e2-4da6-9f20-01a7b72d4b12'
temporary_location = tempfile.gettempdir()

def download_unzip(url, dirname = tempfile.gettempdir(), destname = "borders"):
  myfile = requests.get(url)
  open(dirname + '/' + destname + '.zip', 'wb').write(myfile.content)
  with zipfile.ZipFile(dirname + '/' + destname + '.zip', 'r') as zip_ref:
      zip_ref.extractall(dirname + '/' + destname)
```

Les découpages communaux exploités ici sont issus d'*open street map*. 

