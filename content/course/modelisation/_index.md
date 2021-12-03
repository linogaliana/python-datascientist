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

### Machine Learning ou Econométrie ?

Un modèle statistique est une construction mathématique qui formalise une loi
ayant généré les données. La différence principale entre *machine learning* (ML) et économétrie
est dans le degré de structure imposé par le modélisateur :

- En ML,
la structure imposée par le *data scientist* est minimale et ce sont plutôt
les algorithmes qui, sur des critères de performance statistique, vont
déterminer une loi mathématique qui correspond aux données.

- En économétrie,
les hypothèses de structure des lois sont plus fortes (même dans un cadre semi ou non-paramétrique) et sont plus souvent imposées
par le modélisateur.

L'adoption du Machine Learning dans la littérature économique a été longue car la structuration des données est souvent le pendant empirique d'hypothèses théoriques sur le comportement des acteurs ou des marchés (Athey and Imbens, 2019). 

Pour caricaturer, l’économétrie s’attache à comprendre la causalité de certaines variables sur une autre donc s'attache principalement à l'estimation des paramètres alors que le Machine Learning se focalise sur un simple objectif prédictif en exploitant les relations de corrélations entre les variables.

### Apprentissage supervisé ou non supervisé ?

On distingue généralement deux types de méthodes, selon qu'on dispose d'information, dans l'échantillon
d'apprentissage, sur les valeurs cibles *y* (on utilisera parfois le terme *label*) :

* **apprentissage supervisé** : la valeur cible est connue et peut-être utilisée pour évaluer la qualité d'un modèle 

*Ex : modèles de prédiction du type régression / classification : SVM, kNN, arbres de classification...*

* **apprentissage non supervisé** : la valeur cible est inconnue et ce sont des critères statistiques qui vont amener
à sélectionner la structure de données la plus plausible. 

*Ex : modèles de réduction de dimension ou de clustering (PCA, kmeans...)*

## Panorama d'un éco-système vaste

Grâce aux principaux packages de Machine Learning (`scikit`), Deep Learning (`keras`, `pytorch`, `TensorFlow`...) et économétrie  (`statsmodels`), la modélisation est extrêmement simplifiée. Cela ne doit pas faire oublier l'importance de la structuration et de la préparation des données. Souvent, l'étape la plus cruciale est le choix du modèle le plus adapté à la structure des données.

L'aide-mémoire suivante, issue de l'aide de `scikit-learn`, concernant les modèles de Machine Learning peut déjà donner de premiers enseignements sur les différentes familles de modèles:

![](https://scikit-learn.org/stable/_static/ml_map.png)
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

```{python testchunk, comment='', echo=FALSE, class.output = "python"}
with open('get_data.py', 'r') as f:
  for line in f:
    if not line.startswith("## ----"):
      print(line, end='')
```

## Contenu de la partie

{{< list_children >}}

Autres champs:
* maximum vraisemblance
* stats bayésiennes
* semi et non paramétrique: méthodes noyaux, GAM

## Références

Athey, S., & Imbens, G. W. (2019). Machine learning methods economists should know about, arxiv.