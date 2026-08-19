// Shared front-backmatter for mutliple institutions. Re-exported from institution front-backmatter module

/// Configure the statutory declaration section (shared across all adapters). -> dictionary
#let configure-statutory-declaration(
  /// Whether the statutory declaration section is rendered. -> bool
  enable: default-value,
  /// Where the statutory declaration should be displayed. -> "frontmatter" | "backmatter"
  position: default-value,
  /// What order the statutory declaration should have. -> int
  order: default-value,
  /// Whether the thesis is submitted digitally. Controls whether the signature
  /// line is pre-filled with the author's name/signature or left blank for
  /// handwritten signing. -> bool
  digital-submission: default-value,
  /// Whether the thesis is submitted digitally only (no printed copy). Affects
  /// the wording of the DHBW statutory declaration. -> bool
  digital-only: default-value,
  /// City shown on every signature line in this section. -> str
  signature-city: default-value,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the statutory declaration section `content` (or `none` to skip). -> function
  generator-function: default-value,
) = {
  validate-enable(enable)
  validate-position-order(position, order)
  validate-generator(generator-function)
  assert(
    digital-submission == default-value or type(digital-submission) == bool,
    message: "`digital-submission` must be a boolean, got "
      + repr(digital-submission)
      + " of type "
      + str(type(digital-submission)),
  )
  assert(
    digital-only == default-value or type(digital-only) == bool,
    message: "`digital-only` must be a boolean, got "
      + repr(digital-only)
      + " of type "
      + str(type(digital-only)),
  )
  assert(
    signature-city == default-value or type(signature-city) == str,
    message: "`signature-city` must be a string, got "
      + repr(signature-city)
      + " of type "
      + str(type(signature-city)),
  )
  return (
    front-back-matter: (
      statutory-declaration: get-dict-without-default((
        enable: enable,
        digital-submission: digital-submission,
        digital-only: digital-only,
        signature-city: signature-city,
        position: position,
        order: order,
        generator: generator-function,
      )),
    ),
  )
}

/// Configure the confidentiality clause section (shared across all adapters). -> dictionary
#let configure-confidentiality-clause(
  /// Whether the confidentiality clause section is rendered. -> bool
  enable: default-value,
  /// Where the confidentiality clause should be displayed. -> "frontmatter" | "backmatter"
  position: default-value,
  /// What order the confidentiality clause should have. -> int
  order: default-value,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the confidentiality clause section `content` (or `none` to skip). -> function
  generator-function: default-value,
) = {
  validate-enable(enable)
  validate-position-order(position, order)
  validate-generator(generator-function)
  return (
    front-back-matter: (
      confidentiality-clause: get-dict-without-default((
        enable: enable,
        position: position,
        order: order,
        generator: generator-function,
      )),
    ),
  )
}