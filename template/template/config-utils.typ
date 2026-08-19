#import "@preview/glossarium:0.5.10": print-glossary
#import "util.typ": _linguify-content

/// Configure general page settings -> dictionary
#let configure-document(
  /// Page margins. See #link("https://typst.app/docs/reference/layout/page/#parameters-margin")[the typst documentation] for more information -> relative | dictionary
  margin: default-value,
) = {
  if margin == auto {
    panic(
      "`auto` is not allowed for `margin` in this template to simplify subsequent calculations. Please choose a different type.",
    )
  }
  assert(
    margin == default-value
      or type(margin) == dictionary
      or type(margin) == relative
      or type(margin) == length
      or type(margin) == ratio,
    message: "`margin` must be `auto`, a length, a ratio, a relative length, or a dictionary, got "
      + repr(margin)
      + " of type "
      + str(type(margin)),
  )

  if margin != default-value {
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
    page: get-dict-without-default((
      margin: margin,
    )),
  )
}

#let configure-



/// Configure the appendices. -> dictionary
#let configure-appendices(
  /// List of appendices. Entries must have `title` (content), `reference` (string), by which the appendix can be referenced, and text (content). -> array
  appendices: default-value,
) = {
  if appendices != default-value {
    assert(
      type(appendices) == array,
      message: "`appendices` must be an array, got "
        + repr(appendices)
        + " of type "
        + str(type(appendices)),
    )
    let validated = ()
    for (i, entry) in appendices.enumerate() {
      assert(
        type(entry) == dictionary,
        message: "`appendices` entry at index "
          + str(i)
          + " must be a dictionary, got "
          + repr(entry),
      )
      if "title" not in entry {
        panic(
          "`appendices` entry at index "
            + str(i)
            + " is missing required key `title`",
        )
      }
      if "text" not in entry {
        panic(
          "`appendices` entry at index "
            + str(i)
            + " is missing required key `text`",
        )
      }
      let normalized = entry
      if "reference" not in normalized {
        normalized.insert("reference", none)
      } else {
        assert(
          normalized.reference == none or type(normalized.reference) == str,
          message: "`appendices` entry at index "
            + str(i)
            + " has `reference` of type "
            + str(type(normalized.reference))
            + ", expected string or none",
        )
      }
      validated.push(normalized)
    }
    appendices = validated
  }
  return (
    appendices: get-dict-without-default((
      entries: appendices,
    )),
  )
}

/// Configure options regarding drafting.
/// This includes notes and the watermark.
/// See #link("https://typst.app/universe/package/drafting/")[Drafting] for more information on how to add notes.
/// -> dictionary
#let configure-drafting(
  /// A watermark to show on the document margins -> content
  watermark: default-value,
  /// Generator function used to display the watermark -> function
  watermark-generator: default-value,
  /// Whether to display a list of notes at the very first page of the document. -->
  notes-listing: default-value,
) = {
  validate-enable(notes-listing)
  return (
    drafting: get-dict-without-default((
      watermark: watermark,
      notes-listing: notes-listing,
    )),
  )
}

/// Configure arbitrary metadata of the document, used by adapters and components. Low level configuration, is only called from adapters but may be used modify internal behaviour. -> dictionary
#let configure-metadata(
  metadata: default-value,
) = {
  assert(
    metadata == default-value or type(metadata) == dictionary,
    message: "`metadata` must be a dictionary, got "
      + repr(metadata)
      + " of type "
      + str(type(metadata)),
  )

  if metadata == default-value {
    return (
      metadata: (:),
    )
  } else {
    return (
      metadata: metadata,
    )
  }
}


