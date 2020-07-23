---
title: "Bonne pratique de Python"
date: 2020-07-22T12:00:00Z
draft: false
weight: 30
---

https://docs.python-guide.org/

# Structure d'un projet en python

La structure basique d'un projet développé en `Python` est la suivante, qu'on peut retrouver dans
[ce dépôt](https://github.com/navdeep-G/samplemod):


```python
README.md
LICENSE
setup.py
requirements.txt
monmodule/__init__.py
monmodule/core.py
monmodule/helpers.py
docs/conf.py
docs/index.rst
tests/context.py
tests/test_basic.py
tests/test_advanced.py
```


Quelques explications et parallèles avec les packages `R`^[1] :

* Le code python est stocké dans un module nommé `monmodule`. C'est le coeur du code dans le projet. Contrairement
à `R`, il est possible d'avoir une arborescence avec plusieurs modules dans un seul package. Un bon exemple
de package dont le fonctionnement adopte une arborescence à plusieurs niveaux est `scikit`
* Le fichier `setup.py` sert à construire le package `monmodule` pour en faire un code utilisable. Il n'est pas
obligatoire quand le projet n'a pas vocation à être sur `PyPi` mais il est assez facile à créer en suivant ce
[*template*](https://packaging.python.org/tutorials/packaging-projects/#creating-setup-py). C'est l'équivalent
du fichier `Description` dans un package `R`
([exemple](https://github.com/Rdatatable/data.table/blob/master/DESCRIPTION))
* Le fichier `requirements.txt`  permet de contrôler les dépendances du projet.  Il s'agit des
dépendances nécessaires pour faire tourner les fonctions (par exemple `numpy`), les tester et
construire automatiquement la documentation (par exemple `sphinx`). Dans un package `R`, le fichier qui contrôle
l'environnement est le `NAMESPACE`.
* Le dossier `docs` stocke la documentation du package.
La documentation propre aux fonctions (obtenue en faisant `help(mafonction)`) n'est pas stockée à cet endroit
mais directement dans les fichiers sources avec certaines normes (cf. [plus tard](#docfonctions)). 
Les éléments qui s'en rapprochent dans un package `R` sont les vignettes.
* Les tests génériques des fonctions. Ce n'est pas obligatoire mais c'est recommandé: ça évite de découvrir deux jours
avant un rendu de projet que la fonction ne produit pas le résultat espéré. 
* Le `README.md` permet de créer une présentation du package qui s'affiche automatiquement sur
github/gitlab et le fichier `LICENSE` vise à protéger la propriété intellectuelle. Un certain nombre de licences
standards existent et peuvent être utilisées comme *template* grâce au site <https://choosealicense.com/>

^[1]: La structure nécessaire des projets nécessaire pour pouvoir construire un package `R` est plus contrainte.
Les packages `devtools`, `usethis` et `testthat` ont grandement facilité l'élaboration d'un package `R`. A cet égard,
il est recommandé de lire l'incontournable [livre d'Hadley Wickham](http://r-pkgs.had.co.nz/)


# Style de programmation et de documentation

> The code is read much more often than it is written.
> 
> Guido Van Rossum [créateur de Python]

`Python` est un langage très lisible. Avec un peu d'effort sur le nom des objets, sur la gestion
des dépendances et sur la structure du programme, on peut
très bien comprendre un script sans avoir besoin de l'exécuter. La communauté Python a abouti à un certain
nombre de normes, dites PEP (Python Enhancement Proposal), qui constituent un standard
dans l'écosystème Python. Les deux normes les plus connues sont 
la norme PEP8 (code) et la norme PEP257 (documentation). 

La plupart de ces recommandations ne sont pas propres à `Python`, on les retrouve aussi dans `R`
(cf. [ici](https://linogaliana.gitlab.io/documentationR/comment-nommer-les-objets-dans-r.html)). 
On retrouve de nombreux conseils dans [cet ouvrage](https://docs.python-guide.org/writing/style/) qu'il est
recommandé de suivre. La suite se concentrera sur des éléments complémentaires.

### Import des modules

Un module est un ensemble de fonctions stockées dans un fichier `.py`. Lorsqu'on écrit dans un script

```python
import modu
```

`Python` commence par chercher le fichier `modu.py` dans le dossier de travail. Il n'est donc pas une bonne
idée d'appeler un fichier du nom d'un module standard de python, par exemple `math.py` ou `os.py`. Si le fichier
`modu.py` n'est pas trouvé dans le dossier de travail, `Python` va chercher dans le chemin et s'il ne le trouve pas
retournera une erreur.

Une fois que `modu.py` est trouvé, il sera exécuté dans un environnement isolé (relié de manière cohérente
aux dépendances renseignées) et le résultat rendu disponible à l'interpréteur `Python` pour un usage
dans la session via le *namespace* (espace où python associe les noms donnés aux objets). 

En premier lieu, ne **jamais** utiliser la syntaxe suivante:

```python
# A NE PAS UTILISER
from modu import *
x = sqrt(4)  # Is sqrt part of modu? A builtin? Defined above?
``` 

L'utilisation de la syntaxe `import *` créé une ambiguité sur les fonctions disponibles dans l'environnement. Le code
est ainsi moins clair, moins compartimenté et ainsi moins robuste. La syntaxe à privilégier est la suivante:

```python
import modu
x = modu.sqrt(4)  # Is sqrt part of modu? A builtin? Defined above?
``` 

### Structuration du code

Il est commun de trouver sur internet des codes très longs, généralement dans un fichier `__init__.py`
(méthode pour passer d'un module à un package, qui est un ensemble plus structuré de fonctions).
Avoir des scripts longs est peu désirable (c'est même mauvais) ;
cela rend le code difficilement à s'approprier et à faire évoluer. Mieux vaut avoir des scripts relativement courts
(sans l'être à l'excès...) qui font éventuellement appels à des fonctions définies dans d'autres scripts.

Pour la même raison, la multiplication de conditions logiques `if`...`else if`...`else` est généralement très mauvais
signe (on parle de [code spaghetti](https://fr.wikipedia.org/wiki/Programmation_spaghetti)) ; mieux vaut
utiliser des méthodes génériques dans ce type de circonstances.
 
### Ecrire des fonctions

Les fonctions sont un objet central en `Python`. La fonction idéale est une fonction qui agit de manière compartimentée:
elle prend un certain nombre d'*inputs* et est reliée au monde extérieur uniquement par les dépendances,
elle effectue des opérations sans interaction avec le monde extérieur et retourne un résultat.
Cette définition assez consensuelle masque un certain nombre d'enjeux:

* Une bonne gestion des dépendances nécessite d'avoir appliqué les recommandations évoquées antérieurement 
* Isoler du monde extérieur nécessite de ne pas faire appel à un objet extérieur à l'environnement de la fonction

La fonction la plus lisible est celle qui utilise exclusivement des arguments positionnels avec des noms explicites

```python
def ***
```

Dans le cadre d'une utilisation avancée des fonctions (par exemple un gros modèle de microsimulation), il est 
difficile d'anticiper tous les objets qui seront nécessaires à l'utilisateur. Dans ce cas, on retrouve généralement
dans la définition d'une fonction le mot-clé `**kwargs` (équivalent du `...` en `R`) qui capture les 
arguments supplémentaires et les stocke sous forme de dictionnaire. Il s'agit d'une technique avancée de
programmation qui est à utiliser avec parcimonie.


## Un code documenté {.docfonctions}

sphinx
https://docs.python-guide.org/writing/documentation/

Doc: 
https://www.python.org/dev/peps/pep-0257/

## Privilégier des fonctions imbriquées

TO DO

# Documenter ces fonctions

TO DO
https://docs.python-guide.org/writing/documentation/

# Les tests

Tester ses fonctions peut apparaître formaliste mais c'est, en fait, souvent d'un grand secours car cela permet de
détecter et corriger des bugs précoces (ou au moins d'être conscient de leur existence). 
Au-delà de la correction de *bug*, cela permet de vérifier que
la fonction produit bien un résultat espéré dans une expérience contrôlée. 

On peut partir du principe suivant: *"toute fonctionnalité non testée comporte un bug"*

Le fichier `tests/context.py` sert à définir le contexte dans lequel le test de la fonction s'exécute, de manière
isolée.

```python
import os
import sys
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import sample
```

Chaque fichier du dossier de test
(par exemple `test_basic.py` et `test_advanced.py`) incorpore ensuite la ligne suivante,
en début de script

```python
from .context import sample
```

Pour automatiser les tests, on peut utiliser le package `unittest`
([doc ici](https://docs.python.org/3/library/unittest.html))

```python
import unittest

def fun(x):
    return x + 1

class MyTest(unittest.TestCase):
    def test(self):
        self.assertEqual(fun(3), 4)
```
# Partager

Ce point est ici évoqué en dernier mais, en fait, il est essentiel. Tout travail n'a pas vocation à être public
ou dépasser le cadre d'une équipe. Cependant, les mêmes exigences qui s'appliquent lorsqu'un code est public méritent
de s'appliquer avec un projet personnel. Avant de partager un code avec d'autres, on le partage avec le *"futur moi"*.
Reprendre un code écrit il y a plusieurs semaines est coûteux et mérite d'anticiper en adoptant des bonnes pratiques qui
rendront quasi-indolore la ré-appropriation du code.  

