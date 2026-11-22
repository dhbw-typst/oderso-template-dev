#import "../component/lib.typ" as component
#import "../general/lib.typ" as general
#import "@preview/codly:1.3.0": codly
#import "@preview/drafting:0.2.2": set-margin-note-defaults

/// Shared academic appearance formerly built into the renderer. Disable the
/// keyed `academic` rule to restore Typst defaults, or replace its callback.
/// -> dictionary
#let academic() = component.show-rules(
  show-key: "academic",
  show-order: -1000,
  show-fun: it => {
    show table: set par(justify: false)
    show figure.where(kind: table): set figure(numbering: "I")
    codly(
      zebra-fill: none,
      display-icon: false,
      display-name: false,
      number-align: right + top,
    )
    show link: it => {
      if type(it.dest) == str {
        set text(fill: gray.darken(80%))
        underline(
          stroke: (paint: gray, thickness: 0.5pt, dash: "densely-dashed"),
          offset: 4pt,
          it,
        )
      } else { it }
    }
    set-margin-note-defaults(
      rect: rect.with(radius: 0.5em),
      fill: orange.lighten(80%),
    )
    it
  },
)

/// Default draft watermark appearance. Content alone works after this preset
/// (included in spotless); none suppresses it, and a custom generator replaces it.
/// -> dictionary
#let watermark() = general.drafting(watermark-generator: cfg => {
  let content = cfg.general.drafting.at("watermark", default: none)
  if content != none {
    place(center + horizon, rotate(-45deg, text(
      size: 60pt,
      fill: gray.transparentize(75%),
      content,
    )))
  }
})

#let ieee-equations() = component.show-rules(
  show-key: "ieee-equation",
  show-order: 1000,
  show-fun: it => {
    // follow IEEE style for equation references: `(1)` instead of `equation 1`
    set math.equation(numbering: "(1)")
    show ref: it => {
      if it.element != none and it.element.func() == math.equation {
        link(it.target, numbering(
          "(1)",
          ..counter(math.equation).at(it.target),
        ))
      } else {
        it
      }
    }

    it
  },
)

/// Styled inline code blocks
#let inline-code(
  fill: luma(240),
  inset: (x: 2pt, y: 0pt),
  outset: (y: 3pt),
  radius: 2pt,
  ..opts,
) = component.show-rules(
  show-key: "inline-code",
  show-order: 1000,
  show-fun: it => {
    show raw.where(block: false): box.with(
      fill: fill,
      inset: inset,
      outset: outset,
      radius: radius,
      ..opts,
    )
    it
  },
)
