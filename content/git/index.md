---
title: "Git: un élément essentiel au quotidien"
date: 2020-09-30T13:00:00Z
draft: false
weight: 100
output: 
  html_document:
    keep_md: true
    self_contained: true
slug: introgit
---

## Pourquoi faire du `Git` <i class="fab fa-git-alt"></i> ?

Tous les statisticiens se sont déjà demandé (ou à leurs collègues) : 

* quelle était la bonne version d'un programme 
* qui était l'auteur d'un bout de code en particulier
* si un changement était important ou juste un essai
* comment fusionner des programmes
* etc.

Il existe un outil informatique puissant afin de répondre à tous ces besoins : la gestion de version (*version control system* (VCS) en anglais). Ses avantages sont incontestables et permettent de facilement :

* enregistrer l'historique des modifications d'un ensemble de fichiers 
* revenir à des versions précédentes d'un ou plusieurs fichiers
* rechercher les modifications qui ont pu créer des erreurs
* partager ses modifications et récupérer celles des autres
* proposer des modifications, les discuter, sans pour autant modifier la dernière version existante
* identifier les auteurs et la date des modifications

En outre, ces outils fonctionnent avec tous les langages informatiques (texte, R, Python, SAS, $\LaTeX$, Java, etc.) car reposent sur la comparaison des lignes et des caractères des programmes.


On peut ainsi résumé les principaux avantages du contrôle de version 
de la manière suivante :

1. Conserver et archiver l'ensemble des versions d'un code ou d'une documentation
2. Travailler efficacement en équipe
3. Améliorer la qualité des codes
4. Simplifier la communication autour d'un projet


### Conserver et archiver du code

Une des principales fonctionnalités de la gestion de version est conserver l'ensemble des fichiers de façon sécurisée et de proposer un archivage structuré des codes. Les fichiers sont stockés dans un **dépôt**, qui constitue le projet

Tout repose dans la gestion et la présentation de l'historique des modifications. Chaque modification (ajout, suppression ou changement) sur un ou plusieurs fichiers est identifiée par son auteur, sa date et un bref descriptif^[Plus précisément, chaque modification est identifiée de manière unique par un code `SHA` auquel est associé l'auteur, l'horodatage et des méta-données (par exemple le message descriptif associé)]. Chaque changement est donc unique et aisément identifiable quand ils sont classés par ordre chronologique. Les modifications transmises au dépôt sont appelées **commit**.

On peut ainsi vérifier l'
[ensemble des évolutions d'un fichier (`history`)](https://github.com/linogaliana/python-datascientist/commits/master/README.md), 
ou [l'histoire d'un dépôt](https://github.com/linogaliana/python-datascientist/commits/master).
On peut aussi 
[se concentrer sur une modification particulière d'un fichier](https://github.com/linogaliana/python-datascientist/commit/7e5d30ae0e260f9485453b42f195b0181a53e32e#diff-04c6e90faac2675aa89e2176d2eec7d8) ou vérifier, pour un fichier, la
[modification qui a entraîné l'apparition de telle ou telle ligne](https://github.com/linogaliana/python-datascientist/blame/master/README.md)



### Travailler efficacement en équipe

### Améliorer la qualité des codes

### Simplifier la communication autour d'un projet


### Comment faire du contrôle de version ?

Il existe plusieurs manières d'utiliser le contrôle de version : 

* en ligne de commande, via [git bash](https://gitforwindows.org/), par exemple ;
* avec une interface graphique spécialisée, par exemple [tortoise git](https://tortoisegit.org/) ou [GitHub Desktop](https://desktop.github.com/) ;
* avec un logiciel de développement : la plupart des logiciels de développement ([RStudio](https://rstudio.com/) pour `R`, [PyCharm](https://www.jetbrains.com/fr-fr/pycharm/) ou [jupyter](https://jupyter.org/) pour `python`, [atom](https://atom.io/), etc.) proposent tous des modules graphiques facilitant l'usage de `git` dont les fonctionnalités sont très proches.


{{< panel status="tip" title="Tip" icon="fa fa-lightbulb" >}}
`Git` a été conçu, initialement pour la ligne de commande. Il existe
néanmoins des interfaces graphiques performantes
et pratiques, notamment lorsqu'on désire comparer deux versions d'un même
fichier côte à côte. Ces interfaces graphiques couvrent la majorité des
besoins quotidiens. Néanmoins, pour certaines tâches, il faut nécessairement
passer par la ligne de commande.
{{< /panel >}}



