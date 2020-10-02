---
title: "Git: faire un cadavre exquis"
date: 2020-09-30T13:00:00Z
draft: false
weight: 20
output: 
  html_document:
    keep_md: true
    self_contained: true
slug: exogit
---

<!--- Inspirations
https://github.com/corent01/03-Swartz/blob/master/Parcours/01-La-prairie/git/exercice-git-cadavre-exquis.md
https://github.com/simplonco/cadavre-request
------>

## Git tout seul

### Première étape: avoir un compte `Github`

Les deux premières étapes se font sur `Github`

{{% panel status="exercise" title="Exercise 1: créer un compte Github" icon="fab fa-github" %}}

1. Si vous n'en avez pas déjà un, créer un compte sur `github.com`
2. Créer un dépôt vide. Ce dépôt sera personnel, vous pouvez le rendre public
ou non, comme vous le souhaitez.
{{% /panel %}}

Pour ces exercices, je propose d'utiliser `Github` dont les fonctionalités
nous suffiront amplement. Si, 
dans le futur, les fonctionalités ne vous conviennent pas (sans l'apport de fonctionalités
externes, `Github` propose moins de fonctionalités que `Gitlab`) ou vous êtes
mal à l'aise avec le possesseur de `Github` (Microsoft), vous pourrez utiliser
`Gitlab` <i class="fab fa-gitlab"></i>, le concurrent.
L'avantage de `Github` par rapport à `Gitlab` est que le premier est plus visible, car
mieux indexé par `Google` et concentre, en partie pour des raisons historiques, plus
de développeurs `Python` et `R` (ce qui est important dans des domaines comme
le code où les externalités de réseau jouent). Le débat `Github` vs `Gitlab` n'a
plus beaucoup de sens aujourd'hui car les fonctionalités ont convergé (`Github` 
a rattrapé une partie de son retard sur l'intégration continue) et, de toute
manière, on peut tout à fait connecter des dépôts Gitlab et Github (c'est le cas
du dépôt source <a href="https://github.com/linogaliana/python-datascientist" class="github"><i class="fab fa-github"></i></a> et <a href="https://gitlab.com/linogaliana/python-datascientist" class="github"><i class="fab fa-gitlab"></i></a> de ce cours). 

### Pratique en local

Maintenant, en local. Il faut ouvrir une invite de commande `git bash` (ou une
interface graphique connectée à `git bash`)

{{% panel status="exercise" title="Exercise 2: découvrir l'invite de commande" icon="fas fa-pencil-alt" %}}

1. Sur les postes ENSAE. Aller dans `Scientific Apps/Git`. Vous devriez voir
un raccourci `bash.exe`. Vous pouvez lancer l'application ; elle ouvre une 
invite de commande
2. Créer un dossier de travail, par exemple `Desktop/gitexo`. Dans `git bash`,
faire 

~~~shell
# remplacer par le dossier qui vous intéresse
cd 'Desktop/gitexo'
~~~

3. Initialiser le contrôle de version en tapant dans l'invite de commande

~~~shell
git init
~~~

{{% /panel %}}

Pour le moment, on a uniquement initialisé le contrôle de version avec `Git`. 
On n'a encore ajouté aucun fichier à `Git`. D'ailleurs, la première 
chose à faire est d'exclure un certain nombre de fichiers, afin de ne pas
faire une erreur pénible à réparer.

{{% panel status="exercise" title="Exercise 3: le fichier .gitignore" icon="fas fa-pencil-alt" %}}

Lorsqu'on utilise `Git`, il y a des fichiers qu'on ne veut pas partager
ou dont on ne veut pas suivre les modifications. C'est le fichier `.gitignore`
qui gère les fichiers exclus du contrôle de version.

1. Maintenant, créer un fichier nommé `.gitignore` (:warning: ne pas changer
ce nom) via le bloc note ou votre IDE. 
1. Aller sur le site <https://www.toptal.com/developers/gitignore>. Vous pouvez
dans la barre de recherche taper  `Python`, `Pycharm`, `JupyterNotebooks`. 
Copier-coller dans votre `.gitignore` le contenu de la page. 
1. Quand on crée de la documentation, on veut exclure les extensions `.pdf`
et `.html` qui sont des résultats à partager et non des fichiers source à
suivre. Pour cela, ajouter au début du fichier `.gitignore`, les extensions:

