#import "../template/template/lib.typ": *
#let printing = sys.inputs.at("print", default: "false") == "true"
#show: project.with(
  institution.dhbw-ka.setup(authors: (
    (
      firstname: "Jane",
      lastname: "Doe",
      course: "TINF24",
      matriculation-number: "123",
    ),
  )),
  component.coversheet(enable: false),
  frontbackmatter.statutory-declaration(
    digital-only: true,
    digital-submission: true,
  ),
  feature.print(enable: printing),
  component.show-rules(show-key: "capture", show-fun: it => {
    show text: node => [#metadata(node.text)<submission-text>#node]
    it
  }),
)
Body
#context [#metadata(
  query(<submission-text>).map(it => it.value).join(""),
)<submission-wording>]
