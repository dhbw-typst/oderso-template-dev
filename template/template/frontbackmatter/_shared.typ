#import "../config/lib.typ" as config
// Shared front-backmatter for mutliple institutions. Re-exported from institution front-backmatter module

/// Configure the statutory declaration section (shared across all adapters). -> dictionary
#let configure-statutory-declaration(
  /// Whether the statutory declaration section is rendered. -> bool
  enable: config.util.default-value,
  /// Where and when the statutory declaration should be displayed. Negative = frontmatter, zero or positive = backmatter. The value determines render order within its section. -> int
  position: config.util.default-value,
  /// Whether the thesis is submitted digitally. Controls whether the signature
  /// line is pre-filled with the author's name/signature or left blank for
  /// handwritten signing. -> bool
  digital-submission: config.util.default-value,
  /// Whether the thesis is submitted digitally only (no printed copy). Affects
  /// the wording of the DHBW statutory declaration. -> bool
  digital-only: config.util.default-value,
  /// City shown on every signature line in this section. -> str
  signature-city: config.util.default-value,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the statutory declaration section `content` (or `none` to skip). -> function
  generator-function: config.util.default-value,
) = {
  config.validation.validate-enable(enable)
  config.validation.validate-position(position)
  config.validation.validate-generator(generator-function)
  assert(
    digital-submission == config.util.default-value
      or type(digital-submission) == bool,
    message: "`digital-submission` must be a boolean, got "
      + repr(digital-submission)
      + " of type "
      + str(type(digital-submission)),
  )
  assert(
    digital-only == config.util.default-value or type(digital-only) == bool,
    message: "`digital-only` must be a boolean, got "
      + repr(digital-only)
      + " of type "
      + str(type(digital-only)),
  )
  assert(
    signature-city == config.util.default-value or type(signature-city) == str,
    message: "`signature-city` must be a string, got "
      + repr(signature-city)
      + " of type "
      + str(type(signature-city)),
  )
  return (
    front-back-matter: (
      statutory-declaration: config.util.get-dict-without-default((
        enable: enable,
        digital-submission: digital-submission,
        digital-only: digital-only,
        signature-city: signature-city,
        position: position,
        generator: generator-function,
      )),
    ),
  )
}

/// Configure the confidentiality clause section (shared across all adapters). -> dictionary
#let configure-confidentiality-clause(
  /// Whether the confidentiality clause section is rendered. -> bool
  enable: config.util.default-value,
  /// Where and when the confidentiality clause should be displayed. Negative = frontmatter, zero or positive = backmatter. The value determines render order within its section. -> int
  position: config.util.default-value,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the confidentiality clause section `content` (or `none` to skip). -> function
  generator-function: config.util.default-value,
) = {
  config.validation.validate-enable(enable)
  config.validation.validate-position(position)
  config.validation.validate-generator(generator-function)
  return (
    front-back-matter: (
      confidentiality-clause: config.util.get-dict-without-default((
        enable: enable,
        position: position,
        generator: generator-function,
      )),
    ),
  )
}
