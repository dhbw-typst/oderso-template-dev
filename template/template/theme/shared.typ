#import "../component/lib.typ" as component

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