~~~markdown
.pdf
.html
~~~


{{% /panel %}}


On a créé un fichier `.gitignore` mais on n'a encore rien fait jusqu'à présent.
Il faut dire à `Git` de contrôler les évolutions de chaque fichier 
(passage dans l'index). On appelle cette étape `git add`. ****

{{% panel status="exercise" title="Exercise 4: pratique de git. Enfin..." icon="fas fa-pencil-alt" %}}

1. De temps en temps, il est bon de vérifier l'état d'un dépôt. Pour cela, faire

~~~shell
git status
~~~

1. Dans l'invite de commande, taper

~~~shell
git add .gitignore
~~~

2. Retaper `git status`. Observer le changement. Les nouvelles modifications (en
l'occurrence la création du fichier et la validation de son contenu actuel)
ne sont pas encore archivées. Pour cela, il faut faire

~~~shell
git commit -m "Initial commit"
~~~

{{% /panel %}}

L'option `m` permet de créer un message, qui sera disponible à l'ensemble
des contributeurs du projet. Avec la ligne de commande, ce n'est pas toujours
très pratique. Les interfaces graphiques permettent des messages plus
développés (la bonne pratique veut qu'on écrive un message de commit comme un
mail succinct: un titre et un peu d'explications, si besoin).

Le fait de nommer le premier commit *"Initial commit"* est une
habitude, vous
n'êtes pas obligé de suivre cette convention si elle ne vous plaît pas.

### Premières interactions avec `Github`


{{% panel status="exercise" title="Exercise 5: interagir avec Github" icon="fas fa-pencil-alt" %}}

1. Maintenant, créer un fichier nommé `README.md` (:warning: ne pas changer
ce nom) via le bloc note ou votre IDE. 
2. Y écrire une phrase au format, sujet-verbe-complément mais sans majuscule ni ponctuation.
Observer le statut du fichier avec `git status`.
3. Valider cette création avec le message *"j'écris comme un surréaliste*

Il convient maintenant d'envoyer les fichiers sur le dépôt distant. 
1. Récupérer l'url du dépôt. Dans `Github`, il faut cliquer sur
le bouton `Code`, comme ci-dessous

![](gitclone.png)

2. Créer la connexion avec le dépôt distant (`remote`), qu'on va nommer `origin`,
en utilisant la commande suivante:

~~~~shell
git remote add origin ****
~~~~
Remplacer les astérisques par l'url du dépôt. 

3. Envoyez vos modifications vers `origin` en tapant 

~~~~shell
git push origin master
~~~~

`Git` va vous demander vos identifiants de connexion pour vérifier que vous
êtes bien autorisés à intéragir avec ce dépôt. Il faut les taper (:warning: 
comme le créateur de `Git` était un peu paranoiaque, c'est normal 
de ne pas voir le curseur avancer quand on tape des caractères pour le mot de passe,
si quelqu'un regarde votre écran il ne pourra ainsi pas savoir combien de 
caractères comporte votre mot de passe)


{{% /panel %}}


Retournez voir le dépôt sur `Github`, vous devriez maintenant voir le fichier
`.gitignore` et le `README` devrait s'afficher en page d'accueil. 

{{% panel status="exercise" title="Exercise 4: pratique de git. Enfin..." icon="fas fa-pencil-alt" %}}

1. De temps en temps, il est bon de vérifier l'état d'un dépôt. Pour cela, faire

~~~shell
git status
~~~

1. Dans l'invite de commande, taper

~~~shell
git add .gitignore
~~~

2. Retaper `git status`. Observer le changement. Les nouvelles modifications (en
l'occurrence la création du fichier et la validation de son contenu actuel)
ne sont pas encore archivées. Pour cela, il faut faire

~~~shell
git commit -m "Initial commit"
~~~

{{% /panel %}}

