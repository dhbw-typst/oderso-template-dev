// LTeX: enabled=false

#import "base.typ": __signature-line, project
#import "config.typ": *
#import "@preview/linguify:0.5.0": linguify
#import "utils.typ": __linguify-content

// Default IHK adapter config: sets position/order/enable defaults and IHK
// signature defaults for the front/back matter sections owned by this adapter.
// Content is generated at call site by the adapter function body.
#let __ihk-config = __merge-configs(
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
    #__linguify-content("as-part-of-examination-ihk")

    *#examination*

    #__linguify-content("in-the-training-occupation")\
    #training-occupation
  ]

  // TODO: only for compatibility reasons: Remove with v3.0.0 release
  if type(submission-date) == datetime {
    submission-date = submission-date.display(submission-date-format)
  }

  let metadata = (
    __linguify-content("submission-date"),
    submission-date,
    __linguify-content("processing-duration"),
    __linguify-content("weeks", args: (count: processing-period-weeks)),
    __linguify-content("examinee-number"),
    authors.map(a => a.examinee-number).join(linebreak()),
    __linguify-content("training-company"),
    company-name + linebreak() + company-city,
    __linguify-content("department"),
    company-department,
    __linguify-content("supervisor-at-training-company"),
    company-supervisor,
  )

  if authors == none or type(authors) != array or authors.len() == 0 {
    panic("At least one author has to be specified!")
  }

  // ----------------------------------
  // 1. Construct default config
  // ----------------------------------
  let config = __ihk-config

  // ----------------------------------
  // 2. Apply provided configs from user's positional args
  // ----------------------------------
  for addition in args.pos() {
    assert.eq(
      type(addition),
      dictionary,
      message: "Only configurations are allowed as positional arguments in ihk-adapter.",
    )
    config = __merge-config(config, addition)
  }

  // ----------------------------------
  // 3. Generate content into the config dictionary
  // ----------------------------------

  // Statutory declaration
  if config.front-back-matter.statutory-declaration.enable {
    let sd-cfg = config.front-back-matter.statutory-declaration
    config.front-back-matter.statutory-declaration.content = {
      pagebreak(weak: true)
      align(center, heading(
        __linguify-content("statutory-declaration"),
        level: 1,
      ))

      // Using the statutory declaration of the dhbw, as there is no template for the IHK
      __linguify-content("statutory-declaration-note-dhbw", args: (
        author-count: authors.len(),
      ))

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

      __linguify-content("confidentiality-agreement-note-ihk")
    }
  }

  // ----------------------------------
  // 4. Pass resulting config down to base
  // ----------------------------------
  show: project.with(
    __logo-left: company-logo,
    __logo-right: image("assets/IHK-Logo.svg"),
    __authors: authors,
    __submission-info: submission-info,
    __metadata: metadata,
    __confidentiality-clause: config.front-back-matter.confidentiality-clause.enable,
    config,
    ..args.named(),
  )
  body
}
