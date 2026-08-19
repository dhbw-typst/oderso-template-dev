// LTeX: enabled=false

#import "../base.typ": _signature-line, project
#import "../config-utils.typ": *
#import "config.typ": *
#import "@preview/linguify:0.5.0": linguify
#import "../util.typ": _linguify-content

/// Default IHK adapter config: sets position/order/enable defaults and IHK
/// signature defaults for the front/back matter sections owned by this adapter.
/// Content is generated at call site by the adapter function body.
#let _ihk-config = merge-configs(
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
)

/// Template adapter for IHK thesis documents.
///
/// This function configures the base `project` template for vocational training documentations.
///
/// Section-specific settings (submission mode, signature city, enable flags)
/// live in `configure-statutory-declaration(...)` and
/// `configure-confidentiality-clause(enable: ...)`.
/// -> content
#let ihk-adapter(
  /// The examination type (e.g., "Abschlussprüfung Teil 2"). -> str | none
  examination: none,
  /// The training occupation (Ausbildungsberuf),
  /// e.g., "Fachinformatiker für Anwendungsentwicklung". -> str
  training-occupation: "Fachinformatiker für Anwendungsentwicklung",
  /// List of author dictionaries. Each author should have: `firstname`,
  /// `lastname`, `examinee-number`, and optionally `signature`. -> array
  authors: (
    (
      firstname: none,
      lastname: none,
      examinee-number: none,
      signature: none,
    ),
  ),
  /// Submission date of the thesis. -> str
  submission-date: datetime.today().display("[day].[month].[year]"),
  /// Format string for displaying the submission date. (see #link("https://typst.app/docs/reference/foundations/datetime/#format")[datetime formats]) -> str
  submission-date-format: "[day].[month].[year]",
  /// Duration of the thesis processing period in weeks. -> int | none
  processing-period-weeks: none,
  /// Name of the training company. -> str
  company-name: "Corp SE",
  /// City where the company is located. -> str
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
  let submission-info = [
    #_linguify-content("as-part-of-examination-ihk")

    *#examination*

    #_linguify-content("in-the-training-occupation")\
    #training-occupation
  ]

  // TODO: only for compatibility reasons: Remove with v3.0.0 release
  if type(submission-date) == datetime {
    submission-date = submission-date.display(submission-date-format)
  }

  let metadata = (
    _linguify-content("submission-date"),
    submission-date,
    _linguify-content("processing-duration"),
    _linguify-content("weeks", args: (count: processing-period-weeks)),
    _linguify-content("examinee-number"),
    authors.map(a => a.examinee-number).join(linebreak()),
    _linguify-content("training-company"),
    company-name + linebreak() + company-city,
    _linguify-content("department"),
    company-department,
    _linguify-content("supervisor-at-training-company"),
    company-supervisor,
  )

  if authors == none or type(authors) != array or authors.len() == 0 {
    panic("At least one author has to be specified!")
  }

  // ----------------------------------
  // Construct default config
  // ----------------------------------
  let config = _ihk-config

  // ----------------------------------
  // Install section generators
  // ----------------------------------
  // Generators are installed BEFORE user positional args so that user overrides
  // can override section data without clobbering the adapter's generator. If a
  // user wants to replace a generator, they can pass `generator-function: ...`
  // in their own positional configuration call.

  // Statutory declaration generator
  let statutory-declaration-generator(config) = {
    let sd-cfg = config.front-back-matter.statutory-declaration
    pagebreak(weak: true)
    align(center, heading(
      _linguify-content("statutory-declaration"),
      level: 1,
    ))

    // Using the statutory declaration of the dhbw, as there is no template for the IHK
    _linguify-content("statutory-declaration-note-dhbw", args: (
      author-count: authors.len(),
    ))

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

    _linguify-content("confidentiality-agreement-note-ihk")
  }

  config = merge-configs(
    config,
    configure-statutory-declaration(
      generator-function: statutory-declaration-generator,
    ),
    configure-confidentiality-clause(
      generator-function: confidentiality-clause-generator,
    ),
  )

  // ----------------------------------
  // Apply provided configs from user's positional args
  // ----------------------------------
  for addition in args.pos() {
    assert.eq(
      type(addition),
      dictionary,
      message: "Only configurations are allowed as positional arguments in ihk-adapter.",
    )
    config = merge-config(config, addition)
  }

  show: project.with(
    _logo-left: company-logo,
    _logo-right: image("../assets/IHK-Logo.svg"),
    _authors: authors,
    _submission-info: submission-info,
    _metadata: metadata,
    config,
    ..args.named(),
  )
  body
}
