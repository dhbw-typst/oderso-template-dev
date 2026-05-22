### General terms
at-the-institution = an der { $institution } { $city }
weeks = { $count } {
    $count ->
        [one] Woche
       *[other] Wochen
}

submission-date = Abgabedatum
processing-duration = Bearbeitungszeitraum
course = Kurs
training-company = Ausbildungsfirma
department = Abteilung
supervisor-at-training-company = Betreuer der Ausbildungsfirma

statutory-declaration = Eidesstattliche Erklärung

place-of-signature = Ort
date-of-signature = Datum
signature = Unterschrift

confidentiality-agreement = Sperrvermerk
confidentiality-stamp = VERTRAULICH

tool = Werkzeug
usage-description = Beschreibung der Nutzung

### Base template
by = von
abstract = Zusammenfassung

# lists headers
list-of-notes = Notizverzeichnis
table-of-contents = Inhaltsverzeichnis
abbreviations = Abkürzungsverzeichnis
glossary = Glossar
list-of-figures = Abbildungsverzeichnis
list-of-tables = Tabellenverzeichnis
list-of-code = Quellcodeverzeichnis
bibliography = Literaturverzeichnis

# appendix
appendix = Anhang
list-of-appendices = Anhangsverzeichnis


### DHBW
dhbw-long = Dualen Hochschule Baden-Württemberg
ka = Karlsruhe
ma = Mannheim
as-part-of-examination-dhbw = für die Prüfung zum
in-field-of-study = des Studiengangs { $study }
matriculation-number = Matrikelnummer
supervisor-at-university = Gutachter der Studienakademie
course-director = Studiengangsleiter

statutory-declaration-note-dhbw = { $author-count ->
    [one] Ich versichere hiermit, dass ich die vorliegende Arbeit selbstständig verfasst und keine anderen als die angegebenen Quellen und Hilfsmittel verwendet habe und diese Arbeit bei keiner anderen Prüfung mit gleichem oder vergleichbarem Inhalt vorgelegt habe und diese bislang nicht veröffentlicht wurde.
   *[other] Wir versichern hiermit, dass wir die vorliegende Arbeit selbstständig verfasst und keine anderen als die angegebenen Quellen und Hilfsmittel verwendet haben und diese Arbeit bei keiner anderen Prüfung mit gleichem oder vergleichbarem Inhalt vorgelegt haben und diese bislang nicht veröffentlicht wurde.
}
statutory-declaration-note-dhbw-printed = { $author-count ->
    [one] Des Weiteren versichere ich, dass die eingereichte elektronische Fassung mit der gedruckten Ausfertigung übereinstimmt.
   *[other] Des Weiteren versichern wir, dass die eingereichte elektronische Fassung mit der gedruckten Ausfertigung übereinstimmt.
}
statutory-declaration-note-dhbw-ai = { $author-count ->
    [one] Ich habe bei der Erstellung der Arbeit KI-Werkzeuge eingesetzt. Dies habe ich an entsprechender Stelle der Arbeit kenntlich gemacht.
   *[other] Wir haben bei der Erstellung der Arbeit KI-Werkzeuge eingesetzt. Dies haben wir an entsprechender Stelle der Arbeit kenntlich gemacht.
}

statutory-declaration-note-dhbw-old = { $author-count ->
    [one] Ich versichere hiermit, dass ich meine { $type } dem Thema: "{ $title }" selbstständig verfasst und keine anderen als die angegebenen Quellen und Hilfsmittel benutzt habe.
   *[other] Wir versichern hiermit, dass wir unsere { $type } dem Thema: "{ $title }" selbstständig verfasst und keine anderen als die angegebenen Quellen und Hilfsmittel benutzt haben.
}

statutory-declaration-note-dhbw-old-printed = { $author-count ->
    [one] Ich versichere zudem, dass die eingereichte elektronische Fassung mit der gedruckten Fassung übereinstimmt.
   *[other] Wir versichern zudem, dass die eingereichte elektronische Fassung mit der gedruckten Fassung übereinstimmt.
}

confidentiality-agreement-note-dhbw = Der Inhalt dieser Arbeit darf weder als Ganzes noch in Auszügen Personen außerhalb des Prüfungsprozesses und des Evaluationsverfahrens zugänglich gemacht werden, sofern keine anderslautende Genehmigung des Dualen Partners vorliegt.
ai-acknowledgement-heading-dhbw = Anmerkung zur Nutzung von Künstlicher Intelligenz

### IHK
as-part-of-examination-ihk = Im Rahmen der
in-the-training-occupation = des Ausbildungsberufes
examinee-number = Prüflingsnummer
confidentiality-agreement-note-ihk = Der Inhalt dieser Arbeit darf weder als Ganzes noch in Auszügen Personen außerhalb des Prüfungsprozesses und des Evaluationsverfahrens zugänglich gemacht werden, sofern keine anderslautende Genehmigung des Ausbildungsbetriebes vorliegt.
