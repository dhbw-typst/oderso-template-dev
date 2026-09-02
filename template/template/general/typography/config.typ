// LTeX: enabled=false
#import "../../config/lib.typ" as config

/// Configure body text typography.
///
/// All fields are optional; unset fields fall back to theme/base defaults.
/// -> dictionary
#let body(
  /// Font family name or list of fallbacks. -> str | array | config.util.default-value
  font: config.util.default-value,
  /// Base font size. -> length | config.util.default-value
  size: config.util.default-value,
  /// Line leading (distance between baselines). -> relative | config.util.default-value
  leading: config.util.default-value,
  /// Paragraph spacing (vertical space between paragraphs). -> relative | config.util.default-value
  spacing: config.util.default-value,
) = {
  return (
    general: (
      typography: (
        body: config.util.get-dict-without-default((
          font: font,
          size: size,
          leading: leading,
          spacing: spacing,
        )),
      ),
    ),
  )
}

/// Configure heading typography.
///
/// `size` sets the level-1 heading size; deeper levels scale relative to it.
/// -> dictionary
#let heading(
  /// Font family name or list of fallbacks. -> str | array | config.util.default-value
  font: config.util.default-value,
  /// Level-1 heading size (deeper levels scale proportionally). -> relative | config.util.default-value
  sizes: config.util.default-value,
  numbering: config.util.default-value,
) = {
  return (
    general: (
      typography: (
        heading: config.util.get-dict-without-default((
          font: font,
          sizes: sizes,
          numbering: numbering,
        )),
      ),
    ),
  )
}

/// Configure figure caption typography.
/// -> dictionary
#let caption(
  /// Font family name or list of fallbacks. -> str | array | config.util.default-value
  font: config.util.default-value,
  /// Caption font size relative to body. -> relative | config.util.default-value
  size: config.util.default-value,
) = {
  return (
    general: (
      typography: (
        caption: config.util.get-dict-without-default((
          font: font,
          size: size,
        )),
      ),
    ),
  )
}

/// Configure inline and block code typography.
/// -> dictionary
#let code(
  /// Monospace font family name or list of fallbacks. -> str | array | config.util.default-value
  font: config.util.default-value,
  /// Code font size relative to body. -> relative | config.util.default-value
  size: config.util.default-value,
) = {
  return (
    general: (
      typography: (
        code: config.util.get-dict-without-default((
          font: font,
          size: size,
        )),
      ),
    ),
  )
}

/// Configure math typography.
/// -> dictionary
#let math(
  /// Math font family name. -> str | array | config.util.default-value
  font: config.util.default-value,
  /// Math font size relative to body. -> relative | config.util.default-value
  size: config.util.default-value,
) = {
  return (
    general: (
      typography: (
        math: config.util.get-dict-without-default((
          font: font,
          size: size,
        )),
      ),
    ),
  )
}
