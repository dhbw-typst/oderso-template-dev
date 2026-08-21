#let spotless() = {
   // TODO: Add styling
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

  return config.merge-configs(
    (:),
    _coversheet(),
    _body-header(),
    _body-footer(),
  )
}
