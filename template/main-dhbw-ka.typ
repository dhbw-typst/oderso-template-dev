// LTeX: enabled=false
#import "utils.typ": caption-with-source
#import "template/dhbw-ka.typ": dhbw-ka-adapter, __documentation

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
      course: "TINF23B2",
      // remove if you do not have a signature image
      signature: image("assets/example-signature.png"),
    ), // make sure to keep this comma after the first author if there is only one author!
    (
      firstname: "Erika",
      lastname: "Musterfrau",
      matriculation-number: "1234567",
      course: "TINF23B1",
    ),
  ),

  signature-city: "Karlsruhe",

  // Set to specific date with datetime(year: 2026, month: 06, day: 10)
  submission-date: datetime.today(),

  processing-period-weeks: 12,

  // Remove if your thesis is not written without a company
  company-department: "Human Resources",
  company-supervisor: "Max Mustermann",
  company-logo: image("do_not_touch/Company-Logo.svg"),

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
  // change to "appendices: none" to remove appendix
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

  // Path to reference - either .yaml or .bib file
  // * for `.yaml` files see: [hayagriva](https://github.com/typst/hayagriva)
  library: "refs.bib",

  // Specify abbreviations here.
  // The key is used to reference the acronym.
  // The short form is used every time and the long form is used
  // additionally the first time you reference the acronym.
  abbreviations: (
    (key: "NN", short: "NN", long: "Neural Network"),
    (key: "SG", short: "SG", long: "Singular"),
  ),
)

// You can now start writing :)

#include "chapters/introduction.typ"
#include "chapters/basic_formatting.typ"
#include "chapters/advanced_elements.typ"
#include "chapters/references_citations.typ"
#include "chapters/reference_management.typ"

= Detailed Package Usage

#__documentation()

#include "chapters/conclusion.typ"

