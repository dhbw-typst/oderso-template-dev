// LTeX: enabled=false

#import "@preview/linguify:0.5.0": linguify, linguify-raw
#import "../base.typ": _signature-line, project
#import "../config/lib.typ" as config
#import "config.typ": *
#import "../util.typ": _linguify-content, styled-table

/// Default DHBW Karlsruhe adapter config: sets position/order/enable defaults
/// and DHBW-KA-specific defaults (signature city, submission mode) for the
/// front/back matter sections owned by this adapter. Content is generated at
/// call site by the adapter function body.
#let _dhbw-ka-config = config.util.merge-configs(
  (:),
  frontbackmatter.dhbw-ka.statutory-declaration(
    enable: true,
    order: 80,
    digital-only: true,
    signature-city: "Karlsruhe",
  ),
  frontbackmatter.dhbw-ka.confidentiality-clause(
    enable: true,
    position: "backmatter",
    order: 90,
  )
  frontbackmatter.dhbw-ka(position: "backmatter", order: 100),
)

/// Template adapter for DHBW Karlsruhe thesis documents.
///
/// This function configures the base `project` template with DHBW Karlsruhe-specific
/// settings, including statutory declarations, confidentiality clauses,
/// and AI tool acknowledgements according to DHBW guidelines.
///
/// Section-specific settings (submission mode, signature city, enable flags)
/// live in `configure-statutory-declaration(...)`,
/// `configure-confidentiality-clause(enable: ...)`, and
/// `configure-dhbw-ka-ai-acknowledgement(entries: ...)`.
/// -> content
#let dhbw-ka(
  /// The primary language of the document. Affects hyphenation, quotes,
  /// and localized strings. Supported: `"en"`, `"de"`. -> str
  lang: "en",
  /// Full thesis title displayed on the cover page. -> str | none
  title-long: none,
  /// Shortened title displayed in the page header. -> str | none
  title-short: none,
  /// Type of thesis (e.g., "Projektarbeit 1", "Bachelorarbeit").
  /// Displayed below the title on the cover. -> str | none
  thesis-type: none,
  /// The examination degree, e.g., "Bachelor of Science (B.Sc.)". -> str
  examination: "Bachelor of Science (B.Sc.)",
  /// The field of study, e.g., "Computer Science". -> str
  study: "Computer Science",
  /// List of author dictionaries. Each author should have: `firstname`,
  /// `lastname`, `matriculation-number`, `course`, and optionally `signature`
  /// (an image or text for digital signatures). -> array
  authors: (
    (
      firstname: none,
      lastname: none,
      matriculation-number: none,
      course: none,
      signature: none,
    ),
  ),
  /// Submission date of the thesis. -> str
  submission-date: datetime.today().display("[day].[month].[year]"),
  /// Format string for displaying the submission date. (see #link("https://typst.app/docs/reference/foundations/datetime/#format")[datetime formats]) -> str
  submission-date-format: "[day].[month].[year]",
  /// Duration of the thesis processing period in weeks. -> int | none
  processing-period-weeks: none,
  /// Name of the university supervisor. -> str | none
  university-supervisor: none,
  /// Name of the training company. -> str | none
  company-name: "Corp SE",
  /// City where the company is located. -> str | none
  company-city: "Berlin",
  /// Company logo image. -> content | none
  company-logo: none,
  /// Department within the company. -> str | none
  company-department: none,
  /// Name of the company supervisor. -> str | none
  company-supervisor: none,
  /// Additional arguments passed to the base template plus positional
  /// `configure-*` configurations.
  ..args,
  /// The main document body content. -> content
  body,
) = {
  // ----------------------------------
  // Construct default config
  // ----------------------------------
  let config = _dhbw-ka-config

  // ----------------------------------
  // Fill metadata config
  // ----------------------------------
  // Submission information (for coversheet)
  let submission-info = [
    #_linguify-content("as-part-of-examination-dhbw")

    *#examination*

    #_linguify-content("in-field-of-study", args: (study: study))

    #context _linguify-content("at-the-institution", args: (
      institution: linguify-raw("dhbw-long"),
      city: linguify-raw("ka"),
    ))
  ]

  // Misc data (for coversheet)
  let misc-key-value = (
    _linguify-content("submission-date"),
    submission-date,
    _linguify-content("processing-duration"),
    _linguify-content("weeks", args: (count: processing-period-weeks)),
    _linguify-content("matriculation-number")
      + ", "
      + _linguify-content("course"),
    authors
      .map(a => a.matriculation-number + ", " + a.course)
      .join(linebreak()),
    ..if company-name != none and company-city != none {
      (
        _linguify-content("training-company"),
        company-name + linebreak() + company-city,
      )
    },
    ..if company-department != none {
      (_linguify-content("department"), company-department)
    },
    ..if company-supervisor != none {
      (_linguify-content("supervisor-at-training-company"), company-supervisor)
    },
    _linguify-content("supervisor-at-university"),
    university-supervisor,
  )

  if authors == none or type(authors) != array or authors.len() == 0 {
    panic("At least one author has to be specified!")
  }

  config = merge-configs(config, configure-metadata(
    metadata: (
      lang: lang,
      title-long: title-long,
      title-short: title-short,
      thesis-type: thesis-type,
      logo-left: company-logo,
      logo-right: image("../assets/DHBW-Logo.svg"),
      submission-info: submission-info,
      misc-key-value: misc-key-value,
      authors: authors,
    ),
  ))

  // ----------------------------------
  // Install section generators
  // ----------------------------------
  // Generators are installed BEFORE user positional args so that user calls
  // (e.g. `configure-dhbw-ka-ai-acknowledgement(entries: (...))`) can override
  // section data without clobbering the adapter's generator. If a user wants
  // to replace a generator, they can pass `generator-function: ...` in their
  // own positional configuration call.

  let course-year = int(authors.at(0).course.find(regex("\d+")))

  // Statutory declaration generator: reads configured flags and (for course
  // year >= 24) the AI acknowledgement entries from the final config so user
  // overrides applied after the adapter (e.g. custom AI entries) are honored.
  let statutory-declaration-generator(config) = {
    let sd-cfg = config.front-back-matter.statutory-declaration
    let ai-entries = config
      .front-back-matter
      .ai-acknowledgement
      .at("entries", default: ())
      .filter(ack => ack.tool != none and ack.usage != none)

    pagebreak(weak: true)

    // TODO: The statutory declaration changed for courses starting in 2024.
    // This complicated edge case for courses from 2023 and earlier can safely
    // be removed by September 2026.
    let statuatory-declaration = if course-year < 24 {
      _linguify-content("statutory-declaration-note-dhbw-old", args: (
        author-count: authors.len(),
        title: title-long,
        type: thesis-type,
      ))
    } else {
      _linguify-content("statutory-declaration-note-dhbw", args: (
        author-count: authors.len(),
      ))
    }

    let statuatory-declaration-printed = if course-year < 24 {
      _linguify-content(
        "statutory-declaration-note-dhbw-old-printed",
        args: (
          author-count: authors.len(),
        ),
      )
    } else {
      _linguify-content("statutory-declaration-note-dhbw-printed", args: (
        author-count: authors.len(),
      ))
    }

    align(center, heading(
      _linguify-content("statutory-declaration"),
      level: 1,
    ))

    statuatory-declaration
    if not sd-cfg.digital-only {
      " " + statuatory-declaration-printed
    }

    // TODO: Just like above, this check for course-year >= 24 can be removed
    // after September 2026 as all courses will use that statutory declaration.
    if course-year >= 24 and ai-entries.len() > 0 {
      linebreak()
      _linguify-content("statutory-declaration-note-dhbw-ai")
    }

    set grid.cell(align: left, inset: (x: 1em, y: 0.3em))

    for a in authors {
      _signature-line(
        author: a,
        date: submission-date,
        digital: sd-cfg.digital-submission,
        city: sd-cfg.signature-city,
      )
    }
  }

  // Confidentiality clause generator
  let confidentiality-clause-generator(config) = {
    pagebreak()
    [#[] <_confidentiality-clause>]
    align(center, heading(
      _linguify-content("confidentiality-agreement"),
      level: 1,
    ))

    _linguify-content("confidentiality-agreement-note-dhbw")
  }

  // AI acknowledgement generator: filters entries at render time so that
  // user overrides applied after the adapter are honored. Returns `none` when
  // no valid entries remain, letting the front-/back-matter loop skip the
  // section entirely.
  let ai-acknowledgement-generator(config) = {
    let ai-entries = config
      .front-back-matter
      .ai-acknowledgement
      .at("entries", default: ())
      .filter(ack => ack.tool != none and ack.usage != none)
    if ai-entries.len() == 0 {
      return none
    }

    pagebreak(weak: true)
    align(center, heading(
      _linguify-content("ai-acknowledgement-heading-dhbw"),
      level: 1,
    ))

    let table-cells = ai-entries.fold((), (acc, (tool, usage)) => (
      acc + (tool, usage)
    ))

    align(center, styled-table(
      columns: (auto, 1fr),
      table-content: (
        table.header(
          _linguify-content("tool"),
          _linguify-content("usage-description"),
        ),
        ..table-cells,
      ),
    ))
  }

  config = merge-configs(
    config,
    configure-statutory-declaration(
      generator-function: statutory-declaration-generator,
    ),
    configure-confidentiality-clause(
      generator-function: confidentiality-clause-generator,
    ),
    configure-dhbw-ka-ai-acknowledgement(
      generator-function: ai-acknowledgement-generator,
    ),
  )

  // ----------------------------------
  // Apply provided configs from user's positional args
  // ----------------------------------
  for addition in args.pos() {
    assert.eq(
      type(addition),
      dictionary,
      message: "Only configurations are allowed as positional arguments in dhbw-ka-adapter.",
    )
    config = merge-config(config, addition)
  }

  show: project.with(
    config,
  )
  body
}
