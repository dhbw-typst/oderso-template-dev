#import "../template/template/lib.typ": *
#import "../template/template/config/resolve.typ": _resolve
#let base = (
  component.page(margin: (left: 1cm, right: 2cm)),
  component.body.header(generator-function: (cfg, _) => [Custom], height: 1cm),
)
#let original = _resolve(..base)
#let restored = _resolve(
  ..base,
  feature.print(binding-space: 3mm),
  feature.print(enable: false),
)
#assert.eq(restored.resolved-sections, original.resolved-sections)
#let off = _resolve(
  feature.print(enable: false, binding-space: 3mm),
  feature.print(two-sided: true),
)
#assert.eq(off.resolved-output.print, false)
#let on = _resolve(..base, off, feature.print(enable: true))
#assert.eq(on.feature.print.binding-space, 3mm)
#assert.eq(on.resolved-output.two-sided, true)
#for policy in (false, "even", "odd") {
  assert.eq(
    _resolve(feature.print(), general.layout(pagebreak-heading: policy))
      .resolved-output
      .pagebreak-heading,
    policy,
  )
}
#assert.eq(_resolve(feature.print()).resolved-output.pagebreak-heading, "odd")
#assert.eq(
  _resolve(feature.print(recto-chapters: false))
    .resolved-output
    .pagebreak-heading,
  false,
)
#assert.eq(
  _resolve(feature.print(two-sided: false)).resolved-output.pagebreak-heading,
  false,
)
#assert.eq(
  _resolve(feature.print(), component.body.header(enable: false))
    .resolved-sections
    .body
    .header
    .enable,
  false,
)
Print policy assertions.
