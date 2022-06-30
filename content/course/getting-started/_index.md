---
date: "2018-09-09T00:00:00Z"
icon: python
icon_pack: fab
linktitle: "Introduction: mener un projet statistique avec Python"
summary: |
  Cette introduction propose quelques éléments de
  révision des concepts de base en Python et
  présente l'écosystème Python que nous allons
  découvrir tout au long de ce cours.
title: Introduction
slug: introduction
type: book
weight: 10
---

Avant de plonger dans les arcanes de la *data science*, cette partie
d'introduction propose des éléments de configuration et des
révisions pour mettre le pied à l'étrier.

Chaque chapitre peut être consulté depuis ce site web ou 
est accessible sous un format
éditable `Jupyter Notebook` dans différents 
environnements. Pour les agents de la fonction publique, ou
les élèves des écoles partenaires, il est recommandé
de privilégier le bouton `SSPCloud` qui est
une infrastructure _cloud_ moderne, puissante et flexible
développée par l'Insee et accessible à l'url
[https://datalab.sspcloud.fr](https://datalab.sspcloud.fr/home)[^1].

[^1]: Pour les utilisateurs de cette infrastructure, les _notebooks_
sont également listés, parmi de nombreuses autres
ressources de qualité, sur la
[page `Formation`](https://www.sspcloud.fr/formation)

## Pourquoi faire du `Python` pour travailler sur des données ?

[Python](https://www.python.org/), par sa grande flexibilité, est devenu un langage incontournable
dans le domaine de la *data science*.
Le succès de [scikit-learn](https://scikit-learn.org/stable/) et
de [Tensorflow](https://www.tensorflow.org/) dans la communauté
de la *Data-Science* ont beaucoup contribué à l'adoption de `Python`. Cependant,
résumer `Python` à ces quelques librairies serait réducteur tant il s'agit
d'un véritable couteau-suisse pour les *data-scientists*,
les *social scientists* ou les économistes.

L'intérêt de `Python` pour un *data scientist* ou *data economist*
va au-delà du champ du *Machine Learning*.
Comme pour `R`, l'intérêt de Python est son rôle central dans un
écosystème plus large autour d'outils puissants, flexibles et *open-source*.
`Python` concurrence très bien `R` dans son domaine de prédilection, à
savoir l'analyse statistique sur des bases de données structurées. 
Comme dans `R`, les *dataframes* sont un concept central de `Python`.
`Python` est néanmoins bien plus complet dans certains domaines.
Outre le *Machine Learning*,
`Python` est mieux adapté aux données volumineuses que
`R`. `Python` est également meilleur que `R` pour faire
du *webscraping* ou accéder à des données par le biais d'API.
Dans le domaine de l'économétrie, `Python` offre
l'avantage de la simplicité avec un nombre restreint de packages (`scikit` et
`statsmodels`) permettant d'avoir des modèles très généraux
(les [generalized estimating equations](https://www.statsmodels.org/stable/gee.html))
alors qu'il faut
choisir parmi une grande variété de packages en `R` pour obtenir les
modèles équivalents. Dans le domaine du _Deep Learning_, `Python` écrase
la concurrence.  
Au contraire, dans certains domaines, `R` reste meilleur, même si les 
évolutions très récentes de certains outils peuvent amener à réviser
ce constant. Historiquement,
`R` étant très bien intégré au langage de publication `Markdown` ce qui,
permet la construction de documents reproductibles très raffinés. 
L'émergence récente de `Quarto`, héritier de `R Markdown` et
développé par `RStudio` permet aux utilisateur de `Python` de bénéficier
également de la richesse de cette approche pour leur langage de prédilection.
Ce site *web*, à l'arborescence relativement complexe, est ainsi 
construit grâce à cet outil qui permet à la fois de tester les blocs
de code présentés mais aussi de produire de manière automatisée les 
tableaux et graphiques présentés. S'il fallait trouver un point faible
à `Python` par rapport à `R` dans le domaine de la _data-science_ 
c'est sur la production de graphiques. `matplotlib` et `seaborn`, qui sont
présentés dans la partie visualisation, sont d'excellents outils. Néanmoins,
`ggplot2`, l'équivalent en `R` est plus facile de prise en main et
propose une syntaxe extrêmement flexible, qu'il est difficile de ne pas
apprécier.

Un des avantages comparatifs de `Python` par rapport à d'autres
langages (notamment `R` et `Julia`) est sa dynamique,
ce que montre [l'explosion du nombre de questions
sur `Stack Overflow`](https://towardsdatascience.com/python-vs-r-for-data-science-6a83e4541000).

Cependant, il ne s'agit pas bêtement d'enterrer `R`.
Au contraire, outre leur logique très proche,
les deux langages sont dans une phase de convergence avec des initiatives comme
[`reticulate`](https://rstudio.github.io/reticulate/),
[`quarto`](https://quarto.org/) ou
[snakemake](https://snakemake.readthedocs.io/en/stable/tutorial/basics.html) qui 
permettent, de manière différente, de créer des chaînes de traitement
mélangeant `R` et `Python`:

- [`reticulate`](https://rstudio.github.io/reticulate/) est un _package_ `R` qui 
permet d'exécuter des commandes `Python`, récupérer le résultat de celles-ci
dans `R`, exécuter des commandes `R` sur l'objet converti, et éventuellement
renvoyer le résultat dans un objet `Python` équivalent. Techniquement,
`reticulate` crée une équivalence entre des objets `Python` et `R` et permet
aux deux langages de s'échanger ces objets sans risque de les altérer ;
- [`snakemake`](https://snakemake.readthedocs.io/en/stable/tutorial/basics.html)
propose une approche plus générique, celles des _pipelines_. L'idée est 
de structurer un programme sous formes de maillons dépendants les uns des autres
mais pouvant être exécutés dans des langages différents. `snakemake` est
l'un des nombreux outils qui existent dans le domaine. Celui-ci est présenté
dans la partie relative aux outils modernes de la _data-science_. 
Il s'agit
de celui qui est plus centré sur `Python` mais il en existe d'autres (les
plus flexibles étant
probablement [`Apache Airflow`](https://airflow.apache.org/docs/apache-airflow/stable/tutorial.html)
et `Argo CD`).
- [`quarto`](https://quarto.org/) est un outil pour intégrer ensemble des
éléments de texte et des blocs de code à exécuter afin de produire des
sorties valorisées dans le document. `Quarto` vise à corriger l'un des
défauts majeurs de `R Markdown`, à savoir qu'il était nécessaire d'installer
`R` et un certain nombre de packages
pour créer des publications reproductibles, même lorsque ces dernières
n'utilisaient
pas ce langage. Avec `Quarto`, ceci n'est plus nécessaire. Les utilisateurs
de `Python` bénéficient ainsi des apports de presque une décennie
de développement et d'usage intensif de `R Markdown` par la communauté. 

Une autre raison pour laquelle cette guéguerre `R`/`Python` n'a pas
de sens est que les bonnes
pratiques peuvent être transposées de manière presque transparente d'un
langage à l'autre. Il s'agit d'un point qui est développé plus amplement
dans le cours plus avancé que je donne avec Romain Avouac en dernière année
d'ENSAE: ensae-reproductibilite.netlify.app/. 
A terme, les data-scientists et chercheurs en sciences sociales ou 
économie utiliseront
de manière presque indifférente, et en alternance, `Python` et `R`. Ce cours
présentera ainsi régulièrement des analogies avec `R` pour aider les
personnes découvrant `Python`, mais connaissant déjà bien `R`, à 
mieux comprendre certains messages.


## Structuration de cette partie

{{< list_children >}}
