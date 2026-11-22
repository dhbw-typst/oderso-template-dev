// LTeX: enabled=false
// Private component producer helpers; public functions live in their scopes.
#import "../config/lib.typ" as config

#let _validate-margin(margin) = {
  if margin == config.util.default-value { return }
  assert(
    margin != auto,
    message: "`auto` is not allowed for `margin`; choose explicit lengths for margin arithmetic.",
  )
  if type(margin) == dictionary {
    assert(
      not (
        ("left" in margin or "right" in margin)
          and ("inside" in margin or "outside" in margin)
      ),
      message: "A margin patch cannot mix left/right with inside/outside",
    )
    for (key, value) in margin {
      assert(
        key
          in (
            "rest",
            "x",
            "y",
            "top",
            "bottom",
            "left",
            "right",
            "inside",
            "outside",
          ),
        message: "Unknown margin side: " + key,
      )
      assert(value != auto, message: "`auto` is not allowed for margin sides")
      assert(
        value != config.util.default-value,
        message: "Omit unspecified margin sides instead of storing a sentinel",
      )
      config.validation.validate-relative(value, "margin." + key)
    }
  } else { config.validation.validate-relative(margin, "margin") }
}

// Expand only explicitly provided shorthand. Precedence: side > x/y > rest.
// Missing sides remain missing until the final section resolution.
#let _normalize-margin(margin) = {
  _validate-margin(margin)
  if type(margin) != dictionary {
    return (top: margin, bottom: margin, left: margin, right: margin)
  }
  let result = (:)
  let horizontal = if "inside" in margin or "outside" in margin {
    ("inside", "outside")
  } else { ("left", "right") }
  for side in ("top", "bottom") + horizontal {
    let axis = if side in ("top", "bottom") { "y" } else { "x" }
    if side in margin { result.insert(side, margin.at(side)) } else if (
      axis in margin
    ) { result.insert(side, margin.at(axis)) } else if "rest" in margin {
      result.insert(side, margin.rest)
    }
  }
  result
}

/// Build a keyed patch. Omitted fields inherit, `show-fun: none` clears the
/// callback, and `show-enable: false` disables it without clearing it.
#let _make-show-rule-entry(
  key,
  show-fun,
  order: config.util.default-value,
  enable: config.util.default-value,
) = {
  assert(type(key) == str, message: "`show-key` must be a string")
  assert(
    order == config.util.default-value or type(order) in (int, float),
    message: "`show-order` must be a number",
  )
  config.validation.validate-show(show-fun)
  config.validation.validate-enable(enable)
  (
    (key): config.util.get-dict-without-default((
      function: show-fun,
      order: order,
      enable: enable,
    )),
  )
}

#let _build-show-rules-entry(
  show-key,
  show-order,
  show-fun,
  show-enable: config.util.default-value,
) = {
  if show-key == config.util.default-value {
    assert(
      show-order == config.util.default-value
        and show-fun == config.util.default-value
        and show-enable == config.util.default-value,
      message: "Provide `show-key` when patching a show rule",
    )
    return (:)
  }
  _make-show-rule-entry(
    show-key,
    show-fun,
    order: show-order,
    enable: show-enable,
  )
}

#let make-component-config(scope, key, value) = {
  (
    component: if scope == none { ((key): value) } else {
      ((scope): ((key): value))
    },
  )
}

/// Produce header patches. Generators keep `(cfg, last-page)`; effective local
/// settings are available as `cfg.resolved-section.header`.
#let make-header(scope) = {
  (
    /// Disable an inherited header without replacing its generator. -> bool
    enable: config.util.default-value,
    /// Generator `(cfg, last-page) -> content`; none clears it. -> function | none
    generator-function: config.util.default-value,
    /// Additional space reserved above the body. -> relative
    height: config.util.default-value,
    /// Key of a local show rule to add or patch. -> str
    show-key: config.util.default-value,
    /// Ascending callback order; ties use key insertion order. -> int | float
    show-order: config.util.default-value,
    /// Local content wrapper; none clears an inherited callback. -> function | none
    show-fun: config.util.default-value,
    /// Disable or re-enable the keyed local rule. -> bool
    show-enable: config.util.default-value,
  ) => {
    config.validation.validate-enable(enable)
    config.validation.validate-generator(generator-function)
    config.validation.validate-relative(height, "height")
    let rules = _build-show-rules-entry(
      show-key,
      show-order,
      show-fun,
      show-enable: show-enable,
    )
    make-component-config(
      scope,
      "header",
      config.util.get-dict-without-default((
        enable: enable,
        generator: generator-function,
        height: height,
      ))
        + (show-rules: rules),
    )
  }
}

