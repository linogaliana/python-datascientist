---
title: "Bonne pratique de Python"
date: 2020-07-22T12:00:00Z
draft: false
weight: 80
slug: pythonCI
---

## Qu'est-ce que l'intégration continue ?

L'intégration continue est une pratique consistant, de manière automatique,
à fréquemment tester les effets d'une modification faite à un code ou à un
document faisant parti d'un projet informatique.

Cette pratique permet ainsi de détecter de manière précoce des possibilités
de *bug* ou l'introduction d'un changement non anticipé. Tout comme `Git`, 
cette pratique devient un standard dans les domaines collaboratifs. 
L'intégration continue permet de sécuriser le travail, puisqu'elle offre un 
filet de sécurité (par exemple un test sur une machine à la configuration
arbitraire), mais permet aussi de déployer en temps réel certaines 
évolutions. On parle parfois de déploiement en continu, complémentaire de
l'intégration continue. Cette approche réduit ainsi
la muraille de Chine entre un
analyste de données et une équipe de développeurs d'application. Elle offre donc
plus de contrôle, pour le producteur d'une analyse statistique, sur la
valorisation de celle-ci. 

L'intégration continue fonctionne très bien sur `Gitlab` et sur `Github`.
A chaque interaction avec le dépôt distant (`push`), une série d'instruction
définie par l'utilisateur est exécutée. `Python` et `R` s'intègrent très bien avec l'intégration continue grâce 
à un certain nombre d'images de base (concept sur lequel nous allons revenir)
qui peuvent être customisées pour répondre à une certaine configuration
nécessaire pour exécuter des codes 
([voir ici pour quelques éléments sur R](https://linogaliana.gitlab.io/collaboratif/package.html#utiliser-lint%C3%A9gration-continue-de-gitlab).
C'est une méthode idéale pour améliorer la reproductibilité d'un projet: les
instructions exécutées le sont dans un environnement isolé et contrôlé, ce qui
diffère d'une machine personnelle. 


## Comment fonctionne l'intégration continue ?

L'intégration continue repose sur le système de la *dockerisation* ou *conteneurisation*. 
La technologie sous jacente s'appelle `Docker`.
Il s'agit d'une technologie qui permet la construction
de machines autosuffisantes
(que l'on nomme **containeurs**) répliquant un environnement
contrôlé (que l'on nomme **image**).

On parle de *pipelines* pour désigner une suite de tâches pour partir de 0
(généralement une machine `Linux` à la configuration minimale) et aboutir
à l'issue d'une série d'instructions définies par l'utilisateur.

L'objectif est de trouver une image la plus
parcimonieuse possible, c'est-à-dire à la configuration minimale, qui permet
de tester de faire tourner le code voulu. Dans le domaine de la *datascience*,
les images de [JupyterHub](https://hub.docker.com/r/jupyterhub/jupyterhub/) constituent 
un bon point de départ. Il est également très simple de construire son image 
de rien, ce qui sera proposé par la suite. 

Quand on utilise un dépôt `Github` ou `Gitlab`, des services automatiques
d'intégration continue peuvent être utilisés:

* `Gitlab CI`: solution pleinement intégrée à un dépôt Gitlab. Très généraliste
et permettant des *pipelines* très complexes
([voir l'intégration continue du projet utilitR, une documentation pour R](https://gitlab.com/linogaliana/documentationR/-/blob/master/.gitlab-ci.yml)).
Il est également possible de
l'utiliser avec un dépôt stocké sur `Github`. L'inconvénient de cette approche
est qu'elle est assez lente. 
* `Github Actions`: c'est l'alternative (relativement récente) au service d'intégration continue de
Gitlab uniquement basée sur les technologies Github. 
* `Travis CI`: un service externe d'intégration continue qui peut être connecté
à `Github` ou `Gitlab`. Les *pipelines* Travis ont l'avantage d'être assez 
rapides. Cette solution convient néanmoins pour des *pipelines* moins complexes
que ceux de `Gitlab CI`


## Intégration continue avec `Python`: tester un notebook

Cette section n'est absolument pas exaustive. Au contraire, elle ne fournit
qu'un exemple minimal pour expliquer la logique de l'intégration continue. Il
ne s'agit ainsi pas d'une garantie absolue de reproductibilité d'un *notebook*.

### Connecter son compte `Github` à `Travis`

Les étapes sont expliquées dans
[la documentation Travis](https://docs.travis-ci.com/user/tutorial/#to-get-started-with-travis-ci-using-github)

1. Se rendre sur <travis-ci.com> et cliquer sur `Sign up with GitHub`.
2. Accepter l'autorisation (`OAuth`) demandée. 
3. Après avoir été redirigé sur `Github` et suivi les instructions, retourner sur
<travis-ci.com>.
4. Cliquer, en haut à droite, sur la photo de profil. Cliquer sur `Settings`
puis `Activate` (bouton vert). Sélectionner le dépôt qui doit utiliser `Travis`

### Lister les dépendances

Avant d'écrire les instructions à exécuter par `Travis`, il faut définir un 
environnement d'exécution car `Travis` ne connaît pas la configuration `Python`
dont vous avez besoin. 

Il convient ainsi de lister les dépendances nécessaires dans un fichier 
`requirements`, comme expliqué dans la partie
[Bonnes pratiques](#bonnespratiques)