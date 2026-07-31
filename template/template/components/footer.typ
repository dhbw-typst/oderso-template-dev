#import "../config.typ": __default, __get-dict-without-default, __validate-generator, __validate-relative


/// Configures the footer shown in the documents body. Low-level configuration function for providing a completly custom footer. Use `configure-body-footer-*` for predefined coversheets.
///
/// -> dictionary
#let configure-body-footer(
  /// A function receiving a single position argument `config` holding the configuration dictionary and returing the footer `content`.
  ///
  /// -> function.
  generator-function: __default,
  /// Additional height added to the normal bottom-margin when displaying this footer.
  ///
  /// -> relative
  height: __default,
) = {
  __validate-generator(generator-function)
  __validate-relative(height, "height")
  return (
    body-footer: __get-dict-without-default((
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
  numbering-show-total: __default
) = {
  assert(
    numbering-show-total == __default or type(numbering-show-total) == bool,
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
          ..counter(page).at(<__content-end>),
        )
      } else {
        numbering("1", counter(page).get().at(0))
      }
    }),
    height: 0cm,
  )
}
