// LTeX: enabled=false

#import "base.typ": project, signature-line
#import "../utils.typ": styled-table
#import "@preview/linguify:0.5.0": *

#let dhbw-ka-adapter(
  digital-submission: true,
  digital-only: true,
  confidentiality-clause: true,
  ai-acknowledgement: (
    (
      tool: none,
      usage: none,
    ),
  ),
  examination: "Bachelor of Science (B.Sc.)",
  study: "Computer Science",
  authors: (
    (
      firstname: none,
      lastname: none,
      matriculation-number: none,
      course: none,
      signature: none,
    ),
  ),
  signature-city: "Karlsruhe",
  submission-date: datetime.today(),
  submission-date-format: "[day].[month].[year]",
  processing-period-weeks: none,
  university-supervisor: none,
  company-name: "Corp SE",
  company-city: "Berlin",
  company-logo: image("../do_not_touch/Company-Logo.svg"),
  company-department: none,
  company-supervisor: none,
  ..args,
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
    authors
      .map(a => a.matriculation-number + ", " + a.course)
      .join(linebreak()),
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
    logo-left: company-logo,
    logo-right: image("../do_not_touch/DHBW-Logo.svg"),
    authors: authors,
    submission-info: submission-info,
    metadata: metadata,
    preamble: (
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
