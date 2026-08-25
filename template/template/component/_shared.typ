// LTeX: enabled=false
// Internal helpers shared across component config files.
// Do NOT import this file from outside the component/ directory.
#import "../config/lib.typ" as config

// ── Config-dict builder ───────────────────────────────────────────────────────

/// Build a `(component: ...)` config dict.
///
/// - scope: the section key (e.g. `"frontmatter"`) or `none` for top-level.
/// - key: `"header"` or `"footer"`.
/// - value: the inner dictionary (already stripped of defaults).
#let make-component-config(scope, key, value) = {
  if scope == none {
    return (component: ((key): value))
  } else {
    return (component: ((scope): ((key): value)))
  }
}

// ── Header factory ────────────────────────────────────────────────────────────

/// Return a header config function for the given scope (`none` = top-level).
#let make-header(scope) = {
  (
    generator-function: config.util.default-value,
    height: config.util.default-value,
    show-fun: config.util.default-value,
  ) => {
    config.validation.validate-generator(generator-function)
    config.validation.validate-relative(height, "height")
    config.validation.validate-show(show-fun)
    make-component-config(
      scope,
      "header",
      config.util.get-dict-without-default((
        generator: generator-function,
        height: height,
        show-rule: show-fun,
      )),
    )
  }
}

// ── TOC factory (appendix-specific) ─────────────────────────────────────────

/// Return a toc config function for the given scope.
#let make-toc(scope) = {
  (
    generator-function: config.util.default-value,
    show-fun: config.util.default-value,
  ) => {
    config.validation.validate-generator(generator-function)
    config.validation.validate-show(show-fun)
    make-component-config(
      scope,
      "toc",
      config.util.get-dict-without-default((
        generator: generator-function,
        show-rule: show-fun,
      )),
    )
  }
}

// ── Footer factory ────────────────────────────────────────────────────────────

/// Return a footer config function for the given scope (`none` = top-level).
#let make-footer(scope) = {
  (
    generator-function: config.util.default-value,
    height: config.util.default-value,
    show-fun: config.util.default-value,
  ) => {
    config.validation.validate-generator(generator-function)
    config.validation.validate-relative(height, "height")
    config.validation.validate-show(show-fun)
    make-component-config(
      scope,
      "footer",
      config.util.get-dict-without-default((
        generator: generator-function,
        height: height,
        show-rule: show-fun,
      )),
    )
  }
}
