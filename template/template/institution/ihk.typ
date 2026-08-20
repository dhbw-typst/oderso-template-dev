// LTeX: enabled=false

#import "../base.typ": _signature-line
#import "../config/lib.typ" as config: merge-config, merge-configs
#import "../frontbackmatter/_shared.typ": configure-statutory-declaration, configure-confidentiality-clause
#import "@preview/linguify:0.5.0": linguify
#import "../util.typ": _linguify-content
#import "../general/metadata.typ": metadata as _general-metadata

/// Default IHK config: sets position/order/enable defaults and IHK
/// signature defaults for the front/back matter sections.
#let _ihk-defaults() = {
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
  )
}

/// Pure config producer for IHK thesis documents.
///
/// Returns a configuration dictionary that can be passed to `project()`.
/// -> dictionary
#let ihk(
  /// The examination type (e.g., "Abschlussprüfung Teil 2"). -> str | none
  examination: none,
  /// The training occupation (Ausbildungsberuf). -> str
  training-occupation: "Fachinformatiker für Anwendungsentwicklung",
  /// List of author dictionaries. -> array
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
  /// Format string for displaying the submission date. -> str
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
  /// Full thesis title displayed on the cover. -> str | none
  title-long: none,
  /// Shortened title for the header. -> str | none
  title-short: none,
  /// Type of document. -> str | none
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
    #_linguify-content("as-part-of-examination-ihk")

    *#examination*

    #_linguify-content("in-the-training-occupation")\
    #training-occupation
  ]

  let misc-key-value = (
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

  // ----------------------------------
  // Build config
  // ----------------------------------
  let cfg = _ihk-defaults()

  cfg = merge-config(cfg, _general-metadata(metadata: (
    lang: lang,
    title-long: title-long,
    title-short: title-short,
    thesis-type: thesis-type,
    logo-left: company-logo,
    logo-right: image("../assets/IHK-Logo.svg"),
    submission-info: submission-info,
    misc-key-value: misc-key-value,
    authors: authors,
  )))

  // ----------------------------------
  // Install section generators
  // ----------------------------------

  // Statutory declaration generator
  let statutory-declaration-generator(config) = {
    let sd-cfg = config.front-back-matter.statutory-declaration
    pagebreak(weak: true)
    align(center, heading(
      _linguify-content("statutory-declaration"),
      level: 1,
    ))

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

  cfg = merge-configs(
    cfg,
    configure-statutory-declaration(
      generator-function: statutory-declaration-generator,
    ),
    configure-confidentiality-clause(
      generator-function: confidentiality-clause-generator,
    ),
  )

  cfg
}
