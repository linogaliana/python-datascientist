# Python pour data-scientists et économistes
[![build-doc Actions Status](https://github.com/InseeFrLab/utilitR/workflows/Docker%20Build%20and%20Website%20Deploy/badge.svg)](https://github.com/linogaliana/python-datascientist/actions)
[![Docker Pulls](https://img.shields.io/docker/pulls/linogaliana/python-datascientist)](https://hub.docker.com/repository/docker/linogaliana/python-datascientist/general)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/linogaliana/python-datascientist/master)
[![Onyxia](https://img.shields.io/badge/launch-onyxia-blue)](https://datalab.sspcloud.fr/my-lab/catalogue/inseefrlab-helm-charts-datascience/jupyter/deploiement?kubernetes.role=admin)
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](http://colab.research.google.com/github/linogaliana/python-datascientist/blob/pandas_intro/static/notebooks/numpy.ipynb)
[![Netlify Status](https://api.netlify.com/api/v1/badges/86ebd982-38e0-4e04-81f4-4819131eb800/deploy-status)](https://app.netlify.com/sites/linogaliana-teaching/deploys)


Ce dépôt Github stocke les fichiers sources ayant permis de construire le site
<https://linogaliana-teaching.netlify.app/>. 

Il s'agit de l'ensemble du cours *Python pour les data-scientists et économistes* :snake:
que je donne en  
deuxième année (Master 1) de l'ENSAE.


Le syllabus est disponible [là](https://www.ensae.fr/courses/python-pour-le-data-scientist-pour-leconomiste/).

Le site est construit de manière automatique grâce à [Hugo](https://gohugo.io/)
à partir d'un environnement conteneurisée [Docker](https://hub.docker.com/repository/docker/linogaliana/python-datascientist/general) 
La reproductibilité des exemples et des exercices est testée avec 
Github Actions ([![build-doc Actions Status](https://github.com/InseeFrLab/utilitR/workflows/Docker%20Build%20and%20Website%20Deploy/badge.svg)](https://github.com/linogaliana/python-datascientist/actions)).

L'environnement `conda` nécessaire pour faire tourner l'ensemble du
cours est disponible dans le fichier [environment.yml](environment.yml). 
Il est recommandé d'utiliser la `conda-forge` afin de bénéficier de versions
récentes des packages. 


## Tester les codes Python

Il est possible d'utiliser une installation personnelle de `Python` ou 
des serveurs partagés: 

* Binder ([![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/linogaliana/python-datascientist/master)
)
* Google colab ([![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](http://colab.research.google.com/github/linogaliana/python-datascientist/blob/pandas_intro/static/notebooks/numpy.ipynb))
* Onyxia Datalab ([![Onyxia](https://img.shields.io/badge/launch-onyxia-blue)](https://datalab.sspcloud.fr/my-lab/catalogue/inseefrlab-helm-charts-datascience/jupyter/deploiement?kubernetes.role=admin)) pour les élèves de l'ENSAE et
les agents du système statistique public

## Utilisation de l'image Docker [![Docker Pulls](https://img.shields.io/docker/pulls/linogaliana/python-datascientist)](https://hub.docker.com/repository/docker/linogaliana/python-datascientist/general)

Pour améliorer la reproductibilité des exemples, une image `Docker` est 
automatiquement construite et mise à disposition depuis 
[DockerHub](https://hub.docker.com/repository/docker/linogaliana/python-datascientist).

Pour le moment, l'utilisation de `Python` se fait à travers `Rstudio` via
le package `reticulate`. Des versions futures amélioreront la compatibilité
avec les notebooks `Jupyter`. 

### En local

Cette image peut être déployée en local, de la manière suivante:

```shell
docker pull linogaliana/python-datascientist
docker run --rm -p 8787:8787 -e PASSWORD=test linogaliana/python-datascientist
```

Elle peut également être appelée depuis un *pipeline* d'intégration continue
`Github` ou `Gitlab` puisque l'image se trouve sur `DockerHub`.

### Github Actions

```
container: linogaliana/python-datascientist:latest
```

### Gitlab CI

```
image: linogaliana/python-datascientist:latest
```