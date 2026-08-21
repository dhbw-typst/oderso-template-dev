// LTeX: enabled=false
#import "../config/lib.typ" as config
/// Validate that a component generator is either the default sentinel,
/// `none` (to explicitly suppress), or a function.
#let _validate-component-generator(generator-function) = {
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

// ============================================================
// FLAT / SHARED HEADER & FOOTER
// ============================================================

/// Configure a shared default header shown in ALL document sections (frontmatter,
/// body, backmatter, appendix) unless overridden by a section-specific header.
///
/// Used as the fallback when a section does not have its own header configured.
/// -> dictionary
#let header(
  /// A function receiving a single positional argument `config` returning the
  /// header `content`. Pass `none` to suppress headers globally. -> function | none
  generator-function: config.util.default-value,
  /// Additional height added to the top margin for this header. -> relative
  height: config.util.default-value,
  /// Show rule function receiving content (`it`) applied after all base set/show rules. -> function | none
  show-fun: config.util.default-value,
) = {
  _validate-component-generator(generator-function)
  config.validation.validate-relative(height, "height")
  config.validation.validate-show(show-fun)
  return (
    component: (
      header: config.util.get-dict-without-default((
        generator: generator-function,
        height: height,
        show-rule: show-fun,
      )),
    ),
  )
}

/// Configure a shared default footer shown in ALL document sections unless
/// overridden by a section-specific footer.
/// -> dictionary
#let footer(
  /// A function receiving a single positional argument `config` returning the
  /// footer `content`. Pass `none` to suppress footers globally. -> function | none
  generator-function: config.util.default-value,
  /// Additional height added to the bottom margin for this footer. -> relative
  height: config.util.default-value,
  /// Show rule function receiving content (`it`) applied after all base set/show rules. -> function | none
  show-fun: config.util.default-value,
) = {
  _validate-component-generator(generator-function)
  config.validation.validate-relative(height, "height")
  config.validation.validate-show(show-fun)
  return (
    component: (
      footer: config.util.get-dict-without-default((
        generator: generator-function,
        height: height,
        show-rule: show-fun,
      )),
    ),
  )
}

// ============================================================
// SECTION-SPECIFIC OVERRIDES
// ============================================================

/// Configure the header for the frontmatter section only.
/// Overrides the shared `component.header` for frontmatter pages. -> dictionary
#let frontmatter-header(
  /// Generator function. -> function | none
  generator-function: config.util.default-value,
  /// Additional height. -> relative
  height: config.util.default-value,
  /// Show rule function receiving content (`it`) applied after all base set/show rules. -> function | none
  show-fun: config.util.default-value,
) = {
  _validate-component-generator(generator-function)
  config.validation.validate-relative(height, "height")
  config.validation.validate-show(show-fun)
  return (
    component: (
      frontmatter-header: config.util.get-dict-without-default((
        generator: generator-function,
        height: height,
        show-rule: show-fun,
      )),
    ),
  )
}

/// Configure the footer for the frontmatter section only. -> dictionary
#let frontmatter-footer(
  generator-function: config.util.default-value,
  height: config.util.default-value,
  /// Show rule function receiving content (`it`) applied after all base set/show rules. -> function | none
  show-fun: config.util.default-value,
) = {
  _validate-component-generator(generator-function)
  config.validation.validate-relative(height, "height")
  config.validation.validate-show(show-fun)
  return (
    component: (
      frontmatter-footer: config.util.get-dict-without-default((
        generator: generator-function,
        height: height,
        show-rule: show-fun,
      )),
    ),
  )
}

/// Configure the header for the body section only. -> dictionary
#let body-header(
  generator-function: config.util.default-value,
  height: config.util.default-value,
  /// Show rule function receiving content (`it`) applied after all base set/show rules. -> function | none
  show-fun: config.util.default-value,
) = {
  _validate-component-generator(generator-function)
  config.validation.validate-relative(height, "height")
  config.validation.validate-show(show-fun)
  return (
    component: (
      body-header: config.util.get-dict-without-default((
        generator: generator-function,
        height: height,
        show-rule: show-fun,
      )),
    ),
  )
}

/// Configure the footer for the body section only. -> dictionary
#let body-footer(
  generator-function: config.util.default-value,
  height: config.util.default-value,
  /// Show rule function receiving content (`it`) applied after all base set/show rules. -> function | none
  show-fun: config.util.default-value,
) = {
  _validate-component-generator(generator-function)
  config.validation.validate-relative(height, "height")
  config.validation.validate-show(show-fun)
  return (
    component: (
      body-footer: config.util.get-dict-without-default((
        generator: generator-function,
        height: height,
        show-rule: show-fun,
      )),
    ),
  )
}

/// Configure the header for the backmatter section only. -> dictionary
#let backmatter-header(
  generator-function: config.util.default-value,
  height: config.util.default-value,
  /// Show rule function receiving content (`it`) applied after all base set/show rules. -> function | none
  show-fun: config.util.default-value,
) = {
  _validate-component-generator(generator-function)
  config.validation.validate-relative(height, "height")
  config.validation.validate-show(show-fun)
  return (
    component: (
      backmatter-header: config.util.get-dict-without-default((
        generator: generator-function,
        height: height,
        show-rule: show-fun,
      )),
    ),
  )
}

/// Configure the footer for the backmatter section only. -> dictionary
#let backmatter-footer(
  generator-function: config.util.default-value,
  height: config.util.default-value,
  /// Show rule function receiving content (`it`) applied after all base set/show rules. -> function | none
  show-fun: config.util.default-value,
) = {
  _validate-component-generator(generator-function)
  config.validation.validate-relative(height, "height")
  config.validation.validate-show(show-fun)
  return (
    component: (
      backmatter-footer: config.util.get-dict-without-default((
        generator: generator-function,
        height: height,
        show-rule: show-fun,
      )),
    ),
  )
}

/// Configure the appendix table of contents entry. -> dictionary
#let appendix-toc(
  /// Generator function for the appendix TOC. -> function | none
  generator-function: config.util.default-value,
  /// Show rule function receiving content (`it`) applied after all base set/show rules. -> function | none
  show-fun: config.util.default-value,
) = {
  _validate-component-generator(generator-function)
  config.validation.validate-show(show-fun)
  return (
    component: (
      appendix-toc: config.util.get-dict-without-default((
        generator: generator-function,
        show-rule: show-fun,
      )),
    ),
  )
}

/// Configure the header for the appendix section only. -> dictionary
#let appendix-header(
  generator-function: config.util.default-value,
  height: config.util.default-value,
  /// Show rule function receiving content (`it`) applied after all base set/show rules. -> function | none
  show-fun: config.util.default-value,
) = {
  _validate-component-generator(generator-function)
  config.validation.validate-relative(height, "height")
  config.validation.validate-show(show-fun)
  return (
    component: (
      appendix-header: config.util.get-dict-without-default((
        generator: generator-function,
        height: height,
        show-rule: show-fun,
      )),
    ),
  )
}

/// Configure the footer for the appendix section only. -> dictionary
#let appendix-footer(
  generator-function: config.util.default-value,
  height: config.util.default-value,
  /// Show rule function receiving content (`it`) applied after all base set/show rules. -> function | none
  show-fun: config.util.default-value,
) = {
  _validate-component-generator(generator-function)
  config.validation.validate-relative(height, "height")
  config.validation.validate-show(show-fun)
  return (
    component: (
      appendix-footer: config.util.get-dict-without-default((
        generator: generator-function,
        height: height,
        show-rule: show-fun,
      )),
    ),
  )
}
