---
title: Python pour les data scientists et économistes
type: book  # Do not modify.
toc: true
# Title for the menu link if you wish to use a shorter link title, otherwise remove this option.
linktitle: Homepage
---

Ce cours rassemble l'ensemble du contenu du cours 
*Python pour les data scientists et économistes* que je donne 
à l'[ENSAE](https://www.ensae.fr/courses/python-pour-le-data-scientist-pour-leconomiste/)


Le langage `Python` est récemment devenu, dans le monde académique comme
sur le marché du travail, un outil indispensable pour le traitement de données. 
La richesse de ce langage permet de l'utiliser dans toutes les phases
du traitement de la donnée, de sa récupération et structuration à partir de 
sources diverses à sa valorisation. 
Ce cours introduit différents outils qui permettent de mettre en relation
des données et des théories grâce à `Python`. 

## Reproductibilité

Ce cours permet, par la même occasion, de donner une place centrale à 
la notion de reproductibilité. Cette exigence se traduit de diverses
manières dans cet enseignement, en particulier en insistant sur un
outil indispensable pour favoriser le partage de codes informatiques,
à savoir `Git`. 

L'ensemble du contenu du site *web* est reproductible dans des environnements
informatiques divers. Il est bien-sûr possible de copier-coller les morceaux
de code présents dans ce site. Cette méthode montrant rapidement ses limites, 
le site présente un certain nombre de boutons disponibles sur diverses
pages *web*.

Sur l'ensemble du site web,
il est possible de cliquer sur la petite icone
{{< githubrepo >}}
pour être redirigé vers le dépôt `Github` associé à ce cours. 



Pour visualiser sous une forme plus
ergonomique les notebooks (fichiers `.ipynb`)
que ne le permet ce site *web*, vous trouverez
parfois des liens
[![nbviewer](https://img.shields.io/badge/Visualize-nbviewer-blue?logo=Jupyter)](https://nbviewer.jupyter.org/github/linogaliana/python-datascientist/tree/master)
qui utilisent
[nbviewer](https://github.com/jupyter/nbviewer) une application de visualisation
dédiée aux jupyter notebooks.

Des environnements temporaires d'exécution des notebooks sont proposés
avec les icones suivantes 
[![Onyxia](https://img.shields.io/badge/launch-onyxia-brightgreen)](https://datalab.sspcloud.fr/my-lab/catalogue/inseefrlab-helm-charts-datascience/jupyter/deploiement?resources.requests.memory=4096Mi)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/linogaliana/python-datascientist/master)
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](http://colab.research.google.com/github/linogaliana/python-datascientist/blob/master)

## Architecture du site web


Vous pouvez naviguer dans l'architecture du site via la table des matières
ou par les liens vers le contenu antérieur ou postérieur à la fin de chaque
page. 

## Objectif du cours

Le but de ce cours est de rendre autonome sur l'utilisation de Python
dans un contexte de travail de *data scientist* ou de
*social scientist* (économie, sociologie, géographie...). Autrement dit, 
il présuppose qu'on désire faire un usage intense
de données dans un cadre statistique rigoureux.
Nous partirons de l'hypothèse que les notions de statistiques et d'économétrie
pour lesquels nous verrons des applications informatiques sont connues. 
La facilité avec laquelle il est possible de construire des modèles complexes
avec `Python` peut laisser apparaître que cet *a priori* est inutile. Il 
s'agit d'une grave erreur: même si l'implémentation de modèles est aisée, il 
est nécessaire de bien comprendre la structure des données et leur adéquation
avec les hypothèses d'un modèle. 

Les éléments relatifs à l'évaluation du cours sont disponibles dans la
Section [Evaluation](evaluation)

## Contenu général

{{< list_children >}}
