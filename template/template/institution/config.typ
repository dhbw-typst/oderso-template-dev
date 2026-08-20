#import "../config/lib.typ" as config
// ============================================================
//                    SHARED ADAPTERS
// ============================================================
// Configuration for front/back matter sections that every adapter
// (`dhbw-ka`, `dhbw-ma`, `ihk`) provides.




// ============================================================
//                    DHBW KARLSRUHE
// ============================================================

/// Configure the AI acknowledgement section for DHBW Karlsruhe theses.
/// The section is rendered only when `entries` is non-empty. -> dictionary
#let configure-dhbw-ka-ai-acknowledgement(
  /// Where the AI acknowledgement should be displayed. -> "frontmatter" | "backmatter"
  position: config.util.default-value,
  /// What order the AI acknowledgement should have. -> int
  order: config.util.default-value,
  /// List of AI tool entries. Each entry must have `tool` (str) and `usage`
  /// (content). Empty array disables the section. -> array
  entries: (),
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the AI acknowledgement section `content` (or `none` to skip). -> function
  generator-function: config.util.default-value,
) = {
  config.validation.validate-position-order(position, order)
  config.validation.validate-generator(generator-function)
  assert(
    type(entries) == array,
    message: "`entries` must be an array of AI tool dicts, got "
      + repr(entries)
      + " of type "
      + str(type(entries)),
  )
  for (i, entry) in entries.enumerate() {
    assert(
      type(entry) == dictionary,
      message: "`entries` at index "
        + str(i)
        + " must be a dictionary, got "
        + repr(entry),
    )
    if "tool" not in entry {
      panic("`entries` at index " + str(i) + " is missing required key `tool`")
    }
    if "usage" not in entry {
      panic("`entries` at index " + str(i) + " is missing required key `usage`")
    }
  }
  return (
    front-back-matter: (
      ai-acknowledgement: config.util.get-dict-without-default((
        entries: entries,
        position: position,
        order: order,
        generator: generator-function,
      )),
    ),
  )
}


// ============================================================
//                    DHBW MANNHEIM
// ============================================================

/// Configure the AI declaration form section for DHBW Mannheim theses.
/// The section is rendered only when `authors` is non-empty. -> dictionary
#let configure-dhbw-ma-ai-declaration-form(
  /// Where the AI declaration form should be displayed. -> "frontmatter" | "backmatter"
  position: config.util.default-value,
  /// What order the AI declaration form should have. -> int
  order: config.util.default-value,
  /// Name of the module the AI declaration applies to. -> str | none
  module-name: config.util.default-value,
  /// Semester the module is offered in. -> str | none
  semester: config.util.default-value,
  /// Exam type: "Projektarbeit I", "Projektarbeit II", "Seminararbeit", "Bachelorarbeit". -> str | none
  exam-type: config.util.default-value,
  /// Submission date shown on the AI declaration form. -> str | none
  module-submission-date: config.util.default-value,
  /// Per-author AI declaration data, in the same order as the adapter's `authors`.
  /// Each entry must be a dictionary with keys `product-name`, `topic`,
  /// `topic-editing`, `research`, `design`. Empty array disables the section. -> array
  authors: (),
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the AI declaration form section `content` (or `none` to skip). -> function
  generator-function: config.util.default-value,
) = {
  config.validation.validate-position-order(position, order)
  config.validation.validate-generator(generator-function)
  assert(
    type(authors) == array,
    message: "`authors` must be an array of per-author AI declaration dicts, got "
      + repr(authors)
      + " of type "
      + str(type(authors)),
  )
  for (i, entry) in authors.enumerate() {
    assert(
      type(entry) == dictionary,
      message: "`authors` entry at index "
        + str(i)
        + " must be a dictionary, got "
        + repr(entry),
    )
    for key in (
      "product-name",
      "topic",
      "topic-editing",
      "research",
      "design",
    ) {
      if key not in entry {
        panic(
          "`authors` entry at index "
            + str(i)
            + " is missing required key `"
            + key
            + "`",
        )
      }
    }
  }
  return (
    front-back-matter: (
      ai-declaration-form: config.util.get-dict-without-default((
        module-name: module-name,
        semester: semester,
        exam-type: exam-type,
        module-submission-date: module-submission-date,
        authors: authors,
        position: position,
        order: order,
        generator: generator-function,
      )),
    ),
  )
}
