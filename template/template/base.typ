// LTeX: enabled=false

#import "@preview/glossarium:0.5.10": gls, glspl, make-glossary, print-glossary, register-glossary
#import "@preview/codly:1.3.0": codly, codly-init
#import "@preview/drafting:0.2.2": note-outline, set-margin-note-defaults
#import "@preview/linguify:0.5.0": linguify, linguify-raw, load-ftl-data, set-database
#import "util.typ": _in-outline, _linguify-content
#import "config/lib.typ" as config: merge-config, merge-configs
#import "generators.typ": *
#import "frontbackmatter/general.typ": (
  acknowledgements as _fbm-acknowledgements,
  abstracts as _fbm-abstracts,
  toc as _fbm-toc,
  bibliography as _fbm-bibliography,
  abbreviations as _fbm-abbreviations,
  glossary as _fbm-glossary,
  figure-listings as _fbm-figure-listings,
)
#import "general/layout.typ": document as _general-document
#import "general/metadata.typ": metadata as _general-metadata
#import "general/features.typ": drafting as _general-drafting
#import "general/typography.typ": (
  body as _typography-body,
  headers as _typography-headers,
  captions as _typography-captions,
  code as _typography-code,
  math as _typography-math,
  _default-body-font,
  _default-header-font,
  _default-caption-font,
  _default-code-font,
  _default-math-font,
)
#import "component/appendices.typ": appendices as _component-appendices

/// Default heading numbering pattern.
/// -> str
#let _heading-numbering = "1.1.1"

/// Creates a signature line for statutory declarations.
///
/// Generates a formatted signature block with place, date, and signature fields.
/// When `digital` is true, displays the author's name or signature image;
/// when false, leaves the fields blank for handwritten signatures.
/// -> content
#let _signature-line(
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
    _linguify-content("place-of-signature"),
    _linguify-content("date-of-signature"),
    [],
    grid.cell(_linguify-content("signature"), align: center),
  ))
}

/// Resolve the header or footer config for a given section name.
/// Merges the shared flat `component.header` / `component.footer` with any
/// section-specific override (section-specific wins on key conflicts).
///
/// Returns a dictionary with at least `generator` (function | none) and
/// optional `height` (relative).
/// -> dictionary
#let _resolve-component(config, section-key) = {
  let comp = config.at("component", default: (:))
  // Determine flat fallback key
  let flat-key = if section-key.ends-with("-header") {
    "header"
  } else if section-key.ends-with("-footer") {
    "footer"
  } else {
    none
  }
  let flat = if flat-key != none { comp.at(flat-key, default: (:)) } else { (:) }
  let specific = comp.at(section-key, default: (:))
  merge-configs((:), flat, specific)
}

#let _base-config = merge-configs(
  (:),
  _general-document(margin: 2.5cm),
  _component-appendices(appendices: ()),
  _fbm-acknowledgements(
    text: none,
    position: "frontmatter",
    order: 10,
    generator-function: _acknowledgements-default-generator,
  ),
  _fbm-abstracts(
    abstracts: (),
    position: "frontmatter",
    order: 20,
    generator-function: _abstracts-default-generator,
  ),
  _fbm-toc(
    position: "frontmatter",
    order: 30,
    generator-function: _toc-default-generator,
  ),
  _fbm-bibliography(
    position: "backmatter",
    order: 40,
    generator-function: _bibliography-default-generator,
  ),
  _fbm-abbreviations(
    abbreviations: (),
    print-options: (
      deduplicate-back-references: true,
      minimum-refs: 2,
    ),
    position: "backmatter",
    order: 50,
    generator-function: _abbreviations-default-generator,
  ),
  _fbm-glossary(
    glossary: (),
    print-options: (
      deduplicate-back-references: true,
    ),
    position: "backmatter",
    order: 60,
    generator-function: _glossary-default-generator,
  ),
  _fbm-figure-listings(
    code-listing: true,
    figure-listing: true,
    table-listing: true,
    position: "backmatter",
    order: 70,
    generator-function: _listings-default-generator,
  ),
  _general-metadata(),
  _general-drafting(notes-listing: true),
  _typography-body(
    font: _default-body-font.font,
    size: _default-body-font.size,
    leading: _default-body-font.leading,
    spacing: _default-body-font.spacing,
  ),
  _typography-headers(
    font: _default-header-font.font,
    size: _default-header-font.size,
    level-scaling: 90%,
  ),
  _typography-captions(
    font: _default-caption-font.font,
    size: _default-caption-font.size,
  ),
  _typography-code(
    font: _default-code-font.font,
    size: _default-code-font.size,
  ),
  _typography-math(
    font: _default-math-font.font,
    size: _default-math-font.size,
  ),
  // NOTE: No coversheet, header, or footer defaults here.
  // The active theme is responsible for providing those via component.coversheet,
  // component.body-header, component.body-footer, etc.
)

