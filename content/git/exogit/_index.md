---
title: "Un cadavre exquis pour découvrir Git"
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

{{% panel status="exercise" title="Exercise 6: rapatrier des modifs en local" icon="fas fa-pencil-alt" %}}

Pour le moment, vous êtes tout seul sur le dépôt. Il n'y a donc pas de 
partenaire pour modifier un fichier dans le dépôt distant. Nous verrons cela
lors de l'exercice suivant. Néanmoins, nous allons

1. Modifier le `README` par l'interface de `Github` en cliquant
sur le crayon en haut à droite de l'affichage du `README`.
L'objectif est de lui
donner un titre suivant, en ajoutant, au début du document, la ligne suivante : 

~~~text
# Mon oeuvre d'art surréaliste 
~~~

Ajouter à ce titre le mot `:penc il2:`, ce qui
affichera :pencil2: dans `Github`. 
Rédiger un titre et un message complémentaire pour faire le `commit`. Conserver
l'option par défaut `Commit directly to the master branch`

3. Editer à nouveau le `README`. Ajouter une deuxième phrase et corrigez la
ponctuation de la première. Ecrire un message de commit et valider.

4. Au dessus de l'aborescence des fichiers, vous devriez voir s'afficher le
titre du dernier commit. Vous pouvez cliquer dessus pour voir la modification
que vous avez faite.

5. Les résultats sont sur le dépôt distant mais ne sont pas sur votre ordinateur
Pour les rapatrier en local, faire

~~~shell
git pull origin master
~~~


{{% /panel %}}


