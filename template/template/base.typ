// LTeX: enabled=false

#import "@preview/glossarium:0.5.10": (
  gls, glspl, make-glossary, print-glossary, register-glossary,
)
#import "@preview/codly:1.3.0": codly, codly-init
#import "@preview/drafting:0.2.2": note-outline, set-margin-note-defaults
#import "@preview/linguify:0.5.0": (
  linguify, linguify-raw, load-ftl-data, set-database,
)
#import "utils.typ": __in-outline, __linguify-content
#import "config.typ": *
#import "generators.typ": *
#import "components/coversheet.typ": configure-coversheet-spotless
#import "components/header.typ": configure-body-header-spotless

/// Default heading numbering pattern.
/// -> str
#let __heading-numbering = "1.1.1"

/// Creates a signature line for statutory declarations.
///
/// Generates a formatted signature block with place, date, and signature fields.
/// When `digital` is true, displays the author's name or signature image;
/// when false, leaves the fields blank for handwritten signatures.
/// -> content
#let __signature-line(
  /// Whether this is a digital submission with pre-filled signature. -> bool
  digital: true,
  /// City name for the signature location. -> str | none
  city: none,
  /// Date of the signature. -> str | none
  date: none,
  /// Format string for displaying the date. (see #link("https://typst.app/docs/reference/foundations/datetime/#format")[datetime formats]) -> str
  date-format: "[day].[month].[year]",
  /// Author dictionary with `firstname`, `lastname`, and optionally `signature`
  /// (an image). -> dictionary
  author: (
    firstname: none,
    lastname: none,
  ),
) = {
  let signature-content = if digital {
    (
      city,
      date,
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
    __linguify-content("place-of-signature"),
    __linguify-content("date-of-signature"),
    [],
    grid.cell(__linguify-content("signature"), align: center),
  ))
}

#let __base-config = __merge-configs(
  (:),
  configure-page(margin: 2.5cm),
  configure-appendices(appendices: ()),
  configure-acknowledgements(
    text: none,
    position: "frontmatter",
    order: 10,
    generator-function: __acknowledgements-default-generator,
  ),
  configure-abstracts(
    abstracts: (),
    position: "frontmatter",
    order: 20,
    generator-function: __abstracts-default-generator,
  ),
  configure-toc(
    position: "frontmatter",
    order: 30,
    generator-function: __toc-default-generator,
  ),
  configure-bibliography(
    position: "backmatter",
    order: 40,
    generator-function: __bibliography-default-generator,
  ),
  configure-abbreviations(
    abbreviations: (),
    print-options: (
      deduplicate-back-references: true,
      minimum-refs: 2,
    ),
    position: "backmatter",
    order: 50,
    generator-function: __abbreviations-default-generator,
  ),
  configure-glossary(
    glossary: (),
    print-options: (
      deduplicate-back-references: true,
    ),
    position: "backmatter",
    order: 60,
    generator-function: __glossary-default-generator,
  ),
  configure-figure-listings(
    code-listing: true,
    figure-listing: true,
    table-listing: true,
    position: "backmatter",
    order: 70,
    generator-function: __listings-default-generator,
  ),
  configure-metadata(),
  configure-drafting(notes-listing: true),
  configure-coversheet-spotless(),
  configure-body-header-spotless(),
)

/// Due to a bug in drafting at least one margin must be of a different size then the others.
/// TODO: Evaluate again with the next drafting release.
/// To fix this we check if all margins are the same and if that is the case we increment margin.top by a tiny bit.
#let __transform-margin(margin) = {
  if (
    margin.top == margin.bottom
      and (
        (
          "left" in margin.keys()
            and margin.left == margin.top
            and "right" in margin.keys()
            and margin.right == margin.top
        )
          or (
            "inside" in margin.keys()
              and margin.inside == margin.top
              and "outside" in margin.keys()
              and margin.outside == margin.top
          )
      )
  ) {
    margin.top += 0.01pt
    return margin
  } else {
    return margin
  }
}


