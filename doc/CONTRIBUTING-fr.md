# Guide pour accompagner les personnes désirant contribuer à améliorer le contenu de ce site

> [!NOTE]  
> Vous voyez la version française 🇫🇷  du `CONTRIBUTING`. Pour lire la version anglaise 🇬🇧🇺🇸, vous pouvez cliquer sur le lien ci-dessous
> 
> [![en](https://img.shields.io/badge/lang-en-red.svg)](https://github.com/linogaliana/python-datascientist/blob/main/doc/CONTRIBUTING-en.md)


L'ensemble des contenus de ce site web est contributif et peut être amélioré de manière collaborative selon vos compétences et appétences. __Merci beaucoup si vous êtes prêts à apporter votre concours à l'amélioration du site !__

L'objectif de ce `CONTRIBUTING` est de guider toute personne intéressée par la suggestion de contenu vers le moyen le plus adéquat. Ce fichier présentera la marche à suivre principalement pour les propositions de contenu substantielles, qui nécessitent un accompagnement car elles demandent la compréhension du fonctionnement du site. 

Néanmoins, pour les petites suggestions de modification, il est recommandé de passer directement par l'interface de `Github`: il n'est pas nécessaire de comprendre le fonctionnement (complexe) du site pour pointer un lien mort, pour modifier une coquille ou une référence vers une figure qui n'existe pas !

> [!NOTE]
> Ce `CONTRIBUTING` ne doit pas vous apparaître comme étant intimidant ; au contraire, l'objectif de celui-ci est d'accompagner les utilisateurs désirant faire les modifications les plus substantielles pour leur montrer que le fonctionnement de ce site est moins sorcier qu'il en a l'air. 


> [!CAUTION]
> Pour des modifications substantielles, il est recommandé de tester celles-ci par le biais d'un éditeur de fichiers comme `VSCode`. Ceci est expliqué plus bas.
> 
> Ces suggestions de modifications doivent passer par le biais d'une branche, comme cela sera indiqué. Pour des modifications plus minimalistes, par exemple la correction de coquilles, il est certainement plus simple de passer directement par l'interface de `Github` qui fera ce travail de création de branche pour vous. 

## Quel type de contribution ?

Les suggestions de modifications peuvent principalement êtres faites par deux biais:

* Les _[discussions](https://github.com/linogaliana/python-datascientist/discussions)_ permettent de pointer un problème ou de discuter pour améliorer le contenu. Si vous n'êtes pas à l'aise avec la modification de contenu sur `Github`, c'est la manière la plus simple de démarrer. Il se peut que je transfère la discussion vers une [_issue_](https://github.com/linogaliana/python-datascientist/issues) pour garder une trace de celle-ci dans mon plan de modifications.
* Les [_pull request_](https://github.com/linogaliana/python-datascientist/pulls) permettent de suggérer directement une mise à jour du fichier. 
    + Pour une modification marginale du texte, par exemple une coquille, vous pouvez faire directement ceci grâce au bouton `Edit` de `Github`. 
    + Pour une modification plus substantielle du contenu, avant de faire une grosse _pull request_, n'hésitez pas à ouvrir une [_issue_](https://github.com/linogaliana/python-datascientist/issues) pour échanger sur la modification que vous voudriez mettre en oeuvre.

La suite de ce guide supposera que vous vous trouvez dans le dernier scénario, c'est à dire une modification substantielle du contenu qui a été discutée dans une [_issue_](https://github.com/linogaliana/python-datascientist/issues). L'objectif de la suite de ce guide est de vous donner toute l'information utile pour comprendre la logique du dépôt. 


## Fonctionnement du dépôt

### Principe

Le site web et les notebooks sont construits à partir de [`Quarto`](https://quarto.org/). Les ressources `Python` mises à disposition grâce à ce dépôt `Github` sont de deux types :

* Le site web [pythonds.linogaliana.fr/](https://pythonds.linogaliana.fr/) est le contenu principal produit à partir de ce dépôt. Il s'agit de l'_output_ html construit par `Quarto` (voir plus bas) ;
* Les _notebooks_ proposent le même contenu textuel avec du code exécutable dans un environnement `Jupyter` ou `VSCode` de votre choix. Il s'agit de l'_output_ ipynb construit par `Quarto` (voir plus bas). Ceci est important car le _notebook_ n'est pas, comme c'est souvent le cas, le fichier source mais une production à partir d'une autre source de vérité : ce ne sont donc pas les _notebooks_ sur lesquels vous pourrez faire vos suggestions de modification.

Le contenu bilingue est géré par le biais des [_profiles_](https://quarto.org/docs/projects/profiles.html) `Quarto`. Par conséquent, les fichiers bilingues proposent de nombreuses balises du type `::: {.content-visible when-profile="en"}` ou `::: {.content-visible when-profile="fr"}` pour gérer le contenu affiché dans la version anglaise ou française. Ce choix permet de limiter les redondances de code tout en ayant un contenu adaptatif pour le lecteur de la version web (pour la version _notebook_, seule la langue choisie est affichée mais les versions françaises et anglaises coexistent). 


### Architecture du dépôt

Le dépôt est structuré sous la forme d'un projet `Quarto`. Le comportement de celui-ci est contrôlé par les fichiers `_quarto*.yml` à la racine. A l'heure actuelle, il y a 4 fichiers de ce type qui peuvent être regroupés en deux catégories :

* `_quarto.yml` et `_quarto-prod.yml` sont les fichiers qui définissent le comportement global de `Quarto`.
    + `_quarto.yml` est utile pour les tests lors de la phase de développement car il ne fait pas tourner tous les chapitres, seulement ceux définis dans celui-ci. **C'est celui-ci que vous modifierez** si vous désirez tester des modifications substantielles d'un chapitre. 
    + Le second sert lors de la construction du site dans son ensemble lors de la phase d'intégration continue (cf. ci-dessous). Sauf modification volontaire du comportement du site web, il ne doit pas être modifié. 
* `_quarto-fr.yml` et `_quarto-en.yml` gèrent le paramétrage des versions françaises et anglaises, en complément du paramétrage global expliqué précédemment. Par défaut, la version française est construite exclusivement. Le script `build/preview_all.sh` sur lequel nous reviendrons illustrera comment _build_ une version multilingue du site web. 

Les principaux dossiers 📁 du dépôt sont :

* `content/`: les fichiers source à l'origine du site web (en supplément de la page d'accueil `index.qmd`) ;
* `build/`: des scripts utiles pour l'intégration continue ou pour surcharger des paramètres pour certains chapitres ;
* `dev-scripts/`: des scripts utiles pour le développement en local du site lors de la phase de test ;
* `.github/` et `docker/`: des scripts utiles pour l'intégration continue (création de l'environnement de reproductibilité avec l'image `Docker`, utilisation de celle-ci dans les actions `Github` pour construire le site et tester les _notebooks_)

## Prévisualisation du site web

> [!TIP]
> La prévisualisation nécessite un environnement d'exécution `Quarto` avec `Python`. Les agents publics, étudiants et chercheurs peuvent bénéficier d'un tel environnement gratuitement grâce à l'infrastructure [`SSPCloud`](https://datalab.sspcloud.fr/?lang=fr) développée par l'Insee. Celle-ci sera bien plus malléable et puissante que Google Colab. Si vous n'entrez pas dans ces catégories d'utilisateurs, il est recommandé d'installer [`Quarto`](https://quarto.org/docs/get-started/) sur votre environnement de prédilection.


### Environnement de développement prêt à l'emploi pour les utilisateurs du `SSPCloud`

Pour les utilisateurs du `SSPCloud`, voici l'environnement que j'utilise pour développer mes supports :

<a href="https://datalab.sspcloud.fr/launcher/ide/vscode-python?name=python%20ENSAE&version=1.11.39&autoLaunch=false&kubernetes.role=«admin»&networking.user.enabled=true&git.cache=«36000»&git.repository=«https%3A%2F%2Fgithub.com%2Flinogaliana%2Fpython-datascientist.git»&init.personalInit=«https%3A%2F%2Fraw.githubusercontent.com%2Flinogaliana%2Finit-scripts%2Fmain%2Finstall-copilot.sh»" target="_blank" rel="noopener"><img src="https://img.shields.io/badge/SSPcloud-Tester%20via%20SSP--cloud-informational&amp;color=yellow?logo=Python" alt="Onyxia"></a><br>

### Etapes préliminaires

1️⃣ Changer de branche

```python
cd python-datascientist
git checkout -b suggestion #ou un autre nom si cette branche existe déjà
```


> [!IMPORTANT]  
> Ce changement de branche n'est pas indispensable pour une première suggestion de modification mais vous sera utile ultérieurement pour vous éviter des conflits de version s'il y a eu des évolutions du support entre temps. 

2️⃣ Installer les packages utilisés dans le cours

Ce cours essaie d'être à la page des versions actuelles de `Python` et des librairies de _data science_. Il est donc recommandé d'utiliser une version récente de `Python` (au moins la 3.9 en ce jour d'août 2024). 

Pour installer l'ensemble des dépendances utiles pour construire le site web, vous pouvez faire

```python
./build/requirements.sh
uv sync
```

Si vous avez utilisé `./build/preview_all.sh`, cette étape est directe.

Il y aura certainement beaucoup plus de _packages_ que ceux utiles au développement d'un ou deux chapitres mais au moins vous serez tranquilles. 

## Modifier un fichier

Le contenu d'un chapitre peut être modifié dans n'importe quel éditeur de texte. Je recommande néanmoins d'utiliser `VSCode` qui est l'éditeur qui supporte le mieux `Quarto` et offre le plus de fonctionnalités utiles pour `Python`. 

> [!NOTE]
> Pour modifier exclusivement du texte, il n'est pas nécessaire de tester les exemples `Python` comme indiqué dans la prochaine section. Néanmoins, si le chapitre est multilingue, et que la modification suggérée n'est pas seulement une coquille, il est appréciable de modifier aussi la version anglaise pour m'éviter des incohérences entre le texte dans les différentes versions. Pour réduire la pénibilité de ce travail, je vous donne ci-dessous le _prompt_ que je donne à `ChatGPT` pour qu'il me fasse la mise en forme adéquate dans les balises `::: {.content-visible when-profile="en"}` ou `::: {.content-visible when-profile="fr"}`
> 
> Ceci n'est pas obligatoire et ne doit pas vous rebuter à me suggérer des modifications. Si une traduction est nécessaire, je la mettrai en oeuvre mais si vous êtes d'humeur généreuse, cela me fera économiser un peu de temps 😉 

<details>
<summary>
Exemple de prompt pour avoir la traduction par `ChatGPT`
</summary>

> I am going to give you french content as raw markdown (copy pasted from a .qmd file). I want you to translate that content into english but there is going to be a series of important rules.
> 
> - You should put the translation into pandoc divs (see example below).
> - You should not change me the python chunks (
> {python} ...
> ) when you see one
> - To avoid formatting of the markdown in the UI, you are going to put everything between ~~~
> - You don't change the french text, you just put it inside the relevant pandoc div
> 
> Example:
> 
> ```
> # Contenu français
> 
> Ceci est du contenu français
> 
> {python}
> import numpy as np
> 
> ```
> 
> I want an answer like that
> 
> ```
> ::: {.content-visible when-profile="fr"}
> # Contenu français
> 
> Ceci est du contenu français
> 
> {python}
> import numpy as np
> 
> :::
> ```
> 
> ::: {.content-visible when-profile="en"}
> 
> # English content
> 
> This is English content
> 
> {python}
> import numpy as np
> 
> :::
> 
> ```
> 
> understood ?
> ```
</details>


## Tester des modifications

Imaginons que vous ayez fait des modifications sur un fichier et que vous désirez les tester. 

### Prévisualiser l'apparence sur le site web

- [ ] Mettre à jour `_quarto.yml` (ne pas toucher à `_quarto-prod.yml`) pour inclure votre fichier dans la liste `render` ;
- [ ] Lancer le script `/build/preview_all.sh` en ligne de commande, celui-ci comporte les lignes suivantes :

```python
./build/requirements.sh
uv sync
uv run quarto preview --port 5000 --host 0.0.0.0
```

qui permettent:

1. Installer les dépendances (si ce n'est pas déjà fait) ;
2. Construire le site, en Anglais et en Français
3. Lancer un serveur local qui permet de prévisualiser le site web
    + Si vous utilisez l'environnement du `SSPCloud` (comme suggéré ci-dessus, si vous êtes éligible), dans le `README` de votre projet, vous avez un lien qui vous permet de voir votre site web et naviguer dans celui-ci (cf. capture ci-dessous)
    + Si vous êtes dans un environnement local, le site devrait être accessible par le biais de https://0.0.0.0:5000

_Accéder au contenu prévisualisé pour les utilisateurs du SSPCloud_:
![](https://raw.githubusercontent.com/InseeFrLab/funathon2024_sujet2/main/img/readme_app6.png)

### Vérifier que le notebook fonctionne

Le produit principal du cours est le site web https://pythonds.linogaliana.fr dont la reproduction en local pour _preview_ a été expliquée précédemment. Mais ce n'est pas le seul produit utile dans ce cours, il y a également les _notebooks_ `Jupyter` qui servent à tester les exemples et dont le contenu est une reproduction de celui du site web à quelques exceptions près liées aux limites intrinsèques à ce format par rapport à un site web interactif.

Contrairement à la plupart des ressources en ligne sur `Python`, je ne fais pas du _notebook_ le produit d'entrée de mon _pipeline_ (je pense que c'est une terrible erreur de faire ça pour la maintenance des ressources) mais le produit final. `Quarto` permet de générer des _notebooks_ au même titre que des sites web (dis comme ça cela paraît simple mais en pratique ça a été de belles galères, j'ai donc des scripts intermédiaires en `lua` automatiquement exécutés par `Quarto` pour avoir de beaux _notebooks_). 

Pour créer les _notebooks_, il suffit d'exécuter les commandes suivantes:

```python
./build/requirements.sh
uv sync
uv run quarto preview --to ipynb
```
 
