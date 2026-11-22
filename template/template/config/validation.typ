
#import "util.typ": default-value

/// Asserts that `position` is either the default sentinel or an integer.
/// Negative values place the component in the frontmatter; zero and positive
/// values place it in the backmatter. Signed positions sort in ascending order.
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

/// Generators inherit when omitted, clear when none, and otherwise must be functions.
#let validate-generator(generator-function) = {
  assert(
    generator-function == default-value
      or generator-function == none
      or type(generator-function) == function,
    message: "`generator-function` must be a function or `none`, got "
      + repr(generator-function)
      + " of type "
      + str(type(generator-function)),
  )
}

/// Numbering follows Typst's page/heading API: string, function, or none.
#let validate-numbering(value) = {
  assert(
    value == default-value or value == none or type(value) in (str, function),
    message: "`numbering` must be a string, function, or none, got "
      + repr(value),
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

#let validate-typography(value) = {
  assert(type(value) == dictionary, message: "Typography must be a dictionary")
  if "font" in value {
    assert(
      type(value.font) == str
        or (type(value.font) == array and value.font.all(f => type(f) == str)),
      message: "`font` must be a string or array of strings",
    )
  }
  for key in ("size", "leading", "spacing") {
    if key in value { validate-relative(value.at(key), key) }
  }
  if "sizes" in value {
    assert(
      type(value.sizes) == array,
      message: "Heading `sizes` must be an array",
    )
    for size in value.sizes { validate-relative(size, "sizes entry") }
  }
  if "numbering" in value { validate-numbering(value.numbering) }
}
