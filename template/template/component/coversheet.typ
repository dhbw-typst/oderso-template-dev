#import "../config/lib.typ" as config
#import "_shared.typ": _build-show-rules-entry, _make-show-rule-entry

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
  /// Unique key for this show rule entry. Co-required with `show-fun`. -> str
  show-key: config.util.default-value,
  /// Execution order for this show rule (lower = earlier). Optional. -> int
  show-order: config.util.default-value,
  /// Show rule function receiving content (`it`) applied after all base set/show rules. Co-required with `show-key`. -> function | none
  show-fun: config.util.default-value,
) = {
  _validate-coversheet-generator(generator-function)
  config.validation.validate-show(show-fun)

  let show-rules-entry = _build-show-rules-entry(show-key, show-order, show-fun)

  return (
    component: (
      coversheet: config.util.get-dict-without-default((
        generator: generator-function,
      ))
        + if show-rules-entry.len() > 0 {
          (show-rules: show-rules-entry)
        } else { (:) },
    ),
  )
}
