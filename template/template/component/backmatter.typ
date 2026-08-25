// LTeX: enabled=false
#import "_shared.typ": make-footer, make-header, make-page

/// Configure the header for the backmatter section only.
/// Overrides the shared `component.header` for backmatter pages. -> dictionary
#let header = make-header("backmatter")

/// Configure the footer for the backmatter section only. -> dictionary
#let footer = make-footer("backmatter")

/// Configure the page settings (numbering, margin) for the backmatter section only. -> dictionary
#let page = make-page("backmatter")
