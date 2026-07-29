#import "utils.typ": __linguify-content
#import "@preview/glossarium:0.5.10": print-glossary

// ============================================================
//                DEFAULT SECTION GENERATORS
// ============================================================
// Each default generator receives the fully-merged configuration dictionary
// and returns the section `content` (or `none` to skip rendering). They are
// installed on the base config by `base.typ` via the `generator-function`
// parameter of the matching `configure-*` function.

/// Default generator for the acknowledgements section. Renders a centered
/// acknowledgements page with the configured text, or `none` if no text was
/// provided. -> content | none
#let __acknowledgements-default-generator(config) = {
  let ack = config.front-back-matter.acknowledgements
  if ack.at("text", default: none) == none {
    return none
  }
  align(center + horizon, {
    heading(outlined: false, numbering: none, [#text(
      0.85em,
      smallcaps(__linguify-content("acknowledgments")),
    )\ ])
    align(left, ack.text)
    v(20%)
  })
}

/// Default generator for the abstracts section. Renders one centered page
/// per abstract entry, or `none` if no entries were configured. -> content | none
#let __abstracts-default-generator(config) = {
  let entries = config.front-back-matter.abstracts.at("entries", default: ())
  if entries.len() == 0 {
    return none
  }
  for a in entries {
    pagebreak(weak: true)
    align(center + horizon, {
      heading(outlined: false, numbering: none, [#text(
          0.85em,
          smallcaps(__linguify-content("abstract")),
        )\ #text(
          0.75em,
          weight: "light",
          style: "italic",
          [\- #a.lang-display -],
        )])
      align(left, text(lang: a.lang, a.text))
      v(20%)
    })
  }
}

/// Default generator for the table of contents section. Renders an outline of
/// all headings placed before the appendix. -> content
#let __toc-default-generator(config) = {
  // show level 1 headings in outline in a fancier way
  show outline.entry.where(level: 1): strong
  set par(leading: 0.65em)
  outline(
    title: __linguify-content("table-of-contents"),
    depth: 3,
    indent: auto,
    target: selector(heading).before(<__appendix-start>),
  )
}

/// Default generator for the bibliography section. Renders the configured
/// `library` content (typically produced via `bibliography("refs.bib")`), or
/// `none` if no library was provided. -> content | none
#let __bibliography-default-generator(config) = {
  let library = config.front-back-matter.bibliography.at(
    "library",
    default: none,
  )
  if library == none {
    return none
  }
  library
}

/// Default generator for the glossary section. Renders the glossary heading
/// followed by `print-glossary` output, or `none` if no entries were
/// configured. -> content | none
#let __glossary-default-generator(config) = {
  let gloss = config.front-back-matter.glossary
  let entries = gloss.at("entries", default: ())
  if entries.len() == 0 {
    return none
  }
  heading(__linguify-content("glossary"))
  print-glossary(entries, ..gloss.at("print-options", default: (:)))
}

/// Default generator for the abbreviations section. Renders the abbreviations
/// heading followed by `print-glossary` output, or `none` if no entries were
/// configured. -> content | none
#let __abbreviations-default-generator(config) = {
  let abbr = config.front-back-matter.abbreviations
  let entries = abbr.at("entries", default: ())
  if entries.len() == 0 {
    return none
  }
  heading(__linguify-content("abbreviations"))
  print-glossary(entries, ..abbr.at("print-options", default: (:)))
}

/// Default generator for the figure listings section. Renders lists of
/// figures, tables and code blocks appearing before the appendix, subject to
/// the corresponding enable flags. Uses `context` because the presence of
/// each listing depends on document queries resolved during layout. -> content
#let __listings-default-generator(config) = context {
  let listings = config.front-back-matter.listings

  // list of figures
  if (
    listings.at("figure-listing", default: false)
      and query(figure.where(kind: image)).len() > 0
  ) {
    pagebreak(weak: true)
    heading(__linguify-content("list-of-figures"))
    outline(
      target: figure.where(kind: image).before(<__appendix-start>),
      title: none,
    )
  }

  // list of tables
  if (
    listings.at("table-listing", default: false)
      and query(figure.where(kind: table)).len() > 0
  ) {
    pagebreak(weak: true)
    heading(__linguify-content("list-of-tables"))
    outline(
      target: figure.where(kind: table).before(<__appendix-start>),
      title: none,
    )
  }

  // list of source code
  if (
    listings.at("code-listing", default: false)
      and query(figure.where(kind: raw)).len() > 0
  ) {
    pagebreak(weak: true)
    heading(__linguify-content("list-of-code"))
    outline(
      target: figure.where(kind: raw).before(<__appendix-start>),
      title: none,
    )
  }
}
