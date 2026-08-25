
#import "util.typ": default-value

/// Asserts that `position` is either the default sentinel or an integer.
/// Negative values place the component in the frontmatter; zero and positive
/// values place it in the backmatter. The absolute value determines render order.
#let validate-position(position) = {
  assert(
    position == default-value or type(position) == int,
    message: "`position` must be an integer (negative = frontmatter, ≥0 = backmatter), got: "
      + repr(position),
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


  assert(
    generator-function == default-value or type(generator-function) == function,
    message: "`generator-function` must be a function, got "
      + repr(generator-function)
      + " of type "
      + str(type(generator-function)),
  )
}

/// Asserts that `show-fun` is either the default sentinel, `none`, or a function.
/// The function receives content (`it`) and returns content.
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

#let validate-show(show-fun) = {
  assert(
    show-fun == default-value or show-fun == none or type(show-fun) == function,
    message: "`show` must be a function (content -> content) or `none`, got "
      + repr(show-fun)
      + " of type "
      + str(type(show-fun)),
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
