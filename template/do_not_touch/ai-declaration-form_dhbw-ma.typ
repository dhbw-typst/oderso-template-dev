//Declaration form for the use of AI-based tools in Projektarbeiten at DHBW Mannheim.

#let ai-declaration-form(
  digital: true,
  name: "",
  identification-number: "",
  address: "",
  course: "",
  email: "",
  mobile-number: "",
  module-name: "",
  module-submission-date: datetime.today(),
  date-format: "dd. MMMM yyyy",
  exam-type: "",
  product-name: "",
  topic: "",
  topic-editing: "",
  research: "",
  design: "",
  signature-city: "",
  signature-date: datetime.today(),
  signature-image: none,
) = {
  //parameters
  let emptyFieldPlaceHolder = box(height: 0.3cm)
  let fieldName = name + emptyFieldPlaceHolder
  let fieldIdentificatioNumber = identification-number + emptyFieldPlaceHolder
  let fieldAddress = address + emptyFieldPlaceHolder
  let fieldCourse = course + emptyFieldPlaceHolder
  let fieldEmail = email + emptyFieldPlaceHolder
  let fieldMobileNumber = mobile-number + emptyFieldPlaceHolder
  let fieldModuleName = module-name + emptyFieldPlaceHolder
  let fieldDate = [#module-submission-date.display(
      date-format,
    ) #emptyFieldPlaceHolder]
  let examType = exam-type //"Projektarbeit I", "Projektarbeit II", "Seminararbeit",   Bachelorarbeit"
  let fieldProductName = product-name + emptyFieldPlaceHolder
  let fieldTopic = topic
  let fieldTopicEditing = topic-editing
  let fieldResearch = research
  let fieldDesign = design
  let fieldSignature

  let fieldPlaceHolder(content: []) = box(height: 2.6cm, content)
  let signature
  if (digital) {
    fieldSignature = fieldPlaceHolder(
      content: [#signature-city, #signature-date.display(date-format)],
    )
    signature = signature-image
  } else {
    fieldSignature = fieldPlaceHolder()
    signature = fieldPlaceHolder()
  }

  //measurements and styles
  let margin = (top: 2cm, right: 1.5cm, left: 2.5cm, bottom: 3cm)
  let fontSizeNormal = 10pt
  let fontSizeSmall = 7pt
  let checkRec = [#sym.square]
  let checkRecFilled = [#sym.square.filled]

  //page settings
  set page(paper: "a4", margin: margin)
  set par(leading: 0.2cm, spacing: 0.4cm)
  set v(weak: true)
  set grid(inset: (top: 0.1cm, bottom: 0.1cm))
  set text(size: fontSizeNormal, font: "Arial")

  show heading.where(level: 1): set text(size: 12pt)
  show heading.where(level: 2): set text(size: 10pt)

  //helpers
  let textArea(lines: 4, content: []) = {
    if (digital == false) {
      content = []
      let n = 0
      while n < lines {
        content = content + line(length: 100%) + v(0.9cm)
        n = n + 1
      }
      return content
    } else {
      return block(height: 2.9cm, content)
    }
  }

  let fillCheckRec(kind) = {
    if (
      (kind == examType)
        or (
          (
            kind != "Projektarbeit I"
              and kind != "Projektarbeit II"
              and kind != "Seminararbeit"
              and kind != "Bachelorarbeit"
          )
            and (
              examType != "Projektarbeit I"
                and examType != "Projektarbeit II"
                and examType != "Seminararbeit"
                and examType != "Bachelorarbeit"
            )
        )
    ) {
      return checkRecFilled + " " + kind
    } else {
      return checkRec + " " + kind
    }
  }

  let getOtherExamTypes() = {
    if (
      examType != "Projektarbeit I"
        and examType != "Projektarbeit II"
        and examType != "Seminararbeit"
        and examType != "Bachelorarbeit"
    ) {
      return examType
    }
  }

  //content
  grid(
    columns: (76%, auto),
    inset: 0cm,
    align(left, text(
      size: 12pt,
    )[*Hilfsmittelangabe zum Einsatz von KI-basierten Werkzeugen bei der Anfertigung von wissenschaftlichen Arbeiten*]),
    align(right, image("DHBW-Logo.svg", width: 100%)),
  )

  v(0.7cm)

  heading(level: 2)[Persönliche Angaben]

  v(1.1cm)

  {
    set text(size: fontSizeSmall)
    let lineSpacing = 0.3cm

    grid(
      columns: (60%, 40%),
      text(size: fontSizeNormal)[#fieldName],
      text(size: fontSizeNormal)[#fieldIdentificatioNumber],
      grid.cell(stroke: (top: 1pt))[Nachname, Vorname],
      grid.cell(stroke: (top: 1pt))[Matrikelnummer],
      grid.cell(inset: lineSpacing, colspan: 2)[],
      text(size: fontSizeNormal)[#fieldAddress],
      text(size: fontSizeNormal)[#fieldCourse],
      grid.cell(stroke: (top: 1pt))[Anschrift],
      grid.cell(stroke: (top: 1pt))[Kurs],
      grid.cell(inset: lineSpacing, colspan: 2)[],
      text(size: fontSizeNormal)[#fieldEmail],
      text(size: fontSizeNormal)[#fieldMobileNumber],
      grid.cell(stroke: (top: 1pt))[E-Mail],
      grid.cell(stroke: (top: 1pt))[Telefonnummer /  Handynummer],
    )

    v(1.1cm)

    grid(
      columns: (3.4cm, 5.9cm, 8cm),
      text(size: fontSizeNormal)[*Für das Modul*],
      grid.cell(colspan: 2, text(size: fontSizeNormal)[#fieldModuleName]),
      [],
      grid.cell(
        colspan: 2,
        stroke: (top: 1pt),
        align: center,
      )[Modulbezeichnung /   Semester],
      text(size: fontSizeNormal)[*muss ich am*],
      grid.cell(colspan: 2, text(size: fontSizeNormal)[#fieldDate]),
      [], grid.cell(stroke: (top: 1pt), align: center)[Datum der Frist], [],
    )
  }

  v(0.6cm)

  pad(right: 1cm)[

    *folgende Prüfungsleistung erbringen:*
    #v(0.35cm)

    #grid(
      columns: (4.2cm, 4.1cm, 1.7cm, 5.8cm),
      [#fillCheckRec("Projektarbeit I")],
      [#fillCheckRec("Projektarbeit II")],
      [#fillCheckRec("Sonstige")],
      [#h(2pt) #getOtherExamTypes()],
      grid.cell(colspan: 3)[],
      grid.cell(align: center, stroke: (top: 1pt), text(
        size: fontSizeSmall,
      )[genaue Bezeichnung]),
      grid.cell(colspan: 4, inset: (top: 0.15cm, bottom: 0pt))[],
      [#fillCheckRec("Seminararbeit")], [#fillCheckRec("Bachelorarbeit")],
    )

    #v(2.2cm)

    *Zur Verwendung KI-gestützter Werkzeuge erkläre ich in Kenntnis des Hinweisblatts   "Hinweise zum Einsatz von KI-basierten Werkzeugen bei der Anfertigung wissenschaftlicher  Arbeiten und die prüfungsrechtlichen Folgen ihres Einsatzes" Folgendes:*
  ]

  v(1cm)

  pad(left: 0.6cm, right: 1.2cm)[
    #set list(body-indent: 1em)

    #{
      show text: strong
      list(
        spacing: 0.6cm,
        [Ich habe mich aktiv über die Leistungsfähigkeit und Beschränkungen der in meiner   Arbeit eingesetzten KI-Werkzeuge informiert.],
        [Bei der Anfertigung der Prüfungsleistung habe ich durchgehend eigenständig und beim  Einsatz KI-gestützter Werkzeuge maßgeblich steuernd gearbeitet.],
        [Insbesondere habe ich die Inhalte entweder aus wissenschaftlichen oder anderen   zugelassenen Quellen entnommen und diese gekennzeichnet oder diese unter Anwendung  wissenschaftlicher Methoden selbst entwickelt.],
        [Mir ist bewusst, dass ich als Autor/in der Arbeit die Verantwortung für die in ihr   gemachten Angaben und Aussagen trage.],
        [Ich habe keine weiteren als die nachstehend von mir benannten KI-gestützten Werk-  zeuge zur Erstellung der Arbeit eingesetzt und diese nur in der angegebenen Art und  Weise.],
        [Soweit ich KI-gestützte Werkzeuge zur Erstellung der Arbeit eingesetzt habe, gebe  ich diese in der nachstehenden "Übersicht verwendeter Hilfsmittel" mit ihrem   Produkt-\ namen und ihres genutzten Funktionsumfangs vollständig an; wörtliche oder   sinn- gemäße Übernahmen KI-generierter Inhalte habe ich in ein separates Verzeichnis  aufgenommen und im Text belegt (z. B. als Fußnote). Diese Inhalte sind als pdf-Datei   in den elektronischen Beigaben hinterlegt.],
      )
    }
  ]

  v(2.1cm)

  pad(right: 1.1cm)[
    #set par(justify: true)

    *#underline[Produktname] (n) eingesetzter Hilfsmittel:*
    #{
      if (digital) {
        v(0.7cm)
        fieldProductName
      } else {
        v(1cm)
        line(length: 100%)
      }
    }

    #v(1.3cm)

    *#underline[Genutzter Funktionsumfang] im Hinblick auf:*
    #v(1cm)

    - *Themenerfassung und Strukturierung* (Aufgabenstellung oder Präzisierung,   Forschungsansatz, Gliederung)
    #v(1cm)
    #textArea(content: fieldTopic)

    - *Themenbearbeitung* (Darstellung/Beschreibung des Problems, Darlegung von   wissenschaft-\ lichen Grundlagen, Schlussfolgerungen allgemein und für das konkrete   Thema / Erkenntnisgewinn, Evaluierung des Textes / Feedback der KI)
    #v(1cm)
    #textArea(content: topic-editing)

    - *Quellenrecherche, -auswahl und -auswertung* (welche Quellen wurden durch das KI-\  Werkzeug gefunden, wie erfolgte die weitere Recherche)
    #v(1cm)
    #textArea(content: research)

    #set par(justify: false)

    - *Formale Gestaltung, insbesondere Sprache* (Welche Eingabe wurde an die KI getätigt?  Textgenerierung, Textkorrektur, Paraphrasieren und Umschreiben, Übersetzen, kreatives  Schreiben)
    #v(1cm)
    #textArea(content: design)
  ]

  v(1.8cm)

  pad(right: 0.5cm)[
    #block(stroke: 0.5pt, inset: 3pt)[
      *Hinweis*:

      Geben Sie in der jeweiligen Rubrik die Seitenzahl in ihrer wissenschaftlichen Arbeit an   und erläutern Sie die Art und Weise sowie den Umfang der von Ihnen genutzten  KI-basierten Werkzeuge.
    ]
  ]
  v(1.6cm)

  set text(size: 9pt)

  set image(height: 25mm)

  grid(
    columns: (4.9cm, 10.1cm),
    column-gutter: 0.5cm,
    align(bottom, text(size: fontSizeNormal, fieldSignature)),
    place(bottom, signature),
    grid.cell(stroke: (top: 1pt), [*Ort, Datum*]),
    grid.cell(stroke: (top: 1pt), [*Unterschrift der/des Studierenden*]),
  )
}

//example usage
#ai-declaration-form(
  digital: true,
  name: "Max Mustermann",
  identification-number: "1234567",
  address: "Musterstraße 1, 68161 Mannheim",
  course: "IMB21",
  email: "max.mustermann@dhbw-mannheim.de",
  mobile-number: "0171 1234567",
  module-name: "Projektmanagement",
  module-submission-date: datetime(year: 2026, month: 06, day: 10),
  date-format: "",
  exam-type: "Projektarbeit I", //"Projektarbeit I", "Projektarbeit II", "Seminararbeit",   Bachelorarbeit"
  product-name: "ChatGPT, DeepL",
  topic: "Automatisierung von Geschäftsprozessen",
  topic-editing: "Strukturierung, Gliederung",
  research: "Quellenrecherche mit KI",
  design: "Textgenerierung, Korrektur",
  signature-city: "Mannheim",
  signature-date: datetime(year: 2026, month: 06, day: 10),
  signature-image: image("../assets/example-signature.png"),
)
