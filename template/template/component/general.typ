// LTeX: enabled=false
#import "../config/lib.typ" as config
#import "_shared.typ": make-footer, make-header, make-page

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

/// Configure the document-level show rule applied after all base set/show rules.
/// Use this to inject theme-wide styling (custom heading display, link styling,
/// etc.). The function receives the full document content (`it`) and must return
/// content. -> dictionary
#let show-rules(
  /// Show rule function receiving content (`it`) and returning content. -> function
  show-fun: config.util.default-value,
) = {
  config.validation.validate-show(show-fun)
  (component: config.util.get-dict-without-default((show-rule: show-fun)))
}
