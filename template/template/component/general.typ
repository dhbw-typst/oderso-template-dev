// LTeX: enabled=false
#import "../config/lib.typ" as config
#import "_shared.typ": (
  _build-show-rules-entry, _make-show-rule-entry, make-footer, make-header,
  make-page,
)

/// Configure general page settings (numbering, margin) shared across ALL sections.
/// Overridden by any section-specific `page` config. -> dictionary
#let page = make-page(none)

/// Configure a shared default header shown in ALL document sections (frontmatter,
/// body, backmatter, appendix) unless overridden by a section-specific header.
/// -> dictionary
#let header = make-header(none)

/// Configure a shared default footer shown in ALL document sections unless
/// overridden by a section-specific footer.
/// -> dictionary
#let footer = make-footer(none)

/// Configure a document-level show rule that is applied after all base set/show
/// rules. Multiple calls with different `show-key` values accumulate; a repeated
/// `show-key` overwrites the previous entry. Rules are applied in ascending
/// `show-order` (default `0` at composition time if omitted).
/// `show-key` and `show-fun` are co-required: provide both or neither.
/// -> dictionary
#let show-rules(
  /// Unique identifier for this rule. Co-required with `show-fun`. -> str
  show-key: config.util.default-value,
  /// Execution order (lower = earlier). Optional — omit to leave unset. -> int
  show-order: config.util.default-value,
  /// Show rule function receiving content (`it`) and returning content. Co-required with `show-key`. -> function
  show-fun: config.util.default-value,
) = {
  if (
    show-key == config.util.default-value
      and show-order == config.util.default-value
      and show-fun == config.util.default-value
  ) {
    return (:)
  }
  let entry = _build-show-rules-entry(show-key, show-order, show-fun)
  (component: (show-rules: entry))
}
