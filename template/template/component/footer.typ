#import "../config/lib.typ" as config


/// Configures the footer shown in the documents body. Low-level configuration function for providing a completly custom footer. Use `configure-body-footer-*` for predefined footers.
///
/// -> dictionary
#let configure-body-footer(
  /// A function receiving a single position argument `config` holding the configuration dictionary and returing the footer `content`.
  ///
  /// -> function.
  generator-function: config.util.default-value,
  /// Additional height added to the normal bottom-margin when displaying this footer.
  ///
  /// -> relative
  height: config.util.default-value,
) = {
  config.validation.validate-generator(generator-function)
  config.validation.validate-relative(height, "height")
  return (
    body-footer: config.util.get-dict-without-default((
      generator: generator-function,
      height: height,
    )),
  )
}

/// Configures a body footer of style _spotless_.
///
/// -> dictionary
#let configure-body-footer-spotless(
  /// Whether the numebring style should be "1 / 1" or "1". -> bool
  numbering-show-total: config.util.default-value,
) = {
  assert(
    numbering-show-total == config.util.default-value
      or type(numbering-show-total) == bool,
    message: "`numbering-show-total` must be a boolean, got "
      + repr(numbering-show-total)
      + " of type "
      + str(type(numbering-show-total)),
  )
  return configure-body-footer(
    generator-function: config => context align(center, {
      if numbering-show-total {
        numbering(
          "1 / 1",
          counter(page).get().at(0),
          ..counter(page).at(<_content-end>),
        )
      } else {
        numbering("1", counter(page).get().at(0))
      }
    }),
    height: 0cm,
  )
}

/// Configures the footer shown in the front- and back-matter body. Low-level configuration function for providing a completly custom footer. Use `configure-body-footer-*` for predefined coversheets.
///
/// -> dictionary
#let configure-front-back-matter-footer(
  /// A function receiving a single position argument `config` holding the configuration dictionary and returing the footer `content`.
  ///
  /// -> function.
  generator-function: config.util.default-value,
  /// Additional height added to the normal bottom-margin when displaying this footer.
  ///
  /// -> relative
  height: config.util.default-value,
) = {
  config.validation.validate-generator(generator-function)
  config.validation.validate-relative(height, "height")
  return (
    body-footer: config.util.get-dict-without-default((
      generator: generator-function,
      height: height,
    )),
  )
}

/// Configures a body footer of style _spotless_.
///
/// -> dictionary
#let configure-front-back-matter-footer-spotless(
  /// Whether the numebring style should be "1 / 1" or "1". -> bool
  numbering-show-total: config.util.default-value,
) = {
  assert(
    numbering-show-total == config.util.default-value
      or type(numbering-show-total) == bool,
    message: "`numbering-show-total` must be a boolean, got "
      + repr(numbering-show-total)
      + " of type "
      + str(type(numbering-show-total)),
  )
  return configure-body-footer(
    generator-function: config => context align(center, {
      if numbering-show-total {
        numbering(
          "1 / 1",
          counter(page).get().at(0),
          ..counter(page).at(<_content-end>),
        )
      } else {
        numbering("1", counter(page).get().at(0))
      }
    }),
    height: 0cm,
  )
}
