---
title: "Partie 4: Natural Language Processing (NLP)"
date: 2020-10-14T13:00:00Z
draft: false
weight: 39
slug: "nlp"
icon: book
icon_pack: fas
#linktitle: "Partie 4: Natural Language Processing (NLP)"
summary: |
  L'un des grands avantages comparatifs de Python par rapport aux
  langages concurrents (R notamment) est dans
  la richesse des librairies de Traitement du Langage Naturel (mieux
  connu sous son acronyme anglais : NLP pour natural langage processing).
  Cette partie vise à illustrer la richesse de cet écosystème à partir
  de quelques exemples littéraires:  Dumas, Poe, Shelley, Lovecraft.
type: book
---

Cette partie du cours est consacrée à l'analyse des données textuelles avec
des exemples de :books: pour s'amuser. 

Dans un premier temps, cette partie propose d'explorer *bag of words* 
pour montrer comment transformer un corpus en outil propre à une 
analyse statistique:

* Elle propose d'abord une introduction aux enjeux du nettoyage des données
textuelles à travers l'analyse du *Comte de Monte Cristo* d'Alexandre Dumas
[ici](#nlpintro)
* Elle propose une série d'exercices sur le nettoyage de textes à partir des
oeuvres d'Edgar Allan Poe, Mary Shelley et H.P. Lovecraft. 

Ensuite, nous proposerons d'explorer une approche alternative, prenant en compte
le contexte d'apparition d'un mot. L'introduction à la
_Latent Dirichlet Allocation_ sera l'occasion de présenter la modélisation
de documents sous la forme de *topics*.

Enfin, nous introduirons aux enjeux de la transformation de champs textuels
sous forme de vecteurs numériques. Pour cela, nous présenterons le principe
de `Word2Vec` qui permet ainsi, par exemple,
malgré une distance syntaxique importante,
de dire que sémantiquement `Homme` et `Femme` sont proches.


## Contenu de la partie

{{< list_children >}}