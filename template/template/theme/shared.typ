#import "../component/lib.typ" as component

#let ieee-equations(enabled: true) = component.show-rules(
  show-key: "ieee-equation",
  show-order: 1000,
  show-fun: it => {
    if not enabled {
      it
      return
    }

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
