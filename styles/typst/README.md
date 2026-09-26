# Template Typst des chapitres (PDF)

Mise en forme des chapitres compilés avec `quarto render --to typst`. La config
est dans `format: typst:` de `_quarto.yml`, `_quarto-prod.yml` et
`_quarto-test.yml` (les trois doivent rester alignées).

## Images distantes

Typst n'a pas d'accès réseau: `image("https://...")` échoue avec
`network access is not supported`. Comme toutes les images du site sont
servies depuis `https://minio.lab.sspcloud.fr/...` (pas de copie locale dans
le repo), ça peut faire échouer la compilation typst de n'importe quel
chapitre contenant une image — pas seulement celles migrées depuis des URLs
externes.

Quarto a un mécanisme interne pour ça (téléchargement dans le mediabag puis
réécriture vers un chemin local), mais il ne s'applique pas systématiquement:
il est court-circuité quand l'image est enveloppée pour l'alignement
(attribut `fig-align`, avec ou sans `width`), ce qui produit
`#align(...)[#box(image("https://..."))]` où l'URL reste distante — testé et
reproduit avec Quarto 1.10.18, donc pas qu'un problème de version trop
ancienne ([quarto-dev/quarto-cli#7962](https://github.com/quarto-dev/quarto-cli/issues/7962),
toujours ouvert). `resolve-remote-images.lua` contourne ça en forçant, pour
toute image distante et uniquement en sortie Typst, le téléchargement et la
réécriture vers un chemin local (`_typst-image-cache/`, gitignoré) avant que
Quarto ne génère le code Typst — indépendamment de `fig-align`/`width`.

Par ailleurs le job `pages` de `prod.yml` est passé de Quarto 1.8.26 à
1.10.18. Ça ne corrige ni ce bug (toujours présent en 1.10.18, d'où le
filtre) ni le problème de `content-to-string` non défini (voir plus bas,
corrigé indépendamment en dur dans `typst-template.typ`) — les deux marchent
donc aussi bien avec 1.8.26. La bascule reste utile en précaution: le format
Typst de Quarto a reçu plusieurs correctifs propres à Typst entre 1.8 et
1.10 (accessibilité, logos, blocs de code Skylighting...), donc rester sur
une version aussi ancienne pour un usage typst qui n'était pas testé jusqu'ici
en CI augmente le risque de retomber sur un bug déjà réglé ailleurs. Pas de
régression identifiée en la testant, mais pas non plus testée sur le vrai
site (voir plus bas).

## Téléchargement PDF sur le site et coût de rendu

Le lien « Télécharger le PDF » sur une page HTML vient de `format-links:`
(même 3 fichiers), mais Quarto ne fusionne pas la clé `format:` entre le
projet et le document ([doc](https://quarto.org/docs/output-formats/html-multi-format.html)):
chaque `.qmd` qui doit avoir un PDF déclare donc lui-même
`format: {html: default, typst: default}` dans son en-tête. Les pages qui
n'en ont pas besoin (`index.qmd`, `404.qmd`, `content/annexes/*.qmd`)
déclarent `format: {html: default}` pour ne pas hériter du format `typst`
(ni `ipynb`) du projet sous `--to all`.

Le CI (`pages` dans `prod.yml`) rend avec `quarto render --to all` (un appel
par profil fr/en) plutôt que `--to html` puis `--to typst` séparément: rendre
les formats séparément sur un projet `website` fait que chaque appel
supprime les fichiers de sortie de l'autre format dans `_site` (testé,
reproductible) — `--to all` rend tous les formats déclarés par chaque
document en une seule passe, donc pas de collision.

`execute: freeze: auto` (même 3 fichiers) évite de réexécuter le code pour
rien: les divs `.content-visible when-profile=...` ne font que masquer du
texte *après* exécution (le code des deux profils tourne dans tous les cas),
donc les résultats d'exécution d'un (document, format) sont réutilisables
d'un profil à l'autre. En pratique, pour un chapitre, ça fait 1 exécution
pour `html` + 1 pour `typst` (partagées entre fr et en), au lieu d'une par
profil et par format. Ça ne rend pas le rendu `typst` gratuit — freeze est
gardé par format, pas partagé entre `html` et `typst` — mais ça compense
exactement la redondance fr/en qui existait déjà avant l'ajout de `typst`.
Ce cache (`_freeze/`) n'est pas persisté entre les runs CI (`.gitignore`):
chaque run repart de zéro, par choix.

| Fichier | Rôle |
|---|---|
| `typst-template.typ` | Partial Quarto `typst-template.typ`: palette (`ds-*`), polices, titres, bloc de titre (titre, filet, auteur·date, description en chapeau), table des matières |
| `typst-show.typ` | Partial Quarto `typst-show.typ`: transmet les métadonnées, dont `description`, à `article()` |
| `page.typ` | Partial Quarto `page.typ`: A4, en-tête (titre du chapitre + adresse du site, sauf page 1), pied de page « n / N », marges de notes |
| `style.typ` | Chargé via `include-in-header`: blocs de code, code en ligne, encadrés, notes, figures, tableaux, citations |
| `inline-code.lua` | Filtre (Typst uniquement): envoie le code en ligne à `ds-inline` de `style.typ` |
| `resolve-remote-images.lua` | Filtre (Typst uniquement): télécharge les images distantes vers `_typst-image-cache/` (voir « Images distantes » plus haut) |

## Choix

- Typographie d'article scientifique: Libertinus Serif (intégrée à Typst) en
  10,5 pt, texte justifié avec césure, titres en gras sans filet, bloc de titre
  centré avec la description en résumé. Code en JetBrains Mono (`fonts/`, repli
  sur DejaVu Sans Mono).
- Page A4, marges symétriques de 3 cm (texte de 15 cm). Les `.aside` du site,
  que Quarto émet comme notes de marge (`#note` de marginalia, avec une colonne
  réservée à droite), sont redéfinis en encadrés discrets dans le texte.
- Tableaux à 7 colonnes ou plus (DataFrame de `pandas`): ils débordent de 1,5 cm
  dans chaque marge puis sont réduits à la largeur disponible.
  Sans cela, les colonnes `auto` ne peuvent pas passer à la ligne au milieu d'un
  nombre et les valeurs se chevauchent. Ils ne sont pas sécables d'une page à l'autre.
- Encadrés (`callout`) sécables d'une page à l'autre: sans cela un encadré plus
  haut que la page débordait sur le pied de page.

- Première page: titre, auteur, « Version du <date> » (`date: today` au moment du
  rendu, `date-format: long`), résumé, puis un avertissement (PDF généré
  automatiquement, renvoi vers pythonds.linogaliana.fr) avant la table des matières.
- Blocs de code sur fond sombre (thème `atom-one-dark`, réglé par `highlight-style`
  dans `format: typst`, et fond fixé dans `Skylighting` de `style.typ`). Le code en
  ligne est en rouge sur fond gris clair: comme la coloration de pandoc utilise les
  couleurs du thème sombre (invisibles sur la page blanche), `inline-code.lua`
  l'écrit lui-même au lieu de la laisser faire. Si on change de thème, ajuster le
  fond de `Skylighting` et la couleur de base du texte qui y est définie.

## Points d'attention

- `callout` est redéfini dans `style.typ`. Quarto réassemble le titre des encadrés
  numérotés en parcourant sa structure (`body.children`): ne pas y ajouter de
  `#set` ni d'enveloppe autour du titre.
- Les constantes `ds-*` sont définies dans `typst-template.typ`, avant
  `page.typ` et `style.typ` dans l'ordre d'assemblage de Quarto, et ne sont
  visibles que par ce qui est défini après elles.
- Dans une partial Pandoc, un `$` littéral doit s'écrire `$$`.
- Le PDF d'un fichier absent de la liste `render:` s'obtient avec
  `--profile prod`: sinon Quarto le traite comme un rendu isolé et Typst refuse
  `../../reference.bib`.
