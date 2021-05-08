---
title: "Partie 3: modéliser"
date: 2020-10-14T13:00:00Z
draft: false
weight: 35
slug: "modelisation"
type: book
summary: |
  La facilité à modéliser des processus très diverses a grandement 
  participé au succès de Python. La librairie scikit offre une
  grande variété de modèles et permet ainsi d'avoir un code
  fonctionnel en très peu de temps.
icon: square-root-alt
icon_pack: fas
---


## Principes

Un modèle statistique est une construction mathématique qui formalise une loi
ayant généré les données. La différence principale entre machine learning et économétrie
est dans le degré de structure imposé par le modélisateur. 

Dans le premier cas,
la structure imposée par le *data scientist* est minimale et ce sont plutôt
les algorithmes qui, sur des critères de performance statistique, vont
déterminer une loi mathématique qui correspond aux données. En économétrie,
les hypothèses de structure des lois sont plus fortes (même dans un cadre semi ou non-paramétrique) et sont plus souvent imposées
par le modélisateur.

L'adoption du Machine Learning dans la littérature économique a été longue car la structuration des données est souvent le pendant empirique d'hypothèses théoriques sur le comportement des acteurs ou des marchés (Athey and Imbens, 2019). 

Pour caricaturer, l’économétrie s’attache à comprendre la causalité des certaines variables sur une autre donc s'attache principalement à l'estimation des paramètres alors que le Machine Learning se focalise sur un simple objectif prédictif en exploitant les relations de corrélations entre les variables.

## Panorama d'un éco-système vaste

Grâce aux principaux packages de Machine Learning (`scikit`), Deep Learning (`keras`, `pytorch`, `TensorFlow`...) et économétrie  (`statsmodels`), la modélisation est extrêmement simplifiée. Cela ne doit pas faire oublier l'importance de la structuration et de la préparation des données. Souvent, l'étape la plus cruciale est le choix du modèle le plus adapté à la structure du modèle. L'aide suivante, issue de l'aide de `scikit`, concernant les modèles de Machine Learning peut déjà donner de premiers enseignements sur les différentes familles de modèles:

L'aide-mémoire suivante peut aider à se diriger dans la large gamme des modèles de `scikit-learn`: 

