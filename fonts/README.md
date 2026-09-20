# Polices pour la sortie Typst / PDF

Typst n'embarque pas de police d'emoji. Ce dossier est référencé par
`font-paths` dans la section `format: typst` de `_quarto.yml`.

- `NotoColorEmoji.ttf` : [Noto Color Emoji](https://github.com/googlefonts/noto-emoji)
  (v2.051), licence SIL Open Font License 1.1. Twemoji Mozilla, plus légère
  (1,4 Mo), a été écartée : elle n'affiche pas les emoji-chiffres (1️⃣, 2️⃣…)
  utilisés dans les exercices.

Les icônes `Font Awesome` (shortcode `{{< fa >}}`) utilisent les polices de
l'extension `_extensions/quarto-ext/fontawesome/assets/webfonts`, déjà dans le dépôt.
