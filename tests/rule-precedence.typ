#import "../template/template/lib.typ": *
#let style(fill) = it => {
  set text(fill: fill)
  it
}
#show: project.with(
  component.show-rules(show-key: "inner", show-order: 0, show-fun: style(red)),
  component.show-rules(show-key: "outer", show-order: 1, show-fun: style(blue)),
)
// Callbacks compose in ascending order, but the later blue callback wraps the
// earlier red callback: the inner red style therefore wins.
#context assert.eq(text.fill, red)
Rule precedence.
