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
title: "Nettoyer un texte: approche bag-of-words (exercices)"
date: 2020-10-29T13:00:00Z
draft: false
weight: 20
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


{{% panel status="hint" title="Hint" icon="fa fa-lightbulb" %}}
L'approche *bag of words* est présentée de
manière plus extensive dans le [chapitre précédent](#nlp).

L'idée est d'étudier la fréquence des mots d'un document et la
surreprésentation des mots par rapport à un document de
référence (appelé *corpus*). Cette approche un peu simpliste mais très
efficace : on peut calculer des scores permettant par exemple de faire
de classification automatique de document par thème, de comparer la
similarité de deux documents. Elle est souvent utilisée en première analyse,
et elle reste la référence pour l'analyse de textes mal
structurés (tweets, dialogue tchat, etc.). 

Les analyses tf-idf (*term frequency-inverse document frequency*) ou les
constructions d'indices de similarité cosine reposent sur ce type d'approche
{{% /panel %}}


## Fréquence d'un mot

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


## Premier *wordcloud*

Pour aller plus loin dans l'analyse du champ lexical de chaque auteur,
on peut représenter un `wordcloud` qui permet d'afficher chaque mot avec une
taille proportionnelle au nombre d'occurrence de celui-ci

{{% panel status="exercise" title="Exercise" icon="fas fa-pencil-alt" %}}
1. Faire un wordcloud pour représenter les mots les plus utilisés par chaque auteur
2. Calculer les 25 mots plus communs pour chaque auteur et représenter l'histogramme du décompte
{{% /panel %}}


```
## <matplotlib.image.AxesImage object at 0x0000000043C51460>
## (-0.5, 799.5, 499.5, -0.5)
## <matplotlib.image.AxesImage object at 0x0000000035D312B0>
## (-0.5, 799.5, 499.5, -0.5)
## <matplotlib.image.AxesImage object at 0x0000000035D310D0>
## (-0.5, 799.5, 499.5, -0.5)
```

{{<figure src="unnamed-chunk-10-1.png" >}}



```
## <seaborn.axisgrid.FacetGrid object at 0x00000000434073D0>
```

{{<figure src="unnamed-chunk-11-1.png" >}}

Démonstration par l'exemple qu'il vaut mieux nettoyer le texte avant de 
l'analyser.
On voit ici que ce sont des mots communs, comme *"the"*, *"of"*, etc. sont très
présents. Mais ils sont peu porteurs d'information, on peut donc les éliminer
avant de faire une analyse syntaxique poussée (sauf si on est intéressé
par la loi de Zipf). 

## Aparté: la loi de Zipf

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


## Nettoyage d'un texte

Les premières étapes dans le nettoyage d'un texte, qu'on a
dévelopé au cours du [chapitre précédent](#nlp), sont:

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
## <matplotlib.image.AxesImage object at 0x00000000466B5880>
## (-0.5, 799.5, 499.5, -0.5)
## <matplotlib.image.AxesImage object at 0x0000000043563FA0>
## (-0.5, 799.5, 499.5, -0.5)
## <matplotlib.image.AxesImage object at 0x0000000043C20D60>
## (-0.5, 799.5, 499.5, -0.5)
```

{{<figure src="unnamed-chunk-18-1.png" >}}

Pour aller plus loin dans l'harmonisation d'un texte, il est possible de
mettre en place les classes d'équivalence développées dans la 
[partie précédente](#nlp) afin de remplacer différentes variations d'un même
mot par une forme canonique :

* la **lemmatisation** qui requiert la connaissance des statuts
grammaticaux (exemple : chevaux devient cheval)
* la **racinisation** (*stemming*) plus fruste mais plus rapide, notamment
en présence de fautes d’orthographes. Dans ce cas, chevaux peut devenir chev
mais être ainsi confondu avec chevet ou cheveux 

La racinisation est généralement plus simple à mettre en oeuvre, quoique
plus fruste. Elle est développée dans la [partie précédente](#nlp). 

La lemmatisation est mise en oeuvre, comme toujours avec NLTK, à travers un
modèle. En l'occurrence, un `WordNetLemmatizer`  (WordNet est une base
lexicographique ouverte). Par exemple, les mots *"women"*, *"daughters"*
et *"leaves"* seront ainsi lemmatisés de la manière suivante:


```
## The lemmatized form of women is: woman
## The lemmatized form of daughters is: daughter
## The lemmatized form of leaves is: leaf
```

{{% panel status="note" title="Note" icon="fa fa-comment" %}}
Pour disposer du corpus nécessaire à la lemmatisation, il faut, la première fois,
télécharger celui-ci grâce aux commandes suivantes:
~~~python
import nltk
nltk.download('wordnet')
~~~
{{% /panel %}}


{{% panel status="exercise" title="Exercise: lemmatisation avec NLTK et spaCy" icon="fas fa-pencil-alt" %}}

On va se restreindre au corpus d'Edgar Allan Poe et repartir de la base de données
brute


```python
eap_clean = train[train["Author"] == "EAP"]
eap_clean = ' '.join(eap_clean['Text'])
#Tokenisation naïve sur les espaces entre les mots => on obtient une liste de mots
#tokens = eap_clean.split()
word_list = nltk.word_tokenize(eap_clean)
```

1. Utiliser un `WordNetLemmatizer` et observer le résultat


```
## This process , however , afforded me no means of ascertaining the dimensions of my dungeon ; as I might make its circuit , and return to the point whence I set out , without being aware of the fact ; so perfectly
```

```
## ---------------------------
```

```
## This process , however , afforded me no mean of ascertaining the dimension of my dungeon ; a I might make it circuit , and return to the point whence I set out , without being aware of the fact ; so perfectly
```


{{% /panel %}}


## TF-IDF: calcul de fréquence


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


## Approche contextuelle: les *n-gramms*

{{% panel status="note" title="Note" icon="fa fa-comment" %}}
Pour être en mesure de mener cette analyse, il est nécessaire de télécharger un corpus supplémentaire:
~~~python
import nltk
nltk.download('genesis')
nltk.corpus.genesis.words('english-web.txt')
~~~
{{% /panel %}}

Il s'agit maintenant de raffiner l'analyse. 

On s'intéresse non seulement aux mots et à leur fréquence, mais aussi aux mots qui suivent. Cette approche est essentielle pour désambiguiser les homonymes. Elle permet aussi d'affiner les modèles "bag-of-words". Le calcul de n-grams (bigrams pour les co-occurences de mots deux-à-deux, tri-grams pour les co-occurences trois-à-trois, etc.) constitue la méthode la plus simple pour tenir compte du contexte.


nltk offre des methodes pour tenir compte du contexte : pour ce faire, nous calculons les n-grams, c'est-à-dire l'ensemble des co-occurrences successives de mots deux-à-deux (bigrams), trois-à-trois (tri-grams), etc.

En général, on se contente de bi-grams, au mieux de tri-grams :

* les modèles de classification, analyse du sentiment, comparaison de documents, etc. qui comparent des n-grams avec n trop grands sont rapidement confrontés au problème de données sparse, cela réduit la capacité prédictive des modèles ;
* les performances décroissent très rapidement en fonction de n, et les coûts de stockage des données augmentent rapidement (environ n fois plus élevé que la base de donnée initiale).

{{% panel status="exercise" title="Exercise" icon="fas fa-pencil-alt" %}}

On va, rapidement, regarder dans quel contexte apparaît le mot `fear` dans
l'oeuvre d'Edgar Allan Poe (EAP). Pour cela, on transforme d'abord
le corpus EAP en tokens `NLTK`


```python
eap_clean = train_clean[train_clean["Author"] == "EAP"]
eap_clean = ' '.join(eap_clean['Text'])
#Tokenisation naïve sur les espaces entre les mots => on obtient une liste de mots
tokens = eap_clean.split()
text = nltk.Text(tokens)
```

1. Utiliser la méthode `concordance` pour afficher le contexte dans lequel apparaît le terme `fear`. La liste devrait ressembler à celle-ci:


```
## Exemples d'occurences du terme 'fear' :
```

```
## Displaying 24 of 24 matches:
## lady seventy years age heard express fear never see Marie observation attracte
## ingly well I went open light heart I fear The fact business simple indeed I ma
##  Geneva seemed resolved give scruple fear wind No one spoken frequenting house
## d propeller must entirely remodelled fear serious accident I mean steel rod va
## ud rose amazing velocity I slightest fear result He proceeded observing analyz
## His third contempt ambition Indeed I fear account The ceiling gloomy looking o
## dverted blush extreme recency date I fear right said Prefect This could refast
## loud quick unequal spoken apparently fear well anger three four quite right Sa
## oughts Question Oinos freely without fear No path trodden vicinity reach happy
## ick darkness shutters close fastened fear robbers I knew could see opening doo
## ible game antagonist I even went far fear I occasioned much trouble might glad
## dame could easily enter unobserved I fear mesmerized adding immediately afterw
## here poodle Perhaps said I Legrand I fear artist In left hand little heavy Dut
##  strong relish physical philosophy I fear tinctured mind common error age I me
## ripods expired The replied entered I fear unusual horror thing The rudder ligh
## rdiality In second place impressed I fear indeed impossible make comprehended 
##  spades whole insisted upon carrying fear seemed trusting either implements wi
## ind dreaded whip instantly converted fear This prison like rampart formed limi
##  I started hourly dreams unutterable fear find hot breath thing upon face vast
## ers deputed search premises Be heart fear nothing I removed bed examined corps
##  looked stiff rolled eyes I smiled I fear My first idea mere surprise really r
## g memory long time awaking slumber I fear I shall never see Marie But imagine 
## et lonely I watched minutes somewhat fear wonder The one wrote Jeremiad usury 
## d garments muddy clotted gore I much fear replied Monsieur Maillard becoming e
```

Même si on peut facilement voir le mot avant et après, cette liste est assez difficile à interpréter car elle recoupe beaucoup d'information. 

La `collocation` consiste à trouver les bi-grammes qui
apparaissent le plus fréquemment ensemble. Parmi toutes les paires de deux mots observées, il s'agit de sélectionner, à partir d'un modèle statistique, les "meilleures". 

2. Sélectionner et afficher les meilleures collocation, par exemple selon le critère du ratio de vraisemblance. 

Une approche ingénue de la `collocation` amène ainsi à considérer les mots suivants: 


```
## [('I', 'could'), ('I', 'felt'), ('main', 'compartment'), ('Chess', 'Player'), ('Let', 'us'), ('I', 'saw'), ('Madame', 'Lalande'), ('At', 'length'), ('New', 'York'), ('Ourang', 'Outang'), ('ha', 'ha'), ('three', 'four'), ('I', 'knew'), ('I', 'say'), ('du', 'Roule'), ('I', 'I'), ('General', 'John'), ('could', 'help'), ('In', 'meantime'), ('let', 'us')]
```

Si ces mots sont très fortement associés, les expressions sont également peu fréquentes. Il est donc parfois nécessaire d'appliquer des filtres, par exemple ignorer les bigrammes qui apparaissent moins de 5 fois dans le corpus.

3. Refaire la question précédente mais, avant cela, utiliser un modèle `BigramCollocationFinder` et la méthode `apply_freq_filter` pour ne conserver que les bigrammes présents au moins 5 fois. 


```
## Chess Player
## Ourang Outang
## Brevet Brigadier
## Hans Pfaall
## Bas Bleu
## du Roule
## New York
## ugh ugh
## Tea Pot
## gum elastic
## hu hu
## prodigies valor
## Gad Fly
## Massa Will
## Von Kempelen
```

Cette liste a un peu plus de sens, on a des noms de personnages, de lieux mais aussi des termes fréquemment employés ensemble (*Chess Player* par exemple)

3. Ne s'intéresser qu'aux *collocations* qui concernent le mot *fear*


```
## [('your', 'word'), ('the', 'word'), ('word', 'again'), ('word', 'of'), ('me', 'word'), ('a', 'word'), ('word', '."'), ('word', 'will'), ('word', 'that'), ('word', 'in')]
```


{{% /panel %}}

Si on mène la même analyse pour le terme *love*, on remarque que de manière logique, on retrouve bien des sujets généralement accolés au verbe:


```
## [('love', 'me'), ('love', 'he'), ('will', 'love'), ('I', 'love'), ('love', ','), ('you', 'love'), ('the', 'love')]
```

