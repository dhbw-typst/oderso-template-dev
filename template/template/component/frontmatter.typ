// LTeX: enabled=false
#import "_shared.typ": make-header, make-footer

/// Configure the header for the frontmatter section only.
/// Overrides the shared `component.header` for frontmatter pages. -> dictionary
#let header = make-header("frontmatter")

/// Configure the footer for the frontmatter section only. -> dictionary
#let footer = make-footer("frontmatter")
