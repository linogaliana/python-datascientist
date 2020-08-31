---
jupyter:
  jupytext:
    formats: ipynb,md
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.2'
      jupytext_version: 1.5.2
  kernelspec:
    display_name: Python 3
    language: python
    name: python3
title: "Introduction à pandas"
date: 2020-07-28T13:00:00Z
draft: false
weight: 100
output: 
  html_document:
    keep_md: true
    self_contained: true
---

Dans ce tutoriel `pandas`, nous allons utiliser:

* Les émissions de gaz à effet de serre estimées au niveau communal par l'ADEME. Le jeu de données est 
disponible sur [data.gouv](https://www.data.gouv.fr/fr/datasets/inventaire-de-gaz-a-effet-de-serre-territorialise/#_)
et requêtable directement dans python avec
[cet url](https://koumoul.com/s/data-fair/api/v1/datasets/igt-pouvoir-de-rechauffement-global/convert)
* Quelques données de contexte au niveau communal
[disponibles sur le site de l'Insee](https://www.insee.fr/fr/statistiques/3560121)
requêtables avec Python en utilisant cet
[url](https://www.insee.fr/fr/statistiques/fichier/3560121/filo-revenu-pauvrete-menage-2015.zip)


:warning: `pandas` offre la possibilité d'importer des données directement depuis un url. C'est l'option
prise dans ce tutoriel.
Si vous préfèrez, pour des
raisons d'accès au réseau ou de performance, importer depuis un poste local,
vous pouvez télécharger les données et changer
les commandes d'import avec le chemin adéquat plutôt que l'url. 

Nous suivrons les conventions habituelles dans l'import des packages


```python
import numpy as np
import pandas as pd
```

# Logique de pandas

L'objet central dans la logique `pandas` est le `DataFrame`.
Il s'agit d'une structure particulière de données
à deux dimensions, structurées en alignant des lignes et colonnes. Les colonnes
peuvent être de type différent. 

Un DataFrame est composé des éléments suivants:

* l'indice de la ligne ;
* le nom de la colonne ;
* la valeur de la donnée ;

<div class="figure">
<img src="https://miro.medium.com/max/700/1*6p6nF4_5XpHgcrYRrLYVAw.png" alt="Structuration d'un DataFrame pandas, emprunté à &lt;https://medium.com/epfl-extension-school/selecting-data-from-a-pandas-dataframe-53917dc39953&gt;" width="100%" />
<p class="caption">Structuration d'un DataFrame pandas, emprunté à <https://medium.com/epfl-extension-school/selecting-data-from-a-pandas-dataframe-53917dc39953></p>
</div>

:warning: Les DataFrames sont assez rapides en Python[^1] et permettent de traiter de manière efficace des tables de
données comportant plusieurs millions d'observations et dont la volumétrie peut être conséquente (plusieurs centaines
de Mo). Néanmoins,  passé un certain seuil, qui dépend de la puissance de la machine mais aussi de la complexité
de l'opération effectuée, le DataFrame `pandas` peut montrer certaines limites. Dans ce cas, il existe différentes
solutions: `dask` (dataframe aux opérations parallélisés), SQL (notamment posgres), spark (solution big data)

[^1]:  En `R`, les deux formes de dataframes qui se sont imposées récemment sont les `tibbles` (package `dplyr`)
et les `data.tables` (package `data.table`). `dplyr` reprend la syntaxe SQL de manière relativement
transparente ce qui rend la syntaxe très proche de celle de `pandas`. Cependant, 
alors que `dplyr` supporte très mal les données dont la volumétrie dépasse 1Go, `pandas` s'en
accomode bien. Les performances de `pandas` sont plus proches de celles de `data.table`, qui est 
connu pour être une approche efficace avec des données de taille importante. 

Concernant la syntaxe, une partie des commandes python est inspirée par la logique SQL. On retrouvera ainsi
des instructions relativement transparentes.

Il est vivement recommandé, avant de se lancer dans l'écriture d'une
fonction, de se poser la question de son implémentation native dans `numpy`, `pandas`, etc. 
En particulier, la plupart du temps, les boucles sont à bannir. 



# Les Series

En fait, un DataFrame est une collection d'objets appelés `pandas.Series`. 
Ces `Series` sont des objets d'une dimension qui sont des extensions des
array-unidimensionnels `numpy`. En particulier, pour faciliter le traitement
de données catégorielles ou temporelles, des types de variables
supplémentaires sont disponibles dans `pandas` par rapport à
`numpy` (`categorical`, `datetime64` et `timedelta64`). Ces
types sont associés à des méthodes optimisées pour faciliter le traitement
de ces données.

Il ne faut pas négliger l'attribut `dtype` d'un objet
`pandas.Series` car cela a une influence déterminante sur les méthodes
et fonctions pouvant être utilisés (on ne fait pas les mêmes opérations
sur une donnée temporelle et une donnée catégorielle) et le volume en
mémoire d'une variable (le type de la variable détermine le volume
d'information stocké pour chaque élément ; être trop précis est parfois
néfaste).


### Indexation

La différence essentielle entre une `Series` et un objet `numpy` est l'indexation. Dans `numpy`,
l'indexation est implicite ; elle permet d'accéder à une donnée (celle à
l'index situé à la position *i*).
Avec une `Series`, on peut bien-sûr utiliser un indice de position mais on peut 
surtout faire appel à des indices plus explicites.
Par exemple,


```python
taille = pd.Series(
    [1.,1.5,1],
    index = ['chat', 'chien', 'koala']
)

taille.head()
```

```
## chat     1.0
## chien    1.5
## koala    1.0
## dtype: float64
```


Cette indexation permet d'accéder à des valeurs de la `Series`
via une valeur de l'indice. Par
exemple, `taille['koala']`:


```python
taille['koala']
```

```
## 1.0
```

L'existence d'indice rend le *subsetting* particulièrement aisé,
**cf.exo**

Pour transformer un objet `pandas.Series` en array `numpy`, 
on utilise la méthode `values`. Par exemple, `taille.values`:


```python
taille.values
```

```
## array([1. , 1.5, 1. ])
```

Un avantage des `Series` par rapport à un *array* `numpy` est que
les opérations sur les `Series` alignent
automatiquement les données à partir des labels.
Avec des `Series` labélisées, il n'est ainsi pas nécessaire
de se poser la question de l'ordre des lignes.
L'exemple dans la partie suivante permettra de s'en assurer.


### Valeurs manquantes

Par défaut, les valeurs manquantes sont affichées `NaN` et sont de type `np.nan` (pour 
les valeurs temporelles, i.e. de type `datatime64`, les valeurs manquantes sont
`NaT`).

:warning: Il faut **vraiment faire attention** aux valeurs manquantes, notamment lorsqu'on utilise les
méthodes de statistiques descriptives présentées ultérieurement. Les règles sont les suivantes: 

* Dans les opérations de somme ou de moyenne d'une valeur, les valeurs manquantes
 sont traitées comme des `0`. C'est un comportement par défaut différent
 de celui de `R` où les opérations `sum`, `mean`, etc. renvoient un `NA`.
 __C'est très dangereux pour la moyenne__: la valeur n'est pas ignorée, elle est traitée comme un
 `0` (ce qui biaise la moyenne). Le paramètre crucial à changer pour
 ignorer la valeur (et non la remplacer par 0!) est `skipna` (cet argument
 permettant un comportement équivalent à `na.rm = TRUE` en `R`).
 Pour plus de détails, `help(pandas.Series.sum)`. 
* Les méthodes `cumsum` et `cumprod` ignorent les `NA` par défaut mais les préservent dans le vecteur de sortie.

En revanche, on a un comportement cohérent d'agrégation lorsqu'on combine deux `DataFrames` (ou deux colonnes).
Par exemple,


```python
x = pd.DataFrame(
    {'prix': np.random.uniform(size = 5),
     'quantite': [i+1 for i in range(5)]
    },
    index = ['yaourt','pates','riz','tomates','gateaux']
)

y = pd.DataFrame(
    {'prix': [np.nan, 0, 1, 2, 3],
     'quantite': [i+1 for i in range(5)]
    },
    index = ['tomates','yaourt','gateaux','pates','riz']
)

x + y
```

```
##              prix  quantite
## gateaux  1.397704         8
## pates    2.520899         6
## riz      3.860753         8
## tomates       NaN         5
## yaourt   0.159384         3
```

donne bien une valeur manquante pour la ligne `tomates`. Au passage, on peut remarquer que l'agrégation
a tenu compte des index. 


# Le DataFrame pandas

Le `DataFrame` est l'objet central du package `pandas`.
Il s'agit d'une collection de `pandas.Series` (colonnes) alignés par les lignes.
Les types des variables peuvent différer. 

Un DataFrame non-indexé a la structure suivante:  

<!-----
Exo 1
Aller dans la doc pandas et trouver comment créer le dataFrame pandas suivant
------>


```
##        taille  poids
## chat      1.0    3.0
## chien     1.5    5.0
## koala     1.0    2.5
```

<!-----
Exo2: multiindex sur la base Ademe
------>


## Les attributs et méthodes utiles

Pour présenter les méthodes les plus pratiques pour l'analyse de données,
on peut partir de l'exemple des consommations de CO2 communales issues
des données de l'Ademe. 


```python
df = pd.read_csv("https://koumoul.com/s/data-fair/api/v1/datasets/igt-pouvoir-de-rechauffement-global/convert")
df.head()
```

```
##   INSEE commune                  Commune  ...       Routier     Tertiaire
## 0         01001  L'ABERGEMENT-CLEMENCIAT  ...    793.156501    367.036172
## 1         01002    L'ABERGEMENT-DE-VAREY  ...    348.997893    112.934207
## 2         01004        AMBERIEU-EN-BUGEY  ...  15642.420310  10732.376930
## 3         01005      AMBERIEUX-EN-DOMBES  ...   1756.341319    782.404357
## 4         01006                  AMBLEON  ...    398.786800     51.681756
## 
## [5 rows x 12 columns]
```

:warning: `head` dans un notebook avec des données confidentielles et `git`


### Dimensions et structure du DataFrame


```python
df.axes
```

```
## [RangeIndex(start=0, stop=35798, step=1), Index(['INSEE commune', 'Commune', 'Agriculture', 'Autres transports',
##        'Autres transports international', 'CO2 biomasse hors-total', 'Déchets',
##        'Energie', 'Industrie hors-énergie', 'Résidentiel', 'Routier',
##        'Tertiaire'],
##       dtype='object')]
```

```python
df.ndim
```

```
## 2
```

```python
df.shape
```

```
## (35798, 12)
```

```python
df.head()
```

```
##   INSEE commune                  Commune  ...       Routier     Tertiaire
## 0         01001  L'ABERGEMENT-CLEMENCIAT  ...    793.156501    367.036172
## 1         01002    L'ABERGEMENT-DE-VAREY  ...    348.997893    112.934207
## 2         01004        AMBERIEU-EN-BUGEY  ...  15642.420310  10732.376930
## 3         01005      AMBERIEUX-EN-DOMBES  ...   1756.341319    782.404357
## 4         01006                  AMBLEON  ...    398.786800     51.681756
## 
## [5 rows x 12 columns]
```

```python
df.columns
```

```
## Index(['INSEE commune', 'Commune', 'Agriculture', 'Autres transports',
##        'Autres transports international', 'CO2 biomasse hors-total', 'Déchets',
##        'Energie', 'Industrie hors-énergie', 'Résidentiel', 'Routier',
##        'Tertiaire'],
##       dtype='object')
```

### Statistiques agrégées


```python
df.count()
```

```
## INSEE commune                      35798
## Commune                            35798
## Agriculture                        35736
## Autres transports                   9979
## Autres transports international     2891
## CO2 biomasse hors-total            35798
## Déchets                            35792
## Energie                            34490
## Industrie hors-énergie             34490
## Résidentiel                        35792
## Routier                            35778
## Tertiaire                          35798
## dtype: int64
```

```python
df.describe()
```

```
##         Agriculture  Autres transports  ...        Routier      Tertiaire
## count  35736.000000        9979.000000  ...   35778.000000   35798.000000
## mean    2459.975760         654.919940  ...    3535.501245    1105.165915
## std     2926.957701        9232.816833  ...    9663.156628    5164.182507
## min        0.003432           0.000204  ...       0.555092       0.000000
## 25%      797.682631          52.560412  ...     419.700460      94.749885
## 50%     1559.381286         106.795928  ...    1070.895593     216.297718
## 75%     3007.883903         237.341501  ...    3098.612157     576.155869
## max    98949.317760      513140.971700  ...  586054.672800  288175.400100
## 
## [8 rows x 10 columns]
```

### Méthodes relatives aux valeurs manquantes

```python
Series.isnull, Series.notnull.
Series.isna, Series.notna
```

# Graphiques rapides

Les méthodes par défaut de graphique (approfondies dans le chapitre matplotlib/seaborn)

```python
df['Déchets'].plot()
df['Déchets'].hist()
df['Déchets'].plot(kind = 'hist', logy = True)
```

# Accéder à des éléments d'un DataFrame

```python
df = pd.read_csv("https://koumoul.com/s/data-fair/api/v1/datasets/igt-pouvoir-de-rechauffement-global/convert")
```

Pour accéder à une colonne dans son ensemble on peut utiliser plusieurs approches:

* `dataframe.variable`, par exemple `df.Energie`. Cette méthode requiert néanmoins d'avoir des 
noms de colonnes sans espace. 
* `dataframe[['variable']]` pour renvoyer la variable sous forme de `DataFrame` ou dataframe['variable'] pour
la renvoyer sous forme de `Series`. Par exemple, `df[['Autres transports']]` 
 ou `df['Autres transports']`. C'est une manière préférable de procéder.

Pour accéder à une ou plusieurs valeurs d'un `DataFrame`, il existe trois manières de procéder, selon la 
forme des indices de lignes ou colonnes utilisés:

* `df.loc`
* `df.iloc`
* `df[]`

Les bouts de code utilisant la structure `df.ix` sont à bannir car la fonction est *deprecated* et peut
ainsi disparaître à tout moment. 


data.loc[1:3]
data.loc[(data.age >= 20), ['section', 'city']]

data.iloc[[0,2]]
data.iloc[[0,2],[1,3]]
data.iloc[1:3,2:4]

data.loc[(data.age >= 12), ['section']]


## Principales manipulation de données

Les opérations les plus fréquentes en SQL sont résumées par le tableau suivant.
Il est utile de les connaître (beaucoup de syntaxes de maniement de données
reprennent ces termes) car, d'une manière ou d'une autre, elles couvrent la plupart
des usages de manipulation des données

| Opération | SQL | pandas | dplyr (`R`) | data.table (`R`) |
|-----|-----------|--------|-------------|------------------|
| Sélectionner des variables par leur nom | SELECT | `df[['Autres transports','Energie']]` | `df %>% select(Autres transports, Energie)` | `df[, c('Autres transports','Energie')]` |
| Sélectionner des observations selon une ou plusieurs conditions; | FILTER | `df[df['Agriculture']>2000]` | `df %>% filter(Agriculture>2000)` | `df[Agriculture>2000]` |
| Trier la table selon une ou plusieurs variables | SORT BY | `df.sort_values(['Commune','Agriculture'])` | `df %>% arrange(df.sort_values(Commune, Agriculture)` | `df[order(Commune, Agriculture)]` |
| Ajouter des variables qui sont fonction d’autres variables; | | `df['x'] = np.log(df['Agriculture'])`  |  `df %>% mutate(x = log(Agriculture))` | `df[,x := log(Agriculture)]` |
| Effectuer une opération par groupe | GROUP BY | `df.groupby('Commune').mean()` | `df %>% group_by(Commune) %>% summarise(m = mean)` | `df[,mean(Commune), by = Commune]` |
+ join

### Opérations sur les colonnes: select, mutate, drop

Exercice: 

1. Créer variables x et y
2. Droper x
3. Modifier y en réassignant
4. Vérifier

```python
df = pd.read_csv("https://koumoul.com/s/data-fair/api/v1/datasets/igt-pouvoir-de-rechauffement-global/convert")
```


## Opérations par groupe

## Calculs à partir de données / appliquer des fonctions

## Filtrer et réassigner (update)

# Joindre

Jointure avec données communales (pour avoir population)

# Reordonner

# Indexation et performance

Ouverture sur dask?

# Références

https://pandas.pydata.org/pandas-docs/stable/user_guide/basics.html
