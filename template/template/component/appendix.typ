// LTeX: enabled=false
#import "../config/lib.typ" as config
#import "_shared.typ": (
  make-footer, make-header, make-page, make-show-rules, make-toc,
)

/// Configure show rules scoped to appendix content. -> dictionary
#let show-rules = make-show-rules("appendix")

/// Configure the table of contents entry for the appendix. -> dictionary
#let toc = make-toc("appendix")

/// Configure the header for the appendix section only. -> dictionary
#let header = make-header("appendix")

/// Configure the footer for the appendix section only. -> dictionary
#let footer = make-footer("appendix")

/// Configure the page settings (numbering, margin) for the appendix section only. -> dictionary
#let page = make-page("appendix")

/// Configure the appendices. -> dictionary
#let entries(
  /// List of appendices with title and text; reference is an optional string. An empty array clears inherited entries. -> array
  appendices: config.util.default-value,
) = {
  if appendices != config.util.default-value {
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
    component: (
      appendix: config.util.get-dict-without-default((
        entries: appendices,
      )),
    ),
  )
}
