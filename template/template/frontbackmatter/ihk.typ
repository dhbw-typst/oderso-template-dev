// LTeX: enabled=false
// IHK-specific frontbackmatter configuration functions.
// Accessible as frontbackmatter.ihk.* from lib.typ.

#import "_shared.typ": (
  configure-confidentiality-clause, configure-statutory-declaration,
)

/// Configure the statutory declaration section for IHK. -> dictionary
#let statutory-declaration = configure-statutory-declaration

/// Configure the confidentiality clause section for IHK. -> dictionary
#let confidentiality-clause = configure-confidentiality-clause
