#import "../template/template/lib.typ": *

// New semantic presentation, without editing an adapter switch or theme geometry.
#show: project.with(
  theme.spotless(),
  general.metadata(
    institution: "Example University",
    title-long: "Initial title",
    authors: ((firstname: "Jane", lastname: "Doe"),),
  ),
  component.coversheet(
    presentation-generator: m => (
      submission-info: [Submitted to #m.institution],
      misc-key-value: ([Project], m.title-long),
    ),
    show-key: "independent-page",
    show-fun: it => {
      set page(margin: 3cm)
      it
    },
  ),
  general.metadata(title-long: "Custom public extension points"),
  frontbackmatter.toc(generator-function: cfg => {
    set par(leading: 0.5em)
    outline(
      title: [Custom contents],
      depth: 2,
      target: selector(heading).before(<_appendix-start>),
    )
  }),
  frontbackmatter.entry(
    "tables",
    position: 5,
    generator-function: cfg => {
      heading([Tables])
      outline(title: none, target: figure.where(kind: table))
    },
    show-key: "listing-style",
    show-fun: it => {
      set text(size: 10pt)
      it
    },
  ),
  component.body.show-rules(show-key: "native-styles", show-fun: it => {
    show heading.where(level: 2): set block(above: 1em, below: 0.4em)
    show raw.where(block: false): set text(fill: blue)
    show figure.where(kind: table): set figure(
      numbering: "1",
      supplement: [Dataset],
    )
    show figure.where(kind: table): set text(fill: blue)
    show figure.where(kind: raw): set figure(supplement: [Listing])
    it
  }),
  component.show-rules(show-key: "pdf-metadata", show-fun: it => {
    set document(author: "Jane Doe", keywords: ("customization", "Typst"))
    it
  }),
  component.appendix.entries(appendices: (
    (title: [Custom appendix], text: [Appendix body]),
  )),
  component.appendix.show-rules(show-key: "annex-style", show-fun: it => {
    show heading.where(level: 1): set heading(
      numbering: "A.",
      supplement: [Annex],
    )
    it
  }),
)

= Public customization
== Focused selectors
Use native figures/tables when opt-in helper styling is not wanted.

#figure(
  table(
    columns: 2,
    [A], [B],
    [1], [2],
  ),
  caption: [Native table],
)

Inline `code` and the following block are styled independently.

#figure(
  ```typ
  #let value = 1
  ```,
  caption: [Example code],
)
