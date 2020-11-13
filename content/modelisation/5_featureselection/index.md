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
title: "Sélection de variables: une introduction"
date: 2020-10-15T13:00:00Z
draft: false
weight: 50
output: 
  html_document:
    keep_md: true
    self_contained: true
slug: lasso
---






Pour illustrer le travail de données nécessaire pour faire de la sélection de variable,
nous allons partir du jeu de données de [résultat des élections US 2016 au niveau des comtés](https://public.opendatasoft.com/explore/dataset/usa-2016-presidential-election-by-county/download/?format=geojson&timezone=Europe/Berlin&lang=fr)


Jusqu'à présent, nous avons supposé que les variables permettant d'éclairer le
vote Républicain étaient connues. Nous n'avons ainsi exploité qu'une partie
limitée de l'information disponible dans nos données. Néanmoins, outre le fléau
computationnel que représenterait la construction d'un modèle avec un grand
nombre de variable, le choix d'un nombre restreint de variables
(modèle parcimonieux) limite le risque de sur-apprentissage.

Comment, dès-lors, choisir le bon nombre de variables et la meilleure
combinaison de ces variables ? Il existe de multiples méthodes, parmi lesquelles :

* se fonder sur des critères statistiques de performance qui pénalisent les
modèles non parcimonieux. Par exemple, le BIC
* techniques de *backward elimination*
* construire des modèles pour lesquels la statistique d'intérêt pénalise l'absence
de parcimonie. 


La classe des modèles de *feature selection* est ainsi très vaste et regroupe
un ensemble très diverse de modèles. Nous allons nous focaliser sur le LASSO
(*Least Absolute Shrinkage and Selection Operator*)
qui est une extension de la régression linéaire qui vise à sélectionner des
modèles *sparses*. Ce type de modèle est central dans le champ du 
*Compressed sensing* (où on emploie plutôt le terme 
de *L1-regularization* que de LASSO). Le LASSO est un cas particulier des
régressions elastic-net dont un autre cas fameux est la régression *ridge*.
Contrairement à la régression linéaire classique, elles fonctionnent également
dans un cadre où $p>N$, c'est à dire où le nombre de régresseur est supérieur
au nombre d'observations.

Le lien pour importer le fichier en csv est [là](https://public.opendatasoft.com/explore/dataset/usa-2016-presidential-election-by-county/download/?format=geojson&timezone=Europe/Berlin&lang=fr)



## Principe

En adoptant le principe d'une fonction objectif pénalisée, le LASSO permet de fixer un certain nombre de coefficients à 0. Les variables dont la norme est non nulle passent ainsi le test de sélection. 

{{% panel status="hint" title="Hint" icon="fa fa-lightbulb" %}}
Le LASSO est un programme d'optimisation sous contrainte. On cherche à trouver l'estimateur $\beta$ qui minimise l'erreur quadratique (régression linéaire) sous une contrainte additionnelle régularisant les paramètres:
$$
\min_{\beta} \frac{1}{2}\mathbb{E}\bigg( \big( X\beta - y  \big)^2 \bigg) \\
\text{s.t. } \sum_{j=1}^p |\beta_j| \leq t
$$
Ce programme se reformule grâce au Lagrangien est permet ainsi d'obtenir un programme de minimisation plus maniable: 
$$
\beta^{\text{LASSO}} = \arg \min_{\beta} \frac{1}{2}\mathbb{E}\bigg( \big( X\beta - y  \big)^2 \bigg) + \alpha \sum_{j=1}^p |\beta_j| = \arg \min_{\beta} ||y-X\beta||_{2}^{2} + \alpha ||\beta||_1
$$
où $\lambda$ est une réécriture de la régularisation précédente. 
{{% /panel %}}

warning: sélection de variables corrélées

## Première régression LASSO

Avant de se lancer dans les exercices, on va éliminer quelques colonnes redondantes, celles qui terminent par `_frac2`:


```python
df2 = df.loc[:,~df.columns.str.endswith('frac2')]
```


{{% panel status="exercise" title="Exercise 1: premier LASSO" icon="fas fa-pencil-alt" %}}
1. Importer les données (l'appeler `df`)
2. Standardiser les variables. :warning: Avant ça,
ne garder que les colonnes numériques (idéalement on transformerait
les variables non numériques en numériques)
3. Estimer un modèle LASSO. Afficher les valeurs des coefficients: qu'en déduire sur le modèle idéal ? Quelle variable a une valeur non nulle ?
4. Faire une régression linéaire avec le modèle parcimonieux et comparer la
performance à un modèle avec plus de variables
{{% /panel %}}



Les coefficients estimés sont ainsi les suivants:


```
## array([0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.07813951,
##        0.        , 0.        , 0.        , 0.        , 0.        ,
##        0.        , 0.        , 0.        , 0.        , 0.        ])
```

Le modèle est donc extrêmement parcimonieux puisque, avec le paramètre par défaut, seulement une variable explicative est sélectionnée. La variable sélectionnée est


```python
df2.select_dtypes(include=np.number).drop("rep16_frac", axis = 1).columns[np.abs(lasso1.coef_)>0]
```

```
## Index(['rep12_frac'], dtype='object')
```

Autrement dit, le meilleur prédicteur pour le score des Républicains en 2016 est... le score des Républicains en 2012.
D'ailleurs, cette information est de loin la meilleure pour prédire le score 
des Républicains au point que si on tente de faire varier $\alpha$, un 
hyperparamètre du LASSO, on continuera à ne sélectionner qu'une seule variable



```python
import statsmodels.api as sm
import statsmodels.formula.api as smf
print(smf.ols("rep16_frac ~ rep12_frac", data = df2).fit().summary())
```

```
##                             OLS Regression Results                            
## ==============================================================================
## Dep. Variable:             rep16_frac   R-squared:                       0.873
## Model:                            OLS   Adj. R-squared:                  0.873
## Method:                 Least Squares   F-statistic:                 2.142e+04
## Date:                Fri, 13 Nov 2020   Prob (F-statistic):               0.00
## Time:                        11:49:59   Log-Likelihood:                -9751.5
## No. Observations:                3111   AIC:                         1.951e+04
## Df Residuals:                    3109   BIC:                         1.952e+04
## Df Model:                           1                                         
## Covariance Type:            nonrobust                                         
## ==============================================================================
##                  coef    std err          t      P>|t|      [0.025      0.975]
## ------------------------------------------------------------------------------
## Intercept      4.6048      0.415     11.088      0.000       3.791       5.419
## rep12_frac     0.9888      0.007    146.359      0.000       0.976       1.002
## ==============================================================================
## Omnibus:                      699.498   Durbin-Watson:                   1.972
## Prob(Omnibus):                  0.000   Jarque-Bera (JB):             3668.670
## Skew:                          -0.970   Prob(JB):                         0.00
## Kurtosis:                       7.954   Cond. No.                         256.
## ==============================================================================
## 
## Notes:
## [1] Standard Errors assume that the covariance matrix of the errors is correctly specified.
```

La performance du modèle est déjà très bonne, avec une seule variable explicative.

Pour la suite, on va ainsi se contenter de variables moins bonnes mais qui 
présentent un intérêt pour la sélection.



## Effet du paramètre de pénalisation sur la sélection de variables

{{% panel status="exercise" title="Exercise 2: parcimonie et paramètre alpha" icon="fas fa-pencil-alt" %}}
1. Utiliser la fonction `lasso_path` pour évaluer le nombre de paramètres sélectionnés par LASSO lorsque $\alpha$
varie (parcourir $[0,1]$ pour les valeurs de $\alpha$)
2. Regarder les paramètres qui sont sélectionnés pour, par exemple, $\alpha=0.5$
{{% /panel %}}



```
## C:\Users\W3CRK9\AppData\Local\R-MINI~1\envs\R-RETI~1\lib\site-packages\sklearn\linear_model\_coordinate_descent.py:525: ConvergenceWarning: Objective did not converge. You might want to increase the number of iterations. Duality gap: 133.78377875999269, tolerance: 0.3641845593972687
##   model = cd_fast.enet_coordinate_descent_gram(
```

```
## [Text(0.5, 1.0, 'Number variables and regularization parameter ($\\alpha$)'), Text(0.5, 0, '$\\alpha$'), Text(0, 0.5, 'Nb. de variables')]
```

{{<figure src="lassoplot-1.png" >}}




Les variables sélectionnées, lorsque $\alpha = 0.2$, sont les suivantes:


```
## Index(['asian', 'sexually_transmitted_infections',
##        'white_not_latino_population', 'graduate_degree', 'summer_tmax', 'lat',
##        'green16_frac'],
##       dtype='object')
```

On voit ici que le LASSO sélectionne des variables mais celles-ci peuvent en fait masquer d'autres variables omises. Par exemple, la variable `lat` est une approximation de la géographie du vote: les Etats du Sud votant majoritairement Républicain, les Etats du nord plutôt démocrate.

## Validation croisée pour sélectionner le modèle

Faut-il privilégier le modèle où $\alpha = 1$ ou $\alpha = 0.2$ ? Pour cela, 
il convient d'effectuer une validation croisée afin de prendre le modèle pour
lequel les variables qui passent la phase de sélection permettent de mieux 
prédire le résultat Républicain.


```
## C:\Users\W3CRK9\AppData\Local\R-MINI~1\envs\R-RETI~1\lib\site-packages\sklearn\linear_model\_coordinate_descent.py:525: ConvergenceWarning: Objective did not converge. You might want to increase the number of iterations. Duality gap: 119.61730421758679, tolerance: 0.2944938097303203
##   model = cd_fast.enet_coordinate_descent_gram(
## C:\Users\W3CRK9\AppData\Local\R-MINI~1\envs\R-RETI~1\lib\site-packages\sklearn\linear_model\_coordinate_descent.py:525: ConvergenceWarning: Objective did not converge. You might want to increase the number of iterations. Duality gap: 111.44954361639327, tolerance: 0.2890033442847753
##   model = cd_fast.enet_coordinate_descent_gram(
## C:\Users\W3CRK9\AppData\Local\R-MINI~1\envs\R-RETI~1\lib\site-packages\sklearn\linear_model\_coordinate_descent.py:525: ConvergenceWarning: Objective did not converge. You might want to increase the number of iterations. Duality gap: 119.02090913369085, tolerance: 0.2912967453299923
##   model = cd_fast.enet_coordinate_descent_gram(
## C:\Users\W3CRK9\AppData\Local\R-MINI~1\envs\R-RETI~1\lib\site-packages\sklearn\linear_model\_coordinate_descent.py:525: ConvergenceWarning: Objective did not converge. You might want to increase the number of iterations. Duality gap: 103.23238773456268, tolerance: 0.28747735770517546
##   model = cd_fast.enet_coordinate_descent_gram(
## C:\Users\W3CRK9\AppData\Local\R-MINI~1\envs\R-RETI~1\lib\site-packages\sklearn\linear_model\_coordinate_descent.py:525: ConvergenceWarning: Objective did not converge. You might want to increase the number of iterations. Duality gap: 116.27489769682421, tolerance: 0.29446698053881165
##   model = cd_fast.enet_coordinate_descent_gram(
## C:\Users\W3CRK9\AppData\Local\R-MINI~1\envs\R-RETI~1\lib\site-packages\sklearn\linear_model\_coordinate_descent.py:529: ConvergenceWarning: Objective did not converge. You might want to increase the number of iterations. Duality gap: 141.1966276706751, tolerance: 0.3641845593972687
##   model = cd_fast.enet_coordinate_descent(
```

```
## 0.001
```


```
## C:\Users\W3CRK9\AppData\Local\R-MINI~1\envs\R-RETI~1\lib\site-packages\sklearn\linear_model\_coordinate_descent.py:529: ConvergenceWarning: Objective did not converge. You might want to increase the number of iterations. Duality gap: 141.1966276706751, tolerance: 0.3641845593972687
##   model = cd_fast.enet_coordinate_descent(
```

```
## Index(['unemployment', 'median_age',
##        'management_professional_and_related_occupations',
##        'poor_mental_health_days', 'total_population',
##        'sexually_transmitted_infections', 'black', 'autumn_tmin',
##        'white_not_latino_population', 'elevation', 'graduate_degree',
##        'annual_tmax', 'gini_coefficient', 'amerindian',
##        'preschool_enrollment_ratio_enrolled_ages_3_and_4', 'summer_tmax',
##        'spring_tavg', 'poor_physical_health_days',
##        'at_least_bachelor_s_degree', 'meanalc', 'spring_tmax', 'spring_tmin',
##        'summer_prcp', 's', 'farming_fishing_and_forestry_occupations',
##        'less_than_high_school', 'population_some_other_race_or_races',
##        'adult_obesity', 'ca', 'sire_homogeneity',
##        'sales_and_office_occupations', 'service_occupations',
##        'construction_extraction_maintenance_and_repair_occupations', 'lon',
##        'summer_tavg', 'adults_65_and_older_living_in_poverty', 'white',
##        'children_in_single_parent_households', 'violent_crime',
##        'child_poverty_living_in_families_below_the_poverty_line',
##        'median_earnings_2010_dollars', 'temp', 'at_least_high_school_diploma',
##        'summer_tmin', 'maxalc', 'acfs',
##        'poverty_rate_below_federal_poverty_threshold', 'nearest_county', 'mar',
##        'lat', 'autumn_prcp', 'diabetes', 'spring_prcp', 'hispanic',
##        'school_enrollment', 'autumn_tmax', 'uninsured', 'other08_frac',
##        'other12', 'est_votes_remaining', 'low_birthweight', 'reporting',
##        'green16_frac', 'votes16_johnsong', 'votes16_clintonh',
##        'votes16_trumpd', 'other16_frac', 'precincts', 'other12_frac',
##        'teen_births', 'votes16_steinj', 'homicide_rate', 'hiv_prevalence_rate',
##        'votes16_castled', 'infant_mortality', 'votes16_de_la_fuenter',
##        'votes16_mcmulline', 'votes16_hedgesj'],
##       dtype='object')
```




ce qui correspond à un modèle avec 78 variables sélectionnées. C'est sans aucun doute trop peu parcimonieux : il faudrait revoir la phase de définition des variables pertinentes pour comprendre si des échelles différentes de certaines variables ne seraient pas plus appropriées (par exemple du `log`). 
