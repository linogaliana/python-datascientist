#set page(
  paper: $if(papersize)$"$papersize$"$else$"a4"$endif$,
$if(margin)$
  margin: ($for(margin/pairs)$$margin.key$: $margin.value$,$endfor$),
$else$
  margin: (x: 3cm, y: 2.4cm),
$endif$
  numbering: $if(page-numbering)$"$page-numbering$"$else$"1"$endif$,
  columns: $if(columns)$$columns$$else$1$endif$,
  // En-tête (sauf page de titre): titre du chapitre et adresse du site
  header: context {
    if counter(page).get().first() > 1 {
      set text(size: 8pt, fill: ds-muted)
      grid(
        columns: (1fr, auto),
        column-gutter: 1em,
$if(title)$
        [$title$],
$else$
        [],
$endif$
        [#link("https://pythonds.linogaliana.fr")[pythonds.linogaliana.fr]],
      )
      v(-0.5em)
      line(length: 100%, stroke: 0.4pt + ds-rule)
    }
  },
  header-ascent: 35%,
  footer: context {
    set text(size: 8pt, fill: ds-muted)
    align(center)[#counter(page).display() / #counter(page).final().first()]
  },
)
$if(logo)$
#set page(background: align($logo.location$, box(inset: $logo.inset$, image("$logo.path$", width: $logo.width$$if(logo.alt)$, alt: "$logo.alt$"$endif$))))
$endif$
