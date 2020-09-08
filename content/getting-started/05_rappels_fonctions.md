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
title: "Modules, tests, boucles, fonctions"
date: 2020-07-09T15:00:00Z
draft: false
weight: 60
output: 
  html_document:
    keep_md: true
    self_contained: true
---

Les modules sont les éléments qui font la richesse du langage Python. 

Ils sont l'équivalent des packages R ou Stata. Le monde de développeurs Python est très prolifique : des mises à jour sont très souvent disponibles, les bibliothèques sont très nombreuses. Et les forums regorgent de bons conseils. Le meilleur que je puisse vous donner, en cas d'erreur , copier-coller l'erreur sur votre moteur de recherche préféré, quelqu'un aura déjà posé la question.

Un module est un script qui a vocation à définir des objets utilisés
postérieurement par un interpréteur. C'est un script `.py` autosuffisant,
définissant des objets et des relations entre eux et le monde extérieur
(d'autres modules). Un package est un ensemble cohérent de module. Par exemple
`scikit-learn` propose de nombreux modules utiles pour le machine learning.
Nous utiliserons de manière indifférente les termes modules et packages.

# Installation et mise à jour d'un module

## Comment installer un module Python ? 

### Jupyter

### Pycharm

### Spyder

Dans Spyder, il faut aller dans `Outils > ouvrir une invite de commande`


\bigskip
Ensuite deux possibilités pour rechercher vos modules :

- pour les modules standards : __conda install__ nom_module
- pour les modules plus rare / plus récent : __pip install__ nom_module

Il n'y a pas de réelle différence entre les commandes conda et pip qui sont deux managers de packages différents.
Dans le cas de conda, vous pouvez avoir des librairies qui ne sont pas seulement orientées Python mais aussi C ou R.

### Pour mettre à jour un module déjà installé : 

Il faut retourner dans l'invite de commande et taper

- __conda upgrade__ nom_module



## Utilisation d'un module installé

Au contraire de STATA mais comme pour R, il
faut __toujours préciser les packages que vous utilisez au début du code__,
sinon Python ne reconnait pas les fonctions appellées. 

### Import _module_

On charge un module grâce à la commande `import`.
Pour chaque code que vous exécutez, il faut charger les modules en introduction. 



\bigskip
Une fois que l'on a chargé le module, on peut faire appel aux commandes qui en dépendent en les appelant après avoir tapé le nom du module. Si vous ne précisez pas le nom du module avant celui de la fonction, il ne la trouvera pas forcément.



\bigskip
Voici un exemple avec le module numpy qui est très courant et permet de faire des calculs matriciels sous Python. 


```python
import numpy
print(numpy.arange(5))
```

```
## [0 1 2 3 4]
```

### Import _module_ as _md_ - donner un nom au module

On peut aussi donner un pseudonyme au module pour éviter de taper un nom trop long à chaque fois qu'on utilise une fonction. Classiquement le nom raccourci de numpy est _np_, celui de pandas est _pd_.


```python
import pandas as pd
import numpy as np
small_array = np.array([[1, 2], [3, 4]])
data = pd.DataFrame(small_array)
data.head()
```

```
##    0  1
## 0  1  2
## 1  3  4
```

### from _Module_ Import _fonction_ - seulement une partie du module


{{< panel status="danger" title="warning" icon="fa fa-exclamation-triangle" >}}
Cette méthode n'est pas recommandé **LIEN VERS PARTIE BONNE PRATIQUE**
{{< /panel >}}

Si on ne veut pas être obligé de donner le nom du module avant d'appeler
la fonction, il y a toujours la possibilité de n'importer qu'une fonction du module. Dans le cas de l'exemple, Python sait que la fonction arange est celle de numpy.

Mais ___attention___ : si deux fonctions de modules différents ont le même nom, c'est toujours la dernière importée qui gagne.
On voit souvent from _module_ import \*. C'est-à-dire qu'on importe toutes les fonctions du module mais on n'a pas besoin de spécifier le nom du module avant les méthodes. Faire cela peut être dangereux si vous faites ça pour tous vos modules.


```python
from numpy import array
print(array(5))
```

```
## 5
```


# Les tests

Les tests permettent d'exécuter telle ou telle instruction
selon la valeur d'une condition. 


\bigskip
Pour faire un test avec un bloc d'instruction, il faut toujours : 

- que l'expression à vérifier soit suivie de : 
- et le bloc d'instruction est __forcément indenté__

## Test avec contrepartie : if et else

Comme dans les autres langages, on teste une condition, si elle est vérifiée, alors une instruction suit et sinon, une autre instruction est exécutée. 

Il est conseillé de toujours indiquer une contrepartie afin d'éviter les surprises. 

### Test d'une équalité ou inéqualité
<!-- #endregion -->


```python
x = 6

if x > 5 :
    print("x est plus grand que 5")
else : # la contrepartie si la condition if n'est pas réalisée
    print("x est plus petit que 5")
```

```
## x est plus grand que 5
```

### Test dans un intervalle


```python
# on peut avoir des intervalles directement
x = 6
if 5 < x < 10 : 
    print("x est entre 5 et 10")
else : 
    print("x est plus grand que 10")
```

```
## x est entre 5 et 10
```


```python
# tester plusieurs valeurs avec l'opérateur logique "or"
x = 5
if x == 5 or x == 10 : 
    print("x vaut 5 ou 10")    
else : 
    print("x est différent de 5 et 10")
```

```
## x vaut 5 ou 10
```

### Tests successifs : if, elif et else

Avec if et elif, dès qu'on rencontre une condition qui est réalisée, on n'en cherche pas d'autres potentiellement vérifiées. 
Plusieurs if à la suite peuvent quant à eux être vérifés. Suivant ce que vous souhaitez faire, les opérateurs ne sont pas substituables. Notez la différence entre ces deux bouts de code :


```python
#code 1
x = 5

if x != 10 : 
    print("x ne vaut pas 10")   
elif x >= 5 : 
    print("x est égal ou supérieur à 5")
```

```
## x ne vaut pas 10
```

Dans le cas de elif, on __s'arrête à la première condition__ vérifiée et dans le cas suivant, on __continue à chaque condition vérifiée__


```python
#code 2
x = 5

if x != 10 : 
    print("x ne vaut pas 10")   
```

```
## x ne vaut pas 10
```

```python
if x >= 5 : 
    print("x est égal ou supérieur à 5")
```

```
## x est égal ou supérieur à 5
```

<!-- #region -->
# Boucles

Il existe deux types de boucles : les boucles ___for___ et les boucles ___while___



\bigskip
La boucle _for_ parcourt un ensemble, tandis que la boucle _while_ continue tant qu'une condition est vraie. 


## Boucle for

### Parcourir une liste croissantes d'entiers
<!-- #endregion -->


```python
# parcourt les entiers de 0 à n-1 inclus
for i in range(0,3) : 
    print(i)
```

```
## 0
## 1
## 2
```

### Parcourir une liste décroissante d'entiers


```python
# parcourt les entiers de 3 à n+1 inclus
for i in range(3,0,-1) : 
    print(i)
```

```
## 3
## 2
## 1
```

### Parcourir une liste de chaines de caractères

On va faire une boucle sur les éléments d'une liste

#### Boucle sur les éléments d'une liste


```python
liste_elements = ['Nicolas','Romain','Florimond']

# pour avoir l'ensemble des éléments de la liste
for item in liste_elements : 
    print(item)
```

```
## Nicolas
## Romain
## Florimond
```

#### Boucle sur les éléments d'une liste dans une autre liste


```python
# pour avoir la place des éléments de la première liste dans la seconde liste  

liste_globale = ['Violette','Nicolas','Mathilde','Romain','Florimond','Helene'] 

for item in liste_elements : 
    print(item,liste_globale.index(item))
```

```
## Nicolas 1
## Romain 3
## Florimond 4
```

### Bonus : les list comprehension

Avec les listes, il existe aussi un moyen très élégant de condenser son code pour éviter de faire apparaitre des boucles sans arrêt. Comme les boucles doivent etre indentées, le code peut rapidement devenir illisible.

Grace aux list comprehension, vous pouvez en une ligne faire ce qu'une boucle vous permettait de faire en 3 lignes.

Par exemple, imaginez que vous vouliez faire la liste de toutes les lettres contenues dans un mot, avec un boucle vous devrez d'abord créer une liste vide, puis ajouter à cette liste toutes les lettres en question avec un .append()


```python
liste_lettres = []

for lettre in 'ENSAE':
    liste_lettres.append(lettre)

print(liste_lettres)
```

```
## ['E', 'N', 'S', 'A', 'E']
```

avec une list comprehension, on condense la syntaxe de la manière suivante : 


```python
h_letters = [ letter for letter in 'ENSAE' ]
print(h_letters)
```

```
## ['E', 'N', 'S', 'A', 'E']
```

Avec une list comprehension


```python
[ expression for item in list if conditional ]
```

est équivalent à 



```python
for item in list:
    if conditional:
        expression  
```

#### Mise en application
Mettez sous forme de list comprehension le bout de code suivant


```python
squares = []

for x in range(10):
    squares.append(x**2)
print(squares)
```

```
## [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
```


```python
#squares = [x**2 for x in range(10)]
```

<!-- #region -->
## Boucle while

Le bloc d'instruction d'une boucle __while__ est exécuté tant que la condition est vérifiée. 



Le piège de ces boucles : la boucle while infinie ! Il faut toujours vérifier que votre boucle s'arrêtera un jour, il faut qu'à un moment ou à un autre, il y ait un élément qui s'incrémente ou qui est modifié. 
<!-- #endregion -->


```python
x = 10
y = 8
# tant que y est plus petit que 10, je continue de lui ajouter 1
while y <= x : 
    print("y n'est pas encore plus grand que x")
    y += 1 # l'incrément
else : 
    print("y est plus grand que x et vaut",y)
```

```
## y n'est pas encore plus grand que x
## y n'est pas encore plus grand que x
## y n'est pas encore plus grand que x
## y est plus grand que x et vaut 11
```

## Break et continue

Dans les boucles _for_ ou _while_ on peut avoir besoin d'ignorer ou de ne pas effectuer certaines itérations. __2 instructions utiles : __

- l'instruction __break__ : permet de sortir de la boucle
- l'instruction __continue__ : permet de passer à l'itération suivante sans exécuter les instructions qui suivent 


```python
# utilisation de break
for x in range(5) : 
    if x == 2 : 
        break
    else :
        print(x)
```

```
## 0
## 1
```


```python
# utilisation de continue
for x in range(5) : 
    if x == 2 : 
        continue
    else :
        print(x)
```

```
## 0
## 1
## 3
## 4
```

<!-- #region -->
# Créer ses fonctions

Les fonctions permettent de faire la même chose sans avoir à recopier le code plusieurs fois dans le même programme. Dès que vous le pouvez, faites des fonctions : le copier-coller est trop dangereux.


   - Elles peuvent prendre plusieurs paramètres (ou aucun) elles peuvent retourner plusieurs résultats (ou aucun)
   - Pour mettre une aide à la fonction, on écrit au début entre """ """ (en rouge dans l'exemple)
<!-- #endregion -->


```python
# 1er exemple de fonction

def ma_fonction_increment(parametre) : 
    """Cette fonction ajoute 1 au paramètre qu'on lui donne"""
    x = parametre + 1 
    return x

# pour documenter la fonction, on écrit son aide
help(ma_fonction_increment)
```

```
## Help on function ma_fonction_increment in module __main__:
## 
## ma_fonction_increment(parametre)
##     Cette fonction ajoute 1 au paramètre qu'on lui donne
```

On peut également : 

- avoir des paramètres __facultatifs__, mais ils doivent toujours être placés à la __fin des paramètres__ 
- en cas de paramètre facultatif, il faut lui donner une valeur par défaut
- retourner plus d'un élément à la fin d'une fonction
- avoir des paramètres de taille différentes


```python
def ma_fonction(p,q = 2) :
    y1 = p + q
    y2 = y1%3
    return y1,y2

x = ma_fonction(11) 
# ici, on n'a pas de 2nd paramètre
#, par défaut, x = ma_fonction(10,2)
print("x=", x)
```

```
## x= (13, 1)
```

```python
z = ma_fonction(10,-1)
print("z =",z)
```

```
## z = (9, 0)
```

Une fonction peut également s'appeler elle même : c'est ce qu'on appelle une fonction récursive.

Dans cet exemple, somme_recursion() est une fonction que nous avons défini de sorte à ce qu'elle s'appelle elle même (récursif). 

On utilise l'argument k, qui décroit (-1) chaque fois qu'on fait appelle à la fonction. 

La récursion s'arrête quand k est nul. 
Dans ce cet exemple, on va donc appeler 6 fois la fonction récursive.


```python
def somme_recursion(k):
    if(k > 0):
        result = k + somme_recursion(k - 1)
        print(k,result)
    else:
        result = 0
    return result
somme_recursion(6)
```

```
## 1 1
## 2 3
## 3 6
## 4 10
## 5 15
## 6 21
## 21
```

Les fonctions sont très utiles et nous vous invitons à les utiliser dès que vous le pouvez car elles permettent d'avoir un code clair et structuré, plutot que des bouts de code éparpillés. 

<!-- #region -->
# Lever des exceptions

Python peut rencontrer des erreurs en exécutant votre programme. 



\bigskip
Ces erreurs peuvent être interceptées très facilement et c'est même, dans certains cas, indispensable. Par exemple si vous voulez faire une boucle mais que vous savez que l'instruction ne marchera pas toujours : au lieu de lister les cas où une opération n'est pas possible, on peut indiquer directement quelle erreur doit être ignorée.




\bigskip
Cependant, il ne faut pas tout intercepter non plus : si Python envoie une erreur, c'est qu'il y a une raison. Si vous ignorez une erreur, vous risquez d'avoir des résultats très étranges dans votre programme.
<!-- #endregion -->


```python
# éviter une division par 0, c'est une bonne idée : 

def inverse(x) :
    '''Cette fonction renvoie l inverse de l argument'''
    y = 1/x
    return y

div = inverse(0)
```

```
## Error in py_call_impl(callable, dots$args, dots$keywords): ZeroDivisionError: division by zero
## 
## Detailed traceback: 
##   File "<string>", line 1, in <module>
##   File "<string>", line 3, in inverse
```

<!-- #region -->
L'erreur est écrite noire sur blanc : __ZeroDivisionError__

Dans l'idéal on aimerait éviter que notre code bloque sur ce problème. On pourrait passer par un test if et vérifier que x est différent de 0. Mais on se rend vite compte que dans certains cas, on ne peut lister tous les tests en fonction de valeurs. 

Alors on va lui précisier ce qu'il doit faire en fonction de l'erreur retournée. 


__Syntaxe__

Try : 


    instruction


except TypeErreur :


    autre instruction
<!-- #endregion -->


```python
def inverse(x) : 
    try :
        y = 1/x
    except ZeroDivisionError :
        y = None
    return y
    
print(inverse(10))
```

```
## 0.1
```

```python
print(inverse(0))
```

```
## None
```

Il est recommandé de toujours __préciser le type d'erreur__ qu'on rencontre. Si on met uniquement "except" sans préciser le type, on peut passer à côté d'erreurs pour lesquelles la solution n'est pas universelle


# A retenir et questions

A retenir

- Toujours mettre ":" avant un bloc d'instructions
- Indenter avant un bloc d'instructions (avec 4 espaces et non une tabulation !)
- Indiquer les modules nécessaires à l'exécution en début de code
- Documenter les fonctions créées
- Préciser le type d'erreur pour les exceptions et potentiellement différencier les blocs d'instructions en fonction de l'erreur
- Les modules indispensables 
    - matplotlib : graphes scientifiques
    - numpy : calcul matriciel
    - pandas : gestion de DataFrame
    - scikit-learn : machine learning, statistique descriptive
    - bs4 (nouveau Beautifulsoup) : webscraping 

<!-- #region -->
------
Questions 


- Que fait ce programme ?
<!-- #endregion -->


```python
def inverse(x) : 
    try :
        y = 1/x
    except ZeroDivisionError :
        y = None
        return y
```

- Ecrivez un programme qui peut trouver tous les nombres divisibles par 7 et non multiple de 5 entre 6523 et 8463 (inclus)


- Ecrivez un programme qui prend une phrase en entrée et qui calcule le nombre de voyelles en Majuscules et de consonnes en minuscules : 
    - phrase = "Vous savez, moi je ne crois pas qu’il y ait de bonne ou de mauvaise situation. Moi, si je devais résumer ma vie aujourd’hui avec vous, je dirais que c’est d’abord des rencontres. Des gens qui m’ont tendu la main, peut-être à un moment où je ne pouvais pas, où j’étais seul chez moi. Et c’est assez curieux de se dire que les hasards, les rencontres forgent une destinée... Parce que quand on a le goût de la chose, quand on a le goût de la chose bien faite, le beau geste, parfois on ne trouve pas l’interlocuteur en face je dirais, le miroir qui vous aide à avancer. Alors ça n’est pas mon cas, comme je disais là, puisque moi au contraire, j’ai pu : et je dis merci à la vie, je lui dis merci, je chante la vie, je danse la vie... je ne suis qu’amour ! Et finalement, quand beaucoup de gens aujourd’hui me disent 'Mais comment fais-tu pour avoir cette humanité ?', et bien je leur réponds très simplement, je leur dis que c’est ce goût de l’amour ce goût donc qui m’a poussé aujourd’hui à entreprendre une construction mécanique, mais demain qui sait ? Peut-être simplement à me mettre au service de la communauté, à faire le don, le don de soi..."
