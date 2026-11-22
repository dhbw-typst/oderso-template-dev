// Karlsruhe: German localization, multiple authors, and institution sections.
#import "../template/template/lib.typ": institution, project, theme
#import institution: dhbw-ka

#show: project.with(
  theme.spotless(),
  dhbw-ka.setup(
    lang: "de",
    title-long: "Eine Beispielarbeit an der DHBW Karlsruhe",
    title-short: "Karlsruhe-Beispiel",
    thesis-type: "Bachelorarbeit",
    study: "Informatik",
    submission-date: "24.12.2026",
    processing-period-weeks: 12,
    company-name: "Beispiel GmbH",
    company-city: "Karlsruhe",
    company-supervisor: "Kim Beispiel",
    university-supervisor: "Dr. Robin Beispiel",
    authors: (
      (
        firstname: "Alex",
        lastname: "Beispiel",
        matriculation-number: "1234567",
        course: "TINF24B1",
      ),
      (
        firstname: "Sam",
        lastname: "Muster",
        matriculation-number: "7654321",
        course: "TINF24B1",
      ),
    ),
  ),
  dhbw-ka.frontbackmatter.ai-declaration(entries: (
    (tool: "DeepL", usage: [Übersetzung einzelner Formulierungen.]),
    (tool: "ChatGPT", usage: [Vorschläge zur Gliederung.]),
  )),
  // A position-only patch preserves the entries above.
  dhbw-ka.frontbackmatter.ai-declaration(position: 100),
)

= Einleitung

Dieses Beispiel zeigt das Deckblatt, das Inhaltsverzeichnis, die
Eigenständigkeitserklärung, den Sperrvermerk und die KI-Dokumentation.
Die Namen beider Autoren erscheinen auch in den Unterschriftszeilen.

== Vorgehensweise

Alle Metadaten und das Abgabedatum sind fest vorgegeben, damit die Ausgabe
zwischen zwei Revisionen verglichen werden kann.
