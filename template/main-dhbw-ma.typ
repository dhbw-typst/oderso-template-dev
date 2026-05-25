// LTeX: enabled=false
#import "template/lib.typ": caption-with-source, dhbw-ma-adapter

#show: dhbw-ma-adapter.with(
  lang: "en",

  // Wether to display a signature line for the statutory declaration
  digital-submission: true,

  // Set to false if you also submit a printed copy of your thesis. Important for the statutory declaration
  digital-only: true,

  // Set to false if you do not need a confidentiality clause
  confidentiality-clause: true,

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
      signature: image("assets/example-signature.png"),
      email: "john.doe@dhbw.com",
      address: "Example Street 1, 12345 Example City",
      phone-number: "+49 0000 0000",
    ), // make sure to keep this comma after the first author if there is only one author!
    (
      firstname: "Erika",
      lastname: "Musterfrau",
      matriculation-number: "1234567",
      course: "TINF23B1",
    ),
  ),

  signature-city: "Mannheim",

  // Set to specific date with datetime(year: 2026, month: 06, day: 10)
  submission-date: datetime.today(),
  module-submission-date: datetime.today(),

  processing-period-weeks: 12,

  // Remove if your thesis is written without a company
  company-department: "Human Resources",
  company-supervisor: (
    firstname: "Max",
    lastname: "Mustermann",
    email: "max.mustermann@examples.com",
    phone-number: "+49 0000 1111",
  ),
  company-logo: image("assets/Company-Logo.svg"),

  university-supervisor: (
    firstname: "Heinrich",
    lastname: "Braun",
    email: "heinrich.braun@examples.com",
    phone-number: "+49 0000 2222",
  ),

  course-director: "Sebastian Ritterbusch",

  ai-declaration-form-data: (
    module-name: "Projektmanagement",
    exam-type: "Projektarbeit I", // "Projektarbeit I", "Projektarbeit II", "Seminararbeit", "Bachelorarbeit"
    product-name: "ChatGPT, DeepL",
    topic: "Writing in Typst about a long, very scientific topic",
    topic-editing: "Strukturierung, Gliederung",
    research: "Quellenrecherche mit KI",
    design: "Textgenerierung, Korrektur",
  ),

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

  // Specify glossary terms here for term definitions (not abbreviations).
  // The key is used to reference the term.
  // The long form is the term and the short form is the abbreviation (only if you need it).
  // The description is used for the detailed explanation of the term.
  // Set to empty array () if you don't need a glossary.
  glossary: (
    (
      key: "typ",
      short: none,
      long: "Typst",
      description: "Typst is a new markup-based typesetting system that is designed to be as powerful as LaTeX while being much easier to learn and use.",
    ),
  ),
)

// You can now start writing :)

#include "chapters/introduction.typ"
#include "chapters/basic_formatting.typ"
#include "chapters/advanced_elements.typ"
#include "chapters/references_citations.typ"
#include "chapters/reference_management.typ"
#include "chapters/conclusion.typ"