/// Due to a bug in drafting at least one margin must be of a different size then the others.
/// TODO: Evaluate again with the next drafting release.
/// To fix this we check if all margins are the same and if that is the case we increment margin.top by a tiny bit.
#let _transform-margin(margin) = {
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
/// Pass configurations produced by `theme.*`, `institution.*`,
/// `frontbackmatter.*`, `component.*`, and `general.*` as positional arguments.
/// -> content
#let project(
  ..configs,
  body,
) = {
  // create config dictionary
  let config = _base-config
  for addition in configs.pos() {
    assert.eq(
      type(addition),
      dictionary,
      message: "Only configurations are allowed as positional arguments. See [future link for configuration] for more information.",
    )

    config = merge-config(config, addition)
  }

  // load linguify
  set-database(eval(load-ftl-data("l10n", ("en", "de"))))

  set bibliography(title: _linguify-content("bibliography"))

  // page setup
  set document(title: config.metadata.at("title-long", default: none))

  // set text language (e. g. for smart quotes)
  if "lang" in config.metadata {
    set text(lang: config.metadata.lang)
  }

  // font setup — driven by config.typography.body
  let t-body = config.at("typography", default: (:)).at("body", default: (:))
  let t-headers = config.at("typography", default: (:)).at("headers", default: (:))
  let t-captions = config.at("typography", default: (:)).at("captions", default: (:))
  let t-code = config.at("typography", default: (:)).at("code", default: (:))
  let t-math = config.at("typography", default: (:)).at("math", default: (:))

  set text(
    font: t-body.at("font", default: "New Computer Modern"),
    size: t-body.at("size", default: 12pt),
  )

  set page(
    paper: "a4",
    margin: _transform-margin(config.page.margin),
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
  set par(
    justify: true,
    leading: t-body.at("leading", default: 1.05em),
    spacing: t-body.at("spacing", default: 1.5em),
  )

  // tables settings
  show table: set par(justify: false)

  // heading setup — font driven by config.typography.headers
  let header-font = t-headers.at("font", default: t-body.at("font", default: "New Computer Modern"))
  let h1-size = t-headers.at("size", default: 1em)
  let level-scaling = t-headers.at("level-scaling", default: 90%)
  let h2-size = h1-size * (level-scaling / 100%)
  let h3-size = h2-size * (level-scaling / 100%)

  set heading(numbering: _heading-numbering)

  show heading.where(level: 1): set text(font: header-font, size: h1-size)
  show heading.where(level: 2): set text(font: header-font, size: h2-size)
  show heading.where(level: 3): set text(font: header-font, size: h3-size)
  show heading.where(level: 4): set text(font: header-font)

  show heading: it => {
    it
    v(0.5cm)
  }

  show heading.where(level: 2): it => {
    v(weak: true, 1.2cm)
    it
  }

  // fancy inline code — font driven by config.typography.code
  // if you don't like them, just remove this section.
  let code-font = t-code.at("font", default: none)
  let code-size = t-code.at("size", default: 0.9em)
  show raw: set text(
    font: if code-font != none { code-font } else { () },
    size: code-size,
  )
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
    _in-outline.update(true)
    it
    _in-outline.update(false)
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

  // caption typography — driven by config.typography.captions
  let caption-font = t-captions.at("font", default: none)
  let caption-size = t-captions.at("size", default: 1em)
  show figure.caption: set text(
    font: if caption-font != none { caption-font } else { () },
    size: caption-size,
  )

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
  // math font — driven by config.typography.math
  // Note: Typst math font selection is limited; this primarily controls text inside math.
  let math-font = t-math.at("font", default: none)
  if math-font != none {
    show math.equation: set text(font: math-font)
  }

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
      config.drafting.notes-listing and (query(selector(<margin-note>).or(<inline-note>)).len() > 0)
    ) {
      set heading(numbering: none, outlined: false)
      note-outline(title: _linguify-content("list-of-notes"))
      pagebreak()
    }
  }

  let coversheet-cfg = _resolve-component(config, "coversheet")
  let coversheet-generator = coversheet-cfg.at("generator", default: none)
  if coversheet-generator != none {
    (coversheet-generator)(config)
    pagebreak()
  }

  // ----------------------------------
  // Frontmatter
  // ----------------------------------

  {
    counter(page).update(1)
    let fm-header-cfg = _resolve-component(config, "frontmatter-header")
    let fm-footer-cfg = _resolve-component(config, "frontmatter-footer")
    let fm-header-height = fm-header-cfg.at("height", default: 0cm)
    let fm-header-gen = fm-header-cfg.at("generator", default: none)
    let fm-footer-gen = fm-footer-cfg.at("generator", default: none)
    let fm-margin = config.page.margin
    if fm-header-gen != none and fm-header-height != 0cm {
      fm-margin.top = fm-margin.top + fm-header-height
    }
    set page(
      numbering: "I",
      margin: _transform-margin(fm-margin),
      header: if fm-header-gen != none { (fm-header-gen)(config) } else { none },
      footer: if fm-footer-gen != none { (fm-footer-gen)(config) } else { none },
    )
    set heading(numbering: none)
    // Filter by "frontmatter" and order by order
    let frontmatters = config
      .front-back-matter
      .values()
      .filter(entry => (
        "position" in entry.keys() and entry.position == "frontmatter" and entry.at("enable", default: true) and ("generator" in entry.keys())
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
    let body-header-cfg = _resolve-component(config, "body-header")
    let body-footer-cfg = _resolve-component(config, "body-footer")
    let body-header-height = body-header-cfg.at("height", default: 0cm)
    let body-header-gen = body-header-cfg.at("generator", default: none)
    let body-footer-gen = body-footer-cfg.at("generator", default: none)
    let body-margin = config.page.margin
    if body-header-gen != none {
      body-margin.top = body-margin.top + body-header-height
    }
    set page(
      margin: _transform-margin(body-margin),
      header: if body-header-gen != none { (body-header-gen)(config) } else { none },
      numbering: "1",
      footer: if body-footer-gen != none { (body-footer-gen)(config) } else { none },
    )
    show heading.where(level: 1): it => {
      pagebreak(weak: true)
      it
    }

    // reset page counter and show content
    counter(page).update(1)

    body
    [#[] <_content-end>]
  }

  // ----------------------------------
  // Backmatter
  // ----------------------------------
  {
    counter(page).update(1)
    let bm-header-cfg = _resolve-component(config, "backmatter-header")
    let bm-footer-cfg = _resolve-component(config, "backmatter-footer")
    let bm-header-height = bm-header-cfg.at("height", default: 0cm)
    let bm-header-gen = bm-header-cfg.at("generator", default: none)
    let bm-footer-gen = bm-footer-cfg.at("generator", default: none)
    let bm-margin = config.page.margin
    if bm-header-gen != none and bm-header-height != 0cm {
      bm-margin.top = bm-margin.top + bm-header-height
    }
    set page(
      numbering: "a",
      margin: _transform-margin(bm-margin),
      header: if bm-header-gen != none { (bm-header-gen)(config) } else { none },
      footer: if bm-footer-gen != none { (bm-footer-gen)(config) } else { none },
    )
    set heading(numbering: none)
    // Filter by "backmatter" and order by order
    let backmatters = config
      .front-back-matter
      .values()
      .filter(entry => (
        "position" in entry.keys() and entry.position == "backmatter" and entry.at("enable", default: true) and ("generator" in entry.keys())
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
    let app-header-cfg = _resolve-component(config, "appendix-header")
    let app-footer-cfg = _resolve-component(config, "appendix-footer")
    let app-header-gen = app-header-cfg.at("generator", default: none)
    let app-footer-gen = app-footer-cfg.at("generator", default: none)
    set heading(
      outlined: true,
      numbering: (..nums) => {
        "Appendix "
        numbering("1.1", ..nums)
      },
      supplement: none,
    )
    set page(
      numbering: "A",
      footer: if app-footer-gen != none { (app-footer-gen)(config) } else { none },
      header: if app-header-gen != none { (app-header-gen)(config) } else { none },
    )
    counter(page).update(1)
    counter(heading).update(0)

    let app-toc-cfg = config.at("component", default: (:)).at("appendix-toc", default: (:))
    let app-toc-gen = app-toc-cfg.at("generator", default: none)
    if app-toc-gen != none {
      (app-toc-gen)(config)
    } else {
      // Default appendix TOC
      heading(
        _linguify-content("list-of-appendices"),
        numbering: none,
      )
      outline(
        depth: 1,
        indent: auto,
        title: none,
        target: selector(heading).after(<_appendix-start>),
      )
    }

    pagebreak(weak: true)
    [#[] <_appendix-start>]

    for appendix in config.appendices.entries {
      pagebreak(weak: true)
      [#heading(appendix.title) #label(appendix.reference)]

      appendix.text
    }
  }
}
