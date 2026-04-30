// LTeX: enabled=false

#import "@preview/glossarium:0.5.10": (
  gls, glspl, make-glossary, print-glossary, register-glossary,
)
#import "@preview/hydra:0.6.2": hydra
#import "@preview/codly-languages:0.1.10": *
#import "@preview/codly:1.3.0": *
#import "@preview/drafting:0.2.2": *
#import "@preview/linguify:0.5.0": *
#import "../utils.typ": __in-outline


#let page-numbering = "1 / 1"
#let heading-numbering = "1.1.1"

#let signature-line(
  digital: true,
  city: none,
  date: none,
  date-format: "[day].[month].[year]",
  author: (
    firstname: none,
    lastname: none,
  ),
) = {
  let signature-content = if digital {
    (
      city,
      date.display(date-format),
      [],
      grid.cell(
        if not author.keys().contains("signature") or author.signature == none {
          author.firstname + " " + author.lastname
        } else {
          set image(height: 25mm)
          place(bottom, author.signature)
        },
        align: center,
      ),
    )
  } else {
    ([], [], [], [])
  }

  v(20mm)

  align(center, grid(
    stroke: none,
    columns: (30mm, 30mm, 20mm, 80mm),
    ..signature-content,
    grid.hline(end: 2), grid.hline(start: 3),
    linguify("place-of-signature"),
    linguify("date-of-signature"),
    [],
    grid.cell(linguify("signature"), align: center),
  ))
}


