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
* Quelques données de contexte au niveau communal. Idéalement, on utiliserait les données
[disponibles sur le site de l'Insee](https://www.insee.fr/fr/statistiques/3560121). Pour faciliter l'import de celles-ci, les données ont été mises à disposition dans le dépôt github, [sur cet url](https://github.com/linogaliana/python-datascientist/blob/pandas_intro/data/filosofi_2016.csv)


:warning: `pandas` offre la possibilité d'importer des données
directement depuis un url. C'est l'option prise dans ce tutoriel.
Si vous préfèrez, pour des
raisons d'accès au réseau ou de performance, importer depuis un poste local,
vous pouvez télécharger les données et changer
les commandes d'import avec le chemin adéquat plutôt que l'url. 

Nous suivrons les conventions habituelles dans l'import des packages


```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
```

Pour obtenir des résultats reproductibles, on peut fixer la racine du générateur
pseudo-aléatoire. 


```python
np.random.seed(123)
```

Au cours de cette démonstration des principales fonctionalités de `pandas`, et
lors du TP __LIEN VERS LE TP__,
je recommande de régulièrement se référer aux ressources suivantes:

* L'[aide officielle de pandas](https://pandas.pydata.org/docs/user_guide/index.html).
Notamment, la
[page de comparaison des langages](https://pandas.pydata.org/pandas-docs/stable/getting_started/comparison/index.html)
est très utile
* La cheatsheet suivante, [issue de ce post](https://becominghuman.ai/cheat-sheets-for-ai-neural-networks-machine-learning-deep-learning-big-data-678c51b4b463)

<div class="figure">
<img src="https://cdn-images-1.medium.com/max/2000/1*YhTbz8b8Svi22wNVvqzneg.jpeg" alt="Cheasheet pandas, d'après &lt;https://becominghuman.ai/cheat-sheets-for-ai-neural-networks-machine-learning-deep-learning-big-data-678c51b4b463&gt;" width="90%" />
<p class="caption">Cheasheet pandas, d'après <https://becominghuman.ai/cheat-sheets-for-ai-neural-networks-machine-learning-deep-learning-big-data-678c51b4b463></p>
</div>

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

Le concept de *tidy* data, popularisé par Hadley Wickham via ses packages `R`,
est parfaitement pertinent pour décrire la structure d'un DataFrame pandas. 
Les trois règles sont les suivantes:

* Chaque variable possède sa propre colonne
* Chaque observation possède sa propre ligne
* Une valeur, matérialisant la valeur d'une observation d'une variable, 
se trouve sur une unique cellule.


<div class="figure">
<img src="https://d33wubrfki0l68.cloudfront.net/6f1ddb544fc5c69a2478e444ab8112fb0eea23f8/91adc/images/tidy-1.png" alt="Concept de tidy data (emprunté à H. Wickham)" width="90%" />
<p class="caption">Concept de tidy data (emprunté à H. Wickham)</p>
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
## gateaux  1.719469         8
## pates    2.286139         6
## riz      3.226851         8
## tomates       NaN         5
## yaourt   0.696469         3
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
df
```

```
##       INSEE commune                  Commune  ...       Routier     Tertiaire
## 0             01001  L'ABERGEMENT-CLEMENCIAT  ...    793.156501    367.036172
## 1             01002    L'ABERGEMENT-DE-VAREY  ...    348.997893    112.934207
## 2             01004        AMBERIEU-EN-BUGEY  ...  15642.420310  10732.376930
## 3             01005      AMBERIEUX-EN-DOMBES  ...   1756.341319    782.404357
## 4             01006                  AMBLEON  ...    398.786800     51.681756
## ...             ...                      ...  ...           ...           ...
## 35793         95676       VILLERS-EN-ARTHIES  ...    309.627908    235.439109
## 35794         95678            VILLIERS-ADAM  ...  18759.370070    403.404815
## 35795         95680          VILLIERS-LE-BEL  ...  12217.122400  13849.512000
## 35796         95682          VILLIERS-LE-SEC  ...   4663.232127     85.657725
## 35797         95690      WY-DIT-JOLI-VILLAGE  ...    504.400972    147.867245
## 
## [35798 rows x 12 columns]
```

L'affichage des DataFrames est très ergonomique. On obtiendrait le même *output*
avec `display(df)`[^2]. Les premières et dernières lignes s'affichent
automatiquement. Autrement, on peut aussi faire:

* `head` qui permet, comme son
nom l'indique, de n'afficher que les premières lignes ;
* `tail` qui permet, comme son
nom l'indique, de n'afficher que les dernières lignes
* `sample` qui permet d'afficher un échantillon aléatoire de *n* lignes

^[2]: Il est préférable d'utiliser la fonction `display` (ou tout simplement
taper le nom du DataFrame qu'utiliser la fonction `print`). Le
`display` des objets `pandas` est assez esthétique, contrairement à `print`
qui renvoie du texte brut. 


{{< panel status="danger" title="warning" icon="fa fa-exclamation-triangle" >}}
Il faut faire attention au `display` et aux
commandes qui révèlent des données (`head`, `tail`, etc.)
dans un notebook ou un markdown qui exploite
des données confidentielles lorsqu'on utilise `git`. En effet, on peut se
retrouver à partager des données, involontairement, dans l'historique
`git`. Avec un `R markdown`, il suffit d'ajouter les sorties au fichier 
`gitignore` (par exemple avec une balise de type `*.html`). Avec un
notebook `jupyter`, la démarche est plus compliquée car les fichiers
`.ipynb` intègrent dans le même document, texte, sorties et mise en forme. 
Techniquement, il est possible d'appliquer des filtres avec `git`
(voir
[ici](http://timstaley.co.uk/posts/making-git-and-jupyter-notebooks-play-nice/))
mais c'est une démarche très complexe
{{< /panel >}}


### Dimensions et structure du DataFrame

Les premières méthodes utiles permettent d'afficher quelques
attributs d'un DataFrame.


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
df.columns
```

```
## Index(['INSEE commune', 'Commune', 'Agriculture', 'Autres transports',
##        'Autres transports international', 'CO2 biomasse hors-total', 'Déchets',
##        'Energie', 'Industrie hors-énergie', 'Résidentiel', 'Routier',
##        'Tertiaire'],
##       dtype='object')
```

```python
df.index
```

```
## RangeIndex(start=0, stop=35798, step=1)
```

Pour connaître les dimensions d'un DataFrame, on peut utiliser quelques méthodes
pratiques:



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
df.size
```

```
## 429576
```

Pour déterminer le nombre de valeurs uniques d'une variable, la
méthode `nunique` est pratique. Par exemple,


```python
df['Commune'].nunique()
```

```
## 33338
```

| Opération                     | SQL            | pandas       | dplyr (`R`)    | data.table (`R`)           |
|-------------------------------|----------------|--------------|----------------|----------------------------|
| Récupérer le nom des colonnes |                | `df.columns` | `colnames(df)` | `colnames(df)`             |
| Récupérer les indices[^3]         |                | `df.index`   |                |`unique(df[,get(key(df))])` |
| Récupérer les dimensions | | `df.shape` | `c(nrow(df), ncol(df))` | `c(nrow(df), ncol(df))` |
| Récupérer le nombre de valeurs uniques d'une variable | | `df['myvar'].nunique()` | `df %>%  summarise(distinct(myvar))` | `df[,uniqueN(myvar)]` |

^[3]: Le principe d'indice n'existe pas dans `dplyr`. Les indices, au sens de
`pandas`, sont appelés *clés* en `data.table`.


### Statistiques agrégées

`pandas` propose une série de méthodes pour faire des statistiques
agrégées de manière efficace. 

On peut, par exemple, appliquer des méthodes pour compter le nombre de lignes,
faire une moyenne ou une somme de l'ensemble des lignes


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
df.mean()
```

```
## Agriculture                        2459.975760
## Autres transports                   654.919940
## Autres transports international    7692.344960
## CO2 biomasse hors-total            1774.381550
## Déchets                             410.806329
## Energie                             662.569846
## Industrie hors-énergie             2423.127789
## Résidentiel                        1783.677872
## Routier                            3535.501245
## Tertiaire                          1105.165915
## dtype: float64
```

```python
df.sum()
```

```
## INSEE commune                      0100101002010040100501006010070100801009010100...
## Commune                            L'ABERGEMENT-CLEMENCIATL'ABERGEMENT-DE-VAREYAM...
## Agriculture                                                              8.79097e+07
## Autres transports                                                        6.53545e+06
## Autres transports international                                          2.22386e+07
## CO2 biomasse hors-total                                                  6.35193e+07
## Déchets                                                                  1.47036e+07
## Energie                                                                   2.2852e+07
## Industrie hors-énergie                                                   8.35737e+07
## Résidentiel                                                              6.38414e+07
## Routier                                                                  1.26493e+08
## Tertiaire                                                                3.95627e+07
## dtype: object
```

```python
df.nunique()
```

```
## INSEE commune                      35798
## Commune                            33338
## Agriculture                        35576
## Autres transports                   9963
## Autres transports international     2883
## CO2 biomasse hors-total            35798
## Déchets                            11016
## Energie                             1453
## Industrie hors-énergie              1889
## Résidentiel                        35791
## Routier                            35749
## Tertiaire                           8663
## dtype: int64
```

```python
df.quantile(q = [0.1,0.25,0.5,0.75,0.9])
```

```
##       Agriculture  Autres transports  ...      Routier    Tertiaire
## 0.10   382.620882          25.034578  ...   199.765410    49.289082
## 0.25   797.682631          52.560412  ...   419.700460    94.749885
## 0.50  1559.381286         106.795928  ...  1070.895593   216.297718
## 0.75  3007.883903         237.341501  ...  3098.612157   576.155869
## 0.90  5442.727470         528.349529  ...  8151.047248  1897.732565
## 
## [5 rows x 10 columns]
```

<!---
Comme indiqué précédemment, il faut faire attention aux valeurs manquantes qui,
par défaut, sont traitées comme des 0.
Il est ainsi recommandé de systématiquement
ajouter l'argument skipna, par exemple, 
----->


```python
df.mean(skipna=True)
```

```
## Agriculture                        2459.975760
## Autres transports                   654.919940
## Autres transports international    7692.344960
## CO2 biomasse hors-total            1774.381550
## Déchets                             410.806329
## Energie                             662.569846
## Industrie hors-énergie             2423.127789
## Résidentiel                        1783.677872
## Routier                            3535.501245
## Tertiaire                          1105.165915
## dtype: float64
```

Le tableau suivant récapitule le code équivalent pour avoir des 
statistiques sur toutes les colonnes d'un dataframe en `R`. 


| Opération                     | SQL            | pandas       | dplyr (`R`)    | data.table (`R`)           |
|-------------------------------|----------------|--------------|----------------|----------------------------|
| Nombre de valeurs non manquantes |             | `df.count()`   | `df %>% summarise_each(funs(sum(!is.na(.))))` | `df[, lapply(.SD, function(x) sum(!is.na(x)))]`
| Moyenne de toutes les variables |  | `df.mean` | `df %>% summarise_each(funs(mean((., na.rm = TRUE))))` | `df[,lapply(.SD, function(x) mean(x, na.rm = TRUE))]`
| TO BE CONTINUED |

La méthode `describe` permet de sortir un tableau de statistiques 
agrégées:


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

Les méthodes relatives aux valeurs manquantes peuvent être mobilisées
en conjonction des méthodes de statistiques agrégées

Exercice:

```python
df.isnull().sum()
```

# Graphiques rapides

Les méthodes par défaut de graphique
(approfondies dans le chapitre matplotlib/seaborn) sont pratiques pour 
produire rapidement un graphique, notament après des opérations
complexes de maniement de données

**cf. exo**


```python
fig = df['Déchets'].plot()
plt.show()
```

![](02_pandas_files/figure-html/matplotlib-1.png)<!-- -->

```python
fig = df['Déchets'].hist()
plt.show()
```

![](02_pandas_files/figure-html/matplotlib-2.png)<!-- -->

```python
fig = df['Déchets'].plot(kind = 'hist', logy = True)
plt.show()
```

![](02_pandas_files/figure-html/matplotlib-3.png)<!-- -->


# Accéder à des éléments d'un DataFrame

## Sélectionner des colonnes

En SQL, effectuer des opérations sur les colonnes se fait avec la commande
`SELECT`. Avec `pandas`,
pour accéder à une colonne dans son ensemble on peut
utiliser plusieurs approches:

* `dataframe.variable`, par exemple `df.Energie`.
Cette méthode requiert néanmoins d'avoir des 
noms de colonnes sans espace. 
* `dataframe[['variable']]` pour renvoyer la variable sous
forme de `DataFrame` ou dataframe['variable'] pour
la renvoyer sous forme de `Series`. Par exemple, `df[['Autres transports']]` 
ou `df['Autres transports']`. C'est une manière préférable de procéder.

## Accéder à des lignes

Pour accéder à une ou plusieurs valeurs d'un `DataFrame`,
il existe trois manières de procéder, selon la 
forme des indices de lignes ou colonnes utilisés:

* `df.loc`: use labels
* `df.iloc`: use indices
* `df[]`: uses 

Les bouts de code utilisant la structure `df.ix`
sont à bannir car la fonction est *deprecated* et peut
ainsi disparaître à tout moment. 




data.loc[1:3]
data.loc[(data.age >= 20), ['section', 'city']]

data.iloc[[0,2]]
data.iloc[[0,2],[1,3]]
data.iloc[1:3,2:4]

data.loc[(data.age >= 12), ['section']]


# Principales manipulation de données

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

## Opérations sur les colonnes: select, mutate, drop

Exercice: 

1. Créer variables x et y
2. Drop x
3. Modifier y en réassignant
4. Vérifier

```python
df = pd.read_csv("https://koumoul.com/s/data-fair/api/v1/datasets/igt-pouvoir-de-rechauffement-global/convert")
```

## Reordonner


## Filtrer et réassigner (update)

## Opérations par groupe

En SQL, il est très simple d'effectuer de découper des données pour
effectuer des opérations sur des blocs cohérents et recollecter des résultats.
La logique sous-jacente est celle du split-apply-combine qui est repris
par les langages de manipulation de données, auxquels `pandas`
[ne fait pas exception](https://pandas.pydata.org/pandas-docs/stable/user_guide/groupby.html). 


```r
knitr::include_graphics(
  "https://unlhcc.github.io/r-novice-gapminder/fig/12-plyr-fig1.png"
)
```

![Split-Apply-Combine, d'après <https://unlhcc.github.io/r-novice-gapminder/16-plyr/>](https://unlhcc.github.io/r-novice-gapminder/fig/12-plyr-fig1.png)

https://realpython.com/pandas-groupby/


pandas objects can be split on any of their axes. The abstract definition of grouping is to provide a mapping of labels to group names

SELECT state, count(name)
FROM df
GROUP BY state
ORDER BY state;


In the Pandas version, the grouped-on columns are pushed into the MultiIndex of the resulting Series by default:


he reason that a DataFrameGroupBy object can be difficult to wrap your head around is that it’s lazy in nature. It 
doesn’t really do any operations to produce a useful result until you say so.

print(by_state)
<pandas.core.groupby.generic.DataFrameGroupBy object at 0x107293278>

It can be difficult to inspect df.groupby("state") because it does virtually none of these things until you do something with the resulting object. Again, a Pandas GroupBy object is lazy. It delays virtually every part of the split-apply-combine process until you invoke a method on it.

Utilisation avancée:
If you’re working on a challenging aggregation problem, then iterating over the Pandas GroupBy object can be a great way to visualize the split part of split-apply-combine.

by_state.get_group("PA")
This is virtually equivalent to using .loc[]. You could get the same output with something like df.loc[df["state"] == "PA"].


df.groupby([df.index.year, df.index.quarter])["co"].agg(
...     ["max", "min"]
... ).rename_axis(["year", "quarter"])

Resampling en pandas sur données temporelles
df.resample("Q")["co"].agg(["max", "min"])

## Appliquer des fonctions

Lien vers rappel lambda functions

df.groupby("outlet", sort=False)["title"].apply(
...     lambda ser: ser.str.contains("Fed").sum()
... ).nlargest(10)

Accélérer: https://realpython.com/fast-flexible-pandas/#pandas-apply

Exo :
* isin
* digitize

## Joindre

Jointure avec données communales (pour avoir population)

## Reshape

long to wide: pivot
wide to long: melt


# Quelques enjeux de performance

Ouverture sur dask?

# Références

https://pandas.pydata.org/pandas-docs/stable/user_guide/basics.html
