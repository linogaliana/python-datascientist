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
title: "Natural Language Processing (NLP): des exercices"
date: 2020-10-29T13:00:00Z
draft: false
weight: 80
output: 
  html_document:
    keep_md: true
    self_contained: true
slug: nlpexo
---







Cette page approfondit certains aspects présentés dans la
[partie introductive](#nlp). Après avoir travaillé sur le
*Comte de Monte Cristo*, on va continuer notre exploration de la littérature
avec cette fois des auteurs anglophones:

* Edgar Allan Poe, (EAP) ;
* HP Lovecraft (HPL) ;
* Mary Wollstonecraft Shelley (MWS).

Les données sont disponibles ici : [spooky.csv](https://github.com/GU4243-ADS/spring2018-project1-ginnyqg/blob/master/data/spooky.csv) et peuvent être requétées via l'url 
<https://github.com/GU4243-ADS/spring2018-project1-ginnyqg/raw/master/data/spooky.csv>.

Le but va être dans un premier temps de regarder dans le détail les termes les plus fréquents utilisés par les auteurs, de les représenter graphiquement puis on va ensuite essayer de prédire quel texte correspond à quel auteur à partir d'un modèle `Word2Vec`.


Ce notebook librement inspiré de  : 

* https://www.kaggle.com/enerrio/scary-nlp-with-spacy-and-keras
* https://github.com/GU4243-ADS/spring2018-project1-ginnyqg
* https://www.kaggle.com/meiyizi/spooky-nlp-and-topic-modelling-tutorial/notebook

## Librairies nécessaires

Cette page évoquera, les principales librairies pour faire du NLP, notamment: 

* [WordCloud](https://github.com/amueller/word_cloud)
* [nltk](https://www.nltk.org/)
* [spacy](https://spacy.io/)
* [Keras](https://keras.io/)
* [TensorFlow](https://www.tensorflow.org/)

Il faudra également installer les librairies `gensim` et `pywaffle`

{{% panel status="warning" title="Warning" icon="fa fa-exclamation-triangle" %}}
Comme dans la [partie précédente](#nlp), il faut télécharger quelques éléments pour que `NTLK` puisse fonctionner correctement. Pour cela, faire:

~~~python
import nltk
nltk.download('stopwords')
nltk.download('punkt')
nltk.download('genesis')
nltk.download('wordnet')
~~~
{{% /panel %}}


La liste des modules à importer est assez longue, la voici:



## Données utilisées

{{% panel status="exercise" title="Exercise (pour ceux ayant envie de tester leurs connaissances en pandas)" icon="fas fa-pencil-alt" %}}
1. Importer le jeu de données `spooky` à partir de l'URL <https://github.com/GU4243-ADS/spring2018-project1-ginnyqg/raw/master/data/spooky.csv> sous le nom `train`. L'encoding est `latin-1`
2. Mettre des majuscules au nom des colonnes
3. Retirer le prefix `id` de la colonne `Id`
4. Mettre la colonne `Id` en index
{{% /panel %}}

Une fois n'est pas coutume, la correction de cet exercice ci-dessous:


```python
import pandas as pd

url='https://github.com/GU4243-ADS/spring2018-project1-ginnyqg/raw/master/data/spooky.csv'
import pandas as pd
train = pd.read_csv(url,
                    encoding='latin-1')
train.columns = train.columns.str.capitalize()
                    
train['ID'] = train['Id'].str.replace("id","")
train = train.set_index('Id')
```

Le jeu de données met ainsi en regard un auteur avec une phrase qu'il a écrite:


```
##                                                       Text Author     ID
## Id                                                                      
## id26305  This process, however, afforded me no means of...    EAP  26305
## id17569  It never once occurred to me that the fumbling...    HPL  17569
## id11008  In his left hand was a gold snuff box, from wh...    EAP  11008
## id27763  How lovely is spring As we looked from Windsor...    MWS  27763
## id12958  Finding nothing else, not even gold, the Super...    HPL  12958
```




On peut se rendre compte que les extraits des 3 auteurs ne sont pas forcément équilibrés dans le jeu de données. Il faudra en tenir compte dans la prédiction. 

{{<figure src="unnamed-chunk-6-1.png" >}}


## Approche bag of words

L'approche *bag of words* est présentée de
manière plus extensive dans le [chapitre précédent](#nlp).

L'idée est d'étudier la fréquence des mots d'un document et la surreprésentation des mots par rapport à un document de référence (appelé *corpus*). Cette approche un peu simpliste mais très efficace : on peut calculer des scores permettant par exemple de faire de classification automatique de document par thème, de comparer la similarité de deux documents. Elle est souvent utilisée en première analyse, et elle reste la référence pour l'analyse de textes mal structurés (tweets, dialogue tchat, etc.). 

Les analyses tf-idf (*term frequency-inverse document frequency*) ou les
constructions d'indices de similarité cosine reposent sur ce type d'approche

### Fréquence d'un mot

Avant de s'adonner à une analyse systématique du champ lexical de chaque
auteur, on va rechercher un unique mot, le mot *fear*. 


{{% panel status="exercise" title="Exercise" icon="fas fa-pencil-alt" %}}
1. Compter le nombre de phrases, pour chaque auteur, où apparaît le mot `fear`
2. Utiliser `pywaffle` pour obtenir les graphiques ci-dessous qui résument
de manière synthétique le nombre d'occurrences du mot *"fear"* par auteur
3. Refaire l'analyse avec le mot *"horror"*
{{% /panel %}}



{{<figure src="unnamed-chunk-8-1.png" >}}

{{<figure src="unnamed-chunk-9-1.png" >}}


La peur est ainsi plus évoquée par Mary Shelley
(sentiment assez naturel face à la créature du docteur Frankenstein) alors
que Lovecraft n'a pas volé sa réputation d'écrivain de l'horreur


### Premier *wordcloud*

Pour aller plus loin dans l'analyse du champ lexical de chaque auteur,
on peut représenter un `wordcloud` qui permet d'afficher chaque mot avec une
taille proportionnelle au nombre d'occurrence de celui-ci

{{% panel status="exercise" title="Exercise" icon="fas fa-pencil-alt" %}}
1. Faire un wordcloud pour représenter les mots les plus utilisés par chaque auteur
2. Calculer les 25 mots plus communs pour chaque auteur et représenter l'histogramme du décompte
{{% /panel %}}


```
## <matplotlib.image.AxesImage object at 0x0000000043B71FA0>
## (-0.5, 799.5, 499.5, -0.5)
## <matplotlib.image.AxesImage object at 0x0000000043BBED00>
## (-0.5, 799.5, 499.5, -0.5)
## <matplotlib.image.AxesImage object at 0x0000000043BBED30>
## (-0.5, 799.5, 499.5, -0.5)
```

{{<figure src="unnamed-chunk-10-1.png" >}}



```
## <seaborn.axisgrid.FacetGrid object at 0x0000000035D5F100>
```

{{<figure src="unnamed-chunk-11-1.png" >}}

Démonstration par l'exemple qu'il vaut mieux nettoyer le texte avant de 
l'analyser.
On voit ici que ce sont des mots communs, comme *"the"*, *"of"*, etc. sont très
présents. Mais ils sont peu porteurs d'information, on peut donc les éliminer
avant de faire une analyse syntaxique poussée (sauf si on est intéressé
par la loi de Zipf). 

{{% panel status="hint" title="La loi de Zipf" icon="fa fa-lightbulb" %}}
Dans son sens strict, la loi de Zipf prévoit que
dans un texte donné, la fréquence d'occurrence $f(n_i)$ d'un mot est
liée à son rang $n_i$ dans l'ordre des fréquences par une loi de la forme
$f(n_i) = c/n_i$ où $c$ est une constante. Zipf, dans les années 1930, se basait sur l'oeuvre 
de Joyce, *Ulysse* pour cette affirmation. 

Plus généralement, on peut dériver la loi de Zipf d'une distribution exponentielle des fréquences: $f(n_i) = cn_{i}^{-k}$. Cela permet d'utiliser la famille des modèles linéaire généralisés, notamment les régressions poissonniennes, pour mesurer les paramètres de la loi. Les modèles linéaire traditionnels en `log` souffrent en effet, dans ce contexte, de biais (la loi de Zipf est un cas particulier d'un modèle gravitaire, où appliquer des OLS est une mauvaise idée, cf. [Galiana et al. (2020)](https://linogaliana.netlify.app/publication/2020-segregation/) pour les limites).

On va estimer le modèle suivant par GLM via `statsmodels`:

$$
\mathbb{E}\bigg( f(n_i)|n_i \bigg) = \exp(\beta_0 + \beta_1 \log(n_i))
$$

Prenons les résultats de l'exercice précédent et enrichissons les du rang et de la fréquence d'occurrence d'un mot:


```python
count_words = pd.DataFrame({'counter' : train
    .groupby('Author')
    .apply(lambda s: ' '.join(s['Text']).split())
    .apply(lambda s: Counter(s))
    .apply(lambda s: s.most_common())
    .explode()}
)
count_words[['word','count']] = pd.DataFrame(count_words['counter'].tolist(), index=count_words.index)
count_words = count_words.reset_index()

count_words = count_words.assign(
    freq = lambda x: x['count'] / (x.groupby("Author").transform('sum')['count']),
    rank = lambda x: x.groupby("Author").transform('rank', ascending = False)['count']
)
```


```python
g = sns.lmplot(y = "freq", x = "rank", hue = 'Author', data = count_words, fit_reg = False)
g.set(xscale="log", yscale="log")
g
```



```python
import statsmodels.api as sm


exog = sm.add_constant(np.log(count_words['rank'].astype(float)))

model = sm.GLM(count_words['freq'].astype(float), exog, family = sm.families.Poisson()).fit()

# Display model results
print(model.summary())
```

TO BE COMPLETED

{{% /panel %}}


### Nettoyage d'un texte

Les premières étapes dans le nettoyage d'un texte, qu'on a dévelopé au cours du [chapitre précédent](#nlp), sont:

* suppression de la ponctuation
* suppression des *stopwords*

Cela passe par la tokenisation d'un texte, c'est-à-dire la décomposition
de celui-ci en unités lexicales (les *tokens*). Ces unités lexicales peuvent être de différentes natures, selon l'analyse que l'on désire procéder. Ici, on va définir les tokens comme des mots.

Plutôt que de faire soi-même ce travail de nettoyage, avec des fonctions mal optimisées, on peut utiliser la librairie `nltk` comme détaillé [précédemment](#nlp). 


{{% panel status="exercise" title="Exercise" icon="fas fa-pencil-alt" %}}
Repartir de `train`, notre jeu de données d'entraînement. Pour rappel, `train` a la structure suivante:


```
##                                                       Text  ... wordtoplot
## Id                                                          ...           
## id26305  This process, however, afforded me no means of...  ...          0
## id17569  It never once occurred to me that the fumbling...  ...          0
## 
## [2 rows x 4 columns]
```

1. Tokeniser chaque phrase avec `nltk`. Le `DataFrame` devrait maintenant avoir cet aspect:


```
## ID     Author
## 00001  MWS       [Idris, was, well, content, with, this, resolv...
## 00002  HPL       [I, was, faint, even, fainter, than, the, hate...
## dtype: object
```

2. Retirer les stopwords avec `nltk`


```
##       ID Author                                          tokenized
## 0  00001    MWS              [Idris, well, content, resolve, mine]
## 1  00002    HPL  [I, faint, even, fainter, hateful, modernity, ...
```

{{% /panel %}}

{{% panel status="hint" title="Hint" icon="fa fa-lightbulb" %}}
La méthode `apply` est très pratique ici car nous avons une phrase par ligne. Plutôt que de faire un `DataFrame` par auteur, ce qui n'est pas très flexible comme approche, on peut directement appliquer la tokenisation
sur notre `DataFrame` grâce à `apply`
{{% /panel %}}

Ce petit nettoyage permet d'arriver à un texte plus intéressant en termes d'analyse lexicale. Par exemple, si on reproduit l'analyse précédente,


```
## <matplotlib.image.AxesImage object at 0x0000000043462100>
## (-0.5, 799.5, 499.5, -0.5)
## <matplotlib.image.AxesImage object at 0x00000000471DA220>
## (-0.5, 799.5, 499.5, -0.5)
## <matplotlib.image.AxesImage object at 0x00000000466F31C0>
## (-0.5, 799.5, 499.5, -0.5)
```

{{<figure src="unnamed-chunk-18-1.png" >}}

### TF-IDF: calcul de fréquence


Le calcul [tf-idf](https://fr.wikipedia.org/wiki/TF-IDF) (term frequency–inverse document frequency) permet de calculer un score de proximité entre un terme de recherche et un document (c'est ce que font les moteurs de recherche):

* La partie `tf` calcule une fonction croissante de la fréquence du terme de recherche dans le document à l'étude;
* La partie `idf` calcule une fonction inversement proportionnelle à la fréquence du terme dans l'ensemble des documents (ou corpus).

Le score total, obtenu en multipliant les deux composantes, permet ainsi de donner un score d'autant plus élevé que le terme est surréprésenté dans un document (par rapport à l'ensemble des documents). Il existe plusieurs fonctions, qui pénalisent plus ou moins les documents longs, ou qui sont plus ou moins *smooth*.

{{% panel status="exercise" title="Exercise" icon="fas fa-pencil-alt" %}}
Repartir de `train`. 

1. Utiliser le vectoriseur TfIdF de `scikit-learn` pour transformer notre corpus en une matrice `document x terms`. Au passage, utiliser l'option `stop_words` pour ne pas provoquer une inflation de la taille de la matrice. Nommer le modèle `tfidf` et le jeu entraîné `tfs`




2. Après avoir construit la matrice de documents x terms avec le code suivant


```python
feature_names = tfidf.get_feature_names()
corpus_index = [n for n in list(tfidf.vocabulary_.keys())]
import pandas as pd
df = pd.DataFrame(tfs.todense(), columns=feature_names)

df.head()
```

```
##    aaem   ab  aback  abaft  abandon  ...  zopyrus  zorry  zubmizzion  zuro   á¼
## 0   0.0  0.0    0.0    0.0      0.0  ...      0.0    0.0         0.0   0.0  0.0
## 1   0.0  0.0    0.0    0.0      0.0  ...      0.0    0.0         0.0   0.0  0.0
## 2   0.0  0.0    0.0    0.0      0.0  ...      0.0    0.0         0.0   0.0  0.0
## 3   0.0  0.0    0.0    0.0      0.0  ...      0.0    0.0         0.0   0.0  0.0
## 4   0.0  0.0    0.0    0.0      0.0  ...      0.0    0.0         0.0   0.0  0.0
## 
## [5 rows x 24937 columns]
```

rechercher les lignes où les termes ayant la structure `abandon` sont non-nuls. Les lignes sont les suivantes:


```
## Int64Index([    4,   116,   215,   571,   839,  1042,  1052,  1069,  2247,
##              2317,  2505,  3023,  3058,  3245,  3380,  3764,  3886,  4425,
##              5289,  5576,  5694,  6812,  7500,  9013,  9021,  9077,  9560,
##             11229, 11395, 11451, 11588, 11827, 11989, 11998, 12122, 12158,
##             12189, 13666, 15259, 16516, 16524, 16759, 17547, 18019, 18072,
##             18126, 18204, 18251],
##            dtype='int64')
```


```
##      aaem   ab  aback  abaft   abandon  ...  zopyrus  zorry  zubmizzion  zuro   á¼
## 4     0.0  0.0    0.0    0.0  0.000000  ...      0.0    0.0         0.0   0.0  0.0
## 116   0.0  0.0    0.0    0.0  0.000000  ...      0.0    0.0         0.0   0.0  0.0
## 215   0.0  0.0    0.0    0.0  0.235817  ...      0.0    0.0         0.0   0.0  0.0
## 571   0.0  0.0    0.0    0.0  0.000000  ...      0.0    0.0         0.0   0.0  0.0
## 839   0.0  0.0    0.0    0.0  0.285886  ...      0.0    0.0         0.0   0.0  0.0
## 
## [5 rows x 24937 columns]
```

3. Trouver les 50 extraits où le score TF-IDF est le plus élevé et l'auteur associé. Vous devriez obtenir le classement suivant:


```
## Author
## MWS    22
## HPL    15
## EAP    13
## Name: Text, dtype: int64
```

et les 10 scores les plus élevés sont les suivants:


```
## ['We could not fear we did not.' '"And now I do not fear death.'
##  'Be of heart and fear nothing.' 'I smiled, for what had I to fear?'
##  'Indeed I had no fear on her account.'
##  'I have not the slightest fear for the result.'
##  'At length, in an abrupt manner she asked, "Where is he?" "O, fear not," she continued, "fear not that I should entertain hope Yet tell me, have you found him?'
##  '"I fear you are right there," said the Prefect.'
##  'I went down to open it with a light heart, for what had I now to fear?']
```

{{% /panel %}}

On remarque que les scores les plus élévés sont soient des extraits courts où le mot apparait une seule fois, et des extraits plus longs où le mot fear apprait plusieurs fois.
{{% panel status="note" title="Note" icon="fa fa-comment" %}}
La matrice `document x terms` est un exemple typique de matrice sparse puisque, dans des corpus volumineux, une grande diversité de vocabulaire peut être trouvée.  
{{% /panel %}}
