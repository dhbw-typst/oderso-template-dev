// LTeX: enabled=false
#import "_shared.typ": make-footer, make-header, make-page, make-show-rules

/// Configure show rules scoped to frontmatter content. -> dictionary
#let show-rules = make-show-rules("frontmatter")

/// Configure the header for the frontmatter section only.
/// Overrides the shared `component.header` for frontmatter pages. -> dictionary
#let header = make-header("frontmatter")

/// Configure the footer for the frontmatter section only. -> dictionary
#let footer = make-footer("frontmatter")

/// Configure the page settings (numbering, margin) for the frontmatter section only. -> dictionary
#let page = make-page("frontmatter")
