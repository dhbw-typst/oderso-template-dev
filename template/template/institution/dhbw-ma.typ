// LTeX: enabled=false

#import "@preview/linguify:0.5.0": linguify, linguify-raw
#import "../base.typ": _signature-line
#import "../config/lib.typ" as config: merge-config, merge-configs
#import "../frontbackmatter/_shared.typ": configure-statutory-declaration, configure-confidentiality-clause
#import "config.typ": configure-dhbw-ma-ai-declaration-form
#import "../assets/ai-declaration-form_dhbw-ma.typ": ai-declaration-form
#import "../util.typ": _linguify-content
#import "../general/metadata.typ": metadata as _general-metadata

/// Default DHBW Mannheim config: sets position/order/enable defaults
/// and DHBW-MA-specific defaults for the front/back matter sections.
#let _dhbw-ma-defaults() = {
  merge-configs(
    (:),
    configure-statutory-declaration(
      enable: true,
      position: "backmatter",
      order: 80,
      digital-submission: true,
      digital-only: true,
      signature-city: "Mannheim",
    ),
    configure-confidentiality-clause(
      enable: true,
      position: "backmatter",
      order: 90,
    ),
    configure-dhbw-ma-ai-declaration-form(position: "backmatter", order: 100),
  )
}

/// Pure config producer for DHBW Mannheim thesis documents.
///
/// Returns a configuration dictionary that can be passed to `project()`.
/// -> dictionary
#let dhbw-ma(
  /// The examination degree, e.g., "Bachelor of Science (B.Sc.)". -> str
  examination: "Bachelor of Science (B.Sc.)",
  /// The field of study, e.g., "Computer Science". -> str
  study: "Computer Science",
  /// List of author dictionaries. -> array
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
  /// Format string for displaying dates. -> str
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
  /// Full thesis title displayed on the cover. -> str | none
  title-long: none,
  /// Shortened title for the header. -> str | none
  title-short: none,
  /// Type of thesis. -> str | none
  thesis-type: none,
  /// Language of the document. -> str
  lang: "en",
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
    #_linguify-content("as-part-of-examination-dhbw")

    *#examination*

    #_linguify-content("in-field-of-study", args: (study: study))

    #context _linguify-content("at-the-institution", args: (
      institution: linguify-raw("dhbw-long"),
      city: linguify-raw("ma"),
    ))
  ]

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
    ..if company-supervisor.firstname != none
      or company-supervisor.lastname != none {
      (
        _linguify-content("supervisor-at-training-company"),
        company-supervisor-data,
      )
    },
    ..if course-director != none {
      (_linguify-content("course-director"), course-director)
    },
    _linguify-content("supervisor-at-university"),
    university-supervisor-data,
  )

  // ----------------------------------
  // Build config
  // ----------------------------------
  let cfg = _dhbw-ma-defaults()

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
    pagebreak(weak: true)

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
    pagebreak(weak: true)
    [#[] <_confidentiality-clause>]
    align(center, heading(
      _linguify-content("confidentiality-agreement"),
      level: 1,
    ))

    _linguify-content("confidentiality-agreement-note-dhbw")
  }

  // AI declaration form generator
  let ai-declaration-form-generator(config) = {
    let ai-cfg = config.front-back-matter.ai-declaration-form
    let ai-authors = ai-cfg.at("authors", default: ())
    if ai-authors.len() == 0 {
      return none
    }
    let sd-cfg = config.front-back-matter.statutory-declaration
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
        module-submission-date: ai-cfg.at(
          "module-submission-date",
          default: none,
        ),
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

  cfg = merge-configs(
    cfg,
    configure-statutory-declaration(
      generator-function: statutory-declaration-generator,
    ),
    configure-confidentiality-clause(
      generator-function: confidentiality-clause-generator,
    ),
    configure-dhbw-ma-ai-declaration-form(
      generator-function: ai-declaration-form-generator,
    ),
  )

  cfg
}
