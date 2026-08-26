#import "@preview/codly:1.3.0": codly, codly-init
#import "../../config/lib.typ" as config
#import "../../general/lib.typ" as general
#import "../../frontbackmatter/lib.typ" as fbm
#import "../../component/lib.typ" as component
#import "_components.typ": _body-footer, _body-header, _coversheet
#import "_frontbackmatter.typ": (
  _abbreviations, _abstracts, _acknowledgements, _bibliography, _glossary,
  _listings, _toc,
)

#let spotless() = {
  let document-show(it) = {
    show heading: it => {
      it
      v(0.5cm)
    }

    show heading.where(level: 2): it => {
      v(weak: true, 1.2cm)
      it
    }

    show raw.where(block: false): box.with(
      fill: luma(240),
      inset: (x: 2pt, y: 0pt),
      outset: (y: 3pt),
      radius: 2pt,
    )

    // fancy code blocks. TODO: move to general.features
    show: codly-init.with()
    codly(
      zebra-fill: none,
      display-icon: false,
      display-name: false,
      number-align: right + top,
    )

    show figure.where(kind: raw): set figure(supplement: "Code")

    // set table numbering to roman
    show figure.where(kind: table): set figure(numbering: "I")

    // fancy inline links
    show link: it => {
      if type(it.dest) == str {
        set text(fill: gray.darken(80%))
        underline(
          stroke: (paint: gray, thickness: 0.5pt, dash: "densely-dashed"),
          offset: 4pt,
          it,
        )
      } else {
        it
      }
    }

    // follow IEEE style for equation references: `(1)` instead of `equation 1`
    show ref: it => {
      if it.element != none and it.element.func() == math.equation {
        numbering("(1)", ..counter(math.equation).at(it.target))
      } else {
        it
      }
    }

    it
  }

  return config.util.merge-configs(
    (:),
    component.show-rules(show-fun: document-show),
    component.page(margin: 2.5cm),
    component.frontmatter.page(numbering: "I"),
    component.backmatter.page(numbering: "a"),
    _coversheet(),
    _body-header(),
    _body-footer(),
    general.layout(pagebreak-heading: true),
    general.typography.body(..general.typography.font.libertinus-serif),
    general.typography.heading(
      ..general.typography.heading-style.modular-scale(
        general.typography.font.libertinus-serif,
        1.2,
      ),
      numbering: "1.",
    ),
    fbm.acknowledgements(generator-function: _acknowledgements, position: -80),
    fbm.abstracts(generator-function: _abstracts, position: -70),
    fbm.toc(generator-function: _toc, position: -60),
    fbm.glossary(generator-function: _glossary, position: 10),
    fbm.abbreviations(generator-function: _abbreviations, position: 20),
    fbm.bibliography(generator-function: _bibliography, position: 30),
    fbm.figure-listings(generator-function: _listings, position: 40),
  )
}
