#import "../config/lib.typ" as config

/// Configure general page settings -> dictionary
#let document(
  /// Page margins. See #link("https://typst.app/docs/reference/layout/page/#parameters-margin")[the typst documentation] for more information -> relative | dictionary
  margin: config.util.default-value,
) = {
  if margin == auto {
    panic(
      "`auto` is not allowed for `margin` in this template to simplify subsequent calculations. Please choose a different type.",
    )
  }
  assert(
    margin == config.util.default-value
      or type(margin) == dictionary
      or type(margin) == relative
      or type(margin) == length
      or type(margin) == ratio,
    message: "`margin` must be `auto`, a length, a ratio, a relative length, or a dictionary, got "
      + repr(margin)
      + " of type "
      + str(type(margin)),
  )

  if margin != config.util.default-value {
    // Normalize margins to be a dictionary of either "left, right, top, bottom" or "inside, outside, top, bottom"
    let cp = margin
    if type(margin) == dictionary {
      let rest = margin.at("rest", default: 0pt)
      if "top" in margin.keys() {
        cp.top = margin.top
      } else if "y" in margin.keys() {
        cp.top = margin.y
      } else {
        cp.top = rest
      }

      if "bottom" in margin.keys() {
        cp.bottom = margin.bottom
      } else if "y" in margin.keys() {
        cp.bottom = margin.y
      } else {
        cp.bottom = rest
      }

      if "inside" in margin.keys() or "outside" in margin.keys() {
        // Fill inside/outside values
        if "inside" in margin.keys() {
          cp.inside = margin.inside
        } else if "x" in margin.keys() {
          cp.inside = margin.x
        } else {
          cp.inside = rest
        }

        if "outside" in margin.keys() {
          cp.outside = margin.outside
        } else if "x" in margin.keys() {
          cp.outside = margin.x
        } else {
          cp.outside = rest
        }
      } else {
        // Fill left/right values
        if "left" in margin.keys() {
          cp.left = margin.left
        } else if "x" in margin.keys() {
          cp.left = margin.x
        } else {
          cp.left = rest
        }

        if "right" in margin.keys() {
          cp.right = margin.right
        } else if "x" in margin.keys() {
          cp.right = margin.x
        } else {
          cp.right = rest
        }
      }
    } else {
      margin = (top: margin, bottom: margin, left: margin, right: margin)
    }
  }

  return (
    page: config.util.get-dict-without-default((
      margin: margin,
    )),
  )
}