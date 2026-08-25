// LTeX: enabled=false
#import "_shared.typ": make-header, make-footer

/// Configure a shared default header shown in ALL document sections (frontmatter,
/// body, backmatter, appendix) unless overridden by a section-specific header.
/// -> dictionary
#let header = make-header(none)

/// Configure a shared default footer shown in ALL document sections unless
/// overridden by a section-specific footer.
/// -> dictionary
#let footer = make-footer(none)
