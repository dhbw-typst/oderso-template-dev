
#import "util.typ": default-value

/// Asserts that `position` is either the default sentinel or one of "frontmatter" / "backmatter",
/// and that `order` is either the default sentinel or an integer.
#let validate-position-order(position, order) = {
  assert(
    position == default-value
      or position == "frontmatter"
      or position == "backmatter",
    message: "`position` must be either \"frontmatter\" or \"backmatter\", got: "
      + repr(position),
  )
  assert(
    order == default-value or type(order) == int,
    message: "`order` must be an integer, got "
      + repr(order)
      + " of type "
      + str(type(order)),
  )
}

/// Asserts that `enable` is either the default sentinel or a boolean.
#let validate-enable(enable) = {
  assert(
    enable == default-value or type(enable) == bool,
    message: "`enable` must be a boolean, got "
      + repr(enable)
      + " of type "
      + str(type(enable)),
  )
}

/// Asserts that `generator-function` is either the default sentinel or a function.
#let validate-generator(generator-function) = {
  assert(
    generator-function == default-value or type(generator-function) == function,
    message: "`generator-function` must be a function, got "
      + repr(generator-function)
      + " of type "
      + str(type(generator-function)),
  )
}

#let validate-relative(rel, var-name) = {
  assert(
    rel == default-value
      or type(rel) == relative
      or type(rel) == length
      or type(rel) == ratio,
    message: "`"
      + var-name
      + "` must be a relative value, got "
      + repr(rel)
      + " of type "
      + str(type(rel)),
  )
}
