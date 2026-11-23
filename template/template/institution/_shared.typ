// Private rendering helpers. Institutions do not depend on the orchestrator.
#import "../config/lib.typ" as config
#import "@preview/linguify:0.5.0": linguify-raw
#let linguify-content = config.util.linguify-content

#let _require-authors(
  metadata,
  component,
  fields: ("firstname", "lastname"),
) = {
  let authors = metadata.at("authors", default: ())
  assert(
    type(authors) == array and authors.len() > 0,
    message: component
      + " requires general.metadata.authors; supply authors or disable this component",
  )
  for author in authors {
    assert(
      type(author) == dictionary,
      message: component + " requires author dictionaries",
    )
    for field in fields {
      assert(
        type(author.at(field, default: none)) == str,
        message: component
          + " requires author."
          + field
          + " as a string; supply it or disable this component",
      )
    }
  }
  authors
}

#let _submission-date(metadata) = {
  let date = metadata.at("submission-date", default: none)
  if type(date) == datetime {
    date.display(metadata.at(
      "submission-date-format",
      default: "[day].[month].[year]",
    ))
  } else { date }
}

#let _course-year(authors) = {
  let course = authors.first().at("course", default: none)
  assert(
    type(course) == str and course.find(regex("\d+")) != none,
    message: "Statutory declaration requires author.course containing a course year; supply it or disable the declaration",
  )
  int(course.find(regex("\d+")))
}

#let _signature-line(
  digital: true,
  city: none,
  date: none,
  date-format: "[day].[month].[year]",
  author: (:),
) = {
  let signature-content = if digital {
    (
      city,
      date,
      [],
      grid.cell(
        if author.at("signature", default: none) == none {
          author.firstname + " " + author.lastname
        } else {
          set image(height: 25mm)
          place(bottom, author.signature)
        },
        align: center,
      ),
    )
  } else { ([], [], [], []) }
  v(20mm)
  align(center, grid(
    stroke: none,
    columns: (30mm, 30mm, 20mm, 80mm),
    ..signature-content, grid.hline(end: 2), grid.hline(start: 3),
    linguify-content("place-of-signature"),
    linguify-content("date-of-signature"),
    [],
    grid.cell(linguify-content("signature"), align: center),
  ))
}

#let _supervisor(value) = {
  if type(value) != dictionary { return value }
  [#value.at("firstname", default: none) #value.at(
      "lastname",
      default: none,
    )#if value.at("phone-number", default: none) != none {
      ", " + value.phone-number
    }#if value.at("email", default: none) != none {
      linebreak()
      value.email
    }]
}

// Derive presentation from effective semantic metadata only when the cover is
// rendered. Explicit submission-info/misc-key-value (including none/()) win.
#let _cover-metadata(m, generator: none) = {
  if generator != none {
    let presentation = generator(m)
    assert(
      type(presentation) == dictionary,
      message: "Cover presentation generator must return a dictionary",
    )
    for key in ("submission-info", "misc-key-value") {
      if key not in m and key in presentation {
        m.insert(key, presentation.at(key))
      }
    }
  }
  let institution = m.at("institution", default: none)
  let submission = m.at("submission-info", default: none)
  if (
    "submission-info" not in m and institution in ("ihk", "dhbw-ka", "dhbw-ma")
  ) {
    submission = if institution == "ihk" {
      [#linguify-content("as-part-of-examination-ihk")

        *#m.at("examination", default: none)*

        #linguify-content("in-the-training-occupation")\
        #m.at("training-occupation", default: none)]
    } else {
      [#linguify-content("as-part-of-examination-dhbw")

        *#m.at("examination", default: none)*

        #linguify-content("in-field-of-study", args: (
          study: m.at("study", default: none),
        ))

        #context linguify-content("at-the-institution", args: (
          institution: linguify-raw("dhbw-long"),
          city: linguify-raw(if institution == "dhbw-ka" { "ka" } else {
            "ma"
          }),
        )) ]
    }
  }
  let rows = m.at("misc-key-value", default: ())
  assert(
    rows == none or type(rows) == array,
    message: "Coversheet general.metadata.misc-key-value must be an array or none",
  )
  if (
    "misc-key-value" not in m and institution in ("ihk", "dhbw-ka", "dhbw-ma")
  ) {
    let fields = if institution == "ihk" { ("examinee-number",) } else {
      ("matriculation-number", "course")
    }
    let authors = _require-authors(m, "Coversheet", fields: fields)
    rows = (
      linguify-content("submission-date"),
      _submission-date(m),
      linguify-content("processing-duration"),
      linguify-content("weeks", args: (
        count: m.at("processing-period-weeks", default: none),
      )),
      if institution == "ihk" { linguify-content("examinee-number") } else {
        (
          linguify-content("matriculation-number")
            + ", "
            + linguify-content("course")
        )
      },
      authors
        .map(a => if institution == "ihk" { a.examinee-number } else {
          a.matriculation-number + ", " + a.course
        })
        .join(linebreak()),
    )
    if (
      m.at("company-name", default: none) != none
        and m.at("company-city", default: none) != none
    ) {
      rows += (
        linguify-content("training-company"),
        m.company-name + linebreak() + m.company-city,
      )
    }
    if (
      m.at("company-department", default: none) != none or institution == "ihk"
    ) {
      rows += (
        linguify-content("department"),
        m.at("company-department", default: none),
      )
    }
    let supervisor = m.at("company-supervisor", default: none)
    if (
      (
        type(supervisor) == dictionary
          and (
            supervisor.at("firstname", default: none) != none
              or supervisor.at("lastname", default: none) != none
          )
      )
        or (type(supervisor) != dictionary and supervisor != none)
        or institution == "ihk"
    ) {
      rows += (
        linguify-content("supervisor-at-training-company"),
        _supervisor(supervisor),
      )
    }
    if m.at("course-director", default: none) != none {
      rows += (linguify-content("course-director"), m.course-director)
    }
    if institution != "ihk" {
      rows += (
        linguify-content("supervisor-at-university"),
        _supervisor(m.at("university-supervisor", default: none)),
      )
    }
  }
  (
    submission-info: submission,
    misc-key-value: if rows == none { () } else { rows },
  )
}