/// Initilizes the base template
///
/// - lang (str): The primary language of the document ("en" or "de")
/// - logo-left(): Logo displayed in the top left corner of the cover
/// - logo-right(): Logo displayed in the top right corner of the cover
/// - title-long (str): Thesis title, displayed on the cover
/// - title-short (str): Shortened title, which is displayed in the header on every page
/// - thesis-type (str): Type of thesis. Displayed below the title on the cover
/// - metadata (): List of metadata entries
/// - submission-info (content): Additional information about the thesis, displayed below the thesis type.
/// - authors (): List of authors of the thesis
/// - preamble (): List of content to display directly after the cover
/// - postamble (): List of content to display at the very end of the document
/// - abstracts (): List of abstracts
/// - appendices (): List of appendices with values "title" and "content"
/// - library (str): Path to the library file (e.g. ./src.bib)
/// - abbreviations (): List of abbreviations. See https://typst.app/universe/package/glossarium/ for more information
/// - content-page-numbering (str): Page numbering pattern for main content
/// - body (): Content
/// ->
#let project(
  lang: "en",
  logo-left: none,
  logo-right: none,
  title-long: none,
  title-short: none,
  thesis-type: none,
  submission-info: none,
  metadata: (),
  authors: (
    (
      firstname: none,
      lastname: none,
    ),
  ),
  preamble: (),
  postamble: (),
  abstracts: (),
  appendices: (
    (
      title: none,
      reference: none,
      content: none,
    ),
  ),
  library: (),
  abbreviations: (),
  content-page-numbering: "1",
  body,
) = {
  // load linguify
  set-database(eval(load-ftl-data("../do_not_touch/l10n", ("en", "de"))))

  // page setup
  set document(title: title-long)
  set page(paper: "a4")

  // set text language (e. g. for smart quotes)
  set text(lang: lang)

  // justify content
  set par(justify: true)

  // tables settings
  show table: set par(justify: false)

  // font setup (LaTeX Look: 'New Computer Modern')
  set text(font: "New Computer Modern", size: 12pt)

  // heading setup
  set heading(numbering: heading-numbering)

  show heading: it => {
    text(font: "Libertinus Serif", it)
    v(0.5cm)
  }

  show heading.where(level: 2): it => {
    v(weak: true, 1.2cm)
    it
  }

  // load additional syntaxes for code
  set raw(syntaxes: "../do_not_touch/cds.sublime-syntax")

  // fancy inline code
  // if you don't like them, just remove this section.
  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 2pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )

  // fancy code blocks
  // if you don't like them, just remove this section.
  show: codly-init.with()
  let languages-extended = codly-languages
  languages-extended.insert(
    "cds",
    (
      name: [CDS],
      color: rgb("#2599CD"),
      // styling from https://github.com/swaits/typst-collection/blob/b399080660c0566792cb3579ccf52ce7af9048a6/codly-languages/lib.typ#L16-L21
      // icon: box(
      //   image("logo.svg", height: 0.9em),
      //   baseline: 0.05em,
      //   inset: 0pt,
      //   outset: 0pt,
      // )
      //  + h(0.3em),
    ),
  )

  codly(
    languages: languages-extended,
    zebra-fill: none,
    display-icon: false,
    display-name: false,
    number-align: right + top,
  )

  // set table numbering to roman
  show figure.where(kind: table): set figure(numbering: "I")

  show: make-glossary

  // fancy inline links
  // if you don't like them, just remove this section.
  show link: it => {
    if type(it.dest) == str {
      set text(fill: gray.darken(80%))
      underline(
        stroke: (paint: gray, thickness: 0.5pt, dash: "densely-dashed"),
        offset: 4pt,
        it,
      )
    } else {
      it
    }
  }

  // Block quotes
  set quote(block: true)

  // Configure inline notes
  let caution-rect = rect.with(radius: 0.5em)
  set-margin-note-defaults(rect: caution-rect, fill: orange.lighten(80%))

  // Coversheet
  // Show notes before everything else, so you don't miss them
  context {
    // Check wether there are any notes in the document
    if (query(selector(<margin-note>).or(<inline-note>)).len() > 0) {
      set heading(numbering: none, outlined: false)
      note-outline(title: linguify("list-of-notes"))
      pagebreak()
    }
  }

  // Allow code blocks to span multiple pages
  show figure.where(kind: raw): set block(breakable: true)

  // Coversheet
  grid(
    rows: (1fr, auto, 1fr),
    align: (_, row) => (center + top, center + top, center + bottom).at(row),
    // Left and right logo
    {
      set image(height: 2.5cm)

      grid(
        columns: (1fr, 1fr),
        align(left, logo-left), align(right, logo-right),
      )
    },

    // Title
    align(center)[
      #set par(justify: false)

      #text(20pt)[*#title-long*]

      #smallcaps(text(1.25em, weight: "semibold")[#thesis-type])

      #submission-info

      #linguify("by")

      #for author in authors {
        [*#author.firstname #author.lastname*\ ]
      }
    ],

    // Meta
    align(center, {
      show table.cell.where(x: 0): set text(weight: "semibold")

      table(
        columns: (1fr, 1fr),
        align: (right + top, left + top),
        stroke: none,
        ..metadata
      )
    }),
  )
  pagebreak()

  // start page count on second page
  counter(page).update(1)
  set page(numbering: "I")

  {
    set heading(outlined: false, numbering: none)
    // preamble
    for p in preamble {
      p
    }
  }

  // abstracts
  for a in abstracts {
    let (abstract-lang, abstract-lang-long, abstract-body) = a
    pagebreak()
    align(center + horizon)[
      #heading(outlined: false, numbering: none, [#text(
          0.85em,
          smallcaps(linguify("abstract")),
        )\ #text(
          0.75em,
          weight: "light",
          style: "italic",
          [\- #abstract-lang-long -],
        )])
      #text(lang: abstract-lang, abstract-body)
      #v(20%)
    ]
  }

  // captions with caption_with_source shouldn't show source in outline
  show outline: it => {
    __in-outline.update(true)
    it
    __in-outline.update(false)
  }

  // table of contents
  // show level 1 headings in outline in a fancier way, if not desired feel free to remove it
  pagebreak()
  [#show outline.entry.where(level: 1): it => {
      v(12pt, weak: true)
      strong(it)
    }
    #outline(
      title: linguify("table-of-contents"),
      depth: 3,
      indent: auto,
      target: selector(heading).before(
        <__appendix-start>,
      ),
    )
  ]

  // index of abbreviations
  if abbreviations.len() > 0 {
    pagebreak()
    heading(outlined: true, numbering: none, linguify("list-of-abbreviations"))
    register-glossary(abbreviations)
    print-glossary(abbreviations, deduplicate-back-references: true)
  }

  // only display certain outlines if elements for it exist
  context {
    // list of figures
    if query(figure.where(kind: image)).len() > 0 {
      pagebreak()
      heading(linguify("list-of-figures"), numbering: none)
      outline(
        target: figure.where(kind: image).before(<__appendix-start>),
        title: none,
      )
    }

    // list of tables
    if query(figure.where(kind: table)).len() > 0 {
      pagebreak()
      heading(linguify("list-of-tables"), numbering: none)
      outline(
        target: figure.where(kind: table).before(<__appendix-start>),
        title: none,
      )
    }

    // list of source code
    if query(figure.where(kind: raw)).len() > 0 {
      pagebreak()
      heading(linguify("list-of-code"), numbering: none)
      outline(
        target: figure.where(kind: raw).before(<__appendix-start>),
        title: none,
      )
    }
  }

  // display main document and reset page counter
  set page(
    numbering: (..n) => context {
      numbering(content-page-numbering, n.at(0), ..counter(page).at(<__last-content-page>))
    },
    footer: auto,
    margin: (top: 4cm, x: 2.5cm, bottom: 2.5cm),
  )
  counter(page).update(1)

  set par(leading: 0.9em)

  {
    // display header
    set page(header: {
      context {
        grid(
          columns: (auto, 1fr),
          align(left, text(title-short)),
          align(right, emph(hydra(1, display: (_, it) => {
            it.body
          }))),
        )
        line(length: 100%, stroke: (paint: gray))
      }
    })
    show heading.where(level: 1): it => {
      pagebreak(weak: true)
      it
    }

    body
    [#std.metadata("last-content-page") <__last-content-page>]
  }

  // display bibliography
  set page(numbering: "a", footer: auto)
  counter(page).update(1)

  bibliography("../" + library, title: linguify("list-of-bibliography"))

  // display appendix
  if appendices != none {
    set heading(
      outlined: true,
      numbering: (..nums) => {
        "Appendix "
        numbering("1.1", ..nums)
      },
      supplement: none,
    )
    set page(numbering: "A", footer: auto)
    counter(page).update(1)
    counter(heading).update(0)

    heading(
      linguify("list-of-appendices"),
      numbering: none,
    )

    outline(
      depth: 3,
      indent: auto,
      title: none,
      target: selector(heading).after(<__appendix-start>),
    )

    pagebreak(weak: true)
    [#[] <__appendix-start>]

    for appendix in appendices {
      pagebreak(weak: true)
      [#heading(appendix.title) #label(appendix.reference)]

      appendix.content
    }
  }

  {
    set heading(outlined: false, numbering: none)
    // postamble
    for p in postamble {
      p
    }
  }
}
