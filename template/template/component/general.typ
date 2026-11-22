// LTeX: enabled=false
#import "_shared.typ": make-footer, make-header, make-page, make-show-rules

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
/// `show-key` patches the previous entry field by field. Rules are applied in ascending
/// `show-order` (default `0` at composition time if omitted).
/// A key is required to patch order, callback, or enable. Later callbacks become
/// outer wrappers; execution order is not effective style precedence.
/// -> dictionary
#let show-rules = make-show-rules(none)
