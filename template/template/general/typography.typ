// LTeX: enabled=false
#import "../config/lib.typ" as config: default-value, get-dict-without-default

// ============================================================
// Default font parameters for New Computer Modern
// These match the current hard-coded values in base.typ and
// can be overridden by theme functions.
// ============================================================

/// Default body font parameters.
#let _default-body-font = (
  font: "New Computer Modern",
  size: 12pt,
  leading: 1.05em,
  spacing: 1.5em,
)

/// Default header font parameters.
/// `size` refers to the level-1 heading size; sub-headings scale relative to it.
#let _default-header-font = (
  font: "New Computer Modern",
  size: 1em, // relative to body, level 1 heading
)

/// Default caption font parameters.
#let _default-caption-font = (
  font: "New Computer Modern",
  size: 1em,
)

/// Default code font parameters (monospace).
/// Uses New Computer Modern in its monospace variant (the same family, raw elements use monospace style automatically).
#let _default-code-font = (
  font: "New Computer Modern",
  size: 0.9em,
)

/// Default math font parameters.
#let _default-math-font = (
  font: "New Computer Modern Math",
  size: 1em,
)

// ============================================================
// Public config functions
// ============================================================

/// Configure body text typography.
///
/// All fields are optional; unset fields fall back to theme/base defaults.
/// -> dictionary
#let body(
  /// Font family name or list of fallbacks. -> str | array | default-value
  font: default-value,
  /// Base font size. -> length | default-value
  size: default-value,
  /// Line leading (distance between baselines). -> relative | default-value
  leading: default-value,
  /// Paragraph spacing (vertical space between paragraphs). -> relative | default-value
  spacing: default-value,
) = {
  return (
    typography: (
      body: get-dict-without-default((
        font: font,
        size: size,
        leading: leading,
        spacing: spacing,
      )),
    ),
  )
}

/// Configure heading typography.
///
/// `size` sets the level-1 heading size; deeper levels scale relative to it.
/// -> dictionary
#let headers(
  /// Font family name or list of fallbacks. -> str | array | default-value
  font: default-value,
  /// Level-1 heading size (deeper levels scale proportionally). -> relative | default-value
  size: default-value,
  /// Scaling factor applied per heading level (e.g. 90% means each deeper level
  /// is 90 % of the previous). -> ratio | default-value
  level-scaling: default-value,
) = {
  return (
    typography: (
      headers: get-dict-without-default((
        font: font,
        size: size,
        level-scaling: level-scaling,
      )),
    ),
  )
}

/// Configure figure caption typography.
/// -> dictionary
#let captions(
  /// Font family name or list of fallbacks. -> str | array | default-value
  font: default-value,
  /// Caption font size relative to body. -> relative | default-value
  size: default-value,
) = {
  return (
    typography: (
      captions: get-dict-without-default((
        font: font,
        size: size,
      )),
    ),
  )
}

/// Configure inline and block code typography.
/// -> dictionary
#let code(
  /// Monospace font family name or list of fallbacks. -> str | array | default-value
  font: default-value,
  /// Code font size relative to body. -> relative | default-value
  size: default-value,
) = {
  return (
    typography: (
      code: get-dict-without-default((
        font: font,
        size: size,
      )),
    ),
  )
}

/// Configure math typography.
/// -> dictionary
#let math(
  /// Math font family name. -> str | array | default-value
  font: default-value,
  /// Math font size relative to body. -> relative | default-value
  size: default-value,
) = {
  return (
    typography: (
      math: get-dict-without-default((
        font: font,
        size: size,
      )),
    ),
  )
}
