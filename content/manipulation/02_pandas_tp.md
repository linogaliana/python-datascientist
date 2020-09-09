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
title: "Pratique de pandas: un exemple complet"
date: 2020-07-09T13:00:00Z
draft: false
weight: 30
output: 
  html_document:
    keep_md: true
    self_contained: true
slug: pandasTP
---






Dans ce tutoriel `pandas`, nous allons utiliser:

* Les émissions de gaz à effet de serre estimées au niveau communal par l'ADEME. Le jeu de données est 
disponible sur [data.gouv](https://www.data.gouv.fr/fr/datasets/inventaire-de-gaz-a-effet-de-serre-territorialise/#_)
et requêtable directement dans python avec
[cet url](https://koumoul.com/s/data-fair/api/v1/datasets/igt-pouvoir-de-rechauffement-global/convert)
* Quelques données de contexte au niveau communal. Idéalement, on utiliserait les données
[disponibles sur le site de l'Insee](https://www.insee.fr/fr/statistiques/3560121). Pour faciliter l'import de celles-ci, les données ont été mises à disposition dans le dépôt github, [sur cet url](https://github.com/linogaliana/python-datascientist/blob/pandas_intro/data/filosofi_2016.csv)


`pandas` offre la possibilité d'importer des données directement depuis un url. C'est l'option
prise dans ce tutoriel.
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

## Exploration de la structure des données

Commencer par importer les données de l'Ademe à l'aide du package `pandas`. Vous pouvez les nommer `df`


```python
df = pd.read_csv("https://koumoul.com/s/data-fair/api/v1/datasets/igt-pouvoir-de-rechauffement-global/convert")
```

Pour les données de cadrage au niveau communal (source Insee), une version arrangée et facile à requêter est fournie sur [github](https://github.com/linogaliana/python-datascientist/blob/pandas_intro/data/filosofi_2016.csv)


```python
df_city = pd.read_csv("https://raw.githubusercontent.com/linogaliana/python-datascientist/master/data/filosofi_2016.csv")
```

```
## sys:1: DtypeWarning: Columns (0) have mixed types.Specify dtype option on import or set low_memory=False.
```

-----------------
**Exercice 1: Afficher des données**

L'objectif de cet exercice est de vous amener à afficher des informations sur les données dans un bloc de code (notebook) ou dans la console
    
Commencer sur `df`: 

    * Utiliser les méthodes adéquates pour les 10 premières valeurs, les 15 dernières et un échantillon aléatoire de 10 valeurs
    * Tirer 5 pourcent de l'échantillon sans remise
    * Ne conserver que les 10 premières lignes et tirer aléatoirement dans celles-ci pour obtenir un DataFrame de 100 données.
    * Faire 100 tirages à partir des 6 premières lignes avec une probabilité de 1/2 pour la première observation et une probabilité uniforme pour les autres
    
Faire la même chose sur `df_city`

------------------


```python
df.head(10)
```

```
##   INSEE commune                  Commune  ...       Routier     Tertiaire
## 0         01001  L'ABERGEMENT-CLEMENCIAT  ...    793.156501    367.036172
## 1         01002    L'ABERGEMENT-DE-VAREY  ...    348.997893    112.934207
## 2         01004        AMBERIEU-EN-BUGEY  ...  15642.420310  10732.376930
## 3         01005      AMBERIEUX-EN-DOMBES  ...   1756.341319    782.404357
## 4         01006                  AMBLEON  ...    398.786800     51.681756
## 5         01007                 AMBRONAY  ...  22481.123580   2789.133106
## 6         01008                 AMBUTRIX  ...   3616.168396    356.029873
## 7         01009         ANDERT-ET-CONDON  ...    696.956038    161.266219
## 8         01010                ANGLEFORT  ...   3199.808360   1206.147643
## 9         01011                 APREMONT  ...    686.153720    188.542701
## 
## [10 rows x 12 columns]
```

```python
df.tail(15)
```

```
##       INSEE commune              Commune  ...       Routier     Tertiaire
## 35783         95628           VALMONDOIS  ...    589.164544    574.241730
## 35784         95633          VAUDHERLAND  ...    439.279632    199.435133
## 35785         95637              VAUREAL  ...   4982.982966   7515.388640
## 35786         95641               VEMARS  ...  17783.179830   2654.384495
## 35787         95651             VETHEUIL  ...   1472.779256    414.411115
## 35788         95652              VIARMES  ...   5705.777606   2521.399729
## 35789         95656    VIENNE-EN-ARTHIES  ...    305.819555    206.727023
## 35790         95658                VIGNY  ...   8539.961119    516.817557
## 35791         95660  VILLAINES-SOUS-BOIS  ...    912.992023    336.409947
## 35792         95675             VILLERON  ...   7740.572805    725.467969
## 35793         95676   VILLERS-EN-ARTHIES  ...    309.627908    235.439109
## 35794         95678        VILLIERS-ADAM  ...  18759.370070    403.404815
## 35795         95680      VILLIERS-LE-BEL  ...  12217.122400  13849.512000
## 35796         95682      VILLIERS-LE-SEC  ...   4663.232127     85.657725
## 35797         95690  WY-DIT-JOLI-VILLAGE  ...    504.400972    147.867245
## 
## [15 rows x 12 columns]
```

```python
df.sample(10)
```

```
##       INSEE commune                    Commune  ...       Routier     Tertiaire
## 956           02565                    OEUILLY  ...    203.493417    137.818015
## 22627         59138                CATTENIERES  ...    967.027502    322.532438
## 12806         33141                   CROIGNON  ...    924.027586    258.887313
## 33099         82100                       LOZE  ...    231.978058     62.688056
## 24581         62344       FONTAINE-LES-HERMANS  ...    235.280496     57.424173
## 16851         44190  SAINT-SEBASTIEN-SUR-LOIRE  ...  23789.667860  13441.362600
## 11601         30341                    VAUVERT  ...  14963.045230   8151.955062
## 35099         89384                      SENAN  ...  10191.756930    375.171263
## 2875          09018                     ARROUT  ...     43.338533     37.325712
## 9877          27302           LE BOSC DU THEIL  ...   1766.107122    616.831325
## 
## [10 rows x 12 columns]
```

```python
df.sample(frac = 0.05)
```

```
##       INSEE commune               Commune  ...       Routier    Tertiaire
## 29378         72249             LA QUINTE  ...   4658.285793   383.306355
## 26008         64415       NAVAILLES-ANGOS  ...   3763.830784   668.034546
## 8382          24285  MONTAGNAC-LA-CREMPSE  ...   1476.128552   181.843214
## 27553         68195            LUTTERBACH  ...  32558.455360  4053.126032
## 19281         51518         SAINT-THIERRY  ...   6353.604388   532.472922
## ...             ...                   ...  ...           ...          ...
## 29487         72364                  VAAS  ...   3004.059294  2777.282260
## 14486         38069              CHAMPIER  ...   5914.014514   636.929785
## 18526         50304      LE MESNIL-AUBERT  ...   1535.417938    78.001168
## 16032         41237                SASSAY  ...   2173.652201   470.573282
## 27130         67304          MORSCHWILLER  ...    568.890529   286.163795
## 
## [1790 rows x 12 columns]
```

```python
df[:10].sample(n = 100, replace = True)
```

```
##    INSEE commune                  Commune  ...       Routier     Tertiaire
## 4          01006                  AMBLEON  ...    398.786800     51.681756
## 0          01001  L'ABERGEMENT-CLEMENCIAT  ...    793.156501    367.036172
## 0          01001  L'ABERGEMENT-CLEMENCIAT  ...    793.156501    367.036172
## 2          01004        AMBERIEU-EN-BUGEY  ...  15642.420310  10732.376930
## 3          01005      AMBERIEUX-EN-DOMBES  ...   1756.341319    782.404357
## ..           ...                      ...  ...           ...           ...
## 4          01006                  AMBLEON  ...    398.786800     51.681756
## 9          01011                 APREMONT  ...    686.153720    188.542701
## 4          01006                  AMBLEON  ...    398.786800     51.681756
## 9          01011                 APREMONT  ...    686.153720    188.542701
## 4          01006                  AMBLEON  ...    398.786800     51.681756
## 
## [100 rows x 12 columns]
```

```python
df[:6].sample(n = 100, replace = True, weights = [0.5] + [0.1]*5)
```

```
##    INSEE commune                  Commune  ...       Routier    Tertiaire
## 0          01001  L'ABERGEMENT-CLEMENCIAT  ...    793.156501   367.036172
## 3          01005      AMBERIEUX-EN-DOMBES  ...   1756.341319   782.404357
## 0          01001  L'ABERGEMENT-CLEMENCIAT  ...    793.156501   367.036172
## 5          01007                 AMBRONAY  ...  22481.123580  2789.133106
## 0          01001  L'ABERGEMENT-CLEMENCIAT  ...    793.156501   367.036172
## ..           ...                      ...  ...           ...          ...
## 0          01001  L'ABERGEMENT-CLEMENCIAT  ...    793.156501   367.036172
## 0          01001  L'ABERGEMENT-CLEMENCIAT  ...    793.156501   367.036172
## 1          01002    L'ABERGEMENT-DE-VAREY  ...    348.997893   112.934207
## 0          01001  L'ABERGEMENT-CLEMENCIAT  ...    793.156501   367.036172
## 3          01005      AMBERIEUX-EN-DOMBES  ...   1756.341319   782.404357
## 
## [100 rows x 12 columns]
```


```python
df_city.head(10)
```

```
##   CODGEO                   LIBGEO  ...          D916      RD16
## 0  01001  L'Abergement-Clémenciat  ...           NaN       NaN
## 1  01002    L'Abergement-de-Varey  ...           NaN       NaN
## 2  01004        Ambérieu-en-Bugey  ...  33880.555556  3.239962
## 3  01005      Ambérieux-en-Dombes  ...           NaN       NaN
## 4  01006                  Ambléon  ...           NaN       NaN
## 5  01007                 Ambronay  ...  34914.782609  2.503390
## 6  01008                 Ambutrix  ...           NaN       NaN
## 7  01009         Andert-et-Condon  ...           NaN       NaN
## 8  01010                Anglefort  ...           NaN       NaN
## 9  01011                 Apremont  ...           NaN       NaN
## 
## [10 rows x 29 columns]
```

```python
df_city.tail(15)
```

```
##       CODGEO             LIBGEO  ...          D916      RD16
## 34917  97410       Saint-Benoît  ...  29294.761905  4.000499
## 34918  97411        Saint-Denis  ...  40407.777778  4.934036
## 34919  97412       Saint-Joseph  ...  28241.250000  4.036771
## 34920  97413          Saint-Leu  ...  36507.142857  4.928787
## 34921  97414        Saint-Louis  ...  27378.888889  3.754905
## 34922  97415         Saint-Paul  ...  39826.000000  5.001743
## 34923  97416       Saint-Pierre  ...  35092.222222  4.610119
## 34924  97417     Saint-Philippe  ...  24234.500000  3.460550
## 34925  97418       Sainte-Marie  ...  37836.250000  4.523703
## 34926  97419        Sainte-Rose  ...  24337.826087  3.790939
## 34927  97420     Sainte-Suzanne  ...  33288.000000  4.179809
## 34928  97421            Salazie  ...  23529.333333  4.085819
## 34929  97422          Le Tampon  ...  32987.600000  4.437280
## 34930  97423  Les Trois-Bassins  ...  28596.567164  3.774958
## 34931  97424             Cilaos  ...  24427.222222  3.676391
## 
## [15 rows x 29 columns]
```

```python
df_city.sample(10)
```

```
##       CODGEO                   LIBGEO  ...          D916      RD16
## 5999   17455                La Vallée  ...           NaN       NaN
## 6579   19272                    Tulle  ...  34279.333333  3.203077
## 32817  85232  Saint-Hilaire-le-Vouhis  ...           NaN       NaN
## 4159   12165         Muret-le-Château  ...           NaN       NaN
## 14496  38501                   Tencin  ...  34333.888889  2.335229
## 13380  35196                Mordelles  ...  35456.666667  2.684484
## 20980  57211                    Fèves  ...           NaN       NaN
## 4601   14245                    Ernes  ...           NaN       NaN
## 9052   26078                  Charols  ...           NaN       NaN
## 19446  53276                   Voutré  ...           NaN       NaN
## 
## [10 rows x 29 columns]
```

```python
df_city.sample(frac = 0.05)
```

```
##       CODGEO                   LIBGEO  ...          D916      RD16
## 11489  31217                    Génos  ...           NaN       NaN
## 9313   26353           Les Tourrettes  ...           NaN       NaN
## 30620  78267              Gargenville  ...  36172.666667  2.569446
## 11847  31579                Villariès  ...           NaN       NaN
## 2111   07084                 Eclassan  ...           NaN       NaN
## ...      ...                      ...  ...           ...       ...
## 16890  46142        Lacapelle-Cabanac  ...           NaN       NaN
## 11945  32087        Castex-d'Armagnac  ...           NaN       NaN
## 32480  84009  La Bastide-des-Jourdans  ...           NaN       NaN
## 2993   09183         Mauvezin-de-Prat  ...           NaN       NaN
## 32158  82035                  Caumont  ...           NaN       NaN
## 
## [1747 rows x 29 columns]
```

```python
df_city[:10].sample(n = 100, replace = True)
```

```
##    CODGEO                   LIBGEO  ...          D916      RD16
## 0   01001  L'Abergement-Clémenciat  ...           NaN       NaN
## 2   01004        Ambérieu-en-Bugey  ...  33880.555556  3.239962
## 4   01006                  Ambléon  ...           NaN       NaN
## 5   01007                 Ambronay  ...  34914.782609  2.503390
## 2   01004        Ambérieu-en-Bugey  ...  33880.555556  3.239962
## ..    ...                      ...  ...           ...       ...
## 6   01008                 Ambutrix  ...           NaN       NaN
## 6   01008                 Ambutrix  ...           NaN       NaN
## 2   01004        Ambérieu-en-Bugey  ...  33880.555556  3.239962
## 2   01004        Ambérieu-en-Bugey  ...  33880.555556  3.239962
## 9   01011                 Apremont  ...           NaN       NaN
## 
## [100 rows x 29 columns]
```

```python
df_city[:6].sample(n = 100, replace = True, weights = [0.5] + [0.1]*5)
```

```
##    CODGEO                   LIBGEO  ...          D916      RD16
## 0   01001  L'Abergement-Clémenciat  ...           NaN       NaN
## 3   01005      Ambérieux-en-Dombes  ...           NaN       NaN
## 0   01001  L'Abergement-Clémenciat  ...           NaN       NaN
## 0   01001  L'Abergement-Clémenciat  ...           NaN       NaN
## 4   01006                  Ambléon  ...           NaN       NaN
## ..    ...                      ...  ...           ...       ...
## 1   01002    L'Abergement-de-Varey  ...           NaN       NaN
## 2   01004        Ambérieu-en-Bugey  ...  33880.555556  3.239962
## 0   01001  L'Abergement-Clémenciat  ...           NaN       NaN
## 1   01002    L'Abergement-de-Varey  ...           NaN       NaN
## 2   01004        Ambérieu-en-Bugey  ...  33880.555556  3.239962
## 
## [100 rows x 29 columns]
```

Cette première approche exploratoire donne une idée assez précise de la manière dont les données sont organisées. On remarque ainsi une différence entre `df` et `df_city` quant aux valeurs manquantes: la première base est relativement complète, la seconde comporte beaucoup de valeurs manquantes. Autrement dit, si on désire exploiter `df_city`, il faut faire attention à la variable choisie.


----------------------
**Exercice 2: structure des données**

La première chose à vérifier est le format des données, afin d'identifier des types de variables qui ne conviennent pas. Ici, comme c'est `pandas` qui a géré automatiquement les types de variables, il y a peu de chances que les types ne soient pas adéquats mais une vérification ne fait pas de mal.

* Vérifier les types des variables. S'assurer que les types des variables communes aux deux bases soient cohérents.

Ensuite, on vérifie les dimensions des `DataFrames` et la structure de certaines variables clé. En l'occurrence, les variables fondamentales pour lier nos données sont les variables communales. Ici, on a deux variables géographiques: un code commune et un nom de commune. 

* Vérifier les dimensions des DataFrames
* Vérifier le nombre de valeurs uniques des variables géographiques dans chaque base. Les résultats apparaissent-ils cohérents ?
* Identifier les libellés pour lesquels on a plusieurs codes communes dans `df_city` et les stocker dans un vecteur `x` (conseil: faire attention à l'index de `x`)

On se focalise temporairement sur les observations où le libellé comporte plus de deux codes communes différents

* Regarder dans `df_city` ces observations
* Pour mieux y voir, réordonner la base obtenue par order alphabétique
* Déterminer la taille moyenne (variable nombre de personnes: `NBPERSMENFISC16`) et quelques statistiques descriptives de ces données. Comparer aux mêmes statistiques sur les données où libellés et codes communes coïncident
* Vérifier sur les grandes villes (plus de 100 000 personnes), la proportion de villes où libellés et codes communes ne coïncident pas. Identifier ces observations.
* Vérifier dans `df_city` les villes dont le libellé est égal à Montreuil. Vérifier également celles qui contiennent le terme 'Saint-Denis'

-----------------------


```python
df.dtypes
```

```
## INSEE commune                       object
## Commune                             object
## Agriculture                        float64
## Autres transports                  float64
## Autres transports international    float64
## CO2 biomasse hors-total            float64
## Déchets                            float64
## Energie                            float64
## Industrie hors-énergie             float64
## Résidentiel                        float64
## Routier                            float64
## Tertiaire                          float64
## dtype: object
```

```python
df_city.dtypes
```

```
## CODGEO              object
## LIBGEO              object
## NBMENFISC16        float64
## NBPERSMENFISC16    float64
## MED16              float64
## PIMP16             float64
## TP6016             float64
## TP60AGE116         float64
## TP60AGE216         float64
## TP60AGE316         float64
## TP60AGE416         float64
## TP60AGE516         float64
## TP60AGE616         float64
## TP60TOL116         float64
## TP60TOL216         float64
## PACT16             float64
## PTSA16             float64
## PCHO16             float64
## PBEN16             float64
## PPEN16             float64
## PPAT16             float64
## PPSOC16            float64
## PPFAM16            float64
## PPMINI16           float64
## PPLOGT16           float64
## PIMPOT16           float64
## D116               float64
## D916               float64
## RD16               float64
## dtype: object
```


```python
df[['INSEE commune', 'Commune']].nunique()
```

```
## INSEE commune    35798
## Commune          33338
## dtype: int64
```

```python
df_city[['CODGEO', 'LIBGEO']].nunique()
# Résultats dont l'ordre de grandeur est proche. Dans les deux cas, #(libelles) < #(code)
```

```
## CODGEO    34932
## LIBGEO    32676
## dtype: int64
```


```python
x = df_city.groupby('LIBGEO').count()['CODGEO']
x = x[x>1]
x = x.reset_index()
x
```

```
##          LIBGEO  CODGEO
## 0     Abancourt       2
## 1     Aboncourt       2
## 2         Abzac       2
## 3       Achères       2
## 4        Aiglun       2
## ...         ...     ...
## 1446     Épieds       3
## 1447    Étaules       2
## 1448  Éterpigny       2
## 1449    Étréchy       3
## 1450  Étrépilly       2
## 
## [1451 rows x 2 columns]
```


```python
df_city[df_city['LIBGEO'].isin(x['LIBGEO'])]
```

```
##       CODGEO          LIBGEO  NBMENFISC16  ...         D116          D916      RD16
## 9      01011        Apremont        143.0  ...          NaN           NaN       NaN
## 23     01027           Balan        647.0  ...          NaN           NaN       NaN
## 26     01030      Beauregard        363.0  ...          NaN           NaN       NaN
## 35     01039            Béon        199.0  ...          NaN           NaN       NaN
## 38     01042             Bey        113.0  ...          NaN           NaN       NaN
## ...      ...             ...          ...  ...          ...           ...       ...
## 34921  97414     Saint-Louis      17890.0  ...  7291.500000  27378.888889  3.754905
## 34922  97415      Saint-Paul      37064.0  ...  7962.424242  39826.000000  5.001743
## 34923  97416    Saint-Pierre      31373.0  ...  7612.000000  35092.222222  4.610119
## 34925  97418    Sainte-Marie      11640.0  ...  8364.000000  37836.250000  4.523703
## 34927  97420  Sainte-Suzanne       7827.0  ...  7964.000000  33288.000000  4.179809
## 
## [3707 rows x 29 columns]
```

```python
df_city[df_city['LIBGEO'].isin(x['LIBGEO'])].sort_values('LIBGEO')
```

```
##       CODGEO     LIBGEO  NBMENFISC16  ...          D116          D916      RD16
## 21815  59001  Abancourt        182.0  ...           NaN           NaN       NaN
## 22463  60001  Abancourt        249.0  ...           NaN           NaN       NaN
## 20781  57001  Aboncourt        125.0  ...           NaN           NaN       NaN
## 19449  54003  Aboncourt         48.0  ...           NaN           NaN       NaN
## 12323  33001      Abzac        801.0  ...           NaN           NaN       NaN
## ...      ...        ...          ...  ...           ...           ...       ...
## 6118   18090    Étréchy        191.0  ...           NaN           NaN       NaN
## 34440  91226    Étréchy       2756.0  ...  14681.714286  39019.333333  2.657682
## 18388  51239    Étréchy         46.0  ...           NaN           NaN       NaN
## 30178  77173  Étrépilly        291.0  ...           NaN           NaN       NaN
## 680    02297  Étrépilly         46.0  ...           NaN           NaN       NaN
## 
## [3707 rows x 29 columns]
```


```python
df_city[df_city['LIBGEO'].isin(x['LIBGEO'])]['NBPERSMENFISC16'].describe()
```

```
## count      3302.000000
## mean       1610.143247
## std        6229.752735
## min          88.000000
## 25%         226.000000
## 50%         439.250000
## 75%        1006.125000
## max      145395.500000
## Name: NBPERSMENFISC16, dtype: float64
```

```python
df_city[~df_city['LIBGEO'].isin(x['LIBGEO'])]['NBPERSMENFISC16'].describe()
```

```
## count    2.810300e+04
## mean     2.192490e+03
## std      1.603009e+04
## min      7.600000e+01
## 25%      2.545000e+02
## 50%      5.420000e+02
## 75%      1.320250e+03
## max      2.074630e+06
## Name: NBPERSMENFISC16, dtype: float64
```


```python
df_big_city = df_city[df_city['NBPERSMENFISC16']>100000]
df_big_city['probleme'] = df_big_city['LIBGEO'].isin(x['LIBGEO'])
```

```
## C:/Users/W3CRK9/AppData/Local/r-miniconda/envs/r-reticulate/python.exe:1: SettingWithCopyWarning: 
## A value is trying to be set on a copy of a slice from a DataFrame.
## Try using .loc[row_indexer,col_indexer] = value instead
## 
## See the caveats in the documentation: https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html#returning-a-view-versus-a-copy
```

```python
df_big_city['probleme'].mean()
```

```
## 0.08333333333333333
```


```python
df_big_city[df_big_city['probleme']]
```

```
##       CODGEO       LIBGEO  NBMENFISC16  ...          D916      RD16  probleme
## 34622  93048    Montreuil      43996.0  ...  37583.000000  4.393959      True
## 34634  93066  Saint-Denis      39469.0  ...  28602.666667  3.852411      True
## 34918  97411  Saint-Denis      57567.0  ...  40407.777778  4.934036      True
## 34922  97415   Saint-Paul      37064.0  ...  39826.000000  5.001743      True
## 
## [4 rows x 30 columns]
```


```python
df_city[df_city.LIBGEO == 'Montreuil']
```

```
##       CODGEO     LIBGEO  NBMENFISC16  ...         D116     D916      RD16
## 10153  28267  Montreuil        215.0  ...          NaN      NaN       NaN
## 24099  62588  Montreuil        994.0  ...          NaN      NaN       NaN
## 32750  85148  Montreuil        340.0  ...          NaN      NaN       NaN
## 34622  93048  Montreuil      43996.0  ...  8553.333333  37583.0  4.393959
## 
## [4 rows x 29 columns]
```

```python
df_city[df_city.LIBGEO.str.contains('Saint-Denis')].head(10)
```

```
##      CODGEO                  LIBGEO  ...          D916      RD16
## 290   01344   Saint-Denis-lès-Bourg  ...  40126.666667  2.959194
## 291   01345    Saint-Denis-en-Bugey  ...  34075.333333  2.635467
## 1177  02818    Villiers-Saint-Denis  ...           NaN       NaN
## 3906  11339             Saint-Denis  ...           NaN       NaN
## 4824  14571  Saint-Denis-de-Mailloc  ...           NaN       NaN
## 4825  14572     Saint-Denis-de-Méré  ...           NaN       NaN
## 5874  17323    Saint-Denis-d'Oléron  ...           NaN       NaN
## 6231  18204    Saint-Denis-de-Palin  ...           NaN       NaN
## 7031  21442       Morey-Saint-Denis  ...           NaN       NaN
## 8518  25129   Chassagne-Saint-Denis  ...           NaN       NaN
## 
## [10 rows x 29 columns]
```

Ce petit exercice permet de se rassurer car les libellés dupliqués sont en fait des noms de commune identiques mais qui ne sont pas dans le même département. Il ne s'agit donc pas d'observations dupliquées. On se fiera ainsi aux codes communes, qui eux sont uniques.

## Les indices

Les indices sont des éléments spéciaux d'un DataFrame puisqu'ils permettent d'identifier certaines observations. Il est tout à fait possible d'utiliser plusieurs indices, par exemple si on a des niveaux imbriqués.


----------------------
**Exercice 3: Les indices**

A partir de l'exercice précédent, on peut se fier aux codes communes.

* Fixer comme indice la variable de code commune dans les deux bases. Regarder le changement que cela induit sur le *display* du dataframe
* Les deux premiers chiffres des codes communes sont le numéro de département. Créer une variable de département `dep` dans `df`
* Calculer les émissions totales par secteur pour chaque département. Mettre en log ces résultats dans un objet `df_log`. Garder 5 départements et produire un barplot
* Repartir de `df`. Calculer les émissions totales par département et sortir la liste des 10 principaux émetteurs de CO2 et des 5 départements les moins émetteurs. Sans faire de *merge*, regarder les caractéristiques de ces départements (population et niveau de vie)

-------------------------


```python
df = df.set_index('INSEE commune')
df_city =  df_city.set_index('CODGEO') 
```


```python
df['dep'] = df.index.str[:2]
df_city['dep'] = df_city.index.str[:2]
```


```python
df_log = df.groupby('dep').sum().apply(np.log)
df_log.sample(5).plot(kind = "bar")
```

![](02_pandas_tp_files/figure-html/unnamed-chunk-17-1.png)<!-- -->


```python
df
```

```
##                                Commune  Agriculture  ...     Tertiaire  dep
## INSEE commune                                        ...                   
## 01001          L'ABERGEMENT-CLEMENCIAT  3711.425991  ...    367.036172   01
## 01002            L'ABERGEMENT-DE-VAREY   475.330205  ...    112.934207   01
## 01004                AMBERIEU-EN-BUGEY   499.043526  ...  10732.376930   01
## 01005              AMBERIEUX-EN-DOMBES  1859.160954  ...    782.404357   01
## 01006                          AMBLEON   448.966808  ...     51.681756   01
## ...                                ...          ...  ...           ...  ...
## 95676               VILLERS-EN-ARTHIES  1628.065094  ...    235.439109   95
## 95678                    VILLIERS-ADAM   698.630772  ...    403.404815   95
## 95680                  VILLIERS-LE-BEL   107.564967  ...  13849.512000   95
## 95682                  VILLIERS-LE-SEC  1090.890170  ...     85.657725   95
## 95690              WY-DIT-JOLI-VILLAGE  1495.103542  ...    147.867245   95
## 
## [35798 rows x 12 columns]
```


```python
df_emissions = df.reset_index().set_index(['INSEE commune','dep']).sum(axis = 1).groupby('dep').sum()
gros_emetteurs = df_emissions.sort_values(ascending = False).head(10)
petits_emetteurs = df_emissions.sort_values().head(5)
```


```python
df_city[df_city['dep'].isin(gros_emetteurs.index)][['NBPERSMENFISC16','MED16']].sum()
```

```
## NBPERSMENFISC16    1.662427e+07
## MED16              1.072267e+08
## dtype: float64
```

```python
df_city[df_city['dep'].isin(gros_emetteurs.index)][['NBPERSMENFISC16','MED16']].mean()
```

```
## NBPERSMENFISC16     3343.578037
## MED16              21566.107365
## dtype: float64
```


```python
df_city[df_city['dep'].isin(petits_emetteurs.index)][['NBPERSMENFISC16','MED16']].sum()
```

```
## NBPERSMENFISC16    4.805560e+05
## MED16              9.346100e+06
## dtype: float64
```

```python
df_city[df_city['dep'].isin(petits_emetteurs.index)][['NBPERSMENFISC16','MED16']].mean()
```

```
## NBPERSMENFISC16      994.939959
## MED16              19350.103423
## dtype: float64
```

-------------------------
**Exercice 4: performance des indices**

Un des intérêts des indices est qu'il permettent des agrégations efficaces. 

* Repartir de `df` et créer une copie `df_copy = df.copy()` et `df_copy2 = df.copy()` afin de ne pas écraser le DataFrame `df`
* Utiliser la variable `dep` comme indice pour `df_copy` et retirer tout index pour `df_copy2`
* Importer le module `timeit` et comparer le temps d'exécution de la somme par secteur, pour chaque département, des émissions de CO2

---------------------------


```python
df_copy = df.copy()
df_copy2 = df.copy()
df_copy = df_copy.set_index('dep')
df_copy2 = df_copy2.reset_index()
```


```python
# %timeit df_copy.drop('Commune', axis = 1).groupby('dep').sum()
```


```python
# %timeit df_copy2.drop('Commune', axis = 1).groupby('dep').sum()
```

<!-- #region -->
# Restructurer les données

On présente généralement deux types de données: 
    
    * format __wide__: les données comportent des observations répétées, pour un même individu (ou groupe), dans des colonnes différentes 
    * format __long__: les données comportent des observations répétées, pour un même individu, dans des lignes différentes avec une colonne permettant de distinguer les niveaux d'observations

Un exemple de la distinction entre les deux peut être pris à l'ouvrage de référence d'Hadley Wickham, *R for Data Science*:

![](https://d33wubrfki0l68.cloudfront.net/3aea19108d39606bbe49981acda07696c0c7fcd8/2de65/images/tidy-9.png)


L'aide mémoire suivante aidera à se rappeler les fonctions à appliquer si besoin:

![](../../static/pictures/pandas/reshape.png)
<!-- #endregion -->

Le fait de passer d'un format *wide* au format *long* (ou vice-versa) peut être extrêmement pratique car certaines fonctions sont plus adéquates sur une forme de données ou sur l'autre. En règle générale, avec `python` comme avec `R`, les formats *long* sont souvent préférables.

----------------------------
**Exercice 5: Restructurer les données: wide to long**

* Créer une copie des données de l'ADEME en faisant `df_wide = df.copy()`
* Restructurer les données au format *long* pour avoir des données d'émissions par secteur en gardant comme niveau d'analyse la commune (attention aux autres variables identifiantes). 
* Faire la somme par secteur et représenter graphiquement
* Garder, pour chaque département, le secteur le plus polluant

--------------------------------




```python
df_wide = df.copy()
df_wide.reset_index().melt(id_vars = ['INSEE commune','Commune','dep'],
                          var_name = "secteur", value_name = "emissions")
```

```
##        INSEE commune                  Commune dep      secteur     emissions
## 0              01001  L'ABERGEMENT-CLEMENCIAT  01  Agriculture   3711.425991
## 1              01002    L'ABERGEMENT-DE-VAREY  01  Agriculture    475.330205
## 2              01004        AMBERIEU-EN-BUGEY  01  Agriculture    499.043526
## 3              01005      AMBERIEUX-EN-DOMBES  01  Agriculture   1859.160954
## 4              01006                  AMBLEON  01  Agriculture    448.966808
## ...              ...                      ...  ..          ...           ...
## 357975         95676       VILLERS-EN-ARTHIES  95    Tertiaire    235.439109
## 357976         95678            VILLIERS-ADAM  95    Tertiaire    403.404815
## 357977         95680          VILLIERS-LE-BEL  95    Tertiaire  13849.512000
## 357978         95682          VILLIERS-LE-SEC  95    Tertiaire     85.657725
## 357979         95690      WY-DIT-JOLI-VILLAGE  95    Tertiaire    147.867245
## 
## [357980 rows x 5 columns]
```

```python
(df_wide.reset_index()
 .melt(id_vars = ['INSEE commune','Commune','dep'],
                          var_name = "secteur", value_name = "emissions")
 .groupby('secteur').sum().plot(kind = "barh")
)
(df_wide.reset_index().melt(id_vars = ['INSEE commune','Commune','dep'],
                          var_name = "secteur", value_name = "emissions")
 .groupby(['secteur','dep']).sum().reset_index().sort_values(['dep','emissions'], ascending = False).groupby('dep').head(1)
)
```

```
##          secteur dep     emissions
## 767      Routier  95  1.540301e+06
## 862  Résidentiel  94  1.336894e+06
## 765      Routier  93  1.396911e+06
## 860  Résidentiel  92  1.466794e+06
## 763      Routier  91  2.073377e+06
## ..           ...  ..           ...
## 676      Routier  05  3.458587e+05
## 675      Routier  04  3.905682e+05
## 2    Agriculture  03  1.949985e+06
## 673      Routier  02  1.386403e+06
## 672      Routier  01  1.635350e+06
## 
## [96 rows x 3 columns]
```

-----------------------------------
**Exercice 6: long to wide**

Cette transformation est moins fréquente car appliquer des fonctions par groupe, comme nous le verrons par la suite, est très simple. 

* Repartir de `df_wide = df.copy()`. 
* Reconstruire le DataFrame, au format long, des données d'émissions par secteur en gardant comme niveau d'analyse la commune puis faire la somme par département et secteur
* Passer au format *wide* pour avoir une ligne par secteur et une colonne par département
* Calculer, pour chaque secteur, la place du département dans la hiérarchie des émissions nationales
* A partir de là, en déduire le rang médian de chaque département dans la hiérarchie des émissions et regarder les 10 plus mauvais élèves, selon ce critère.

---------------------------------


```python
df_wide = df.copy()
df_wide_agg = (df_wide.reset_index()
 .melt(id_vars = ['INSEE commune','Commune','dep'],
                          var_name = "secteur", value_name = "emissions").groupby(["dep", "secteur"]).sum()
 .reset_index().pivot_table(values = "emissions", index = "secteur", columns = "dep")
)
df_wide_agg.rank(axis = 1).median().nlargest(10)
```

```
## dep
## 13    94.5
## 59    94.5
## 69    92.0
## 77    89.5
## 33    89.0
## 62    88.0
## 76    88.0
## 44    87.0
## 38    85.0
## 31    83.5
## dtype: float64
```



# Combiner les données

L'information de valeur s'obtient de moins en moins à partir d'une unique base de données. Il devient commun de devoir combiner des données issues de sources différentes. Nous allons ici nous focaliser sur le cas le plus favorable qui est la situation où une information permet d'apparier de manière exacte deux bases de données (autrement nous serions dans une situation, beaucoup plus complexe, d'appariement flou). La situation typique est l'appariement entre deux sources de données selon un identifiant individuel ou un identifiant de code commune, ce qui est notre cas.

Il est recommandé de lire [ce guide assez complet sur la question des jointures avec R](https://linogaliana.gitlab.io/documentationR/joindre-des-tables-de-donn%C3%A9es.html) qui donne des recommandations également utiles en `python`.

On utilise de manière indifférente les termes *merge* ou *join*. Le deuxième terme provient de la syntaxe SQL. En `pandas`, dans la plupart des cas, on peut utiliser indifféremment `df.join` et `df.merge`

![](../../static/pictures/pandas/pandas_join.png)

------------------------------------
**Exercice 7: Calculer l'empreinte carbone par habitant**

* Créer une variable `emissions` qui correspond aux émissions totales d'une commune
* Faire une jointure à gauche entre les données d'émissions et les données de cadrage. Comparer les émissions moyennes des villes sans *match* (celles dont des variables bien choisies de la table de droite sont NaN) avec celles où on a bien une valeur correspondante dans la base Insee
* Faire un *inner join* puis calculer l'empreinte carbone dans chaque commune. Sortir un histogramme en niveau puis en log et quelques statistiques descriptives sur le sujet. 
* Regarder la corrélation entre les variables de cadrage et l'empreinte carbone. Certaines variables semblent expliquer l'empreinte carbone ?

--------------------------------------------


```python
df['emissions'] = df.sum(axis = 1)
df_merged = df.merge(df_city, how = "left", left_index = True, right_index = True)

df_merged[df_merged['LIBGEO'].isna()]['emissions'].mean()
```

```
## 18173.94906449251
```


```python
df_merged[~df_merged['LIBGEO'].isna()]['emissions'].mean()
```

```
## 14530.993903545383
```


```python
df_merged = df.merge(df_city, left_index = True, right_index = True)
df_merged['empreinte'] = df_merged['emissions']/df_merged['NBPERSMENFISC16']
```


```python
df_merged['empreinte'].plot(kind ="hist")
np.log(df_merged['empreinte']).plot.hist()
```

```
## <AxesSubplot:ylabel='Frequency'>
```

```python
df_merged['empreinte'].describe()
```

```
## count    29397.000000
## mean        13.968018
## std         68.403150
## min          0.989768
## 25%          6.031835
## 50%          9.491476
## 75%         15.620874
## max      10164.872743
## Name: empreinte, dtype: float64
```


```python
df_merged.corr()['empreinte']
```

```
## Agriculture                        0.046821
## Autres transports                  0.268390
## Autres transports international    0.733542
## CO2 biomasse hors-total           -0.005091
## Déchets                            0.046192
## Energie                            0.061412
## Industrie hors-énergie             0.099497
## Résidentiel                       -0.015723
## Routier                            0.001927
## Tertiaire                         -0.005275
## emissions                          0.311855
## NBMENFISC16                       -0.016482
## NBPERSMENFISC16                   -0.017641
## MED16                             -0.033656
## PIMP16                            -0.043378
## TP6016                             0.012082
## TP60AGE116                         0.008622
## TP60AGE216                        -0.045172
## TP60AGE316                        -0.024147
## TP60AGE416                        -0.051447
## TP60AGE516                         0.002961
## TP60AGE616                         0.040756
## TP60TOL116                        -0.031122
## TP60TOL216                         0.001886
## PACT16                             0.008487
## PTSA16                             0.020298
## PCHO16                             0.029914
## PBEN16                            -0.069436
## PPEN16                            -0.023084
## PPAT16                            -0.057115
## PPSOC16                            0.043591
## PPFAM16                            0.073953
## PPMINI16                           0.023268
## PPLOGT16                           0.030526
## PIMPOT16                           0.079574
## D116                              -0.019581
## D916                              -0.066617
## RD16                              -0.062849
## empreinte                          1.000000
## Name: empreinte, dtype: float64
```


```python
df
```

```
##                                Commune  Agriculture  ...  dep     emissions
## INSEE commune                                        ...                   
## 01001          L'ABERGEMENT-CLEMENCIAT  3711.425991  ...   01   5724.424941
## 01002            L'ABERGEMENT-DE-VAREY   475.330205  ...   01   1332.811619
## 01004                AMBERIEU-EN-BUGEY   499.043526  ...   01  63259.689113
## 01005              AMBERIEUX-EN-DOMBES  1859.160954  ...   01   6792.867439
## 01006                          AMBLEON   448.966808  ...   01   1068.584766
## ...                                ...          ...  ...  ...           ...
## 95676               VILLERS-EN-ARTHIES  1628.065094  ...   95   2625.668140
## 95678                    VILLIERS-ADAM   698.630772  ...   95  22708.808791
## 95680                  VILLIERS-LE-BEL   107.564967  ...   95  59484.157090
## 95682                  VILLIERS-LE-SEC  1090.890170  ...   95   6351.999447
## 95690              WY-DIT-JOLI-VILLAGE  1495.103542  ...   95   2506.319181
## 
## [35798 rows x 13 columns]
```

# Appliquer des fonctions


On peut utiliser `apply` pour passer des fonctions à appliquer sur plusieurs colonnes ou sur plusieurs valeurs


```python
df['emissions'].apply(np.sqrt)
```

```
## INSEE commune
## 01001     75.659930
## 01002     36.507693
## 01004    251.514789
## 01005     82.418854
## 01006     32.689215
##             ...    
## 95676     51.241274
## 95678    150.694422
## 95680    243.893741
## 95682     79.699432
## 95690     50.063152
## Name: emissions, Length: 35798, dtype: float64
```
