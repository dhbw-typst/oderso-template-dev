#import "../template/template/lib.typ": *
#let mode = sys.inputs.at("mode", default: "ordinary")
#let breaking = if mode == "ordinary" { true } else { mode }
#show: project.with(general.layout(pagebreak-heading: breaking))
Page one.
= First heading <first-heading>
Some content.
= Second heading <second-heading>
#context {
  let first = query(<first-heading>).first().location().page()
  let second = query(<second-heading>).first().location().page()
  assert.eq(first, if mode == "odd" { 3 } else { 2 })
  assert.eq(second, if mode == "odd" { 5 } else if mode == "even" { 4 } else {
    3
  })
}
