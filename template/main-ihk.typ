// LTeX: enabled=false
#import "template/lib.typ": (
  caption-with-source, configure-abbreviations, configure-appendices,
  configure-bibliography, configure-glossary, ihk-adapter,
)
#import "glossary.typ": abbreviations, glossary
#import "appendix.typ": appendices

#show: ihk-adapter.with(
  lang: "de",

  title-long: "Writing in Typst about a long, very scientific topic",
  title-short: "Writing in Typst",
  thesis-type: "Abschlussprojekt",
  examination: "Winterprüfung 2026",
  authors: (
    (
      firstname: "John",
      lastname: "Doe",
      examinee-number: "(000)-0000",
      signature: image("assets/placeholder-signature.png"),
    ), // make sure to keep this comma after the first author if there is only one author!
    (
      firstname: "Erika",
      lastname: "Musterfrau",
      examinee-number: "(123)-4567",
    ),
  ),
  processing-period-weeks: 12,
  company-department: "Human Resources",
  company-supervisor: "Max Mustermann",
  company-logo: image("assets/placeholder-company-logo.svg"),

  // Appendix can be configured in appendix.typ; remove this call to remove appendices
  configure-appendices(appendices: appendices),

  // Bibliography
  configure-bibliography(library: bibliography("refs.bib")),

  configure-abbreviations(abbreviations: abbreviations),
  configure-glossary(glossary: glossary),
)

// You can now start writing :)

#include "chapters/introduction.typ"
#include "chapters/basic_formatting.typ"
#include "chapters/advanced_elements.typ"
#include "chapters/references_citations.typ"
#include "chapters/reference_management.typ"
#include "chapters/conclusion.typ"
