#import "../template/template/lib.typ": *
#import "@preview/linguify:0.5.0": linguify-raw, set-database
#show: project.with(
  general.metadata(lang: "fr"),
  component.show-rules(show-key: "localization", show-fun: it => {
    set-database((lang: (fr: (custom-title: "Titre personnalisé"))))
    it
  }),
  frontbackmatter.entry(
    "custom-locale",
    position: -1,
    generator-function: cfg => context {
      assert.eq(linguify-raw("custom-title"), "Titre personnalisé")
      heading(linguify-raw("custom-title"))
    },
  ),
)
Body
#context assert.eq(text.lang, "fr")
