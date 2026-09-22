# Polices pour la sortie Typst / PDF

Typst n'embarque ni JetBrains Mono ni de police d'emoji (le texte courant utilise
Libertinus Serif, intégrée à Typst). Ce dossier est
référencé par `font-paths` dans la section `format: typst` de `_quarto.yml`
(et de `_quarto-prod.yml`, `_quarto-test.yml`). Voir `styles/typst/README.md`.

- `JetBrainsMono-*.ttf` (Regular, Italic, Bold, BoldItalic):
  [JetBrains Mono](https://www.jetbrains.com/lp/mono/), licence SIL OFL 1.1.
  Police du code, comme sur le site.
- `NotoColorEmoji.ttf`: [Noto Color Emoji](https://github.com/googlefonts/noto-emoji)
  (v2.051), licence SIL OFL 1.1. Twemoji Mozilla, plus légère (1,4 Mo), a été
  écartée: elle n'affiche pas les emoji-chiffres (1️⃣, 2️⃣…) utilisés dans les
  exercices.

Les icônes `Font Awesome` des encadrés viennent de Quarto (Typst les charge
avec ses polices intégrées); l'extension `quarto-ext/fontawesome` ne gère pas
le shortcode `{{< fa >}}` en Typst.
