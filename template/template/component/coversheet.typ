#import "../config-utils.typ": (
  default-value, get-dict-without-default, validate-generator,
)
#import "../util.typ": _linguify-content

/// Configure the coversheet. Low-level configuration function for providing a completly custom coversheet. Use `configure-coversheet-*` for predefined coversheets. -> dictionary
#let coversheet(
  /// A function receiving a single position argument `config` holding the configuration dictionary and returing the conversheet `content` -> function.
  generator-function: default-value,
) = {
  validate-generator(generator-function)

  return (
    coversheet: get-dict-without-default((
      generator: generator-function,
    )),
  )
}

