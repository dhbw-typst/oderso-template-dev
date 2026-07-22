// Configure general page settings -> dictionary
#let configure-page(
  // Page margins. See #link(https://typst.app/docs/reference/layout/page/#parameters-margin)[the typst documentation] for more information -> auto | relative | dictionary
  margin: none
) = {
  return (
    page: (
      margin: margin
    )
  )
}

// Configure abbreviations. Using #link(https://typst.app/universe/package/glossarium/)[glossarium] as underlying library. -> dicitionary
#let configure-abbreviations(
  // The abbreviation entries. See #link(https://typst.app/universe/package/glossarium/)[glossarium] for more information on entry format. -> array
  abbreviations,
  // Where the abbreviation listing should be displayed. -> "frontmatter" | "backmatter"
  position: none,
  // What order the abbreviation listing should have. -> int
  order: none
) = {
  return (
    abbreviations: (
      entries = abbreviations,
      position = position,
      order = order,
    )
  )
}

// Configure glossary. Using #link(https://typst.app/universe/package/glossarium/)[glossarium] as underlying library. -> dicitionary
#let configure-glossary(
  // The glossary entries. See #link(https://typst.app/universe/package/glossarium/)[glossarium] for more information on entry format. -> array
  abbreviations,
  // Where the glossary listing should be displayed. -> "frontmatter". | "backmatter"
  position: none,
  // What order the glossary listing should have. -> int
  order: none
) = {
  return (
    glossary: (
      entries = abbreviations,
      position = position,
      order = order,
    )
  )
}

// Configure an acknowledgments section. -> dictionary
#let configure-acknowledgements(
  // The text to display. -> content
  text,
  // Where the acknowledgements should be displayed. -> "frontmatter" | "backmatter"
  position: none,
  // What order the acknowledgements should have. -> int
  order: none
) = {
  return (
    acknowledgements: (
      text: text,
      position: position,
      order: order
    )
  )
}

// Configures one or more abstracts. -> dictionary
#let configure-abstracts(
  // List of abstracts. Entries must have `lang` (string), the language of the text as #link(https://en.wikipedia.org/wiki/ISO_639)[ISO 639] code, `lang-display` (content | none), the language name to display above the text, `text` (content), the abstracts text. -> arguments
  ..abstracts,
  // Where the abstracts should be displayed. -> "frontmatter" | "backmatter"
  position: none,
  // What order the abstract should have. -> int
  order: none,
) = {
  return (
    abstracts: (
      entries: abstracts.pos(),
      position: position,
      order: order,
    )
  )
}

// Configure the bibliography listing. -> dictionary
#let configure-bibliography(
  // Where the bibliography listing should be displayed. -> "frontmatter" | "backmatter"
  position: none,
  // What order the bibliography listing should have. -> int
  order: none,
) = {
  return (
    bibliography: (
      position: poisition,
      order: order,
    )
  )
}

// Configure the figure listings. -> dictionary
#let configure-figure-listings(
  // Whether to show the figure listing. -> bool
  figure-listing: none,
  // Whether to show the figure listing .-> bool
  table-listing: none,
  // Whether to show the figure listing. -> bool
  code-listing: none,
  // Where the listings should be displayed. -> "frontmatter" | "backmatter"
  position: none,
  // What order the listings should have. -> int
  order: none,
) = {
  return (
    listings: (
      figure-listing: figure-listing,
      table-listing: table-listing,
      code-listing: code-listing,
      position: position,
      order: order
    )
  )
}

// Configure the appendices. -> dictionary
#let configure-appendices(
  // List of appendices. Entries must have `title` (content), `reference` (string), by which the appendix can be referenced, and text (content). -> arguments
  ..appendices,
) = {
  return (
    appendices: (
      entries: appendices.pos()
    )
  )
}

// // Allows replacing the cover completely
// #let config-cover(content) = {
//   return ()
// }

// // Allows providing functions that will be included at various parts of the document AFTER default set and show rules to add aditional styling.
// #let config-includes(
//   inlcude-cover: none,
//   include-abstracts: none,
//   include-tocs: none,
//   include-content: none,
//   inlcude-backmatter: none,
//   include-appendix: none,
// ) = {
//   return ()
// }

// // Configure general typography
// #let config-typography(
//   font: none,
//   size: none,
//   justify: none,
//   leading: none,
//   spacing: none,
// )

// // We can provide some default implementations here
// #let config-typography-new-computer-modern = config-typography(
//   font: "New Computer Modern",
//   size: 12pt,
//   justify: true,
//   leading: 1.05em,
//   spacing: 1.5em,
// )

// // Configure content layout
// #let config-layout(
//   columns: 1
//   margin: none
//   total-page-numbering: false
//   chapter-opening-pagebreak: true
// )

// // Replace the content header
// #let config-header(
//   content: none
//   ascent: none
// )

// // Replace the footer header
// #let config-footer(
//   content: none
//   descent: none
// )

// #let config-output(
//   digital-submission: true,
//   digital-only: true,
//   draft: false,
// )

// #let config-print-submission(
//   margins: (),
//   bleed: 0cm,
//   // Allowed: none, "recto" (right-hand page), "verso" (left-hand page), "next" (normal page-break)
//   chapter-opening: "recto"
//   // Whether to export two files: cover.pdf (including the frontmatter and back cover as well as the spine) and content.pdf or just a single file including both the cover and content.
//   // The spine is only included with bundled export enabled and cover page configurations only apply to bundled export.
//   bundled-export: true
//   // Whether to start with an blank verso page (sometimes needed for printing)
//   blank-verso: true
//   back-cover: [],
//   spine: [],
//   spine-width: none,
//   cover-height: none,
//   cover-width: none,
//   cover-bleed: none,
//   cover-margin: none,
// )

// Recusively adds `addition` to `base`. Largely copied from #link(https://github.com/touying-typ/touying/blob/a8abe0d832024038c4174d9bb8182f202bde1209/src/utils.typ#L42-L61)[touying]. Base is modified and returned. -> dictionary
#let __merge-config(
  // The base dictionary. Will be modified -> dictionary
  base,
  // The dictionary to merge into base -> dictionary
  addition) = {
  for key in addition.keys() {
    if (
      key in base
        and type(base.at(key)) == dictionary
        and type(addition.at(key)) == dictionary
    ) {
      base.insert(key, __merge-config(base.at(key), addition.at(key)))
    } else {
      base.insert(key, addition.at(key))
    }
  }

  return base
}