// LTeX: enabled=false

#import "@preview/linguify:0.5.0": linguify, linguify-raw
#import "../base.typ": _signature-line
#import "../config/lib.typ" as config
#import "../frontbackmatter/_shared.typ": configure-statutory-declaration, configure-confidentiality-clause
#import "config.typ": configure-dhbw-ka-ai-acknowledgement
#import "../util.typ": styled-table
#import "../general/metadata.typ": metadata as _general-metadata

/// Default DHBW Karlsruhe config: sets position/order/enable defaults
/// and DHBW-KA-specific defaults for the front/back matter sections.
#let _dhbw-ka-defaults() = {
  merge-configs(
    (:),
    configure-statutory-declaration(
      enable: true,
      position: "backmatter",
      order: 80,
      digital-submission: true,
      digital-only: true,
      signature-city: "Karlsruhe",
    ),
    configure-confidentiality-clause(
      enable: true,
      position: "backmatter",
      order: 90,
    ),
    configure-dhbw-ka-ai-acknowledgement(position: "backmatter", order: 100),
  )
}

/// Pure config producer for DHBW Karlsruhe thesis documents.
///
/// Returns a configuration dictionary that can be passed to `project()`.
/// Metadata, section defaults, and institution-specific generators are
/// configured here.
///
/// Positional `configure-*` / `frontbackmatter.*` overrides may be appended
/// after this call in `#show: project.with(...)` to further customise the document.
/// -> dictionary
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
  /// `lastname`, `matriculation-number`, `course`, and optionally `signature`. -> array
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
  /// Format string for displaying the submission date. -> str
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
) = {
  if authors == none or type(authors) != array or authors.len() == 0 {
    panic("At least one author has to be specified!")
  }

  // TODO: only for compatibility: Remove with v3.0.0 release
  if type(submission-date) == datetime {
    submission-date = submission-date.display(submission-date-format)
  }

  // ----------------------------------
  // Build metadata
  // ----------------------------------
  let submission-info = [
    #config.util.linguify-content("as-part-of-examination-dhbw")

    *#examination*

    #config.util.linguify-content("in-field-of-study", args: (study: study))

    #context config.util.linguify-content("at-the-institution", args: (
      institution: linguify-raw("dhbw-long"),
      city: linguify-raw("ka"),
    ))
  ]

  let misc-key-value = (
    config.util.linguify-content("submission-date"),
    submission-date,
    config.util.linguify-content("processing-duration"),
    config.util.linguify-content("weeks", args: (count: processing-period-weeks)),
    config.util.linguify-content("matriculation-number")
      + ", "
      + config.util.linguify-content("course"),
    authors
      .map(a => a.matriculation-number + ", " + a.course)
      .join(linebreak()),
    ..if company-name != none and company-city != none {
      (
        config.util.linguify-content("training-company"),
        company-name + linebreak() + company-city,
      )
    },
    ..if company-department != none {
      (config.util.linguify-content("department"), company-department)
    },
    ..if company-supervisor != none {
      (config.util.linguify-content("supervisor-at-training-company"), company-supervisor)
    },
    config.util.linguify-content("supervisor-at-university"),
    university-supervisor,
  )

  // ----------------------------------
  // Build config
  // ----------------------------------
  let cfg = _dhbw-ka-defaults()

  cfg = merge-config(cfg, _general-metadata(metadata: (
    lang: lang,
    title-long: title-long,
    title-short: title-short,
    thesis-type: thesis-type,
    logo-left: company-logo,
    logo-right: image("../assets/DHBW-Logo.svg"),
    submission-info: submission-info,
    misc-key-value: misc-key-value,
    authors: authors,
  )))

  // ----------------------------------
  // Install section generators
  // ----------------------------------
  let course-year = int(authors.at(0).course.find(regex("\d+")))

  // Statutory declaration generator
  let statutory-declaration-generator(config) = {
    let sd-cfg = config.front-back-matter.statutory-declaration
    let ai-entries = config
      .front-back-matter
      .ai-acknowledgement
      .at("entries", default: ())
      .filter(ack => ack.tool != none and ack.usage != none)

    pagebreak(weak: true)

    let statuatory-declaration = if course-year < 24 {
      config.util.linguify-content("statutory-declaration-note-dhbw-old", args: (
        author-count: authors.len(),
        title: title-long,
        type: thesis-type,
      ))
    } else {
      config.util.linguify-content("statutory-declaration-note-dhbw", args: (
        author-count: authors.len(),
      ))
    }

    let statuatory-declaration-printed = if course-year < 24 {
      config.util.linguify-content(
        "statutory-declaration-note-dhbw-old-printed",
        args: (
          author-count: authors.len(),
        ),
      )
    } else {
      config.util.linguify-content("statutory-declaration-note-dhbw-printed", args: (
        author-count: authors.len(),
      ))
    }

    align(center, heading(
      config.util.linguify-content("statutory-declaration"),
      level: 1,
    ))

    statuatory-declaration
    if not sd-cfg.digital-only {
      " " + statuatory-declaration-printed
    }

    if course-year >= 24 and ai-entries.len() > 0 {
      linebreak()
      config.util.linguify-content("statutory-declaration-note-dhbw-ai")
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
      config.util.linguify-content("confidentiality-agreement"),
      level: 1,
    ))

    config.util.linguify-content("confidentiality-agreement-note-dhbw")
  }

  // AI acknowledgement generator
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
      config.util.linguify-content("ai-acknowledgement-heading-dhbw"),
      level: 1,
    ))

    let table-cells = ai-entries.fold((), (acc, (tool, usage)) => (
      acc + (tool, usage)
    ))

    align(center, styled-table(
      columns: (auto, 1fr),
      table-content: (
        table.header(
          config.util.linguify-content("tool"),
          config.util.linguify-content("usage-description"),
        ),
        ..table-cells,
      ),
    ))
  }

  cfg = merge-configs(
    cfg,
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

  cfg
}
