// LTeX: enabled=false
// Internal helpers shared across component config files.
// Do NOT import this file from outside the component/ directory.
#import "../config/lib.typ" as config

// ── Margin helpers (private) ─────────────────────────────────────────────────

#let _validate-margin(margin) = {
  if margin == auto {
    panic(
      "`auto` is not allowed for `margin` in this template to simplify subsequent calculations. Please choose a different type.",
    )
  }
  assert(
    margin == config.util.default-value
      or type(margin) == dictionary
      or type(margin) == relative
      or type(margin) == length
      or type(margin) == ratio,
    message: "`margin` must be a length, a ratio, a relative length, or a dictionary, got "
      + repr(margin)
      + " of type "
      + str(type(margin)),
  )
}

#let _normalize-margin(margin) = {
  if type(margin) == dictionary {
    let cp = margin
    let rest = margin.at("rest", default: 0pt)
    cp.top = if "top" in margin {
      margin.top
    } else if "y" in margin {
      margin.y
    } else {
      rest
    }
    cp.bottom = if "bottom" in margin {
      margin.bottom
    } else if "y" in margin {
      margin.y
    } else {
      rest
    }
    if "inside" in margin.keys() or "outside" in margin.keys() {
      cp.inside = if "inside" in margin {
        margin.inside
      } else if "x" in margin {
        margin.x
      } else {
        rest
      }
      cp.outside = if "outside" in margin {
        margin.outside
      } else if "x" in margin {
        margin.x
      } else {
        rest
      }
    } else {
      cp.left = if "left" in margin {
        margin.left
      } else if "x" in margin {
        margin.x
      } else {
        rest
      }
      cp.right = if "right" in margin {
        margin.right
      } else if "x" in margin {
        margin.x
      } else {
        rest
      }
    }
    return cp
  } else {
    return (top: margin, bottom: margin, left: margin, right: margin)
  }
}

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

// ── Page factory ─────────────────────────────────────────────────────────────

/// Return a page config function for the given scope (`none` = top-level).
/// Configures the page numbering and/or margin for the given section.
#let make-page(scope) = {
  (
    numbering: config.util.default-value,
    margin: config.util.default-value,
  ) => {
    _validate-margin(margin)
    if margin != config.util.default-value {
      margin = _normalize-margin(margin)
    }
    make-component-config(
      scope,
      "page",
      config.util.get-dict-without-default((
        numbering: numbering,
        margin: margin,
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
