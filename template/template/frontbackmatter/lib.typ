// LTeX: enabled=false
// Public frontbackmatter namespace.
// Imported as `frontbackmatter` in lib.typ.

// General (institution-agnostic) front/back matter sections
#import "general.typ": (
  abbreviations, abstracts, acknowledgements, bibliography, entry,
  figure-listings, glossary, toc,
)

// Common declaration settings; institution setups install their generators.
#import "_shared.typ": confidentiality-clause, statutory-declaration
