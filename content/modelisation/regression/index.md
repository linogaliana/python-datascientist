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
3. Evaluer la pertinence du modèle avec le $R^2$ et la qualité du fit avec le MSE
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
## 19.946649559275073 [-1.28869547e+02  3.43983009e-01 -1.21353543e+00 -1.98739059e-01
##   3.69549853e-01  4.13501039e-02 -3.59661219e+01  8.76347009e-01
##   6.32532377e+01 -5.28588328e-01]
```

```
## Mean squared error: 10.31
```

```
## Coefficient of determination: 0.59
```

{{% panel status="exercise" title="Exercise: régression linéaire avec scikit [parcours économie]" icon="fas fa-pencil-alt" %}}
Cet exercice vise à illustrer la manière d'effectuer une régression linéaire avec `statsmodels` qui offre une interface proche de celle de `R`

L'objectif est d'expliquer le score des Républicains en fonction de quelques
variables

1. A partir de quelques variables, par exemple, *"unemployment", "median_age", "asian", "black", "white_not_latino_population","latino_population", "gini_coefficient", "less_than_high_school", "adult_obesity", "median_earnings_2010_dollars"*, expliquer la variable `rep16_frac`. :warning: utiliser la variable `median_earnings_2010_dollars`
en `log` sinon son échelle risque d'écraser tout effet.
2. Afficher un tableau de régression
3. Evaluer la pertinence du modèle avec le R^2
4. Utiliser l'API `formula` pour régresser le score des républicains en fonction de la variable `unemployment`, de `unemployment` au carré et du log de 
`median_earnings_2010_dollars`
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
##                                  OLS Regression Results                                
## =======================================================================================
## Dep. Variable:             rep16_frac   R-squared (uncentered):                   0.977
## Model:                            OLS   Adj. R-squared (uncentered):              0.976
## Method:                 Least Squares   F-statistic:                          1.291e+04
## Date:                Thu, 12 Nov 2020   Prob (F-statistic):                        0.00
## Time:                        16:23:46   Log-Likelihood:                         -11583.
## No. Observations:                3110   AIC:                                  2.319e+04
## Df Residuals:                    3100   BIC:                                  2.325e+04
## Df Model:                          10                                                  
## Covariance Type:            nonrobust                                                  
## ===============================================================================================
##                                   coef    std err          t      P>|t|      [0.025      0.975]
## -----------------------------------------------------------------------------------------------
## unemployment                 -130.6126      7.576    -17.240      0.000    -145.467    -115.758
## median_age                      0.3444      0.043      8.047      0.000       0.260       0.428
## asian                          -1.0656      0.102    -10.492      0.000      -1.265      -0.866
## black                          -0.2110      0.030     -7.067      0.000      -0.270      -0.152
## white_not_latino_population     0.3744      0.029     13.082      0.000       0.318       0.430
## latino_population               0.0381      0.033      1.155      0.248      -0.027       0.103
## gini_coefficient              -33.7733      5.171     -6.531      0.000     -43.913     -23.634
## less_than_high_school           0.9041      0.037     24.689      0.000       0.832       0.976
## adult_obesity                  65.7221      5.629     11.677      0.000      54.686      76.758
## log_income                      1.2057      0.413      2.918      0.004       0.395       2.016
## ==============================================================================
## Omnibus:                       66.723   Durbin-Watson:                   2.064
## Prob(Omnibus):                  0.000   Jarque-Bera (JB):               75.897
## Skew:                          -0.315   Prob(JB):                     3.31e-17
## Kurtosis:                       3.434   Cond. No.                     3.93e+03
## ==============================================================================
## 
## Notes:
## [1] R² is computed without centering (uncentered) since the model does not contain a constant.
## [2] Standard Errors assume that the covariance matrix of the errors is correctly specified.
## [3] The condition number is large, 3.93e+03. This might indicate that there are
## strong multicollinearity or other numerical problems.
```



