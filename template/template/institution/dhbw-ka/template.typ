// LTeX: enabled=false

#import "@preview/linguify:0.5.0": linguify, linguify-raw
#import "../_shared.typ": (
  _course-year, _require-authors, _signature-line, _submission-date,
)
#import "../../config/lib.typ" as config
#let merge-config = config.util.merge-config
#let merge-configs = config.util.merge-configs
#import "frontbackmatter.typ": (
  ai-declaration, confidentiality-clause, statutory-declaration,
)
#let configure-statutory-declaration = statutory-declaration
#let configure-confidentiality-clause = confidentiality-clause
#let configure-dhbw-ka-ai-acknowledgement = ai-declaration
#import "../../util.typ": styled-table
#let linguify-content = config.util.linguify-content
#import "../../general/lib.typ" as general
#let _general-metadata = general.metadata

/// Default DHBW Karlsruhe config: sets position/enable defaults
/// and DHBW-KA-specific defaults for the front/back matter sections.
#let _dhbw-ka-defaults() = {
  merge-configs(
    (:),
    configure-statutory-declaration(
      enable: true,
      position: 80,
      digital-submission: true,
      digital-only: true,
      signature-city: "Karlsruhe",
    ),
    configure-confidentiality-clause(
      enable: true,
      position: 90,
    ),
    configure-dhbw-ka-ai-acknowledgement(position: 100, entries: ()),
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
#let setup(
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
  // ----------------------------------
  // Build config
  // ----------------------------------
  let cfg = _dhbw-ka-defaults()

  cfg = merge-config(cfg, _general-metadata(
    lang: lang,
    title-long: title-long,
    title-short: title-short,
    thesis-type: thesis-type,
    logo-left: company-logo,
    logo-right: image("../assets/DHBW-Logo.svg"),
    institution: "dhbw-ka",
    examination: examination,
    study: study,
    submission-date: submission-date,
    submission-date-format: submission-date-format,
    processing-period-weeks: processing-period-weeks,
    university-supervisor: university-supervisor,
    company-name: company-name,
    company-city: company-city,
    company-department: company-department,
    company-supervisor: company-supervisor,
    authors: authors,
  ))

  // ----------------------------------
  // Install section generators
  // ----------------------------------

  // Statutory declaration generator
  let statutory-declaration-generator(config) = {
    let metadata = config.general.metadata
    let authors = _require-authors(metadata, "Statutory declaration")
    let course-year = _course-year(authors)
    let title-long = metadata.at("title-long", default: none)
    let thesis-type = metadata.at("thesis-type", default: none)
    let submission-date = _submission-date(metadata)
    let sd-cfg = config.front-back-matter.statutory-declaration
    let ai-entries = config
      .front-back-matter
      .ai-acknowledgement
      .at("entries", default: ())
      .filter(ack => ack.tool != none and ack.usage != none)

    pagebreak(weak: true)

    let statuatory-declaration = if course-year < 24 {
      linguify-content("statutory-declaration-note-dhbw-old", args: (
        author-count: authors.len(),
        title: title-long,
        type: thesis-type,
      ))
    } else {
      linguify-content("statutory-declaration-note-dhbw", args: (
        author-count: authors.len(),
      ))
    }

    let statuatory-declaration-printed = if course-year < 24 {
      linguify-content(
        "statutory-declaration-note-dhbw-old-printed",
        args: (
          author-count: authors.len(),
        ),
      )
    } else {
      linguify-content("statutory-declaration-note-dhbw-printed", args: (
        author-count: authors.len(),
      ))
    }

    align(center, heading(
      linguify-content("statutory-declaration"),
      level: 1,
    ))

    statuatory-declaration
    if not sd-cfg.digital-only {
      " " + statuatory-declaration-printed
    }

    if course-year >= 24 and ai-entries.len() > 0 {
      linebreak()
      linguify-content("statutory-declaration-note-dhbw-ai")
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
      linguify-content("confidentiality-agreement"),
      level: 1,
    ))

    linguify-content("confidentiality-agreement-note-dhbw")
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
      linguify-content("ai-acknowledgement-heading-dhbw"),
      level: 1,
    ))

    let table-cells = ai-entries.fold((), (acc, entry) => (
      acc + (entry.tool, entry.usage)
    ))

    align(center, styled-table(
      columns: (auto, 1fr),
      table-content: (
        table.header(
          linguify-content("tool"),
          linguify-content("usage-description"),
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
