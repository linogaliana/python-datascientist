---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.2'
      jupytext_version: 1.6.0
  kernelspec:
    display_name: Python 3
    language: python
    name: python3
title: "Comment aborder un jeu de données"
date: 2020-07-22T12:00:00Z
draft: false
weight: 35
slug: datanalysis
type: book
summary: |
  La démarche à adopter face à un jeu de données
---

## Démarche à adopter face à un jeu de données

Pour bien débuter des travaux sur une base de données,
il est nécessaire de se poser quelques questions de bon sens
et de suivre une démarche assez simple.

### Une démarche scientifique

Dans un projet sur des jeux de données, on peut schématiquement séparer les étapes en 3 grandes parties :

* la récupération des données;
* leur analyse (notamment descriptive);
* la modélisation.


### Lors de la récupération des données

La phase de constitution de son jeu de données sous-tend tout le projet qui suit :
- de quelles données ai-je besoin ?
- est-ce que les sources trouvées sont fiables ? (les sites de l'Open Data sont par exemple assez fiable, Wikipedia aussi)
- est-ce que je peux les compléter avec d'autres données ? (dans ce cas, faire attention à avoir des niveaux de granularité adéquats)

Vient ensuite la phase de mise en forme et nettoyage des jeux de données récupérés. Cette étape est primordiale, car le jeu de données soit être propre afin de permettre leur analyse.

Propre ? ça veut dire quoi pour des données ?

Quelques exemples pour vous permettre de saisir le sens de données propres :
- les __informations manquantes__ sont bien comprises et traitées (remplacer par NaN ou 0 le cas échéant)
- les __variables servant d'identifiants__ sont bien les mêmes d'une table à l'autre (notamment dans le cas de jointure) : même format, même modalités
- pour des __variables textuelles__, qui peuvent etre mal saisies, avoir corrigé les éventuelles fautes (ex "Rolland Garros" > "Roland Garros")
- créer des variables qui synthétisent l'information dont vous avez besoin
- supprimer les éléments inutiles (colonne ou ligne vide)
- renommer les colonnes avec des noms compréhensibles


### Lors de l'analyse descriptive

Une fois les jeux de données nettoyés, vous pouvez plus sereinement regarder ce que vos données vous disent. Cette phase et celle du nettoyage ne sont pas séquentielles, en réalité vous devrez régulièrement passer de votre nettoyage à quelques statistiques descriptives qui vous montreront un problème, retourner au nettoyage etc.

Les questions à se poser pour "challenger" le jeu de données :

- est-ce que mon échantillon est bien __représentatif__ de ce qui m'intéresse ? N'avoir que 2000 communes sur les 35000 n'est pas nécessairement un problème mais il est bon de s'être posé la question.
- est-ce que les __ordres de grandeur__ sont bons ? pour cela, regarder confronter vos premieres stats desc à vos recherches internet. Par exemple trouver que les maisons vendues en France en 2020 font en moyenne 400 m² n'est pas un ordre de grandeur réaliste.
- est-ce que je __comprends toutes les variables__ de mon jeu de données ? est-ce qu'elles se "comportent" de la bonne façon ? à ce stade, il est parfois utile de se faire un dictionnaire de variable (qui explique comment elles sont construites ou calculées). On peut également mener des études de __corrélation__ entre nos variables.
- est-ce que j'ai des __outliers__, i.e. des valeurs aberrantes pour certains individus ? Dans ce cas, il faut décider quel traitement on leur apporte (les supprimer, appliquer une transformation logarithmique, les laisser tel quel) et surtout bien le justifier.
- est-ce que j'ai des __premiers grands messages__ sortis de mon jeu de données ? est-ce que j'ai des résultats surprenants ? Si oui, les ai-je creusé suffisamment pour voir si les résultats tiennent toujours ou si c'est à cause d'un souci dans la construction du jeu de données (mal nettoyées, mauvaise variable...)

### Lors de la modélisation

A cette étape, l'analyse descriptive doit voir avoir donné quelques premières pistes pour savoir dans quelle direction vous voulez mener votre modèle.

Vous devrez plonger dans vos autres cours (Econométrie 1, Series Temporelles, Sondages, Analyse des données etc.) pour trouver le modèle le plus adapté à votre question.

- Est-ce que vous voulez expliquer ou prédire ? https://hal-cnam.archives-ouvertes.fr/hal-02507348/document
- Est-ce que vous voulez classer un élément dans une catégorie (classification ou clustering) ou prédire une valeur numérique (régression) ?

En fonction des modèles que vous aurez déjà vu en cours et des questions que vous souhaiterez résoudre sur votre jeu de données, le choix du modèle sera souvent assez direct.


Vous pouvez également vous référez à la démarche proposée par Xavier Dupré
http://www.xavierdupre.fr/app/ensae_teaching_cs/helpsphinx3/debutermlprojet.html#l-debutermlprojet

Pour aller plus loin (mais de manière simplifiée) sur les algorithmes de Machine Learning :  
https://datakeen.co/8-machine-learning-algorithms-explained-in-human-language/


### Une démarche éthique

On entend souvent qu'on peut "faire dire ce qu'on veut aux données".

En suivant quelques préceptes simples, mélange d'honneteté intellectuelle et
de recherche scientifique, cette remarque est facilement écartée.
Ces principes ont été repris dans
*"le serment d'Hippocrate du Data Scientist"* : https://hippocrate.tech/.
