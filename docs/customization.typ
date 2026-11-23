#set document(title: "ODERSO customization contracts")
#set text(lang: "en", size: 10pt)
#set page(margin: 2cm, numbering: "1")
#set heading(numbering: "1.1")

= Configuration and scoped rules

Configuration producers are pure dictionaries composed positionally with
`project.with(...)`. Omitted fields inherit; dictionaries merge recursively;
arrays replace. Disabling retains settings and generators; explicit `none`
clears a callback/generator. Only enabled, nonempty matter is wrapped and printed.
Required institutional fields are checked when the enabled generator renders.

Callbacks execute in ascending order and later callbacks form *outer* wrappers.
An earlier inner set rule can therefore be stronger than a later outer set rule.
Equal orders preserve key insertion order. A key patch retains omitted fields;
`show-enable: false` disables without discarding the function.

All common and institution-specific matter producers accept named `show-key`,
`show-order`, `show-fun`, and `show-enable` hooks through `..rules`.
`frontbackmatter.entry(key, ...)` exposes arbitrary keyed matter through the same
renderer. Generators keep `(cfg)` signatures and consume final configuration;
running components keep `(cfg, last-page)` signatures. `cfg.resolved-section`
and `cfg.resolved-sections` expose effective page/component settings.

Common matter producers, including `statutory-declaration` and
`confidentiality-clause`, live only under `frontbackmatter`. Institution setups
install their compliant generators and defaults; institution-local matter
namespaces expose only their distinct AI declarations/forms. Configure total
page display with `component.footer(show-total-pages: ...)` or a section-local
footer patch, not through the theme.

Heading sizes address every supplied level, including levels above six.
An absent or explicitly emptied array leaves native heading sizing; modular-scale
presets store calibrated values and do not rescale after later body-size changes.

== Cover and institution presentation

Shared section page settings intentionally exclude the cover in screen output.
A cover-local native `set page(...)` rule provides independent page geometry.
`component.coversheet(presentation-generator: m => (...))` supplies computed
`submission-info` and `misc-key-value` from final semantic metadata. Explicit
metadata presentation fields, including `none`/`()`, still win. Unknown institution
identifiers no longer fall through to DHBW presentation. Theme geometry is
independent of institution semantics.

== Glossary visibility

For glossary/abbreviations `enable: false` hides the listing, not supplied
definitions or first-use expansion. Clear the entries array to remove definitions.
Replaced/none/empty listing generators also retain definitions. Registration alone
does not supply printed link targets. Without a printed listing use
`dependency.glossarium.gls("term", link: false)`. Default linked calls fail when
their target is absent; `@term` requires an explicit unlinked native rule:

```typ
show ref.where(target: <term>): _ => dependency.glossarium.gls("term", link: false)
```

Target each spelling/suffix used (for example `<term:pl>` can call
`dependency.glossarium.glspl("term", link: false)`). This remains a package/native
escape hatch, not a reference-option matrix. Linked references work normally
with a printed listing. Replacement generators wanting links must produce package
targets through `print-glossary`.

= Features versus appearance

`theme` supplies coherent visual identity; `theme.shared` supplies small reusable
appearance/convention presets. `feature` owns optional capabilities: Codly,
drafting output, and printing. Features work without themes; themes can contribute
feature defaults as mergeable data. `general` owns metadata, typography, and basic
layout; components/matter own document parts. Underlying package APIs remain
available through `dependency.codly`, `dependency.drafting`, and
`dependency.glossarium`.

Feature presence activates by default. Omitted `enable` inherits any explicit
value; option-only patches never re-enable an explicitly disabled feature.
Disabling retains options; `enable: true` deliberately restores them later.
Codly named options forward to the pinned package rather than duplicating template
parameters. Dictionaries merge and arrays replace. Final configuration and
initialization apply once through the stable `feature-codly` document rule
(order -2000); existing keyed-rule composition/disabling/replacement still applies.
Do not install `codly-init` again when using the adapter. Direct local package
configuration can customize later content as before.

Drafting separates watermark/listing capability and placement from appearance.
`notes-position: none` retains notes before the cover; an integer uses the shared
keyed `drafting-notes` matter entry. Customize that entry through
`frontbackmatter.entry` hooks/replacement. Disabling suppresses watermark and
listing, not explicit note content inserted through the package. Watermark
generators consume final configuration through `cfg.feature.drafting`. No matching
notes means no listing page.

