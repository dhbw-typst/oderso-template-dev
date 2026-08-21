#import "../config/lib.typ" as config

/// Configure the appendices. -> dictionary
#let appendices(
  /// List of appendices. Entries must have `title` (content), `reference` (string), by which the appendix can be referenced, and text (content). -> array
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
    appendices: config.util.get-dict-without-default((
      entries: appendices,
    )),
  )
}
