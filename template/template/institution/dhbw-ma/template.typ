// LTeX: enabled=false

#import "@preview/linguify:0.5.0": linguify, linguify-raw
#import "../_shared.typ": (
  _course-year, _require-authors, _signature-line, _submission-date,
)
#import "../../config/lib.typ" as config
#let merge-config = config.util.merge-config
#let merge-configs = config.util.merge-configs
#import "../../frontbackmatter/lib.typ" as fbm
#import "frontbackmatter.typ": ai-declaration-form as ai-declaration-form-config
#import "ai-declaration-form_dhbw-ma.typ": ai-declaration-form
#let linguify-content = config.util.linguify-content
#import "../../general/lib.typ" as general
#let _general-metadata = general.metadata

/// Default DHBW Mannheim config: sets position/enable defaults
/// and DHBW-MA-specific defaults for the front/back matter sections.
#let _dhbw-ma-defaults() = {
  merge-configs(
    (:),
    fbm.statutory-declaration(
      enable: true,
      position: 80,
      digital-submission: true,
      digital-only: true,
      signature-city: "Mannheim",
    ),
    fbm.confidentiality-clause(
      enable: true,
      position: 90,
    ),
    ai-declaration-form-config(position: 100, authors: ()),
  )
}

/// Pure config producer for DHBW Mannheim thesis documents.
///
/// Returns a configuration dictionary that can be passed to `project()`.
/// -> dictionary
#let setup(
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
  // ----------------------------------
  // Build config
  // ----------------------------------
  let cfg = _dhbw-ma-defaults()

  cfg = merge-config(cfg, _general-metadata(
    lang: lang,
    title-long: title-long,
    title-short: title-short,
    thesis-type: thesis-type,
    logo-left: company-logo,
    logo-right: image("../assets/DHBW-Logo.svg"),
    institution: "dhbw-ma",
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
    course-director: course-director,
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
      linguify-content("confidentiality-agreement"),
      level: 1,
    ))

    linguify-content("confidentiality-agreement-note-dhbw")
  }

  // AI declaration form generator
  let ai-declaration-form-generator(config) = {
    let ai-cfg = config.front-back-matter.ai-declaration-form
    let ai-authors = ai-cfg.at("authors", default: ())
    if ai-authors.len() == 0 {
      return none
    }
    let authors = _require-authors(
      config.general.metadata,
      "AI declaration form",
      fields: ("firstname", "lastname", "matriculation-number", "course"),
    )
    let submission-date = _submission-date(config.general.metadata)
    let sd-cfg = config.front-back-matter.statutory-declaration
    for (i, a) in authors.enumerate() {
      let ai-author = ai-authors.at(i, default: (:))
      ai-declaration-form(
        digital: sd-cfg.digital-only,
        name: a.lastname + ", " + a.firstname,
        identification-number: a.matriculation-number,
        address: a.at("address", default: none),
        course: a.course,
        email: a.at("email", default: none),
        mobile-number: a.at("phone-number", default: none),
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
        signature-image: a.at("signature", default: none),
      )
    }
  }

  cfg = merge-configs(
    cfg,
    fbm.statutory-declaration(
      generator-function: statutory-declaration-generator,
    ),
    fbm.confidentiality-clause(
      generator-function: confidentiality-clause-generator,
    ),
    ai-declaration-form-config(
      generator-function: ai-declaration-form-generator,
    ),
  )

  cfg
}