/// Produce appendix TOC patches. Omission inherits the preset; none clears its
/// generator (no automatic fallback after explicit suppression).
#let make-toc(scope) = {
  (
    /// Whether to render the TOC. -> bool
    enable: config.util.default-value,
    /// Generator `(cfg) -> content`; none suppresses the TOC. -> function | none
    generator-function: config.util.default-value,
    /// Key of the local rule to add or patch. -> str
    show-key: config.util.default-value,
    /// Ascending callback order. -> int | float
    show-order: config.util.default-value,
    /// Local wrapper, or none to clear it. -> function | none
    show-fun: config.util.default-value,
    /// Whether the keyed rule is enabled. -> bool
    show-enable: config.util.default-value,
  ) => {
    config.validation.validate-enable(enable)
    config.validation.validate-generator(generator-function)
    let rules = _build-show-rules-entry(
      show-key,
      show-order,
      show-fun,
      show-enable: show-enable,
    )
    make-component-config(
      scope,
      "toc",
      config.util.get-dict-without-default((
        enable: enable,
        generator: generator-function,
      ))
        + (show-rules: rules),
    )
  }
}

/// Produce page patches. Shorthand expands only supplied sides. Switching
/// horizontal modes maps inherited left/right to inside/outside, respectively.
#let make-page(scope) = {
  (
    /// Typst numbering pattern, `(current, total)` page callback, or none. -> str | function | none
    numbering: config.util.default-value,
    /// Margin patch: explicit side > x/y > rest. Auto is unsupported. -> relative | dictionary
    margin: config.util.default-value,
  ) => {
    config.validation.validate-numbering(numbering)
    if margin != config.util.default-value {
      margin = _normalize-margin(margin)
    }
    make-component-config(scope, "page", config.util.get-dict-without-default((
      numbering: numbering,
      margin: margin,
    )))
  }
}

/// Produce footer patches. Local effective settings are available as
/// `cfg.resolved-section.footer`; numbering is in `cfg.resolved-section.page`.
#let make-footer(scope) = {
  (
    /// Disable an inherited footer without clearing its generator. -> bool
    enable: config.util.default-value,
    /// Generator `(cfg, last-page) -> content`; none clears it. -> function | none
    generator-function: config.util.default-value,
    /// Additional space reserved below the body. -> relative
    height: config.util.default-value,
    /// Whether a supporting generator displays total section pages. -> bool
    show-total-pages: config.util.default-value,
    /// Key of the local rule to add or patch. -> str
    show-key: config.util.default-value,
    /// Ascending callback order. -> int | float
    show-order: config.util.default-value,
    /// Local wrapper, or none to clear it. -> function | none
    show-fun: config.util.default-value,
    /// Whether the keyed rule is enabled. -> bool
    show-enable: config.util.default-value,
  ) => {
    config.validation.validate-enable(enable)
    config.validation.validate-enable(show-total-pages)
    config.validation.validate-generator(generator-function)
    config.validation.validate-relative(height, "height")
    let rules = _build-show-rules-entry(
      show-key,
      show-order,
      show-fun,
      show-enable: show-enable,
    )
    make-component-config(
      scope,
      "footer",
      config.util.get-dict-without-default((
        enable: enable,
        generator: generator-function,
        height: height,
        show-total-pages: show-total-pages,
      ))
        + (show-rules: rules),
    )
  }
}

/// Produce section-local show-rule patches with the same field-wise semantics
/// as document-level rules.
#let make-show-rules(scope) = {
  (
    /// Key to add, replace, or patch. -> str
    show-key: config.util.default-value,
    /// Ascending callback order; omitted order inherits. -> int | float
    show-order: config.util.default-value,
    /// Content wrapper; omission inherits, none clears it. -> function | none
    show-fun: config.util.default-value,
    /// Disable an inherited rule without losing its callback. -> bool
    show-enable: config.util.default-value,
  ) => {
    let rules = _build-show-rules-entry(
      show-key,
      show-order,
      show-fun,
      show-enable: show-enable,
    )
    make-component-config(
      none,
      if scope == none { "show-rules" } else { scope },
      if scope == none { rules } else { (show-rules: rules) },
    )
  }
}
