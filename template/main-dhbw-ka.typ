// LTeX: enabled=false
#import "template/lib.typ": *
#import "glossary.typ": abbreviations, glossary
#import "appendix.typ": appendices

#show: project.with(
  theme.spotless(),
  institution.dhbw-ka(
    lang: "en",

    // Long title, displayed on cover slide
    title-long: "Writing in Typst about a long, very scientific topic",

    // Shorter title, displayed in header of each page
    title-short: "Writing in Typst",

    thesis-type: "Projektarbeit 1 (T3_2000)",
    examination: "Bachelor of Science (B.Sc.)",
    study: "Wirtschaftsinformatik Software Engineering",

    authors: (
      (
        firstname: "John",
        lastname: "Doe",
        matriculation-number: "0000000",
        course: "TINF23B2",
        // remove if you do not have a signature image
        signature: image("assets/placeholder-signature.png"),
      ), // make sure to keep this comma after the first author if there is only one author!
      (
        firstname: "Erika",
        lastname: "Musterfrau",
        matriculation-number: "1234567",
        course: "TINF23B1",
        signature: none,
      ),
    ),

    // Set to specific date with "24.12.2026"
    submission-date: datetime.today().display("[day].[month].[year]"),

    processing-period-weeks: 12,

    // Remove if your thesis is written without a company
    company-department: "Human Resources",
    company-supervisor: "Max Mustermann",
    company-logo: image("assets/placeholder-company-logo.svg"),

    university-supervisor: "Heinrich Braun",
  ),

  // AI declaration (optional – remove this call if you did not use any AI tools)
  frontbackmatter.dhbw-ka.ai-declaration(
    entries: (
      (tool: "ChatGPT", usage: "Text generation and correction"),
      (tool: "DeepL", usage: "Translation"),
    ),
  ),

  // remove this call to remove acknowledgements
  frontbackmatter.acknowledgements(text: include "misc/acknowledgments.typ"),

  // Abstracts are dictionaries with `lang`, `lang-display`, `text` keys.
  frontbackmatter.abstracts(abstracts: (
    (
      lang: "de",
      lang-display: "Deutsch",
      text: include "misc/abstract-german.typ",
    ),
    (
      lang: "en",
      lang-display: "English",
      text: include "misc/abstract-english.typ",
    ),
  )),

  // Appendix can be configured in appendix.typ; remove this call to remove appendices
  component.appendices(appendices: appendices),

  // Bibliography
  frontbackmatter.bibliography(library: bibliography("refs.bib")),

  frontbackmatter.abbreviations(abbreviations: abbreviations),
  frontbackmatter.glossary(glossary: glossary),
)
// You can now start writing :)

#include "chapters/introduction.typ"
#include "chapters/basic_formatting.typ"
#include "chapters/advanced_elements.typ"
#include "chapters/references_citations.typ"
#include "chapters/reference_management.typ"
#include "chapters/conclusion.typ"
