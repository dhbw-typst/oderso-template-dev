#import "../config/lib.typ" as config
#import "../util.typ": config.util.linguify-content

/// Component-local validator: accepts config.util.default-value, none (suppress), or function.
#let _validate-coversheet-generator(generator-function) = {
  assert(
    generator-function == config.util.default-value
      or generator-function == none
      or type(generator-function) == function,
    message: "`generator-function` must be a function or `none`, got "
      + repr(generator-function)
      + " of type "
      + str(type(generator-function)),
  )
}

/// Configure the coversheet. Low-level configuration function for providing a completly custom coversheet. Use theme functions for predefined coversheets. -> dictionary
#let coversheet(
  /// A function receiving a single position argument `config` holding the configuration dictionary and returing the conversheet `content`. Pass `none` to suppress the coversheet. -> function | none
  generator-function: config.util.default-value,
) = {
  _validate-coversheet-generator(generator-function)

  return (
    component: (
      coversheet: config.util.get-dict-without-default((
        generator: generator-function,
      )),
    ),
  )
}
