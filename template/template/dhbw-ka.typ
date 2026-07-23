// LTeX: enabled=false

#import "@preview/linguify:0.5.0": linguify, linguify-raw
#import "base.typ": __signature-line, project
#import "config.typ": *
#import "utils.typ": __linguify-content, styled-table

// Default DHBW Karlsruhe adapter config: sets position/order/enable defaults
// and DHBW-KA-specific defaults (signature city, submission mode) for the
// front/back matter sections owned by this adapter. Content is generated at
// call site by the adapter function body.
#let __dhbw-ka-config = __merge-configs(
  (:),
  configure-statutory-declaration(
    enable: true,
    position: "backmatter",
    order: 80,
    digital-submission: true,
    digital-only: true,
    signature-city: "Karlsruhe",
  ),
  configure-confidentiality-clause(enable: true, position: "backmatter", order: 90),
  configure-dhbw-ka-ai-acknowledgement(position: "backmatter", order: 100),
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
#let dhbw-ka-adapter(
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
  // Submission Information
  let submission-info = [
    #__linguify-content("as-part-of-examination-dhbw")

    *#examination*

    #__linguify-content("in-field-of-study", args: (study: study))

    #context __linguify-content("at-the-institution", args: (
      institution: linguify-raw("dhbw-long"),
      city: linguify-raw("ka"),
    ))
  ]

  // TODO: only for compatibility reasons: Remove with v3.0.0 release
  if type(submission-date) == datetime {
    submission-date = submission-date.display(submission-date-format)
  }

  // Metadata
  let metadata = (
    __linguify-content("submission-date"),
    submission-date,
    __linguify-content("processing-duration"),
    __linguify-content("weeks", args: (count: processing-period-weeks)),
    __linguify-content("matriculation-number")
      + ", "
      + __linguify-content("course"),
    authors
      .map(a => a.matriculation-number + ", " + a.course)
      .join(linebreak()),
    ..if company-name != none and company-city != none {
      (
        __linguify-content("training-company"),
        company-name + linebreak() + company-city,
      )
    },
    ..if company-department != none {
      (__linguify-content("department"), company-department)
    },
    ..if company-supervisor != none {
      (__linguify-content("supervisor-at-training-company"), company-supervisor)
    },
    __linguify-content("supervisor-at-university"),
    university-supervisor,
  )

  if authors == none or type(authors) != array or authors.len() == 0 {
    panic("At least one author has to be specified!")
  }

  // ----------------------------------
  // 1. Construct default config
  // ----------------------------------
  let config = __dhbw-ka-config

  // ----------------------------------
  // 2. Apply provided configs from user's positional args
  // ----------------------------------
  for addition in args.pos() {
    assert.eq(
      type(addition),
      dictionary,
      message: "Only configurations are allowed as positional arguments in dhbw-ka-adapter.",
    )
    config = __merge-config(config, addition)
  }

  // ----------------------------------
  // 3. Generate content into the config dictionary
  // ----------------------------------

  // AI acknowledgement: filter to valid entries; if none remain, the section
  // gets no content and is skipped by the base filter.
  let ai-entries = config
    .front-back-matter
    .ai-acknowledgement
    .at("entries", default: ())
    .filter(ack => ack.tool != none and ack.usage != none)

  let course-year = int(authors.at(0).course.find(regex("\d+")))

  // Statutory declaration
  if config.front-back-matter.statutory-declaration.enable {
    let sd-cfg = config.front-back-matter.statutory-declaration
    config.front-back-matter.statutory-declaration.content = {
      pagebreak(weak: true)

      // TODO: The statutory declaration changed for courses starting in 2024.
      // This complicated edge case for courses from 2023 and earlier can safely
      // be removed by September 2026.
      let statuatory-declaration = if course-year < 24 {
        __linguify-content("statutory-declaration-note-dhbw-old", args: (
          author-count: authors.len(),
          title: args.at("title-long"),
          type: args.at("thesis-type"),
        ))
      } else {
        __linguify-content("statutory-declaration-note-dhbw", args: (
          author-count: authors.len(),
        ))
      }

      let statuatory-declaration-printed = if course-year < 24 {
        __linguify-content("statutory-declaration-note-dhbw-old-printed", args: (
          author-count: authors.len(),
        ))
      } else {
        __linguify-content("statutory-declaration-note-dhbw-printed", args: (
          author-count: authors.len(),
        ))
      }

      align(center, heading(
        __linguify-content("statutory-declaration"),
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
        __linguify-content("statutory-declaration-note-dhbw-ai")
      }

      set grid.cell(align: left, inset: (x: 1em, y: 0.3em))

      for a in authors {
        __signature-line(
          author: a,
          date: submission-date,
          digital: sd-cfg.digital-submission,
          city: sd-cfg.signature-city,
        )
      }
    }
  }

  // Confidentiality clause
  if config.front-back-matter.confidentiality-clause.enable {
    config.front-back-matter.confidentiality-clause.content = {
      pagebreak()
      [#[] <__confidentiality-clause>]
      align(center, heading(
        __linguify-content("confidentiality-agreement"),
        level: 1,
      ))

      __linguify-content("confidentiality-agreement-note-dhbw")
    }
  }

  // AI acknowledgement
  if ai-entries.len() > 0 {
    config.front-back-matter.ai-acknowledgement.content = {
      pagebreak(weak: true)
      align(center, heading(
        __linguify-content("ai-acknowledgement-heading-dhbw"),
        level: 1,
      ))

      let table-cells = ai-entries.fold((), (acc, (tool, usage)) => (
        acc + (tool, usage)
      ))

      align(center, styled-table(
        columns: (auto, 1fr),
        table-content: (
          table.header(
            __linguify-content("tool"),
            __linguify-content("usage-description"),
          ),
          ..table-cells,
        ),
      ))
    }
  }

  // ----------------------------------
  // 4. Pass resulting config down to base
  // ----------------------------------
  show: project.with(
    __logo-left: company-logo,
    __logo-right: image("assets/DHBW-Logo.svg"),
    __authors: authors,
    __submission-info: submission-info,
    __metadata: metadata,
    __confidentiality-clause: config.front-back-matter.confidentiality-clause.enable,
    config,
    ..args.named(),
  )
  body
}
