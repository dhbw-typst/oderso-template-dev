// LTeX: enabled=false
// DHBW Karlsruhe-specific frontbackmatter configuration functions.
// Accessible as frontbackmatter.dhbw-ka.* from lib.typ.

#import "../../frontbackmatter/lib.typ": *

#import "../../frontbackmatter/_shared.typ": (
  configure-confidentiality-clause, configure-statutory-declaration,
)
#import "../../config/lib.typ" as config

/// Configure the statutory declaration section for DHBW Karlsruhe. -> dictionary
#let statutory-declaration = configure-statutory-declaration

/// Configure the confidentiality clause section for DHBW Karlsruhe. -> dictionary
#let confidentiality-clause = configure-confidentiality-clause

/// Configure the AI acknowledgement section for DHBW Karlsruhe theses.
/// The section is rendered only when `entries` is non-empty. -> dictionary
#let ai-declaration(
  /// Disable the section while preserving its entries and generator. -> bool
  enable: config.util.default-value,
  /// Where and when the AI acknowledgement should be displayed. Negative = frontmatter, zero or positive = backmatter. The value determines render order within its section. -> int
  position: config.util.default-value,
  /// List of AI tool entries. Each entry must have `tool` (str) and `usage`
  /// (content). Empty array disables the section. -> array
  entries: config.util.default-value,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the AI acknowledgement section `content` (or `none` to skip). -> function
  generator-function: config.util.default-value,
) = {
  config.validation.validate-enable(enable)
  config.validation.validate-position(position)
  config.validation.validate-generator(generator-function)
  assert(
    entries == config.util.default-value or type(entries) == array,
    message: "`entries` must be an array of AI tool dicts, got "
      + repr(entries)
      + " of type "
      + str(type(entries)),
  )
  for (i, entry) in (
    if entries == config.util.default-value { () } else { entries }
  ).enumerate() {
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
        enable: enable,
        entries: entries,
        position: position,
        generator: generator-function,
      )),
    ),
  )
}
