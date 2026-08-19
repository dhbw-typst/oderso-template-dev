// LTeX: enabled=false
#import "template/lib.typ": *
#import "glossary.typ": abbreviations, glossary
#import "appendix.typ": appendices

#show: project.with(
  theme.spotless(),
  institution.dhbw-ka()
)
// You can now start writing :)

#include "chapters/introduction.typ"
#include "chapters/basic_formatting.typ"
#include "chapters/advanced_elements.typ"
#include "chapters/references_citations.typ"
#include "chapters/reference_management.typ"
#include "chapters/conclusion.typ"