```
##                             OLS Regression Results                            
## ==============================================================================
## Dep. Variable:             rep16_frac   R-squared:                       0.114
## Model:                            OLS   Adj. R-squared:                  0.113
## Method:                 Least Squares   F-statistic:                     133.0
## Date:                Thu, 12 Nov 2020   Prob (F-statistic):           4.84e-81
## Time:                        16:23:46   Log-Likelihood:                -12773.
## No. Observations:                3110   AIC:                         2.555e+04
## Df Residuals:                    3106   BIC:                         2.558e+04
## Df Model:                           3                                         
## Covariance Type:            nonrobust                                         
## ========================================================================================================
##                                            coef    std err          t      P>|t|      [0.025      0.975]
## --------------------------------------------------------------------------------------------------------
## Intercept                              239.8566     14.241     16.843      0.000     211.934     267.779
## unemployment                          -226.1863     33.202     -6.812      0.000    -291.286    -161.086
## I(unemployment ** 2)                   293.1405    182.496      1.606      0.108     -64.684     650.965
## np.log(median_earnings_2010_dollars)   -15.8818      1.396    -11.379      0.000     -18.618     -13.145
## ==============================================================================
## Omnibus:                      337.717   Durbin-Watson:                   1.985
## Prob(Omnibus):                  0.000   Jarque-Bera (JB):              457.853
## Skew:                          -0.878   Prob(JB):                    3.79e-100
## Kurtosis:                       3.669   Cond. No.                     7.15e+03
## ==============================================================================
## 
## Notes:
## [1] Standard Errors assume that the covariance matrix of the errors is correctly specified.
## [2] The condition number is large, 7.15e+03. This might indicate that there are
## strong multicollinearity or other numerical problems.
```



