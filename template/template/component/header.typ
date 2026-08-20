#import "../config/lib.typ" as config
#import "@preview/hydra:0.6.3": hydra

/// Configures the header shown in the documents body. Low-level configuration function for providing a completly custom header. Use `configure-body-header-*` for predefined coversheets.
///
/// -> dictionary
#let configure-body-header(
  /// A function receiving a single position argument `config` holding the configuration dictionary and returing the header `content`.
  ///
  /// -> function.
  generator-function: config.util.default-value,
  /// Additional height added to the normal top-margin when displaying this header.
  ///
  /// -> relative
  height: config.util.default-value,
) = {
  config.validation.validate-generator(generator-function)
  config.validation.validate-relative(height, "height")
  return (
    body-header: config.util.get-dict-without-default((
      generator: generator-function,
      height: height,
    )),
  )
}

/// Configures a body header of style _spotless_.
///
/// -> dictionary
#let configure-body-header-spotless() = {
  return configure-body-header(
    generator-function: config => context {
      grid(
        columns: (auto, 1fr),
        align(left, text(config.metadata.title-short)),
        align(right, emph(hydra(1, display: (_, it) => {
          it.body
        }))),
      )
      line(length: 100%, stroke: (paint: gray))
    },
    height: 1cm,
  )
}
