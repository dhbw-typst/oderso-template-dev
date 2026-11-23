#import "../template/template/lib.typ": *
#import "../template/template/config/resolve.typ": _resolve
#let first = feature.codly(display-icon: false, languages: (
  typ: (name: "Typst", color: red),
))
#let off = _resolve(first, feature.codly(enable: false), feature.codly(
  display-name: false,
  languages: (typ: (color: blue)),
))
#assert.eq(off.feature.codly.enable, false)
#assert.eq(off.feature.codly.options.languages.typ, (
  name: "Typst",
  color: blue,
))
#assert("feature-codly" not in off.component.at("show-rules", default: (:)))
#let on = _resolve(off, feature.codly(enable: true))
#assert.eq(on.feature.codly.options.display-icon, false)
#assert.eq(on.feature.codly.options.display-name, false)
#assert.eq(
  on.component.show-rules.keys().filter(k => k == "feature-codly").len(),
  1,
)
#let style = _resolve(theme.spotless(), feature.codly(display-icon: true))
#assert.eq(style.feature.codly.options.zebra-fill, none)
#assert.eq(style.feature.codly.options.display-icon, true)
#assert.eq(_resolve().feature, (:))
#assert.eq(
  _resolve(feature.drafting(watermark: [First]), feature.drafting(
    watermark: [New],
  ))
    .feature
    .drafting
    .watermark,
  [New],
)
#assert.eq(
  _resolve(feature.drafting(enable: false), feature.drafting(
    watermark: [Patch],
  ))
    .feature
    .drafting
    .enable,
  false,
)
#assert.eq(
  _resolve(feature.drafting(watermark: [New]), (
    feature: (drafting: (watermark: [Raw])),
  ))
    .feature
    .drafting
    .watermark,
  [Raw],
)
#assert("drafting" not in _resolve(feature.drafting()).general)
#let native = _resolve(first, component.show-rules(
  show-key: "feature-codly",
  show-enable: false,
))
#assert.eq(native.component.show-rules.feature-codly.enable, false)
Feature configuration assertions.
