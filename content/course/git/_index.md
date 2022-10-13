---
title: "Git: un outil nécessaire pour les data-scientists"
date: 2020-07-16T13:00:00Z
draft: false
weight: 70
slug: git
icon: git-alt
icon_pack: fab
#linktitle: "Partie 4: Natural Language Processing (NLP)"
summary: |
  Une partie annexe au cours pour découvrir `Git`,
  un outil
  devenu indispensable pour les data-scientists
  afin de mener des projets impliquant
  du code `Python`.
type: book
---

Cette partie du site présente un élément qui n'est pas propre à
`Python` mais qui est néanmoins indispensable : la pratique de `Git`.

Une grande partie du contenu de la partie provient du cours
[Travail collaboratif avec `R`](https://linogaliana.gitlab.io/collaboratif/git.html)
ou d'un [cours dédié fait avec Romain Avouac](https://formation.pages.lab.sspcloud.fr/git/20220929-formation-git-dese/#/title-slide).

Le chapitre [de présentation de `Git`](/introgit) propose 
une introduction visant à présenter l'intérêt d'utiliser
cet outil. Une mise en pratique est proposée
avec [un cadavre exquis](/exogit).



# Utilisation de `Git` avec `Python`

`Git` est à la fois un outil et un langage. Il
est donc nécessaire d'installer, dans un premier
temps `Git Bash`, puis de connecter
son outil préféré pour faire du `Python` (qu'il
s'agisse de `Jupyter`, `VSCode` ou `PyCharm`). 

L'un des intérêts d'utiliser une approche _cloud_
est que l'utilisateur final n'a pas à se préoccuper
de l'installation de ces différentes briques. 
Les interfaces `Git` sont parfois déjà
configurées pour faciliter l'usage. C'est le
cas sur le `SSPCloud`.  


# Configuration 

## Configurer `PyCharm` pour utiliser le plugin `Git`

Aller dans `File > Settings > Version Control > Git` pour définir le
chemin vers lequel `Pycharm` doit trouver
l'exécutable `git`. Si `Git` a été installé dans un chemin standard,
`Pycharm` le trouve ; sinon,
il faut lui donner (dans le dossier d'installation `git`,
bien choisir l'exécutable présent dans
le sous-dossier `cmd/git.exe`)[^1]

![Récupération d'un dépôt sur github via git bash](./pictures/vcspycharm2.png)

[^1]: Si la case `Use credential helper` est cochée, il est recommandé de la décocher car en cas
de mot de passe tapé trop vite, les tentatives de connexion au dépôt distant seront
systématiquement refusées

## Configurer `Jupyter` pour utiliser le plugin `Git`

La marche à suivre est présentée
[sur cette page](https://github.com/jupyterlab/jupyterlab-git)

## Configurer `Visual Studio` pour utiliser le plugin `Git`

Vous pouvez par exemple vous référer à [cette documentation](https://docs.microsoft.com/fr-fr/visualstudio/version-control/git-with-visual-studio?view=vs-2019)

{{< list_children >}}
