#import "../template/template/lib.typ": *
#let mode = sys.inputs.at("mode", default: "ka")
#let year = sys.inputs.at("year", default: "23")
#let old = (
  (
    firstname: "STALE_FIRST",
    lastname: "STALE_LAST",
    course: "TINF24B1",
    matriculation-number: "STALE_ID",
    examinee-number: "STALE_ID",
  ),
)
#let effective = (
  (
    firstname: "EffectiveFirst",
    lastname: "EffectiveLast",
    course: "TINF" + year + "B1",
    matriculation-number: "EffectiveID",
    examinee-number: "EffectiveID",
  ),
)
#let institute = if mode == "ka" { institution.dhbw-ka } else if mode == "ma" {
  institution.dhbw-ma
} else { institution.ihk }
#let ai = if mode == "ma" {
  institute.frontbackmatter.ai-declaration-form(authors: (
    (
      product-name: "EffectiveAI",
      topic: "Topic",
      topic-editing: "Editing",
      research: "Research",
      design: "Design",
    ),
  ))
} else if mode == "ka" {
  institute.frontbackmatter.ai-declaration(entries: (
    (tool: "EffectiveAI", usage: "Editing"),
  ))
} else { (:) }
#let setup = institute.setup(
  authors: old,
  title-long: "STALE_TITLE",
  thesis-type: "STALE_TYPE",
  submission-date: "STALE_DATE",
)
#show: project.with(
  theme.spotless(),
  setup,
  ai,
  // Keeping data while changing another field is also exercised at render time.
  if mode == "ma" {
    institute.frontbackmatter.ai-declaration-form(position: 100)
  } else if mode == "ka" {
    institute.frontbackmatter.ai-declaration(position: 100)
  } else { (:) },
  general.metadata(
    authors: effective,
    title-long: "EffectiveTitle",
    title-short: "EffectiveShort",
    thesis-type: "EffectiveType",
    submission-date: datetime(year: 2026, month: 11, day: 22),
    submission-date-format: "[year]-[month]-[day]",
    examination: "EffectiveExamination",
    study: "EffectiveStudy",
    training-occupation: "EffectiveTraining",
    company-name: "EffectiveCompany",
    company-city: "EffectiveCity",
    company-department: "EffectiveDepartment",
    company-supervisor: "EffectiveSupervisor",
    university-supervisor: "EffectiveUniversity",
    processing-period-weeks: 12,
  ),
  component.show-rules(
    show-key: "capture-text",
    show-order: -2000,
    show-fun: it => {
      show text: node => [#metadata(node.text)<rendered-text>#node]
      it
    },
  ),
)
Body.
#context {
  let texts = query(<rendered-text>).map(it => it.value).join(" ")
  for key in (
    "EffectiveTitle",
    "EffectiveType",
    "EffectiveFirst",
    "EffectiveLast",
    "EffectiveID",
    "2026-11-22",
    "EffectiveExamination",
    "EffectiveCompany",
    "EffectiveCity",
    "EffectiveDepartment",
    "EffectiveSupervisor",
  ) {
    assert(texts.contains(key), message: "Final metadata not rendered: " + key)
  }
  for key in (
    "STALE_FIRST",
    "STALE_LAST",
    "STALE_ID",
    "STALE_TITLE",
    "STALE_TYPE",
    "STALE_DATE",
  ) {
    assert(not texts.contains(key), message: "Setup snapshot leaked: " + key)
  }
  assert(
    texts.matches(regex("EffectiveFirst")).len()
      >= if mode == "ma" { 3 } else { 2 },
    message: "Effective author missing from signature or AI form",
  )
  if mode != "ihk" {
    assert(texts.contains("EffectiveAI"))
    assert(texts.contains("EffectiveStudy"))
    if year == "23" {
      assert(
        texts.matches(regex("EffectiveTitle")).len() >= 2,
        message: "Course-year-dependent old declaration did not use final title",
      )
    } else {
      assert.eq(
        texts.matches(regex("EffectiveTitle")).len(),
        1,
        message: "Final course year did not select the new declaration",
      )
    }
  } else { assert(texts.contains("EffectiveTraining")) }
}
