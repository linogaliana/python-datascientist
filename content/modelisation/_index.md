---
title: "Partie 3: modéliser"
date: 2020-10-14T13:00:00Z
draft: false
weight: 20
slug: "modelisation"
---

Cette partie du cours illustrera les concepts à partir des jeux de données suivants: 

* [Résultats des élections US 2016 au niveau des comtés](https://public.opendatasoft.com/explore/dataset/usa-2016-presidential-election-by-county/download/?format=geojson&timezone=Europe/Berlin&lang=fr)

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

## Panorama d'un éco-système vaste

Grâce aux principaux packages de Machine Learning (`scikit`), Deep Learning (`keras`, `pytorch`, `TensorFlow`...) et économétrie  (`statsmodels`), la modélisation est extrêmement simplifiée. Cela ne doit pas faire oublier l'importance de la structuration et de la préparation des données. Souvent, l'étape la plus cruciale est le choix du modèle le plus adapté à la structure du modèle. L'aide suivante, issue de l'aide de `scikit`, concernant les modèles de Machine Learning peut déjà donner de premiers enseignements sur les différentes familles de modèles:


![](https://scikit-learn.org/stable/_static/ml_map.png)




## Références

Athey, S., & Imbens, G. W. (2019). Machine learning methods economists should know about, arxiv.