Compose `theme.shared.table-conventions()`, `theme.shared.urls()`, and
`theme.shared.notes()` independently; Codly settings belong to `feature.codly`.
Unthemed documents opt in with `feature.codly()`. Spotless supplies its calibrated
Codly defaults, overridable or disabled through the same feature producer.

#raw(read("../examples/features.typ"), lang: "typ", block: true)

= Reversible print output

`feature.print(enable: ..., two-sided: true, binding-space: 5mm)` coordinates
print layout without changing theme or submission semantics. `cfg.resolved-output`
exposes final `print`, `two-sided`, `binding-space`, and `pagebreak-heading` policy
before section layout resolves. The section's `base-page` preserves underlying
layout; `page` and `reserved-margin` expose derived print layout.

- Duplex maps final left/right to inside/outside, preserving asymmetry and
  existing logical margins. Binding space is added to the inside margin.
  Simplex uses a fixed left binding edge, even for logical-margin input.
- These are deliberate transforms, not defaults merged over explicit user
  component settings. Later disabling restores underlying layout. Explicit
  header/footer generators, disabling, and reservation heights remain untouched.
  Scoped native page rules can override derived margins. Right-bound documents
  can use native `set page(binding: right)` with logical margins and custom
  running-component arrangement.
- Duplex starts ordinary/unspecified body chapters and appendix entries on
  physical odd pages. Explicit false/even/odd general.layout chapter policies
  remain authoritative. `recto-chapters: false` keeps ordinary breaks.
  Section alignment occurs before counter reset, keeping displayed body page 1.
  Blank parity pages may carry preceding running components.
- Physical parity includes cover/frontmatter pages independently of displayed
  numbering resets. Spotless swaps its header arrangement and places footer
  numbers outside. Custom generators can use `here().page()` and
  `cfg.resolved-output.two-sided` to do the same.
- Print output derives a weak cover margin from shared layout (or 2.5cm when
  absent); local native cover rules can override it. Screen output retains
  independent cover geometry.
- Printing never changes `digital-only`, `digital-submission`, legal wording,
  dates, or signatures. A printed proof is not a different submission mode.

This is layout policy, not printer-driver duplex setup, imposition, crop marks,
color conversion, or a bleed/prepress engine. Those workflows remain native
page rules or external tooling. Binding space uses existing relative-length
arithmetic; choose nonnegative lengths.

#raw(read("../examples/printing.typ"), lang: "typ", block: true)

= Advanced customization without an option catalogue

These public-API examples/regressions compile in the test runner:

- `examples/advanced-customization.typ`: independent cover geometry, a new
  institution's presentation, TOC title/depth/spacing/targets, independent table
  listing placement, heading spacing, separate inline/block code, per-kind
  captions/supplements, and extra PDF metadata.
- `tests/structural-hooks.typ`: selector-backed appendix numbering, outlined and
  supplement overrides, heading-counter changes, custom visible headings,
  continuous matter with scoped `show pagebreak`, and a body page-counter update.
  Plain outer set rules may lose to structural inner defaults; focused show-set
  selectors are a stronger native seam.
- Cover/header/matter generator replacement handles custom logos, title/table/
  stamp slots, running arrangements, declaration/signature geometry, and AI forms.
  For fully custom appendix scaffolding, clear appendix entries and use keyed
  matter. Legal revisions remain compliant institution defaults; replace the
  generator for an established alternative. Mannheim form signing follows final
  declaration submission settings; custom generators can decouple presentation.
- Scoped native page rules handle unusual dimensions, columns, foreground/
  background and auto margins where template reservation arithmetic is unnecessary.
  Component margin producers retain their explicit arithmetic restrictions.
- Localization/resources use package/database hooks (a document rule may call
  `linguify.set-database`); generators replace labels without a locale schema.
- `util.styled-table`, `util.tablefigure`, and `util.tablefigure-raw` are opt-in
  local helpers. Native figures/tables bypass injected rules and Roman helper
  numbering. Caption-source separators and inline glossary formatting likewise
  remain utility/direct-package customization.

Validation covers supported compilers, examples, generated API labels, and
print PDF glyph positions via Poppler. Compilation alone is not visual parity
or full prepress validation. All test artifacts use temporary directories.
