#import "../component/lib.typ" as component
#import "../feature/lib.typ" as feature
#import "@preview/drafting:0.2.2": set-margin-note-defaults

/// Academic table conventions; native tables/figures remain an escape hatch.
/// -> dictionary
#let table-conventions() = component.show-rules(
  show-key: "academic",
  show-order: -1000,
  show-fun: it => {
    show table: set par(justify: false)
    show figure.where(kind: table): set figure(numbering: "I")
    it
  },
)

/// Muted, underlined URL appearance; internal links are untouched. -> dictionary
#let urls() = component.show-rules(
  show-key: "academic-urls",
  show-order: -1000,
  show-fun: it => {
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
    it
  },
)

/// Replaceable drafting note appearance, independent of listing placement.
/// -> dictionary
#let notes() = component.show-rules(
  show-key: "academic-notes",
  show-order: -1000,
  show-fun: it => {
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
#let watermark() = feature.drafting(watermark-generator: cfg => {
  let content = cfg.feature.drafting.at("watermark", default: none)
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
