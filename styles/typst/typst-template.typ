// Gabarit des chapitres compilés en Typst / PDF (voir styles/typst/README.md).
// Remplace la partial `typst-template.typ` de Quarto: mêmes paramètres, plus
// `description`, et une mise en page pensée pour la lecture d'un chapitre long.

// Palette, alignée sur celle du site (styles/custom*.scss et git-sandbox)
#let ds-ink = rgb("#22384C")     // titres
#let ds-accent = rgb("#447099")  // filets, liens
#let ds-soft = rgb("#F3F6F8")    // fonds discrets
#let ds-muted = rgb("#5B6770")   // métadonnées, légendes
#let ds-rule = rgb("#D0DBE5")    // filets fins

#let ds-body-font = ("Libertinus Serif",)
#let ds-code-font = ("JetBrains Mono", "DejaVu Sans Mono")

#let article(
  title: none,
  subtitle: none,
  authors: none,
  keywords: (),
  date: none,
  abstract-title: none,
  abstract: none,
  description: none,
  thanks: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: none,
  fontsize: 10.5pt,
  title-size: 1.9em,
  subtitle-size: 1.25em,
  heading-family: none,
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  mathfont: none,
  codefont: none,
  linestretch: 1.25,
  sectionnumbering: none,
  linkcolor: none,
  citecolor: none,
  filecolor: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.2em,
  doc,
) = {
  // Métadonnées du PDF (accessibilité)
  set document(title: title, keywords: keywords)
  set document(
    author: authors.map(author => content-to-string(author.name)).join(", ", last: " & "),
  ) if authors != none and authors != ()

  // Texte courant: police à empattements, justifié avec césure (typographie
  // d'article scientifique).
  let body-font = if font != none { font } else { ds-body-font }
  set text(
    lang: lang,
    region: region,
    size: fontsize,
    font: body-font,
    hyphenate: true,
    fill: rgb("#1E2226"),
  )
  set par(justify: true, leading: linestretch * 0.5em, spacing: 0.95em)
  show math.equation: set text(font: mathfont) if mathfont != none
  show raw: set text(font: if codefont != none { codefont } else { ds-code-font }, size: 0.85em)

  // Listes plus aérées
  set list(indent: 0.4em, body-indent: 0.6em, spacing: 0.75em)
  set enum(indent: 0.4em, body-indent: 0.6em, spacing: 0.75em)

  // Titres: sobres, en gras, couleur encre; jamais isolés en bas de page
  set heading(numbering: sectionnumbering)
  show heading: it => {
    let sizes = (1.45em, 1.2em, 1.05em, 1em)
    let size = sizes.at(calc.min(it.level, sizes.len()) - 1)
    set text(fill: ds-ink, weight: if it.level <= 2 { heading-weight } else { "semibold" }, size: size)
    set par(leading: 0.45em, justify: false)
    let content = {
      if it.numbering != none {
        counter(heading).display(it.numbering)
        h(0.6em)
      }
      it.body
    }
    if it.level == 1 {
      block(above: 2.1em, below: 1.3em, sticky: true, content)
    } else if it.level >= 3 {
      block(above: 1.5em, below: 1.05em, sticky: true, text(style: "italic", content))
    } else {
      block(above: 1.8em, below: 1.2em, sticky: true, content)
    }
  }

  // Liens
  show link: set text(fill: if linkcolor != none { rgb(content-to-string(linkcolor)) } else { ds-accent })
  show ref: set text(fill: rgb(content-to-string(citecolor))) if citecolor != none
  show link: this => {
    if filecolor != none and type(this.dest) == label {
      text(this, fill: rgb(content-to-string(filecolor)))
    } else {
      text(this)
    }
  }

  // Bloc de titre centré: titre, auteur · date, puis la description en résumé
  let has-title-block = title != none or (authors != none and authors != ()) or date != none or abstract != none
  if has-title-block {
    block(width: 100%, above: 0pt, below: 1.8em, {
      set par(leading: 0.4em, justify: false)
      align(center, {
        if title != none {
          text(size: title-size, weight: "bold", fill: ds-ink)[#title #if thanks != none {
            footnote(thanks, numbering: "*")
            counter(footnote).update(n => n - 1)
          }]
          if subtitle != none {
            linebreak()
            text(size: subtitle-size, fill: ds-muted)[#subtitle]
          }
          v(0.8em)
        }
        if authors != none and authors != () {
          v(0.2em)
          text(size: 1.1em, weight: "semibold")[#authors.map(author => author.name).join([, ], last: [ & ])]
        }
        if date != none {
          linebreak()
          text(size: 0.95em, fill: ds-muted)[#if lang == "en" [Version of] else [Version du] #date]
        }
      })
      if description != none {
        v(1.1em)
        pad(x: 1.2cm, {
          set text(size: 0.95em)
          set par(justify: true)
          description
        })
      }
      if abstract != none {
        v(1em)
        pad(x: 1.2cm)[#text(weight: "semibold")[#abstract-title] #h(1em) #abstract]
      }
      v(0.9em)
      line(length: 100%, stroke: 0.5pt + ds-rule)
    })
  }

  // Avertissement: PDF généré automatiquement
  block(
    width: 100%,
    above: 0pt,
    below: 1.6em,
    breakable: false,
    fill: rgb("#FFF7E8"),
    stroke: (left: 3pt + rgb("#E8A33D"), rest: 0.5pt + rgb("#F0D9AE")),
    inset: (x: 11pt, y: 9pt),
    radius: 3pt,
  )[
    #set text(size: 0.93em)
    #set par(justify: false)
    #if lang == "en" [
      *⚠️ Automatically generated PDF.* This document is produced from the course
      website and may contain formatting issues. For an up-to-date version adapted
      to your reading, visit the course page:
      #link("https://pythonds.linogaliana.fr")[pythonds.linogaliana.fr].
    ] else [
      *⚠️ PDF généré automatiquement.* Ce document est produit à partir du site du
      cours et peut présenter des problèmes de mise en forme. Pour une version à
      jour et adaptée à la lecture, consultez la page du cours :
      #link("https://pythonds.linogaliana.fr")[pythonds.linogaliana.fr].
    ]
  ]

  // Table des matières
  if toc {
    show outline.entry.where(level: 1): it => {
      v(0.55em, weak: true)
      strong(it)
    }
    show outline.entry: set text(size: 0.94em)
    block(above: 0em, below: 2.2em, {
      // Titre en texte simple: `outline(title:)` en ferait un titre de niveau 1 (filet, grande taille)
      if toc_title != none {
        block(below: 0.8em, text(size: 1.15em, weight: "semibold", fill: ds-ink, toc_title))
      }
      outline(title: none, depth: toc_depth, indent: toc_indent)
    })
  }

  doc
}
