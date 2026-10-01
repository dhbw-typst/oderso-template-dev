// LTeX: enabled=false
// Public frontbackmatter namespace.
// Imported as `frontbackmatter` in lib.typ.

// General (institution-agnostic) front/back matter sections
#import "general.typ": (
  abbreviations, abstracts, acknowledgements, bibliography, figure-listings,
  glossary, toc,
)

// Institution-specific sub-namespaces
#import "dhbw-ka.typ" as dhbw-ka
#import "dhbw-ma.typ" as dhbw-ma
#import "ihk.typ" as ihk