{{% panel status="hint" title="Hint" icon="fa fa-lightbulb" %}}
Pour sortir une belle table pour un rapport sous $\LaTeX$, il est possible d'utiliser
la méthode [`Summary.as_latex`](https://www.statsmodels.org/devel/generated/statsmodels.iolib.summary.Summary.as_latex.html#statsmodels.iolib.summary.Summary.as_latex). Pour un rapport HTML, on utilisera [`Summary.as_html`](https://www.statsmodels.org/devel/generated/statsmodels.iolib.summary.Summary.as_latex.html#statsmodels.iolib.summary.Summary.as_latex)
{{% /panel %}}


{{% panel status="note" title="Note" icon="fa fa-comment" %}}
Les utilisateurs de `R` retrouveront des éléments très familiers avec `statsmodels`,
notamment la possibilité d'utiliser une formule pour définir une régression.
La philosophie de `statsmodels` est similaire à celle qui a présidé à la construction
des packages `stats` et `MASS` de `R`: offrir une librairie généraliste, proposant
une large gamme de modèles. Néanmoins, `statsmodels` bénéficie de sa jeunesse
par rapport aux packages `R`. Depuis les années 1990, les packages `R` visant 
à proposer des fonctionalités manquantes dans `stats` et `MASS` se sont
multipliés alors que `statsmodels`, enfant des années 2010, n'a eu qu'à
proposer un cadre général (les *generalized estimating equations*) pour
englober ces modèles.
{{% /panel %}}

## La régression logistique

Ce modèle s'applique à une distribution binaire.
Dans ce cas, $\mathbb{E}\_{\theta}(Y|X) = \mathbb{P}\_{\theta}(Y = 1|X)$.
La régression logistique peut être vue comme un modèle linéaire en probabilité:

$$
\text{logit}\bigg(\mathbb{E}\_{\theta}(Y|X)\bigg) = \text{logit}\bigg(\mathbb{P}\_{\theta}(Y = 1|X)\bigg) = X\beta
$$

La fonction $\text{logit}$ est $]0,1[ \to \mathbb{R}: p \mapsto \log(\frac{p}{1-p})$
permet ainsi de transformer une probabilité dans $\mathbb{R}$.
Sa fonction réciproque est la sigmoïde ($\frac{1}{1 + e^{-x}}$),
objet central du *Deep Learning*.

Il convient de noter que les probabilités ne sont pas observées, c'est l'*outcome*
binaire (0/1) qui l'est. Cela amène à voir la régression logistique de deux
manières différente:

* En économétrie, on s'intéresse au modèle latent qui détermine le choix de
l'outcome. Par exemple, si on observe les choix de participer ou non au marché
du travail, on va modéliser les facteurs déterminant ce choix
* En *Machine Learning*, le modèle latent n'est nécessaire que pour classifier
dans la bonne catégorie les observations

L'estimation des paramètres $\beta$ peut se faire par maximum de vraisemblance
ou par régression, les deux solutions sont équivalentes. 


{{% panel status="note" title="Note" icon="fa fa-comment" %}}
Par défaut, `scikit` applique une régularisation pour pénaliser les modèles
peu parcimonieux (comportement différent
de celui de `statsmodels`). Ce comportement par défaut est à garder à l'esprit
si l'objectif n'est pas de faire de la prédiction. 
{{% /panel %}}

{{% panel status="exercise" title="Régression logistique [data-scientists]" icon="fas fa-pencil-alt" %}}
Avec `scikit`, en utilisant échantillons d'apprentissage et d'estimation:

1. Evaluer l'effet des variables déjà utilisées sur la probabilité des Républicains
de gagner
2. Faire varier le paramètre de régularisation. Quel effet sur les paramètres estimés?
3. Classifier le fait que chaque comté soit ou non gagné par les Républicains en fonction du score prédit. En déduire une matrice de confusion et 
une mesure de qualité du modèle
{{% /panel %}}

{{% panel status="exercise" title="Régression logistique [economists]" icon="fas fa-pencil-alt" %}}
En utilisant échantillons d'apprentissage et d'estimation:

1. Evaluer l'effet des variables déjà utilisées sur la probabilité des Républicains
de gagner
2. Faire un test de ratio de vraisemblance concernant l'inclusion de la variable de (log)-revenu 
{{% /panel %}}

{{% panel status="hint" title="Hint" icon="fa fa-lightbulb" %}}
La statistique du test est:
$$
LR = -2\log\bigg(\frac{\mathcal{L}_{\theta}}{\mathcal{L}_{\theta_0}}\bigg) = -2(\mathcal{l}_{\theta} - \mathcal{l}_{\theta_0})
$$
{{% /panel %}}


```
## <string>:1: SettingWithCopyWarning: 
## A value is trying to be set on a copy of a slice from a DataFrame.
## Try using .loc[row_indexer,col_indexer] = value instead
## 
## See the caveats in the documentation: https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html#returning-a-view-versus-a-copy
```

```
## Optimization terminated successfully.
##          Current function value: 0.467632
##          Iterations 7
```

```
##                            Logit Regression Results                           
## ==============================================================================
## Dep. Variable:                      y   No. Observations:                 3136
## Model:                          Logit   Df Residuals:                     3132
## Method:                           MLE   Df Model:                            3
## Date:                Thu, 12 Nov 2020   Pseudo R-squ.:                 0.05089
## Time:                        16:23:46   Log-Likelihood:                -1466.5
## converged:                       True   LL-Null:                       -1545.1
## Covariance Type:            nonrobust   LLR p-value:                 7.176e-34
## ========================================================================================================
##                                            coef    std err          z      P>|z|      [0.025      0.975]
## --------------------------------------------------------------------------------------------------------
## Intercept                               22.2487      2.623      8.483      0.000      17.108      27.389
## unemployment                           -21.3369      6.419     -3.324      0.001     -33.917      -8.757
## I(unemployment ** 2)                    10.5663     32.923      0.321      0.748     -53.961      75.094
## np.log(median_earnings_2010_dollars)    -1.8915      0.254     -7.448      0.000      -2.389      -1.394
## ========================================================================================================
```

```
## Optimization terminated successfully.
##          Current function value: 0.476741
##          Iterations 7
```



## Modèles linéaires généralisés

## Autres modèles de Machine Learning



## Tests d'hypothèses

