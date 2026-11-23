#import "../template/template/lib.typ": *
#let glossarium = dependency.glossarium
#import dependency: glossarium
#let mode = sys.inputs.at("mode", default: "hidden")
#let terms = if mode == "empty" { () } else {
  (
    (
      key: "term",
      short: "TERM",
      long: "Long term",
      description: "Term definition",
    ),
  )
}
#let abbr = if mode == "empty" { () } else {
  (
    (
      key: "abbr",
      short: "ABBR",
      long: "Long abbreviation",
      description: "Abbreviation definition",
    ),
  )
}
#let hidden = (
  mode
    in (
      "hidden",
      "none",
      "empty-generator",
      "replacement",
      "unsafe-gls",
      "unsafe-ref",
    )
)
#show: project.with(
  frontbackmatter.glossary(
    glossary: terms,
    position: 1,
    enable: mode not in ("hidden", "unsafe-gls", "unsafe-ref"),
    generator-function: if mode == "none" { none } else if mode
      == "empty-generator" { cfg => [] } else if mode == "replacement" {
      cfg => [Custom glossary without targets]
    } else {
      cfg => if terms.len() > 0 {
        glossarium.print-glossary(cfg.front-back-matter.glossary.entries)
      }
    },
  ),
  frontbackmatter.abbreviations(
    abbreviations: abbr,
    position: 2,
    enable: not hidden,
    generator-function: cfg => if abbr.len() > 0 {
      glossarium.print-glossary(cfg.front-back-matter.abbreviations.entries)
    },
  ),
  if hidden and mode not in ("unsafe-ref", "unsafe-gls") {
    component.show-rules(show-key: "hidden-refs", show-fun: it => {
      show ref.where(target: <abbr>): _ => glossarium.gls("abbr", link: false)
      show ref.where(target: <term>): _ => glossarium.gls("term", link: false)
      it
    })
  } else { (:) },
  component.show-rules(show-key: "capture", show-fun: it => {
    show text: node => [#metadata(node.text)<glossary-text>#node]
    it
  }),
)
#if mode == "empty" { [No terms] } else if mode == "unsafe-gls" {
  glossarium.gls("term")
} else if mode == "unsafe-ref" { [@term] } else {
  glossarium.gls("term", link: not hidden)
  glossarium.gls("term", link: not hidden)
  [@abbr @abbr]
  glossarium.gls("abbr", link: false)
}
#context if hidden and mode not in ("unsafe-gls", "unsafe-ref") {
  let texts = query(<glossary-text>).map(it => it.value).join(" ")
  assert.eq(texts.matches("Long term").len(), 1)
  assert.eq(texts.matches("Long abbreviation").len(), 1)
}
