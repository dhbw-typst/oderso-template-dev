// LTeX: enabled=false
// DHBW Mannheim-specific frontbackmatter configuration functions.
// Accessible as institution.dhbw-ma.frontbackmatter.* from lib.typ.
#import "../../config/lib.typ" as config
#import "../../frontbackmatter/_rules.typ": _local-rules

/// Configure the AI declaration form section for DHBW Mannheim theses.
/// The section is rendered only when `authors` is non-empty. -> dictionary
#let ai-declaration-form(
  /// Disable the section while preserving its data and generator. -> bool
  enable: config.util.default-value,
  /// Where and when the AI declaration form should be displayed. Negative = frontmatter, zero or positive = backmatter. The value determines render order within its section. -> int
  position: config.util.default-value,
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
  authors: config.util.default-value,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the AI declaration form section `content` (or `none` to skip). -> function
  generator-function: config.util.default-value,
  /// Named local hooks: show-key, show-order, show-fun, show-enable. -> arguments
  ..rules,
) = {
  config.validation.validate-enable(enable)
  config.validation.validate-position(position)
  config.validation.validate-generator(generator-function)
  assert(
    authors == config.util.default-value or type(authors) == array,
    message: "`authors` must be an array of per-author AI declaration dicts, got "
      + repr(authors)
      + " of type "
      + str(type(authors)),
  )
  for (i, entry) in (
    if authors == config.util.default-value { () } else { authors }
  ).enumerate() {
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
        enable: enable,
        module-name: module-name,
        semester: semester,
        exam-type: exam-type,
        module-submission-date: module-submission-date,
        authors: authors,
        position: position,
        generator: generator-function,
      ))
        + _local-rules(..rules),
    ),
  )
}
