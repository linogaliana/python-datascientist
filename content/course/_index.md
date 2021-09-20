---
title: Python pour les data scientists et économistes
type: book  # Do not modify.
toc: true
# Title for the menu link if you wish to use a shorter link title, otherwise remove this option.
linktitle: Homepage
slides: intro.md
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

Un certain nombre de boutons permettent de transformer chaque
page web en `Jupyter Notebooks` s'il est nécessaire de
visualiser ou exécuter du code `Python`. 


Voici, par exemple, ces boutons pour le tutoriel `numpy`

<a href="https://github.com/linogaliana/python-datascientist/blob/master/C:/Users/W3CRK9/Documents/FORMATIONS/python-datascientist/notebooks/course/manipulation/01_numpy.ipynb" class="github"><i class="fab fa-github"></i></a>
[![Download](https://img.shields.io/badge/Download-Notebook-important?logo=Jupyter)](https://downgit.github.io/#/home?url=https://github.com/linogaliana/python-datascientist/blob/master/C:/Users/W3CRK9/Documents/FORMATIONS/python-datascientist/notebooks/course/manipulation/01_numpy.ipynb)
[![nbviewer](https://img.shields.io/badge/Visualize-nbviewer-blue?logo=Jupyter)](https://nbviewer.jupyter.org/github/linogaliana/python-datascientist/blob/master/C:/Users/W3CRK9/Documents/FORMATIONS/python-datascientist/notebooks/course/manipulation/01_numpy.ipynb)
[![Onyxia](https://img.shields.io/badge/SSPcloud-Tester%20via%20SSP--cloud-informational&color=yellow?logo=Python)](https://datalab.sspcloud.fr/launcher/inseefrlab-helm-charts-datascience/jupyter?onyxia.friendlyName=%C2%ABpython-datascientist%C2%BB&resources.requests.memory=%C2%AB4Gi%C2%BB)
[![Binder](https://img.shields.io/badge/Launch-Binder-E66581.svg?logo=data:image/png;base64,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)](https://mybinder.org/v2/gh/linogaliana/python-datascientist/master?filepath=C:/Users/W3CRK9/Documents/FORMATIONS/python-datascientist/notebooks/course/manipulation/01_numpy.ipynb)
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](http://colab.research.google.com/github/linogaliana/python-datascientist/blob/master/C:/Users/W3CRK9/Documents/FORMATIONS/python-datascientist/notebooks/course/manipulation/01_numpy.ipynb)


## Architecture du site web

Ce cours présente des tutoriels et des exercices complets.
Chaque page est structurée sous la forme d'un problème concret et présente la
démarche générique pour résoudre ce problème général. 

Vous pouvez naviguer dans l'architecture du site via la table des matières
ou par les liens vers le contenu antérieur ou postérieur à la fin de chaque
page. 

<!----
print_badges(here::here("content","course","manipulation","01_numpy.Rmd"))
----->




## Objectif du cours

Le but de ce cours est de rendre autonome sur l'utilisation de Python
dans un contexte de travail de *data scientist* ou de
*social scientist* (économie, sociologie, géographie...). Autrement dit, 
il présuppose qu'on désire faire un usage intense
de données dans un cadre statistique rigoureux.

Nous partirons de l'hypothèse que les notions de statistiques, d'économétrie
et de *Machine Learning* pour lesquels nous verrons des applications informatiques sont connues.
Ne pas connaître ces notions n'empêche néanmoins pas de comprendre
le contenu de ce site *web*. En effet, la facilité d'usage de `Python` rend 
évite de devoir programmer soi-même un modèle, ce qui possible l'application
de modèles dont on n'est pas expert. La connaissance des modèles sera 
plutôt nécessaire dans l'interprétation des résultats.

Cepdant, la facilité avec laquelle il est possible de construire des modèles complexes
avec `Python` peut laisser apparaître que connaître les spécifités de chaque
modèle est inutile. Il 
s'agirait d'une grave erreur: même si l'implémentation de modèles est aisée, il 
est nécessaire de bien comprendre la structure des données et leur adéquation
avec les hypothèses d'un modèle. 


## Evaluation

Les éléments relatifs à l'évaluation du cours sont disponibles dans la
Section [Evaluation](evaluation)

## Contenu général

{{< list_children >}}
