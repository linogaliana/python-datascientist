---
title: "Git: un élément essentiel au quotidien"
date: 2020-07-16T13:00:00Z
draft: false
weight: 70
slug: git
icon: git-alt
icon_pack: fab
#linktitle: "Partie 4: Natural Language Processing (NLP)"
summary: |
  Une partie annexe au cours pour découvrir Git, un langage
  devenu indispensable pour les data-scientists et économistes
  pour stocker et partager des projets Python.
type: book
---

Cette partie du site présente un élément qui n'est pas propre à
`Python` mais qui est néanmoins indispensable: la pratique de `Git`

TO DO


### Configurer pycharm pour utiliser le plugin git

Aller dans `File > Settings > Version Control > Git` pour définir le
chemin vers lequel `Pycharm` doit trouver
l'exécutable `git`. Si `Git` a été installé dans un chemin standard,
`Pycharm` le trouve ; sinon,
il faut lui donner (dans le dossier d'installation `git`,
bien choisir l'exécutable présent dans
le sous-dossier `cmd/git.exe`) ^[2]

![Récupération d'un dépôt sur github via git bash](./pictures/vcspycharm2.png)

^[2:] Si la case `Use credential helper` est cochée, il est recommandé de la décocher car en cas
de mot de passe tapé trop vite, les tentatives de connexion au dépôt distant seront
systématiquement refusées


### Configurer Jupyter pour utiliser le plugin git

La marche à suivre est présentée
[sur cette page](https://github.com/jupyterlab/jupyterlab-git)

### Configuration Visual Studio pour utiliser `Git`


{{< list_children >}}
