// LTeX: enabled=false
#import "template/lib.typ": caption-with-source, ihk-adapter

#show: ihk-adapter.with(
  lang: "de",

  // Set to false if you do not need a confidentiality clause
  confidentiality-clause: true,

  title-long: "Writing in Typst about a long, very scientific topic",
  title-short: "Writing in Typst",
  thesis-type: "Abschlussprojekt",
  examination: "Winterprüfung 2026",
  authors: (
    (
      firstname: "John",
      lastname: "Doe",
      examinee-number: "(000)-0000",
      signature: image("assets/example-signature.png"),
    ), // make sure to keep this comma after the first author if there is only one author!
    (
      firstname: "Erika",
      lastname: "Musterfrau",
      examinee-number: "(123)-4567",
    ),
  ),
  signature-city: "Karlsruhe",
  processing-period-weeks: 12,
  company-department: "Human Resources",
  company-supervisor: "Max Mustermann",
  company-logo: image("assets/Company-Logo.svg"),

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

  // Path/s to references - .bib files
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
