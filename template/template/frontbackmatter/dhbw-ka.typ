// LTeX: enabled=false
// DHBW Karlsruhe-specific frontbackmatter configuration functions.
// Accessible as frontbackmatter.dhbw-ka.* from lib.typ.

#import "_shared.typ": configure-statutory-declaration, configure-confidentiality-clause
#import "../institution/config.typ": configure-dhbw-ka-ai-acknowledgement

/// Configure the statutory declaration section for DHBW Karlsruhe. -> dictionary
#let statutory-declaration = configure-statutory-declaration

/// Configure the confidentiality clause section for DHBW Karlsruhe. -> dictionary
#let confidentiality-clause = configure-confidentiality-clause

/// Configure the AI declaration section for DHBW Karlsruhe.
///
/// Entries must have `tool` (str) and `usage` (content). The section is
/// rendered only when `entries` is non-empty. -> dictionary
#let ai-declaration = configure-dhbw-ka-ai-acknowledgement
