#import "../template/template/lib.typ": *
#let field = sys.inputs.at("field", default: "spacing")
#show: project.with(general.typography.body(..((field): 15pt)))
First paragraph.

Second paragraph.
#context {
  if field == "spacing" { assert.eq(par.spacing, 15pt) } else {
    assert.eq(par.leading, 15pt)
  }
}