![](https://scikit-learn.org/stable/_static/ml_map.png)


On distingue généralement deux types de méthodes, selon qu'on dispose d'information, dans l'échantillon
d'apprentissage, sur les *y* (on utilisera parfois le terme *label*) :

* apprentissage supervisé: la valeur cible est connue et peut-être utilisée pour évaluer la qualité d'un modèle
* apprentissage non supervisé: la valeur cible est inconnue et ce sont des critères statistiques qui vont amener
à sélectionner la structure de données la plus plausible. 


## Contenu de la partie:

Plan prévisionnel:

* Préparation des données: Feature extraction, normalization, constitution d'échantillons,
Model selection and evaluation
https://scikit-learn.org/stable/modules/preprocessing.html#preprocessing
* Régression: régression linéaire, logistique, lasso/ridge/elasticnet
https://scikit-learn.org/stable/supervised_learning.html#supervised-learning
* Classification: logit, SVM, arbres de décision
https://scikit-learn.org/stable/supervised_learning.html#supervised-learning
* Réduction dimension: PCA
* Clustering: kmeans, hiearchical clustering

Autres champs:
* maximum vraisemblance
* stats bayésiennes
* semi et non paramétrique: méthodes noyaux, GAM

## Données

La plupart des exemples de cette partie s'appuient sur les résultats des
élections US 2020 au niveau comtés. Plusieurs bases sont utilisées pour 
cela:

* Les données électorales sont une reconstruction à partir des données du MIT election lab
proposées sur `Github` par [@tonmcg](https://github.com/tonmcg/US_County_Level_Election_Results_08-20)
ou directement disponibles sur le site du [MIT Election Lab](https://electionlab.mit.edu/data)
* Les données socioéconomiques (population, données de revenu et de pauvreté, 
taux de chômage, variables d'éducation) proviennent de l'USDA ([source](https://www.ers.usda.gov/data-products/county-level-data-sets/))
* Le *shapefile* vient des données du *Census Bureau*. Le fichier peut
être téléchargé directement depuis cet url:
<https://www2.census.gov/geo/tiger/GENZ2019/shp/cb_2019_us_county_20m.zip>

Le code pour construire une base unique à partir de ces sources diverses
est disponible ci-dessous : 


```{python, eval = FALSE}
import os
import zipfile
import urllib.request
from pathlib import Path

import numpy as np
import pandas as pd
import geopandas as gpd

def download_url(url, save_path):
    with urllib.request.urlopen(url) as dl_file:
        with open(save_path, 'wb') as out_file:
            out_file.write(dl_file.read())
    
Path("data").mkdir(parents=True, exist_ok=True)


download_url("https://www2.census.gov/geo/tiger/GENZ2019/shp/cb_2019_us_county_20m.zip", "data/shapefile")
with zipfile.ZipFile("data/shapefile", 'r') as zip_ref:
    zip_ref.extractall("data/counties")

shp = gpd.read_file("data/counties/cb_2019_us_county_20m.shp")
shp = shp[~shp["STATEFP"].isin(["02", "69", "66", "78", "60", "72", "15"])]
shp

df_election = pd.read_csv("https://raw.githubusercontent.com/tonmcg/US_County_Level_Election_Results_08-20/master/2020_US_County_Level_Presidential_Results.csv")
df_election.head(2)
population = pd.read_excel("https://www.ers.usda.gov/webdocs/DataFiles/48747/PopulationEstimates.xls?v=290.4", header = 2).rename(columns = {"FIPStxt": "FIPS"})
education = pd.read_excel("https://www.ers.usda.gov/webdocs/DataFiles/48747/Education.xls?v=290.4", header = 4).rename(columns = {"FIPS Code": "FIPS", "Area name": "Area_Name"})
unemployment = pd.read_excel("https://www.ers.usda.gov/webdocs/DataFiles/48747/Unemployment.xls?v=290.4", header = 4).rename(columns = {"fips_txt": "FIPS", "area_name": "Area_Name", "Stabr": "State"})
income = pd.read_excel("https://www.ers.usda.gov/webdocs/DataFiles/48747/PovertyEstimates.xls?v=290.4", header = 4).rename(columns = {"FIPStxt": "FIPS", "Stabr": "State", "Area_name": "Area_Name"})


dfs = [df.set_index(['FIPS', 'State']) for df in [population, education, unemployment, income]]
data_county = pd.concat(dfs, axis=1)
df_election = df_election.merge(data_county.reset_index(), left_on = "county_fips", right_on = "FIPS")
df_election['county_fips'] = df_election['county_fips'].astype(str).str.lstrip('0')
shp['FIPS'] = shp['GEOID'].astype(str).str.lstrip('0')
votes = shp.merge(df_election, left_on = "FIPS", right_on = "county_fips")


df_historical = pd.read_csv('https://dataverse.harvard.edu/api/access/datafile/3641280?gbrecs=false', sep = "\t")
df_historical = df_historical.dropna(subset = ["FIPS"])
df_historical["FIPS"] = df_historical["FIPS"].astype(int)
df_historical['share'] = df_historical['candidatevotes']/df_historical['totalvotes']
df_historical = df_historical[["year", "FIPS", "party", "candidatevotes", "share"]]
df_historical['party'] = df_historical['party'].fillna("other")

df_historical_wide = df_historical.pivot_table(index = "FIPS", values=['candidatevotes',"share"], columns = ["year","party"])
df_historical_wide.columns = ["_".join(map(str, s)) for s in df_historical_wide.columns.values]
df_historical_wide = df_historical_wide.reset_index()
df_historical_wide['FIPS'] = df_historical_wide['FIPS'].astype(str).str.lstrip('0')
votes['FIPS'] = votes['GEOID'].astype(str).str.lstrip('0')
votes = votes.merge(df_historical_wide, on = "FIPS")

color_dict = {"republican": '#FF0000', 'democrats': '#0000FF'}
votes["winner"] =  np.where(votes['votes_gop'] > votes['votes_dem'], 'republican', 'democrats') 
```

{{< list_children >}}


## Références

Athey, S., & Imbens, G. W. (2019). Machine learning methods economists should know about, arxiv.
