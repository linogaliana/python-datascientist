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
README.rst
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

Quelques explications:

* Le code python est stocké dans un module nommé `monmodule`. C'est le coeur du code dans le projet. 
* Le fichier `setup.py` sert à construire le package `monmodule` pour en faire un code utilisable.
* Le fichier `requirements.txt`  permet de contrôler les dépendances du projet.  Il s'agit des
dépendances nécessaires pour faire tourner les fonctions (par exemple `numpy`), les tester et
construire automatiquement la documentation (par exemple `sphinx`)
* Le dossier `docs` stocke la documentation du package.
La documentation propre aux fonctions (obtenue en faisant `help(mafonction)`) n'est pas stockée à cet endroit
mais directement dans les fichiers sources avec certaines normes (cf. [plus tard](#docfonctions))
* Les tests génériques des fonctions. Ce n'est pas obligatoire mais c'est recommandé: ça évite de découvrir deux jours
avant un rendu de projet que la fonction ne produit pas le résultat espéré.

# Les tests

Tester ses fonctions peut apparaître formaliste mais c'est, en fait, souvent d'un grand secours car cela permet de
détecter et corriger des bugs précoces (ou au moins d'être conscient de leur existence), vérifier que
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

unittest

# Style de programmation et de documentation

## Un code propre

## Un code documenté {.docfonctions}
Doc: 
https://www.python.org/dev/peps/pep-0257/

## Privilégier des fonctions imbriquées

Python has a system of community-generated proposals known as Python Enhancement Proposals (PEPs)
Perhaps one of the most widely
known and referenced PEPs ever created is PEP8, which is the “Python community Bible” for properly styling your code.

## Documenter ces fonctions

# Gestion des dépendances

En premier lieu, dans un script, il est 

# Tester



# Partager

