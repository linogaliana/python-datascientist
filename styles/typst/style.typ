// Mise en forme des éléments du corps du texte (inclus via `include-in-header`,
// donc après les définitions de Quarto et avant le contenu). Les redéfinitions
// `#let` ci-dessous remplacent celles de Quarto pour tout ce qui suit.

// Blocs de code (coloration de pandoc, thème `atom-one-dark` défini dans
// `highlight-style`): fond sombre. Les sorties de cellules restent sur fond clair.
#let Skylighting(fill: none, number: false, start: 1, sourcelines) = {
  let blocks = []
  let lnum = start - 1
  for ln in sourcelines {
    if number {
      lnum = lnum + 1
      blocks = blocks + box(width: if start + sourcelines.len() > 999 { 30pt } else { 24pt }, text(fill: rgb("#636D83"), [ #lnum ]))
    }
    blocks = blocks + ln + EndLine()
  }
  block(
    fill: rgb("#282C34"),
    width: 100%,
    inset: (x: 10pt, y: 9pt),
    radius: 3pt,
    above: 1em,
    below: 1em,
    text(fill: rgb("#ABB2BF"), blocks),
  )
}

// Sorties de cellules et blocs de code sans coloration
#show raw.where(block: true): set block(
  fill: rgb("#F6F8FA"),
  stroke: 0.5pt + ds-rule,
  width: 100%,
  inset: (x: 10pt, y: 8pt),
  radius: 3pt,
)

// Code en ligne (`toto`): couleur et léger fond, sécable en fin de ligne.
// Appelé par le filtre inline-code.lua, qui court-circuite la coloration de
// pandoc (dont les couleurs, prévues pour fond sombre, seraient invisibles ici).
#let ds-inline(s) = highlight(
  fill: rgb("#F3F4F6"),
  extent: 1.5pt,
  radius: 2pt,
  text(fill: rgb("#B0304F"), raw(s)),
)

// Encadrés (callouts): même structure que celle de Quarto (sa règle d'assemblage
// des titres en dépend: ne pas ajouter de `set` ni d'enveloppe), mais sécables d'une page à l'autre (sinon
// un encadré plus haut que la page déborde) et avec plus d'espace autour.
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: true,
    above: 1.2em,
    below: 1.2em,
    fill: background_color,
    stroke: (paint: icon_color, thickness: 0.6pt, cap: "round"),
    width: 100%,
    radius: 3pt,
    block(
      inset: 1pt,
      width: 100%,
      below: 0pt,
      block(
        fill: background_color,
        width: 100%,
        inset: (x: 10pt, y: 7pt))[#if icon != none [#text(icon_color, weight: 900)[#icon] ]#title]) +
      if(body != []){
        block(
          inset: 1pt,
          width: 100%,
          block(fill: body_background_color, width: 100%, inset: (x: 10pt, y: 8pt), body))
      }
    )
}

// Figures: légende discrète et centrée
#show figure: set block(above: 1.4em, below: 1.4em)
#show figure.caption: set text(size: 0.88em, fill: ds-muted)

// Citations en bloc
#show quote.where(block: true): it => block(
  width: 100%,
  inset: (left: 1em, y: 0.3em),
  stroke: (left: 3pt + ds-rule),
  text(fill: ds-muted, it.body),
)

// Tableaux: en-tête grisé, filets horizontaux fins
#set table(
  inset: (x: 8pt, y: 5pt),
  stroke: (x, y) => (
    top: if y == 0 { 0.8pt + ds-ink } else { none },
    bottom: if y == 0 { 0.6pt + ds-ink } else { 0.4pt + ds-rule },
  ),
  fill: (x, y) => if y == 0 { ds-soft } else { none },
)
#show table.cell.where(y: 0): set text(weight: "semibold")
#show table: set text(size: 0.92em)

// Notes de marge (`.aside` du site): Quarto les émet comme `#note(...)[...]` de
// marginalia, qui réserve une colonne à droite de toutes les pages. On les rend
// en encadré discret dans le texte, pour garder des marges symétriques.
#let note(body, ..args) = block(
  width: 100%,
  above: 0.9em,
  below: 0.9em,
  inset: (left: 0.9em, y: 0.3em),
  stroke: (left: 2.5pt + ds-rule),
  {
    set text(size: 0.9em, fill: ds-muted)
    set par(justify: false)
    body
  },
)

// Tableaux larges (DataFrame de `pandas` à une dizaine de colonnes): sans cela
// les colonnes `auto` ne peuvent pas passer à la ligne au milieu d'un nombre et
// les valeurs se chevauchent. On les laisse déborder de 1,5 cm dans chaque marge,
// puis on les réduit s'ils sont encore trop larges.
#show table: it => {
  let ncols = if type(it.columns) == int { it.columns } else if type(it.columns) == array { it.columns.len() } else { 1 }
  if ncols < 7 { return it }
  pad(x: -1.5cm, layout(size => {
    let small = { set text(size: 0.85em, hyphenate: false); it }
    let natural = measure(small)
    if natural.width > size.width {
      let k = size.width / natural.width
      scale(x: k * 100%, y: k * 100%, origin: top + left, reflow: true, small)
    } else {
      small
    }
  }))
}
