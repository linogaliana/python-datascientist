---
title: "Partie 3: modéliser"
date: 2020-10-14T13:00:00Z
draft: false
weight: 25
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

Pour caricaturer, l’économétrie s’attache à comprendre la causalité des certaines variables sur une autre donc s'attache principalement à l'estimation des paramètres alors que le Machine Learning se focalise sur un simple objectif prédictif en exploitant les relations de corrélations entre les variables.

## Panorama d'un éco-système vaste

Grâce aux principaux packages de Machine Learning (`scikit`), Deep Learning (`keras`, `pytorch`, `TensorFlow`...) et économétrie  (`statsmodels`), la modélisation est extrêmement simplifiée. Cela ne doit pas faire oublier l'importance de la structuration et de la préparation des données. Souvent, l'étape la plus cruciale est le choix du modèle le plus adapté à la structure du modèle. L'aide suivante, issue de l'aide de `scikit`, concernant les modèles de Machine Learning peut déjà donner de premiers enseignements sur les différentes familles de modèles:

L'aide-mémoire suivante peut aider à se diriger dans la large gamme des modèles de `scikit-learn`: 

![](https://scikit-learn.org/stable/_static/ml_map.png)


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


## Références

Athey, S., & Imbens, G. W. (2019). Machine learning methods economists should know about, arxiv.