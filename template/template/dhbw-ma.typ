// LTeX: enabled=false

#import "base.typ": project, signature-line
#import "../do_not_touch/ai-declaration-form_dhbw-ma.typ": ai-declaration-form
#import "@preview/linguify:0.5.0": *

#let dhbw-ma-adapter(
  digital-submission: true,
  digital-only: true,
  confidentiality-clause: true,
  examination: "Bachelor of Science (B.Sc.)",
  study: "Computer Science",
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
  signature-city: "Mannheim",
  submission-date: datetime.today(),
  module-submission-date: datetime.today(),
  submission-date-format: "[day].[month].[year]",
  processing-period-weeks: none,
  university-supervisor: (
    firstname: none,
    lastname: none,
    email: none,
    phone-number: none,
  ),
  company-name: "Corp SE",
  company-city: "Berlin",
  company-logo: image("../do_not_touch/Company-Logo.svg"),
  company-department: none,
  company-supervisor: (
    firstname: none,
    lastname: none,
    email: none,
    phone-number: none,
  ),
  course-director: none,
  ai-declaration-form-data: (
    module-name: none,
    exam-type: none, // "Projektarbeit I", "Projektarbeit II", "Seminararbeit", "Bachelorarbeit"
    product-name: none,
    topic: none,
    topic-editing: none,
    research: none,
    design: none,
  ),
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
        city: linguify-raw("ma"),
      ))
    }
  ]
  let company-supervisor-data = [
    #company-supervisor.firstname #company-supervisor.lastname
    #if (company-supervisor.phone-number != none) {
      linebreak()
      company-supervisor.phone-number
    }
    #if (company-supervisor.email != none) {
      linebreak()
      company-supervisor.email
    }
  ]

  let university-supervisor-data = [
    #university-supervisor.firstname #university-supervisor.lastname
    #if (university-supervisor.phone-number != none) {
      linebreak()
      university-supervisor.phone-number
    }
    #if (university-supervisor.email != none) {
      linebreak()
      university-supervisor.email
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
    ..if company-supervisor.firstname != none
      or company-supervisor.lastname != none {
      (linguify("supervisor-at-training-company"), company-supervisor-data)
    },
    ..if course-director != none {
      (linguify("course-director"), course-director)
    },
    linguify("supervisor-at-university"),
    university-supervisor-data,
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
    pagebreak(weak: true)
    align(center, heading(linguify("confidentiality-agreement"), level: 1))

    linguify("confidentiality-agreement-note-dhbw")
  }

  let main-author = authors.at(0)

  let ai-tools-declaration = ai-declaration-form(
    digital: digital-only,
    name: main-author.firstname + " " + main-author.lastname,
    identification-number: main-author.matriculation-number,
    address: main-author.address,
    course: main-author.course,
    email: main-author.email,
    mobile-number: main-author.phone-number,
    module-name: ai-declaration-form-data.module-name,
    module-submission-date: module-submission-date,
    date-format: submission-date-format,
    exam-type: ai-declaration-form-data.exam-type,
    product-name: ai-declaration-form-data.product-name,
    topic: ai-declaration-form-data.topic,
    topic-editing: ai-declaration-form-data.topic-editing,
    research: ai-declaration-form-data.research,
    design: ai-declaration-form-data.design,
    signature-city: signature-city,
    signature-date: submission-date,
    signature-image: main-author.signature,
  )

  show: project.with(
    logo-left: company-logo,
    logo-right: image("../do_not_touch/DHBW-Logo.svg"),
    authors: authors,
    submission-info: submission-info,
    metadata: metadata,
    postamble: (
      statutory-declaration,
      ..if (confidentiality-clause) { (confidentiality-clause-text,) },
      ai-tools-declaration,
    ),
    ..args,
  )
  body
}
