// LTeX: enabled=false

#import "base.typ": project, signature-line, __generate-adapter-documentation
#import "@preview/linguify:0.5.0": *

/// Template adapter for IHK thesis documents.
///
/// This function configures the base `project` template for vocational training documentations.
///
/// In addition to the parameters listed below, this adapter accepts all parameters
/// from the base `project` template (e.g., `title-long`, `title-short`, `thesis-type`,
/// `abstracts`, `appendices`, `library`, `abbreviations`, `lang`).
/// -> content
#let ihk-adapter(
  /// Whether the thesis is submitted digitally. Affects the signature line
  /// display in the statutory declaration. -> bool
  digital-submission: true,
  /// Whether to include a confidentiality clause page. -> bool
  confidentiality-clause: true,
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
  /// City shown on the signature line. -> str
  signature-city: "Karlsruhe",
  /// Submission date of the thesis. -> datetime
  submission-date: datetime.today(),
  /// Format string for displaying the submission date. -> str
  submission-date-format: "[day].[month].[year]",
  /// Duration of the thesis processing period in weeks. -> int | none
  processing-period-weeks: none,
  /// Name of the training company. -> str
  company-name: "Corp SE",
  /// City where the company is located. -> str
  company-city: "Berlin",
  /// Company logo image. -> content | none
  company-logo: image("../do_not_touch/Company-Logo.svg"),
  /// Department within the company. -> str | none
  company-department: none,
  /// Name of the company supervisor. -> str | none
  company-supervisor: none,
  /// Additional arguments passed to the base template.
  ..args,
  /// The main document body content. -> content
  body,
) = {
  let submission-info = [
    #linguify("as-part-of-examination-ihk")

    *#examination*

    #linguify("in-the-training-occupation")\
    #training-occupation
  ]
  let metadata = (
    linguify("submission-date"),
    submission-date.display(submission-date-format),
    linguify("processing-duration"),
    linguify("weeks", args: (count: processing-period-weeks)),
    linguify("examinee-number"),
    authors.map(a => a.examinee-number).join(linebreak()),
    linguify("training-company"),
    company-name + linebreak() + company-city,
    linguify("department"),
    company-department,
    linguify("supervisor-at-training-company"),
    company-supervisor,
  )
  let statutory-declaration = {
    pagebreak(weak: true)
    align(center, heading(linguify("statutory-declaration"), level: 1))

    // Using the statutory declaration of the dhbw, as there is no template for the IHK
    linguify("statutory-declaration-note-dhbw", args: (
      author-count: authors.len(),
    ))

    set grid.cell(align: left, inset: (x: 1em, y: 0.3em))

    for a in authors {
      signature-line(
        author: a,
        date: submission-date,
        date-format: submission-date-format,
        digital: digital-submission,
        city: signature-city,
      )
    }
  }

  let confidentiality-clause = {
    pagebreak(weak: true)
    align(center, heading(linguify("confidentiality-agreement"), level: 1))

    linguify("confidentiality-agreement-note-ihk")
  }

  show: project.with(
    __logo-left: company-logo,
    __logo-right: image("../do_not_touch/IHK-Logo.svg"),
    __authors: authors,
    __submission-info: submission-info,
    __metadata: metadata,
    __preamble: (
      statutory-declaration,
      confidentiality-clause,
    ),
    ..args,
  )
  body
}

#let __documentation() = {
  __generate-adapter-documentation(
    "IHK Adapter",
    "ihk.typ",
  )
}