/// Base template for thesis documents.
///
/// This is the core template function that sets up the document structure,
/// styling, and layout. It handles the cover page, table of contents,
/// lists of figures/tables/code, bibliography, and appendices.
///
/// Institution-specific adapters should wrap this function to add their
/// specific requirements. However the parameters shown here can be used with all adapters.
/// -> content
#let project(
  /// Whether the content page numbering should include total pages ("3 / 24") or not ("3"). -> bool
  numbering-show-total: false,
  ..__opts,
  body,
) = {
  // create config dictionary
  let config = __base-config
  for addition in __opts.pos() {
    assert.eq(
      type(addition),
      dictionary,
      message: "Only configurations are allowed as positional arguments. See [future link for configuration] for more information.",
    )

    config = __merge-config(config, addition)
  }

  // load linguify
  set-database(eval(load-ftl-data("l10n", ("en", "de"))))

  set bibliography(title: __linguify-content("bibliography"))

  // page setup
  set document(title: config.metadata.at("title-long", default: none))

  // set text language (e. g. for smart quotes)
  if "lang" in config.metadata {
    set text(lang: config.metadata.lang)
  }

  // font setup (LaTeX Look: 'New Computer Modern')
  set text(font: "New Computer Modern", size: 12pt)

  set page(
    paper: "a4",
    margin: __transform-margin(config.page.margin),
    background: if config.drafting.at("watermark", default: none) != none {
      let watermark-text = text(
        15pt,
        fill: rgb("#ff00004b"),
        config.drafting.watermark,
      )
      (
        (pos: start + horizon, dx: 20pt, rot: -90deg),
        (pos: end + horizon, dx: -20pt, rot: 90deg),
      )
        .map(side => {
          place(side.pos, dx: side.dx, rotate(
            side.rot,
            reflow: true,
            watermark-text,
          ))
        })
        .join()
    },
  )

  // justify content.
  // Values researched in https://github.com/dhbw-typst/oderso-template-dev/pull/64 to match Arial 12pt and 1.5 line spacing in Microsoft Word
  set par(justify: true, leading: 1.05em, spacing: 1.5em)

  // tables settings
  show table: set par(justify: false)

  // heading setup
  set heading(numbering: __heading-numbering)

  show heading: it => {
    it
    v(0.5cm)
  }

  show heading.where(level: 2): it => {
    v(weak: true, 1.2cm)
    it
  }

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

  // captions with caption_with_source shouldn't show source in outline
  show outline: it => {
    __in-outline.update(true)
    it
    __in-outline.update(false)
  }

  codly(
    zebra-fill: none,
    display-icon: false,
    display-name: false,
    number-align: right + top,
  )

  show figure.where(kind: raw): set figure(supplement: "Code")

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

  // Allow code blocks to span multiple pages
  show figure.where(kind: raw): set block(breakable: true)

  // Equation figures
  set math.equation(numbering: "(1)")
  // follow IEEE style for equation references: `(1)` instead of `equation 1`
  show ref: it => {
    if it.element != none and it.element.func() == math.equation {
      numbering("(1)", ..counter(math.equation).at(it.target))
    } else {
      it
    }
  }

  // Configure inline notes
  let caution-rect = rect.with(radius: 0.5em)
  set-margin-note-defaults(rect: caution-rect, fill: orange.lighten(80%))

  // register abbreviations before content so references resolve
  if config.front-back-matter.abbreviations.entries.len() > 0 {
    register-glossary(config.front-back-matter.abbreviations.entries)
  }

  // register glossary entries before content so references resolve
  if config.front-back-matter.glossary.entries.len() > 0 {
    register-glossary(config.front-back-matter.glossary.entries)
  }

  // ----------------------------------
  // Coversheet
  // ----------------------------------

  // Show notes before everything else, so you don't miss them
  context {
    // Check wether there are any notes in the document and whether notes-listing is enabled
    if (
      config.drafting.notes-listing
        and (query(selector(<margin-note>).or(<inline-note>)).len() > 0)
    ) {
      set heading(numbering: none, outlined: false)
      note-outline(title: __linguify-content("list-of-notes"))
      pagebreak()
    }
  }

  (config.coversheet.generator)(config)

  pagebreak()

  // ----------------------------------
  // Frontmatter
  // ----------------------------------

  {
    counter(page).update(1)
    set page(numbering: "I")
    set heading(numbering: none)
    // Filter by "frontmatter" and order by order
    let frontmatters = config
      .front-back-matter
      .values()
      .filter(entry => (
        entry.position == "frontmatter"
          and entry.at("enable", default: true)
          and ("generator" in entry.keys())
      ))
      .sorted(key: entry => entry.order, by: (l, r) => l < r)

    for frontmatter in frontmatters {
      let rendered = (frontmatter.generator)(config)
      if rendered != none {
        pagebreak(weak: true)
        rendered
      }
    }
  }

  // ----------------------------------
  // Body
  // ----------------------------------

  {
    // display header
    let body-margin = config.page.margin
    body-margin.top = config.page.margin.top + config.body-header.height
    set page(
      margin: __transform-margin(body-margin),
      header: (config.body-header.generator)(config),
      numbering: "1",
      footer: context align(center, {
        if numbering-show-total {
          numbering(
            "1 / 1",
            counter(page).get().at(0),
            ..counter(page).at(<__content-end>),
          )
        } else {
          numbering("1", counter(page).get().at(0))
        }
      }),
    )
    show heading.where(level: 1): it => {
      pagebreak(weak: true)
      it
    }

    // reset page counter and show content
    counter(page).update(1)

    body
    [#[] <__content-end>]
  }

  // ----------------------------------
  // Backmatter
  // ----------------------------------
  {
    counter(page).update(1)
    set page(numbering: "a")
    set heading(numbering: none)
    // Filter by "backmatter" and order by order
    let backmatters = config
      .front-back-matter
      .values()
      .filter(entry => (
        entry.position == "backmatter"
          and entry.at("enable", default: true)
          and ("generator" in entry.keys())
      ))
      .sorted(key: entry => entry.order, by: (l, r) => l < r)

    for backmatter in backmatters {
      let rendered = (backmatter.generator)(config)
      if rendered != none {
        pagebreak(weak: true)
        rendered
      }
    }
  }

  // display appendix
  if config.appendices.entries.len() > 0 {
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
      __linguify-content("list-of-appendices"),
      numbering: none,
    )

    outline(
      depth: 1,
      indent: auto,
      title: none,
      target: selector(heading).after(<__appendix-start>),
    )

    pagebreak(weak: true)
    [#[] <__appendix-start>]

    for appendix in config.appendices.entries {
      pagebreak(weak: true)
      [#heading(appendix.title) #label(appendix.reference)]

      appendix.text
    }
  }
}
