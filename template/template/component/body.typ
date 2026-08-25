// LTeX: enabled=false
#import "_shared.typ": make-header, make-footer

/// Configure the header for the body section only.
/// Overrides the shared `component.header` for body pages. -> dictionary
#let header = make-header("body")

/// Configure the footer for the body section only. -> dictionary
#let footer = make-footer("body")
