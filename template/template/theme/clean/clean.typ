#import "@preview/codly:1.3.0": codly, codly-init
#import "../../config/lib.typ" as config
#import "../../general/lib.typ" as general
#import "../../frontbackmatter/lib.typ" as fbm
#import "../../component/lib.typ" as component
#import "../shared.typ" as shared
#import "_components.typ": _body-footer, _body-header, _coversheet
#import "_frontbackmatter.typ": _abbreviations, _abstracts, _acknowledgements, _bibliography, _glossary, _listings, _toc

#let clean() = {
  let document-show(it) = {
    show heading: set text(fill: luma(80))

    show raw.where(block: false): box.with(
      fill: luma(240),
      inset: (x: 2pt, y: 0pt),
      outset: (y: 3pt),
      radius: 2pt,
    )

    show figure.where(kind: raw): set figure(supplement: "Code")

    it
  }

  return config.util.merge-configs(
    (:),
    component.show-rules(
      show-key: "spotless",
      show-order: 0,
      show-fun: document-show,
    ),
    component.page(margin: 2.5cm),
    component.frontmatter.page(numbering: "I"),
    component.backmatter.page(numbering: "a"),
    component.body.page(numbering: "1"),
    _coversheet(),
    _body-header(),
    _body-footer(show-total-pages: false),
    general.layout(pagebreak-heading: true),
    general.typography.body(..general.typography.font.source-serif-4),
    general.typography.heading(
      ..general.typography.heading-style.custom-scale(
        general.typography.font.source-sans-3,
        (1, 1, 16 / 11, 40 / 11),
      ),
      numbering: "1.1",
    ),
    general.drafting(notes-listing: true),
    fbm.acknowledgements(generator-function: _acknowledgements, position: -80),
    fbm.abstracts(generator-function: _abstracts, position: -70),
    fbm.toc(generator-function: _toc, position: -60),
    fbm.glossary(generator-function: _glossary, position: 10),
    fbm.abbreviations(generator-function: _abbreviations, position: 20),
    fbm.bibliography(generator-function: _bibliography, position: 30),
    fbm.figure-listings(generator-function: _listings, position: 40),
    shared.ieee-equations(),
    shared.inline-code(),
  )
}
