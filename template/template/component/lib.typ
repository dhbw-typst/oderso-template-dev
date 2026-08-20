// LTeX: enabled=false
#import "coversheet.typ": coversheet
#import "appendices.typ": appendices
#import "config.typ": (
  header,
  footer,
  frontmatter-header,
  frontmatter-footer,
  body-header,
  body-footer,
  backmatter-header,
  backmatter-footer,
  appendix-toc,
  appendix-header,
  appendix-footer,
)

// Section-specific sub-namespaces for ergonomic access:
// component.frontmatter.header(...), component.body.footer(...), etc.

/// Frontmatter component overrides.
#let frontmatter = (
  header: frontmatter-header,
  footer: frontmatter-footer,
)

/// Body component overrides.
#let body = (
  header: body-header,
  footer: body-footer,
)

/// Backmatter component overrides.
#let backmatter = (
  header: backmatter-header,
  footer: backmatter-footer,
)

/// Appendix component overrides.
#let appendix = (
  toc: appendix-toc,
  header: appendix-header,
  footer: appendix-footer,
)
