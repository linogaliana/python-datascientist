---
title: "L'environnement du data-scientist en python"
date: 2020-07-22T12:00:00Z
draft: false
weight: 30
---

# Les packages python essentiels pour le cours et la vie d'un ENSAE

## `numpy`

`numpy` gère tout ce qui est calcul matriciel. Le langage Python est un des langages les plus lents qui soient. Tous les calculs rapides ne sont pas écrits en Python mais en C++, voire fortran. C’est le cas du module numpy, il est incontournable dès qu’on veut être rapide. Le module scipy est une extension où l’on peut trouver des fonctions statistiques, d’optimisation.

La Cheat Sheet de `numpy` : https://s3.amazonaws.com/assets.datacamp.com/blog_assets/Numpy_Python_Cheat_Sheet.pdf

## pandas

pandas est incontournable dès qu’on veut manipuler des données. Il gère la plupart des formats de données. Il est lui aussi implémenté en C++. Il est rapide mais pas tant que ça, il utilise en règle générale trois fois plus d’espace en mémoire que les données n’en prennent sur le disque.

La Cheat Sheet de pandas : https://s3.amazonaws.com/assets.datacamp.com/blog_assets/Python_Pandas_Cheat_Sheet_2.pdf


## matplotlib

matplotlib s’occupe de tout ce qui est graphique. Il faut également connaître seaborn qui propose des graphiques étudiés pour un usage statistique.

## scikit-learn

scikit-learn est le module le plus populaire pour deux raisons. Son design a été pensé pour être simple avec deux méthodes fit et predict pour apprendre et prédire. Sa documentation est un modèle à suivre.

## statsmodels

statsmodels plaira plus aux statisticiens, il implémente des modèles similaires à scikit-learn, il est meilleur pour tout ce qui est linéaire avec une présentation des résultats très proche de ce qu’on trouve en R.

<!---
(source http://www.xavierdupre.fr/app/papierstat/helpsphinx/rappel.html)
----->

# Environnement autour de Python

# Démarche à adopter face à un jeu de données

Pour bien débuter des travaux sur une base de données, il est nécessaire de se poser quelques questions de bon sens et de suivre une démarche assez simple. 

<!-- #region -->
### Une démarche scientifique 

Dans un projet sur des jeux de données, on peut schématiquement séparer les étapes en 3 grandes parties : la récupération des données, leur analyse (notamment descriptive) et la modélisation. 

#### Lors de la récupération des données

La phase de constitution de son jeu de données sous-tend tout le projet qui suit : 
- de quelles données ai-je besoin ? 
- est-ce que les sources trouvées sont fiables ? (les sites de l'Open Data sont par exemple assez fiable, Wikipedia aussi)
- est-ce que je peux les compléter avec d'autres données ? (dans ce cas, faire attention à avoir des niveaux de granularité adéquats)

Vient ensuite la phase de mise en forme et nettoyage des jeux de données récupérés. Cette étape est primordiale, car le jeu de données soit être propre afin de permettre leur analyse.

Propre ? ça veut dire quoi pour des données ? 

Quelques exemples pour vous permettre de saisir le sens de données propres : 
- les __informations manquantes__ sont bien comprises et traitées (remplacer par NaN ou 0 le cas échéant) 
- les __variables servant d'identifiants__ sont bien les mêmes d'une table à l'autre (notamment dans le cas de jointure) : même format, même 
- pour des __variables textuelles__, qui peuvent etre mal saisies, avoir corrigé les éventuelles fautes (ex "Rolland Garros" > "Roland Garros" 
- créer des variables qui synthétisent l'information dont vous avez besoin
- supprimer les éléments inutiles (colonne ou ligne vide)
- renommez les colonnes avec des noms compréhensibles 


#### Lors de l'analyse descriptive

Une fois les jeux de données nettoyés, vous pouvez plus sereinement regarder ce que vos données vous disent. Cette phase et celle du nettoyage ne sont pas séquentielles, en réalité vous devrez régulièrement passer de votre nettoyage à quelques statistiques descriptives qui vous montreront un problème, retourner au nettoyage etc. 

Les questions à se poser pour "challenger" le jeu de données : 

- est-ce que mon échantillon est bien __représentatif__ de ce qui m'intéresse ? N'avoir que 2000 communes sur les 35000 n'est pas nécessairement un problème mais il est bon de s'être posé la question. 
- est-ce que les __ordres de grandeur__ sont bons ? pour cela, regarder confronter vos premieres stats desc à vos recherches internet. Par exemple trouver que les maisons vendues en France en 2020 font en moyenne 400 m² n'est pas un ordre de grandeur réaliste. 
- est-ce que je __comprends toutes les variables__ de mon jeu de données ? est-ce qu'elles se "comportent" de la bonne façon ? à ce stade, il est parfois utile de se faire un dictionnaire de variable (qui explique comment elles sont construites ou calculées). On peut également mener des études de __corrélation__ entre nos variables.
- est-ce que j'ai des __premiers grands messages__ sortis de mon jeu de données ? est-ce que j'ai des résultats surprenants ? Si oui, les ai-je creusé suffisamment pour voir si les résultats tiennent toujours ou si c'est à cause d'un souci dans la construction du jeu de données (mal nettoyées, mauvaise variable...)

#### Lors de la modélisation

A cette étape, l'analyse descriptive doit voir avoir donné quelques premières pistes pour savoir dans quelle direction vous voulez mener votre modèle. 

Vous devrez plonger dans vos autres cours (Econométrie 1, Series Temporelles, Sondages, Analyse des données etc.) pour trouver le modèle le plus adapter à votre question.

- Est-ce que vous voulez expliquer ou prédire ? https://hal-cnam.archives-ouvertes.fr/hal-02507348/document
- Est-ce que vous voulez classer un élément dans une catégorie ? 

En fonction des modèles que vous aurez déjà vu en cours et des questions que vous souhaiterez résoudre sur votre jeu de données, le choix du modèle sera souvent assez direct. 


Vous pouvez également vous référez à la démarche proposée par Xavier Dupré
http://www.xavierdupre.fr/app/ensae_teaching_cs/helpsphinx3/debutermlprojet.html#l-debutermlprojet

Pour aller plus loin (mais de manière simplifiée) sur les algorithmes de Machine Learning :  
https://datakeen.co/8-machine-learning-algorithms-explained-in-human-language/
<!-- #endregion -->

### Une démarche éthique 

On entend souvent qu'on peut "faire dire ce qu'on veut aux données". 

En suivant quelques préceptes simples, mélange d'honneteté intellectuelle et de recherche scientifique, cette remarque est facilement écartée. Ces principes ont été repris dans "le sermet d'Hippocrate du Data Scientist" : https://hippocrate.tech/.
