#import "../template/template/lib.typ": *
#let mode = sys.inputs.at("mode", default: "sizes")
#let sizes = (20pt, 19pt, 18pt, 17pt, 16pt, 15pt, 77pt)
#show: project.with(
  general.typography.body(size: 11pt),
  if mode == "absent" { (:) } else { general.typography.heading(sizes: sizes) },
  if mode == "empty" { general.typography.heading(sizes: ()) } else { (:) },
)
#for level in (1, 6, 7, 8) {
  heading(level: level, [
    #context assert.eq(text.size, if mode == "sizes" and level <= sizes.len() {
      sizes.at(level - 1)
    } else if level == 1 { 15.4pt } else { 11pt })
    Level #level
  ])
}
