---
jupyter:
  jupytext:
    text_representation:
      extension: .Rmd
      format_name: rmarkdown
      format_version: '1.2'
      jupytext_version: 1.6.0
  kernelspec:
    display_name: Python 3
    language: python
    name: python3
title: "Régression: une introduction"
date: 2020-10-15T13:00:00Z
draft: false
weight: 40
output: 
  html_document:
    keep_md: true
    self_contained: true
slug: regression
---





Pour illustrer le travail de données nécessaire pour construire un modèle de Machine Learning, mais aussi nécessaire pour l'exploration de données avant de faire une régression linéaire, nous allons partir du jeu de données de [résultat des élections US 2016 au niveau des comtés](https://public.opendatasoft.com/explore/dataset/usa-2016-presidential-election-by-county/download/?format=geojson&timezone=Europe/Berlin&lang=fr)


{{% panel status="exercise" title="Exercise 1: importer les données" icon="fas fa-pencil-alt" %}}
1. Importer les données (l'appeler `df`) des élections américaines et regarder les informations dont on dispose
2. Créer une variable `republican_winner` égale à `red`  quand la variable `rep16_frac` est supérieure à `dep16_frac` (`blue` sinon)
3. Représenter une carte des résultats avec en rouge les comtés où les républicains ont gagné et en bleu ceux où se sont
les démocrates
{{% /panel %}}



Le principe général de la régression consiste à trouver une loi $h_\theta(X)$
telle que

$$
h_\theta(X) = \mathbb{E}_\theta(Y|X)
$$
Cette formalisation est extrêmement généraliste et ne se restreint d'ailleurs
par à la régression linéaire. 

En économétrie, la régression offre une alternative aux méthodes de maximum
de vraisemblance et aux méthodes de moment. La régression est un ensemble 
très vaste de méthodes, selon la famille de modèles
(paramétriques, non paramétriques, etc.) et la structure de modèles. 
En *Machine Learning* 

## La régression linéaire

C'est la manière la plus simple de représenter la loi $h_\theta(X)$ comme 
combinaison linéaire de variables $X$ et de paramètres $\theta$. Dans ce
cas, 

$$
\mathbb{E}_\theta(Y|X) = X\beta
$$


Cette relation est encore, sous cette formulation, théorique. Il convient 
de l'estimer à partir des données observées $y$. La méthode des moindres
carrés consiste à minimiser l'erreur quadratique entre la prédiction et 
les données observées (ce qui explique qu'on puisse voir la régression comme
un problème de *Machine Learning*). En toute généralité, la méthode des
moindres carrés consiste à minimiser la g

$$
\min_{\theta} \mathbb{E}\bigg[ \left( y - h_\theta(X) \right)^2 \bigg]
$$

Ce qui, dans le cadre de la régression linéaire, s'exprime de la manière suivante:

$$
\beta = \arg\min \mathbb{E}\bigg[ \left( y - X\beta \right)^2 \bigg]
$$

Lorsqu'on amène le modèle théorique ($\mathbb{E}_\theta(Y|X) = X\beta$) aux données,
on formalise le modèle de la manière suivante:

$$
Y = X\beta + \epsilon
$$

Avec une certaine distribution du bruit $\epsilon$ qui dépend
des hypothèses faites. Par exemple, avec des 
$\epsilon \sim \mathcal{N}(0,\sigma^2)$ i.i.d., l'estimateur $\beta$ obtenu
est équivalent à celui du Maximum de Vraisemblance dont la théorie asymptotique
nous assure l'absence de biais, la variance minimale (borne de Cramer-Rao).

{{% panel status="exercise" title="Exercise: régression linéaire avec scikit [parcours data-science]" icon="fas fa-pencil-alt" %}}
Cet exercice vise à illustrer la manière d'effectuer une régression linéaire avec scikit. Dans ce domaine,
`statsmodels` est néanmoins plus complet, ce que montrera l'exercice suivant. L'intérêt de faire 
des régressions avec `scikit` est de pouvoir comparer les résultats d'une régression linéaire
avec d'autres modèles de régression.

L'objectif est d'expliquer le score des Républicains en fonction de quelques
variables

1. A partir de quelques variables, par exemple, *"unemployment", "median_age", "asian", "black", "white_not_latino_population","latino_population", "gini_coefficient", "less_than_high_school", "adult_obesity", "median_earnings_2010_dollars"*, expliquer la variable `rep16_frac`. :warning: utiliser la variable `median_earnings_2010_dollars`
en `log` sinon son échelle risque d'écraser tout effet.
2. Afficher les valeurs des coefficients, constante comprise
3. Evaluer la pertinence du modèle avec le R^2 et la qualité du fit avec le MSE
4. Représenter un nuage de point des valeurs observées
et des erreurs de prédiction. Observez-vous
un problème de spécification

{{% /panel %}}



```
## C:\Users\W3CRK9\AppData\Local\R-MINI~1\envs\R-RETI~1\lib\site-packages\pandas\core\series.py:726: RuntimeWarning: divide by zero encountered in log
##   result = getattr(ufunc, method)(*inputs, **kwargs)
## <string>:1: SettingWithCopyWarning: 
## A value is trying to be set on a copy of a slice from a DataFrame.
## Try using .loc[row_indexer,col_indexer] = value instead
## 
## See the caveats in the documentation: https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html#returning-a-view-versus-a-copy
```

```
## 21.529665435871834 [-1.28768371e+02  3.67836166e-01 -9.49273221e-01 -2.01894406e-01
##   3.77692350e-01  2.93314498e-02 -3.66691048e+01  8.75165180e-01
##   6.35410981e+01 -8.29884257e-01]
```

```
## Mean squared error: 9.92
```

```
## Coefficient of determination: 0.59
```

Avec ce modèle, on se trompe ainsi, en moyenne de 9.9 points
et on explique 59 % de la variance observée des scores républicains.
Le nuage de point suggère 

{{<figure src="unnamed-chunk-4-1.png" >}}



## La régression logistique

Ce modèle s'applique à une distribution binaire.
Dans ce cas, $\mathbb{E}_{\theta}(Y|X) = \mathbb{P}_{\theta}(Y = 1|X)$.
La régression logistique peut être vue comme un modèle linéaire en probabilité:

$$
\text{logit}\bigg(\mathbb{E}_\theta(Y|X)\bigg) = \text{logit}\bigg(\mathbb{P}_\theta(Y = 1|X)\bigg) = X\beta
$$

La fonction $\text{logit}$ est $]0,1[ \to \mathbb{R}: p \mapsto \log(\frac{p}{1-p})$
permet ainsi de transformer une probabilité dans $\mathbb{R}$.
Sa fonction réciproque est la sigmoïde ($\frac{1}{1 + e^{-x}}$),
objet central du *Deep Learning*.

Il convient de noter que les probabilités ne sont pas observées, c'est l'*outcome*
binaire (0/1) qui l'est. Selon amène à voir la régression logistique de deux
manières différente:

* En économétrie, on s'intéresse au modèle latent qui détermine le choix de
l'outcome. Par exemple, si on observe les choix de participer ou non au marché
du travail, on va modéliser les facteurs déterminant ce choix
* En *Machine Learning*, le modèle latent n'est nécessaire que pour classifier
dans la bonne catégorie les observations


## Modèles linéaires généralisés

## Tests d'hypothèses

