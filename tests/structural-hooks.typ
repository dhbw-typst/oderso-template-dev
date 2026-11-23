#import "../template/template/lib.typ": *
#show: project.with(
  frontbackmatter.entry(
    "first",
    position: -2,
    generator-function: cfg => [First <first-matter>],
  ),
  frontbackmatter.entry(
    "second",
    position: -1,
    generator-function: cfg => [Second <second-matter>],
  ),
  component.frontmatter.show-rules(show-key: "continuous", show-fun: it => {
    show pagebreak: _ => []
    it
  }),
  component.appendix.entries(appendices: (
    (
      title: [Original],
      reference: "custom-appendix",
      text: [Custom text #context assert.eq(counter(heading).get().first(), 9)],
    ),
  )),
  component.appendix.show-rules(show-key: "structure", show-fun: it => {
    show heading.where(level: 1): set heading(
      numbering: "A.",
      outlined: false,
      supplement: [Annex],
    )
    show heading.where(level: 1): node => {
      counter(heading).update(9)
      text([Replacement title])
    }
    it
  }),
)
#counter(page).update(7)
Body <custom-body>
#context {
  assert.eq(counter(page).get().first(), 7)
  let first = query(<first-matter>).first().location().page()
  assert.eq(query(<second-matter>).first().location().page(), first)
  let appendix = query(heading).last()
  assert.eq(appendix.numbering, "A.")
  assert.eq(appendix.outlined, false)
  assert.eq(appendix.supplement, [Annex])
}
