// LTeX: enabled=false
#import "template/lib.typ": (
  caption-with-source, configure-abbreviations, configure-abstracts,
  configure-acknowledgements, configure-appendices, configure-bibliography,
  configure-dhbw-ma-ai-declaration-form, configure-glossary, dhbw-ma-adapter,
)
#import "glossary.typ": abbreviations, glossary
#import "appendix.typ": appendices

#show: dhbw-ma-adapter.with(
  lang: "en",

  // Long title, displayed on cover slide
  title-long: "Writing in Typst about a long, very scientific topic",

  // Shorter title, displayed in header of each file
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
      email: "john.doe@dhbw.com",
      address: "Example Street 1, 12345 Example City",
      phone-number: "+49 0000 0000",
    ), // make sure to keep this comma after the first author if there is only one author!
    (
      firstname: "Erika",
      lastname: "Musterfrau",
      matriculation-number: "1234567",
      course: "TINF23B1",
      signature: none,
      email: none,
      address: none,
      phone-number: none,
    ),
  ),

  // Set to specific date with "24.12.2026"
  submission-date: datetime.today().display("[day].[month].[year]"),

  processing-period-weeks: 12,

  // Remove if your thesis is written without a company
  company-department: "Human Resources",
  company-supervisor: (
    firstname: "Max",
    lastname: "Mustermann",
    email: "max.mustermann@examples.com",
    phone-number: "+49 0000 1111",
  ),
  company-logo: image("assets/placeholder-company-logo.svg"),

  university-supervisor: (
    firstname: "Heinrich",
    lastname: "Braun",
    email: "heinrich.braun@examples.com",
    phone-number: "+49 0000 2222",
  ),

  course-director: "Sebastian Ritterbusch",

  // AI declaration form. Per-author entries must be in the same order as the
  // adapter's `authors` array above.
  configure-dhbw-ma-ai-declaration-form(
    module-name: "Projektmanagement",
    semester: "1",
    exam-type: "Projektarbeit I", // "Projektarbeit I", "Projektarbeit II", "Seminararbeit", "Bachelorarbeit"
    module-submission-date: datetime.today().display("[day].[month].[year]"),
    authors: (
      (
        product-name: "ChatGPT, DeepL",
        topic: "Writing in Typst about a long, very scientific topic",
        topic-editing: "Structuring, organizing",
        research: "Research using AI",
        design: "Text generation, correction",
      ),
      (
        product-name: "ChatGPT, DeepL",
        topic: "Writing in Typst about a long, very scientific topic",
        topic-editing: "Structuring, organizing",
        research: "Research using AI",
        design: "Text generation, correction",
      ),
    ),
  ),

  // remove this call to remove acknowledgements
  configure-acknowledgements(text: include "misc/acknowledgments.typ"),

  // Abstracts are dictionaries with `lang`, `lang-display`, `text` keys.
  configure-abstracts(abstracts: (
    (lang: "de", lang-display: "Deutsch", text: include "misc/abstract-german.typ"),
    (lang: "en", lang-display: "English", text: include "misc/abstract-english.typ"),
  )),

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
