# python-datascientist

[![Build Status](https://travis-ci.com/linogaliana/python-datascientist.svg?branch=master)](https://travis-ci.com/linogaliana/python-datascientist)
[![pipeline status](https://gitlab.com/linogaliana/python-datascientist/badges/master/pipeline.svg)](https://gitlab.com/linogaliana/python-datascientist/-/commits/master)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/linogaliana/python-datascientist/master)
[![Onyxia](https://img.shields.io/badge/launch-onyxia-blue)](https://spyrales.sspcloud.fr/my-lab/catalogue/inseefrlab-datascience/jupyter/deploiement)
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](http://colab.research.google.com/github/linogaliana/python-datascientist/blob/pandas_intro/static/notebooks/numpy.ipynb)
[![Netlify Status](https://api.netlify.com/api/v1/badges/86ebd982-38e0-4e04-81f4-4819131eb800/deploy-status)](https://app.netlify.com/sites/linogaliana-teaching/deploys)

:warning: :construction: **Ce site est en construction** :construction:

Supports associés au site disponible à l'adresse <https://linogaliana-teaching.netlify.app/>. 

Les `notebooks` d'exercice sont dans l'arborescence :folder: `content/**/notebooks/*.ipynb`


Syllabus disponible [là](https://www.ensae.fr/courses/python-pour-le-data-scientist-pour-leconomiste/)



# Contribuer

Pour éditer des notebooks bien intégrés dans le site web, utiliser `jupytext`
![](./static/pictures/intro/jupytext.png)


Pour convertir un notebook jupyter en `.Rmd` (on n'utilise le `.md` que
pour la transition avec hugo) :

```shell
for i in $(find . -type f -name "*.ipynb"); do
  jupytext --to md "$i"
done
```

```shell
jupytext --to Rmd ./content/01_data/02_pandas_tp.ipynb
jupytext --to ipynb ./content/01_data/02_pandas_tp.Rmd
```

