// LTeX: enabled=false

#import "base.typ": project, signature-line, __generate-adapter-documentation
#import "../utils.typ": styled-table
#import "@preview/linguify:0.5.0": *

/// Template adapter for DHBW Karlsruhe thesis documents.
///
/// This function configures the base `project` template with DHBW Karlsruhe-specific
/// settings, including statutory declarations, confidentiality clauses,
/// and AI tool acknowledgements according to DHBW guidelines.
///
/// In addition to the parameters listed below, this adapter accepts all parameters
/// from the base `project` template (e.g., `title-long`, `title-short`, `thesis-type`,
/// `abstracts`, `appendices`, `library`, `abbreviations`, `lang`).
/// -> content
#let dhbw-ka-adapter(
  /// Whether the thesis is submitted digitally. Affects the signature line
  /// display in the statutory declaration. -> bool
  digital-submission: true,
  /// Whether the thesis is submitted digitally only (no printed copy).
  /// Affects the wording of the statutory declaration. -> bool
  digital-only: true,
  /// Whether to include a confidentiality clause page. -> bool
  confidentiality-clause: true,
  /// List of AI tools used in the thesis, according to section 4.6 of
  /// "Leitlinien für Wissenschaftliche Arbeiten". Each entry should have
  /// `tool` (name) and `usage` (description of how it was used). -> array
  ai-acknowledgement: (
    (
      tool: none,
      usage: none,
    ),
  ),
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
  /// City shown on the signature line. -> str
  signature-city: "Karlsruhe",
  /// Submission date of the thesis. -> datetime
  submission-date: datetime.today(),
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
  company-logo: image("../do_not_touch/Company-Logo.svg"),
  /// Department within the company. -> str | none
  company-department: none,
  /// Name of the company supervisor. -> str | none
  company-supervisor: none,
  /// Additional arguments passed to the base template (e.g., `title-long`,
  /// `title-short`, `thesis-type`, `abstracts`, `appendices`, `library`,
  /// `abbreviations`, `lang`).
  ..args,
  /// The main document body content. -> content
  body,
) = {
  let submission-info = [
    #linguify("as-part-of-examination-dhbw")

    *#examination*

    #linguify("in-field-of-study", args: (study: study))

    #context {
      linguify-raw("at-the-institution", args: (
        institution: linguify-raw("dhbw-long"),
        city: linguify-raw("ka"),
      ))
    }
  ]
  let metadata = (
    linguify("submission-date"),
    submission-date.display(submission-date-format),
    linguify("processing-duration"),
    linguify("weeks", args: (count: processing-period-weeks)),
    linguify("matriculation-number") + ", " + linguify("course"),
    authors.map(a => a.matriculation-number + ", " + a.course).join(linebreak()),
    ..if company-name != none and company-city != none {
      (linguify("training-company"), company-name + linebreak() + company-city)
    },
    ..if company-department != none {
      (linguify("department"), company-department)
    },
    ..if company-supervisor != none {
      (linguify("supervisor-at-training-company"), company-supervisor)
    },
    linguify("supervisor-at-university"),
    university-supervisor,
  )
  let statutory-declaration = {
    pagebreak(weak: true)
    // Get course year of first author
    if authors == none or type(authors) != array or authors.len() == 0 {
      panic("At least one author has to be specified!")
    }

    let course-year = int(authors.at(0).course.find(regex("\d+")))

    // TODO: The statutory declaration changed for courses starting in 2024. This complicated edge case for courses from 2023
    // and earlier can safely be removed by September 2026
    let statuatory-declaration = if course-year < 24 {
      linguify("statutory-declaration-note-dhbw-old", args: (
        author-count: authors.len(),
        title: args.at("title-long"),
        type: args.at("thesis-type"),
      ))
    } else {
      linguify("statutory-declaration-note-dhbw", args: (
        author-count: authors.len(),
      ))
    }

    let statuatory-declaration-printed = if course-year < 24 {
      linguify("statutory-declaration-note-dhbw-old-printed", args: (
        author-count: authors.len(),
      ))
    } else {
      linguify("statutory-declaration-note-dhbw-printed", args: (
        author-count: authors.len(),
      ))
    }

    align(center, heading(linguify("statutory-declaration"), level: 1))

    statuatory-declaration
    if not digital-only {
      (
        " " + statuatory-declaration-printed
      )
    }

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

  let confidentiality-clause-text = {
    pagebreak()
    align(center, heading(linguify("confidentiality-agreement"), level: 1))

    linguify("confidentiality-agreement-note-dhbw")
  }

  let ai-acknowledgement-empty = false
  let ai-acknowledgement-text = {
    if not confidentiality-clause {
      pagebreak()
    } else {
      v(2em)
    }

    align(center, heading(
      linguify("ai-acknowledgement-heading-dhbw"),
      level: 1,
    ))

    let table-cells = ()

    for tool-usage in ai-acknowledgement {
      if tool-usage.tool == none or tool-usage.usage == none {
        continue
      }

      table-cells.push(tool-usage.tool)
      table-cells.push(tool-usage.usage)
    }

    if table-cells.len() == 0 {
      ai-acknowledgement-empty = true
    }

    align(center, styled-table(
      columns: (auto, 1fr),
      table-content: (
        table.header(linguify("tool"), linguify("usage-description")),
        ..table-cells,
      ),
    ))
  }

  show: project.with(
    __logo-left: company-logo,
    __logo-right: image("../do_not_touch/DHBW-Logo.svg"),
    __authors: authors,
    __submission-info: submission-info,
    __metadata: metadata,
    __preamble: (
      statutory-declaration,
      ..if (confidentiality-clause) { (confidentiality-clause-text,) },
      ..if (not ai-acknowledgement-empty) {
        (ai-acknowledgement-text,)
      },
    ),
    ..args,
  )
  body
}

#let __documentation() = {
  __generate-adapter-documentation(
    "DHBW Karlsruhe Adapter",
    "dhbw-ka.typ",
  )
}
