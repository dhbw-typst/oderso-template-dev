// appendices: usage: (
//   title: "Title",
//   reference: "reference-label",
//   text: [content] || include("appendix.typ")
// )
#let appendices = (
  (
    title: "Relevant Stuff",
    reference: "appendix-relevant-stuff",
    text: [
      == This is some more source code
      #lorem(10)

      You can reference this appendix using `@appendix-relevant-stuff`.
    ],
  ), // appendix inline
  (
    title: "Table Examples",
    reference: "appendix-table-examples",
    text: include "appendix/tables.typ",
  ), // appendix from file
)
