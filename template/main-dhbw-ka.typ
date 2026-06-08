// LTeX: enabled=false
#import "template/lib.typ": caption-with-source, dhbw-ka-adapter
#import "glossary.typ": abbreviations, glossary

#show: dhbw-ka-adapter.with(
  lang: "en",

  // Wether to display a signature line for the statutory declaration
  digital-submission: true,

  // Set to false if you also submit a printed copy of your thesis. Important for the statutory declaration
  digital-only: true,

  // Set to false if you do not need a confidentiality clause
  confidentiality-clause: true,

  // Add AI tools used for this thesis here, according to 4.6 of "Leitlinien für Wissenschaftliche Arbeiten in Bachelorstudiengängen Studienbereich Technik"
  ai-acknowledgement: (
    (
      tool: "ChatGPT",
      usage: [
        + Vibed chapter 1 - 6
        + Grammer correction
      ],
    ), // This last comma is important, keep it!
  ),

  // Long title, displayed on cover slide
  title-long: "Writing in Typst about a long, very scientific topic",

  // Shorter title, displayed in header of each file
  title-short: "Writing in Typst",

  thesis-type: "Projektarbeit 1 (T3_2000)",
  examination: "Bachelor of Science (B.Sc.)",
  study: "Computer Science",

  authors: (
    (
      firstname: "John",
      lastname: "Doe",
      matriculation-number: "0000000",
      course: "TINF24B2",
      // remove if you do not have a signature image
      signature: image("assets/example-signature.png"),
    ), // make sure to keep this comma after the first author if there is only one author!
    (
      firstname: "Erika",
      lastname: "Musterfrau",
      matriculation-number: "1234567",
      course: "TINF24B1",
    ),
  ),

  signature-city: "Karlsruhe",

  // Set to specific date with "24.12.2026"
  submission-date: datetime.today().display("[day].[month].[year]"),

  processing-period-weeks: 12,

  // Remove if your thesis is not written without a company
  company-department: "Human Resources",
  company-supervisor: "Max Mustermann",
  company-logo: image("assets/Company-Logo.svg"),

  university-supervisor: "Heinrich Braun",

  // abstracs: usage: (language, language (displayed), content)
  abstracts: (
    ("de", "Deutsch", include "abstracts/abstract_german.typ"),
    (
      "en",
      "English",
      [
        This is a short abstract to show the formatting and general style of the template

        It is possible to have multiple abstracts in different languages
      ],
    ),
  ),

  // appendices: usage: (
  //   title: "Title",
  //   reference: "reference-label",
  //   content: [content] || include("appendix.typ")
  // )
  // remove property to remove appendices
  appendices: (
    (
      title: "Relevant Stuff",
      reference: "appendix-relevant-stuff",
      content: [
        == This is some more source code
        #lorem(10)

        You can reference this appendix using `@appendix-relevant-stuff`.
      ],
    ), // appendix inline
    (
      title: "Table Examples",
      reference: "appendix-table-examples",
      content: include "assets/example-tables.typ",
    ), // appendix from file
  ),

  // Bibliography
  library: bibliography("refs.bib"),

  abbreviations: abbreviations,
  glossary: glossary,
)

// You can now start writing :)

#include "chapters/introduction.typ"
#include "chapters/basic_formatting.typ"
#include "chapters/advanced_elements.typ"
#include "chapters/references_citations.typ"
#include "chapters/reference_management.typ"
#include "chapters/conclusion.typ"
