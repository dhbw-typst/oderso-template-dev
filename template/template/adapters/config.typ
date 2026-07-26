#import "../config.typ": __default, __validate-enable, __validate-position-order, __get-dict-without-default

// ============================================================
//                    SHARED ADAPTERS
// ============================================================
// Configuration for front/back matter sections that every adapter
// (`dhbw-ka`, `dhbw-ma`, `ihk`) provides.

/// Configure the statutory declaration section (shared across all adapters). -> dictionary
#let configure-statutory-declaration(
  /// Whether the statutory declaration section is rendered. -> bool
  enable: __default,
  /// Where the statutory declaration should be displayed. -> "frontmatter" | "backmatter"
  position: __default,
  /// What order the statutory declaration should have. -> int
  order: __default,
  /// Whether the thesis is submitted digitally. Controls whether the signature
  /// line is pre-filled with the author's name/signature or left blank for
  /// handwritten signing. -> bool
  digital-submission: __default,
  /// Whether the thesis is submitted digitally only (no printed copy). Affects
  /// the wording of the DHBW statutory declaration. -> bool
  digital-only: __default,
  /// City shown on every signature line in this section. -> str
  signature-city: __default,
) = {
  __validate-enable(enable)
  __validate-position-order(position, order)
  assert(
    digital-submission == __default or type(digital-submission) == bool,
    message: "`digital-submission` must be a boolean, got "
      + repr(digital-submission)
      + " of type "
      + str(type(digital-submission)),
  )
  assert(
    digital-only == __default or type(digital-only) == bool,
    message: "`digital-only` must be a boolean, got "
      + repr(digital-only)
      + " of type "
      + str(type(digital-only)),
  )
  assert(
    signature-city == __default or type(signature-city) == str,
    message: "`signature-city` must be a string, got "
      + repr(signature-city)
      + " of type "
      + str(type(signature-city)),
  )
  return (
    front-back-matter: (
      statutory-declaration: __get-dict-without-default((
        enable: enable,
        digital-submission: digital-submission,
        digital-only: digital-only,
        signature-city: signature-city,
        position: position,
        order: order,
      )),
    ),
  )
}

/// Configure the confidentiality clause section (shared across all adapters). -> dictionary
#let configure-confidentiality-clause(
  /// Whether the confidentiality clause section is rendered. -> bool
  enable: __default,
  /// Where the confidentiality clause should be displayed. -> "frontmatter" | "backmatter"
  position: __default,
  /// What order the confidentiality clause should have. -> int
  order: __default,
) = {
  __validate-enable(enable)
  __validate-position-order(position, order)
  return (
    front-back-matter: (
      confidentiality-clause: __get-dict-without-default((
        enable: enable,
        position: position,
        order: order,
      )),
    ),
  )
}


// ============================================================
//                    DHBW KARLSRUHE
// ============================================================

/// Configure the AI acknowledgement section for DHBW Karlsruhe theses.
/// The section is rendered only when `entries` is non-empty. -> dictionary
#let configure-dhbw-ka-ai-acknowledgement(
  /// Where the AI acknowledgement should be displayed. -> "frontmatter" | "backmatter"
  position: __default,
  /// What order the AI acknowledgement should have. -> int
  order: __default,
  /// List of AI tool entries. Each entry must have `tool` (str) and `usage`
  /// (content). Empty array disables the section. -> array
  entries: (),
) = {
  __validate-position-order(position, order)
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
      message: "`entries` at index " + str(i) + " must be a dictionary, got " + repr(entry),
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
      ai-acknowledgement: __get-dict-without-default((
        entries: entries,
        position: position,
        order: order,
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
  position: __default,
  /// What order the AI declaration form should have. -> int
  order: __default,
  /// Name of the module the AI declaration applies to. -> str | none
  module-name: __default,
  /// Semester the module is offered in. -> str | none
  semester: __default,
  /// Exam type: "Projektarbeit I", "Projektarbeit II", "Seminararbeit", "Bachelorarbeit". -> str | none
  exam-type: __default,
  /// Submission date shown on the AI declaration form. -> str | none
  module-submission-date: __default,
  /// Per-author AI declaration data, in the same order as the adapter's `authors`.
  /// Each entry must be a dictionary with keys `product-name`, `topic`,
  /// `topic-editing`, `research`, `design`. Empty array disables the section. -> array
  authors: (),
) = {
  __validate-position-order(position, order)
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
      message: "`authors` entry at index " + str(i) + " must be a dictionary, got " + repr(entry),
    )
    for key in ("product-name", "topic", "topic-editing", "research", "design") {
      if key not in entry {
        panic(
          "`authors` entry at index " + str(i) + " is missing required key `" + key + "`",
        )
      }
    }
  }
  return (
    front-back-matter: (
      ai-declaration-form: __get-dict-without-default((
        module-name: module-name,
        semester: semester,
        exam-type: exam-type,
        module-submission-date: module-submission-date,
        authors: authors,
        position: position,
        order: order,
      )),
    ),
  )
}
