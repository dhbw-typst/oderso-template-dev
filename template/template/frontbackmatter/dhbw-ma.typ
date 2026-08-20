// LTeX: enabled=false
// DHBW Mannheim-specific frontbackmatter configuration functions.
// Accessible as frontbackmatter.dhbw-ma.* from lib.typ.

#import "_shared.typ": configure-statutory-declaration, configure-confidentiality-clause
#import "../institution/config.typ": configure-dhbw-ma-ai-declaration-form

/// Configure the statutory declaration section for DHBW Mannheim. -> dictionary
#let statutory-declaration = configure-statutory-declaration

/// Configure the confidentiality clause section for DHBW Mannheim. -> dictionary
#let confidentiality-clause = configure-confidentiality-clause

/// Configure the AI declaration form section for DHBW Mannheim.
///
/// Per-author AI declaration data is passed via `authors`. The section is
/// rendered only when `authors` is non-empty. -> dictionary
#let ai-declaration-form = configure-dhbw-ma-ai-declaration-form