{{% panel status="hint" title="Hint" icon="fa fa-lightbulb" %}}
`:XXXXXX:` permet, dans des systèmes qui reposent sur `Markdown`, d'afficher
des emojis. Vous pouvez [trouver une liste ici](https://gist.github.com/rxaviers/7360908)
{{% /panel %}}

L'opération `pull` permet: 

1. A votre système local de vérifier les modifications sur le dépôt distant
que vous n'auriez pas faites
2. De les fusionner s'il n'y a pas de conflit de version ou si les conflits de
version sont automatiquement fusionnable (deux modifications d'un fichier mais
qui ne portent pas sur le même emplacement)


### Même tout seul, ne pas se limiter à `master`


Au début d’une tâche particulière ou d’un projet, il est recommandé d’ouvrir des issues. Prenant la forme d’un espace de discussion, elles correpondront à la fin à des nouvelles fonctionnalités (en anglais, features). Les issues permettent également de signaler des bugs constatés, de se les répartir et d’indiquer s’ils sont réglés ou s’ils ont avancés. Une utilisation intensive des *issues*, avec des labels adéquats, peut
même amener à se passer d'outils de gestion de projets comme `Trello`. 


La branche `master` est la branche principale. Elle se doit d'être "propre". On ne pousse pas des travaux non aboutis sur `master`, c'est très mal vu.  

Peut-on pousser directement sur `master` ? oui, pour des petites corrections, des modifications mineures dont vous êtes certains qu'elles vont fonctionner. Mais sachez que dans le cadre de projets sensibles, c'est strictement interdit. N'ayez pas peur de fixer comme règle l'interdiction de pousser sur `master` (voir section précédente), cela obligera l'équipe projet à travailler professionnellement. 

Au moindre doute, créez une branche. Les branches sont utilisées pour des travaux significatifs :

- vous travaillez seul sur une tâche qui va vous prendre plusieurs heures ou jours de travail (vous ne devez pas pousser sur `master` des travaux non aboutis);
- vous travaillez sur une fonctionnalité nouvelle et vous souhaiterez recueillir l'avis de vos collègues avant de modifier `master`;
- vous n'êtes pas certain de réussir vos modifications du premier coup et préférez faire des tests en parallèle.

{{% panel status="warning" title="Warning" icon="fa fa-exclamation-triangle" %}}
Les branches ne sont pas personnelles : **Toutes les branches sont publiées, le `rebase` est interdit. Le push force est également interdit.**

Il faut **absolument** bannir les usages de `push force` qui peuvent déstabiliser les copies locales des collaborateurs. S'il est nécessaire de faire un `push force`, c'est qu'il y a un problème dans la branche, à identifier et régler **sans** faire `push force`

![](https://miro.medium.com/max/400/0*XaLzNzYkA6PZjbl9.jpg)

**Tous les merges dans `master` doivent se faire par l'intermédiaire d'une merge request dans `GitLab`**. En effet, il est très mal vu de merger une branche dans master localement.

{{% /panel %}}


{{% panel status="hint" title="Hint" icon="fa fa-lightbulb" %}}
Comment nommer les branches ? Là encore, il y a énormément de conventions différentes. Une fréquemment observée est :

- pour les nouvelles fonctionnalités : `feature/nouvelle-fonctionnalite` où `nouvelle-fontionnalite` est un nom court résumant la fonctionnalité
- pour les corrections de bug : `issue-num` où `num` est le numéro de l'issue

N'hésitez pas à aller encore plus loin dans la normalisation  !
{{% /panel %}}



{{% panel status="exercise" title="Exercise" icon="fas fa-pencil-alt" %}}
1. Ouvrir une *issue* sur `Github`. Signaler qu'il serait bien d'ajouter un emoji chat dans le README. Dans la partie de droite, cliquer sur la petite roue à côté de `Label` et cliquer sur `Edit Labels`. Créer un label `Markdown`. Retourner sur la page de l'*issue* et ajouter ce label
2. Sur votre dépôt local, créer une branche `issue-1` en faisant 

~~~shell
git checkout -b issue-1
~~~~

3. Ajouter un ou plusieurs emojis chat à la suite du titre. Valider avec `git add` et `git commit`. Faire un **deuxième commit** pour ajouter un emoji koala. Pousser les modifications locales:

~~~shell
git push origin issue-1
~~~~

4. Dans `Github`, devrait apparaître `issue-1 had recent pushes XX minutes ago`. 
Cliquer sur `Compare & Pull Request`. Donner un titre informatif à votre *pull request*. Dans le message en dessous, taper `Close #1` ce qui permettra de fermer automatiquement l'*issue 1* lorsque vous ferez le *merge*. **Ne validez pas la fusion**, on le fera dans un second temps.

5. En local, retourner sur `master`:

~~~shell
git checkout master
~~~~

Et ajouter une phrase à la suite de votre texte. Valider les modifications et les pusher. 

6. Cliquer sur `Insights` en haut du dépôt puis, à gauche sur `Network`. Vous devriez voir apparaître l'arborescence de votre dépôt. On peut voir `issue-1` comme une ramification et `master` comme le tronc.

L'objectif est maintenant de ramener les modifications faites dans `issue-1` dans la branche principale. Retournez dans l'onglet `Pull Requests`. Là, changer le type de `merge` pour `Squash and Merge`, comme ci-dessous. Vous pouvez vous reporter là [**METTRE LIEN**] pour la justification.

![](squashmerge.png)


7. Supprimer la branche. Elle est mergée, la conserver risque d'amener à des push involontaires dessus. 

Faire la fusion et regarder le résultat dans la page d'accueil de `Github` (le `README`) et dans le graphique. 

{{% /panel %}}


{{% panel status="note" title="Note" icon="fa fa-comment" %}}
La commande `checkout` est un couteau-suisse de la gestion de branche en `Git`. Elle permet en effet de basculer d'une branche à l'autre, mais aussi d'en créer, etc. 
{{% /panel %}}

{{% panel status="note" title="Note" icon="fa fa-comment" %}}
L'option de fusion *Squash and Merge* permet de regrouper tous les commits d'une branche (potentiellement très nombreux) en un seul dans la branche de destination. Cela évite, sur les gros projets, des branches avec des milliers de *commits*.
{{% /panel %}}


## Cadavre exquis: découvrir le travail collaboratif

