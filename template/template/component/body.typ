// LTeX: enabled=false
#import "_shared.typ": make-footer, make-header, make-page, make-show-rules

/// Configure the header for the body section only.
/// Overrides the shared `component.header` for body pages. -> dictionary
#let header = make-header("body")

/// Configure the footer for the body section only. -> dictionary
#let footer = make-footer("body")

/// Configure the page settings (numbering, margin) for the body section only. -> dictionary
#let page = make-page("body")

/// Configure show rules scoped to body content. -> dictionary
#let show-rules = make-show-rules("body")
