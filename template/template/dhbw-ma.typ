// LTeX: enabled=false

#import "@preview/linguify:0.5.0": linguify, linguify-raw
#import "base.typ": __signature-line, project
#import "config.typ": *
#import "assets/ai-declaration-form_dhbw-ma.typ": ai-declaration-form
#import "utils.typ": __linguify-content

// Default DHBW Mannheim adapter config: sets position/order/enable defaults
// and DHBW-MA-specific defaults (signature city, submission mode) for the
// front/back matter sections owned by this adapter. Content is generated at
// call site by the adapter function body.
#let __dhbw-ma-config = __merge-configs(
  (:),
  configure-statutory-declaration(
    enable: true,
    position: "backmatter",
    order: 80,
    digital-submission: true,
    digital-only: true,
    signature-city: "Mannheim",
  ),
  configure-confidentiality-clause(enable: true, position: "backmatter", order: 90),
  configure-dhbw-ma-ai-declaration-form(position: "backmatter", order: 100),
)

/// Template adapter for DHBW Mannheim thesis documents.
///
/// This function configures the base `project` template with DHBW Mannheim-specific
/// settings, including statutory declarations, confidentiality clauses,
/// and the official AI declaration form.
///
/// Section-specific settings (submission mode, signature city, enable flags)
/// live in `configure-statutory-declaration(...)`,
/// `configure-confidentiality-clause(enable: ...)`, and
/// `configure-dhbw-ma-ai-declaration-form(...)`.
/// -> content
#let dhbw-ma-adapter(
  /// The examination degree, e.g., "Bachelor of Science (B.Sc.)". -> str
  examination: "Bachelor of Science (B.Sc.)",
  /// The field of study, e.g., "Computer Science". -> str
  study: "Computer Science",
  /// List of author dictionaries. Each author should have: `firstname`,
  /// `lastname`, `matriculation-number`, `course`, `signature` (optional),
  /// `email`, `address`, and `phone-number`. AI declaration data per author
  /// is passed separately via `configure-dhbw-ma-ai-declaration-form(authors: ...)`. -> array
  authors: (
    (
      firstname: none,
      lastname: none,
      matriculation-number: none,
      course: none,
      signature: none,
      email: none,
      address: none,
      phone-number: none,
    ),
  ),
  /// Submission date of the thesis. -> str
  submission-date: datetime.today().display("[day].[month].[year]"),
  /// Format string for displaying dates. (see #link("https://typst.app/docs/reference/foundations/datetime/#format")[datetime formats]) -> str
  submission-date-format: "[day].[month].[year]",
  /// Duration of the thesis processing period in weeks. -> int | none
  processing-period-weeks: none,
  /// University supervisor dictionary with `firstname`, `lastname`,
  /// `email`, and `phone-number`. -> dictionary
  university-supervisor: (
    firstname: none,
    lastname: none,
    email: none,
    phone-number: none,
  ),
  /// Name of the training company. -> str | none
  company-name: "Corp SE",
  /// City where the company is located. -> str | none
  company-city: "Berlin",
  /// Company logo image. -> content | none
  company-logo: none,
  /// Department within the company. -> str | none
  company-department: none,
  /// Company supervisor dictionary with `firstname`, `lastname`,
  /// `email`, and `phone-number`. -> dictionary
  company-supervisor: (
    firstname: none,
    lastname: none,
    email: none,
    phone-number: none,
  ),
  /// Name of the course director. -> str | none
  course-director: none,
  /// Additional arguments passed to the base template plus positional
  /// `configure-*` configurations.
  ..args,
  /// The main document body content. -> content
  body,
) = {
  let submission-info = [
    #__linguify-content("as-part-of-examination-dhbw")

    *#examination*

    #__linguify-content("in-field-of-study", args: (study: study))

    #context __linguify-content("at-the-institution", args: (
      institution: linguify-raw("dhbw-long"),
      city: linguify-raw("ma"),
    ))
  ]

  // TODO: only for compatibility reasons: Remove with v3.0.0 release
  if type(submission-date) == datetime {
    submission-date = submission-date.display(submission-date-format)
  }

  let company-supervisor-data = [
    #company-supervisor.firstname #company-supervisor.lastname#if (
      company-supervisor.phone-number != none
    ) {
      ", " + company-supervisor.phone-number
    }
    #if (company-supervisor.email != none) {
      linebreak()
      company-supervisor.email
    }
  ]

  let university-supervisor-data = [
    #university-supervisor.firstname #university-supervisor.lastname#if (
      university-supervisor.phone-number != none
    ) {
      ", " + university-supervisor.phone-number
    }
    #if (university-supervisor.email != none) {
      linebreak()
      university-supervisor.email
    }
  ]

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
    ..if company-supervisor.firstname != none
      or company-supervisor.lastname != none {
      (
        __linguify-content("supervisor-at-training-company"),
        company-supervisor-data,
      )
    },
    ..if course-director != none {
      (__linguify-content("course-director"), course-director)
    },
    __linguify-content("supervisor-at-university"),
    university-supervisor-data,
  )

  if authors == none or type(authors) != array or authors.len() == 0 {
    panic("At least one author has to be specified!")
  }

  // ----------------------------------
  // 1. Construct default config
  // ----------------------------------
  let config = __dhbw-ma-config

  // ----------------------------------
  // 2. Apply provided configs from user's positional args
  // ----------------------------------
  for addition in args.pos() {
    assert.eq(
      type(addition),
      dictionary,
      message: "Only configurations are allowed as positional arguments in dhbw-ma-adapter.",
    )
    config = __merge-config(config, addition)
  }

  // ----------------------------------
  // 3. Generate content into the config dictionary
  // ----------------------------------

  // Statutory declaration
  if config.front-back-matter.statutory-declaration.enable {
    let sd-cfg = config.front-back-matter.statutory-declaration
    let course-year = int(authors.at(0).course.find(regex("\d+")))
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
      pagebreak(weak: true)
      [#[] <__confidentiality-clause>]
      align(center, heading(
        __linguify-content("confidentiality-agreement"),
        level: 1,
      ))

      __linguify-content("confidentiality-agreement-note-dhbw")
    }
  }

  // AI declaration form
  let ai-cfg = config.front-back-matter.ai-declaration-form
  let ai-authors = ai-cfg.at("authors", default: ())
  if ai-authors.len() > 0 {
    let sd-cfg = config.front-back-matter.statutory-declaration
    // TODO: only for compatibility reasons: Remove with v3.0.0 release
    let module-submission-date = ai-cfg.at("module-submission-date", default: none)
    if type(module-submission-date) == datetime {
      module-submission-date = module-submission-date.display(submission-date-format)
    }
    config.front-back-matter.ai-declaration-form.content = {
      for (i, a) in authors.enumerate() {
        let ai-author = ai-authors.at(i, default: (:))
        ai-declaration-form(
          digital: sd-cfg.digital-only,
          name: a.lastname + ", " + a.firstname,
          identification-number: a.matriculation-number,
          address: a.address,
          course: a.course,
          email: a.email,
          mobile-number: a.phone-number,
          module-name: ai-cfg.at("module-name", default: none),
          semester: ai-cfg.at("semester", default: none),
          module-submission-date: module-submission-date,
          exam-type: ai-cfg.at("exam-type", default: none),
          product-name: ai-author.at("product-name", default: none),
          topic: ai-author.at("topic", default: none),
          topic-editing: ai-author.at("topic-editing", default: none),
          research: ai-author.at("research", default: none),
          design: ai-author.at("design", default: none),
          signature-city: sd-cfg.signature-city,
          signature-date: submission-date,
          signature-image: a.signature,
        )
      }
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
