---
title: "Evaluation"
date: 2020-09-07T13:00:00Z
draft: false
weight: 90
slug: evaluation
icon: user-graduate
icon_pack: fas
#linktitle: "Partie 4: Natural Language Processing (NLP)"
summary: |
  Résumé des attentes pour les projets de fin d'année
type: book
---

Résumé : 

* A la fin du semestre, les étudiants rendront un projet informatique par __groupe de 2-3 personnes.__
* Ce projet dont le __sujet est libre__ devra comporter
    - Un jeu de données (de préférence collecté par le groupe ou a minima enrichi)
    - De la visualisation
    - De la modélisation
* La __date du rendu__ est fixée au : **mardi 15 décembre 23h59**
* Le **18 décembre 2020**, auront lieu des __soutenances__
* __Le projet doit utiliser `Git` et être disponible sous
[github](https://github.com/) <a href="https://github.com" class="github"><i class="fab fa-github"></i></a> ou [gitlab](https://gitlab.com/)__ <a href="https://gitlab.com" class="gitlab"><i class="fab fa-gitlab"></i></a>
(dépôt public ou dépôt privé à partager avec le chargé de TD)
* Les étudiants sont invités à proposer des sujets qui leur plaisent, à faire valider par le chargé de TD. 
* Un exemple de configuration d'intégration continue est disponible [ici](/getting-started/pythonCI) pour aider à avoir un notebook reproductible (:warning: ce n'est pas une garantie)

## Attentes du projet

Le projet est une problématique à laquelle vous souhaitez répondre à
l’aide d’un ou de plusieurs jeu(s) de données.

Il faut donc dans un premier temps se pencher sur la recherche de problématisation et de contextualisation. Nous vous recommandons de prendre un sujet qui vous intéresse pour intéresser également le lecteur.

{{% panel status="hint" title="Exemples de sujets des années précédentes" icon="fa fa-lightbulb" %}}
* Pourquoi les employés quittent l’entreprise ?
* Quelles primes d’insécurité pour les emplois temporaires ?
* Que peut-on dire des derniers mots d’un condamné à mort ?
* Comment améliorer la performance d’une équipe de NBA ?
* Peut-on déduire le nombre de restaurant autour d’une station velib ?
* Quels sont les déterminants des prix des concerts en ile de France ?
* Analyse de sentiments sur les compagnies aériennes à partir de tweets
* Qu’est ce que votre assiette dit de vous ?
* Titanic : l’inégalité face au naufrage
{{% /panel %}}

Trois dimensions doivent être présentes dans le projet.
Pour chacune de ces parties, il est possible d’aller plus ou moins loin. Il est recommandé d’aller loin sur au moins une des 3 dimensions.


### La récupération et le traitement des données

Ces données peuvent être directement disponibles sous la forme de fichiers txt, csv … ou provenir de sites internet (scrapping, API). Plus le travail sur la récupération de données est important (par exemple scrapping sur plusieurs sites), plus la partie obtiendra de points. Si le jeu de données utilisé est un téléchargement d’un jeu propre existant, il faudra chercher à le compléter d’une manière ou d’une autre pour obtenir des points sur cette partie.

Vous obtiendrez vraisemblablement des données qui ne sont pas « propres » du premier coup : mettez en place des protocoles de nettoyage pour obtenir à la fin de cette étape un ou des jeux de données fiable et robuste pour mener ensuite votre analyse. C’est également le moment de créer des variables plus appréhendables, mieux identifiées etc.

### L’analyse descriptive et la représentation graphique

La présence de statistiques descriptives est indispensable dans le projet. De la description de la base aux premières grandes tendances des données, cette partie permet d’avoir une vision globale des données : le lien avec la problématique, comment elle permet d’y répondre, quels sont les premiers éléments de réponse… Chaque résultat doit être interprété : pas la peine de faire un describe et de ne pas le commenter.
 En termes de représentation graphique, plusieurs niveaux sont envisageables. Vous pouvez simplement représenter vos données en utilisant matplotlib, aller plus loin avec seaborn ou scikit-plot, (voire D3.js pour les plus motivés). La base d’une bonne visualisation est de trouver le type de graphique adéquat pour ce que vous voulez montrer (faut-il un scatter ou un line pour représenter une évolution ?) et de le rendre visible : une légende qui a du sens, des axes avec des noms etc. Encore une fois, il faudra commenter votre graphique, qu’est ce qu’il montre, en quoi cela valide / contredit votre argumentaire ?

### La modélisation

 Vient ensuite la phase de modélisation : un modèle peut être le bienvenu quand des statistiques descriptives ne suffisent pas à apporter une solution complète à votre problématique ou pour compléter / renforcer l’analyse descriptive. Le modèle importe peu (régression linéaire, random forest ou autre) : il doit être approprié (répondre à votre problématique) et justifié.
Vous pouvez aussi confronter plusieurs modèles qui n’ont pas la même vocation : par exemple une CAH pour catégoriser et créer des nouvelles variables / faire des groupes puis une régression. 
Même si le projet n’est pas celui du cours de stats, il faut que la démarche soit scientifique et que les résultats soient interprétés.


## Format du rendu

 Sur le format du rendu, vous devrez :

* Écrire un rapport sous forme de notebook
* Avoir un répertoire github avec le rapport. Les données utilisées doivent être accessibles également, dans le dépôt ou sur internet.
* Les dépôts Github où seul un *upload* du projet a été réalisé ne sont pas autorisés. Il faut utiliser effectivement le contrôle de version. 
* Le code contenu dans le rapport devra être un maximum propre (pas de copier coller de cellule, préférez des fonctions)

Le test à réaliser : faire tourner toutes les cellules de votre notebook et ne pas avoir d’erreur est une condition sine qua non pour avoir la moyenne.
Un exemple de configuration d'intégration continue est disponible [ici](/getting-started/pythonCI) pour aider à avoir un notebook reproductible (:warning: ce n'est pas une garantie)


## Barême approximatif

* Données (collecte et nettoyage) : 4 points
* Analyse descriptive : 4 points
* Modélisation : 2 points
* Démarche scientifique tout au long du projet : 4 points
* Format du code (code propre et github) : 2 points
* Soutenance : 4 points

Le projet doit être réalisé en groupe de deux, voire trois. 


## Projets menés par les étudiants

### 2020-2021

| Projet | Auteurs | URL projet <a href="https://github.com" class="github"><i class="fab fa-github"></i></a> | Tags |
|--------|---------|------------|------|
<!---
-----Suivre ce modèle------
| Prédiction du prix des carottes | Bugs Bunny ; Daffy Duck | https://github.com/TheAlgorithms/Python | Prédiction ; Machine Learning ; Alimentation |
----->
| GPS vélo intégrant les bornes Vélib, les accidents, la congestion et la météo | Vinciane Desbois ; Imane Fares ; Romane Gajdos | https://github.com/ImaneFa/Projet_Python | Vélib ; Pistes cyclables ; Accidents ; Folium|
