// IHK: occupation and examinee metadata, plus printed-submission signatures.
#import "../template/template/lib.typ": (
  frontbackmatter, institution, project, theme,
)
#import institution: ihk

#show: project.with(
  theme.spotless(),
  ihk.setup(
    lang: "de",
    title-long: "Entwicklung einer Beispielanwendung",
    title-short: "IHK-Beispiel",
    thesis-type: "Projektdokumentation",
    examination: "Abschlussprüfung Teil 2",
    training-occupation: "Fachinformatiker für Anwendungsentwicklung",
    submission-date: "24.12.2026",
    processing-period-weeks: 2,
    company-name: "Beispiel GmbH",
    company-city: "Karlsruhe",
    company-department: "Softwareentwicklung",
    company-supervisor: "Kim Beispiel",
    authors: (
      (
        firstname: "Alex",
        lastname: "Beispiel",
        examinee-number: "123456",
      ),
    ),
  ),
  frontbackmatter.statutory-declaration(
    digital-submission: false,
    digital-only: false,
  ),
)

= Projektbeschreibung

Das Deckblatt zeigt Ausbildungsberuf, Prüfung und Prüflingsnummer statt der
DHBW-spezifischen Studien- und Kursangaben. Die Unterschriftsfelder bleiben
für die handschriftliche Unterschrift leer.
