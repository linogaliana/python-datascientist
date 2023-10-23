# Contribuer aux supports

## Fonctionnement du dépôt

Le site web et les notebooks sont construits à partir de `Quarto`. Le site
web est le format par défaut, les _notebooks_ sont construits par
intégration continue. 

En supposant que l'environnement `Python` est fonctionnel (cf. ci-dessous), 
le site web dans son ensemble peut être construit avec la commande
suivante

```shell
# pour les utilisateurs du sspcloud
quarto preview --port 5000 --host 0.0.0.0

# hors du sspcloud
quarto preview
```

Pour ne faire un _render_ que d'une fiche, il est possible de modifier à la main 
la section `render` du 
fichier `_quarto.yml`. Supprimer la liste des fichiers sauf les `**/introductions.qmd`
et la fiche désirée.
N'oubliez pas de restaurer la version d'origine
du `quarto.yml` avant de faire la _pull request_ !

Pour visualiser le _notebook_ qui sera généré à l'issue des
modifications, la commande à exécuter est la suivante :

```shell
quarto render chemin_du_fichier/fichier.qmd --to ipynb
```

puis ouvrir le `.ipynb` obtenu. 

La correction peut être prévisualisée de la manière suivante :

```shell
quarto render --execute -M echo:true
```

puis ouvrir le `.ipynb` obtenu. 


__Aucun *output* ne doit être committé, seuls les fichiers sources `.qmd`__. Toutes les
sorties (fichiers .png, .html, .ipynb, etc.) sont générées
par le biais de scripts automatisés qui tournent à chaque
_commit_ sur le dépôt `linogaliana/python-datascientist`. 


## Mise en place de l'environnement pour tester les exemples

Pour les contributeurs ayant un accès au SSP Cloud,
ces commandes suffisent pour
avoir l'environnement minimal nécessaire pour construire en local
le site _web_. 

```shell
# Sur le SSPCloud
pip install -r requirements.txt
./requirements.sh
```

Pour les contributeurs hors de cet environnement (dommage !), 
il est nécessaire en premier lieu d'avoir les éléments suivants :

- Une version récente de `Quarto`, _a minima_ la `1.3.450`.
- `Jupyter` et un outil de gestion des environnements `Python` (`miniconda` par exemple).

L'installation de l'environnement minimal pour reproduire les exemples peut être
fait sur la base d'un _trial and error_ en attendant la mise à disposition
d'un fichier adéquat (`pip freeze` ne fournit pas un fichier satisfaisant)

