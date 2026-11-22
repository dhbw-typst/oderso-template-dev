// Mannheim: structured supervisor metadata and the per-author AI form.
#import "../template/template/lib.typ": institution, project, theme
#import institution: dhbw-ma

#show: project.with(
  theme.spotless(),
  dhbw-ma.setup(
    lang: "en",
    title-long: "An example thesis at DHBW Mannheim",
    title-short: "Mannheim example",
    thesis-type: "Bachelorarbeit",
    submission-date: "24.12.2026",
    processing-period-weeks: 12,
    company-name: "Example Ltd",
    company-city: "Mannheim",
    company-supervisor: (
      firstname: "Kim",
      lastname: "Example",
      email: "kim@example.org",
      phone-number: "+49 000 123456",
    ),
    university-supervisor: (
      firstname: "Robin",
      lastname: "Example",
      email: "robin@example.org",
      phone-number: "+49 000 654321",
    ),
    course-director: "Dr. Taylor Example",
    authors: (
      (
        firstname: "Alex",
        lastname: "Example",
        matriculation-number: "1234567",
        course: "TINF24B1",
        email: "alex@example.org",
        address: "Example Street 1, 68159 Mannheim",
        phone-number: "+49 000 111111",
      ),
    ),
  ),
  dhbw-ma.frontbackmatter.ai-declaration-form(
    module-name: "Bachelor thesis",
    semester: "6",
    exam-type: "Bachelorarbeit",
    module-submission-date: "24.12.2026",
    authors: (
      (
        product-name: "DeepL",
        topic: "An example thesis at DHBW Mannheim",
        topic-editing: "No AI assistance",
        research: "No AI assistance",
        design: "Translation of selected sentences",
      ),
    ),
  ),
)

= Introduction

The cover derives its supervisor rows from dictionaries rather than strings.
The back matter includes the statutory declaration, confidentiality clause,
and a filled AI declaration form for the author.
