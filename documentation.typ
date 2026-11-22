// LTeX: enabled=false
#import "@preview/tidy:0.4.3"
#import "template/template/lib.typ" as oderso

// Follow the public facade instead of maintaining a second list of exports.
// lib.typ files expose their imports; implementation files expose declarations
// and wildcard re-exports, not their private implementation dependencies.
#let identifier = "[\\w-]+"
#let import-pattern = regex(
  "(?m)^#import \"([^\"]+)\"(?: as ("
    + identifier
    + "))?(?::\\s*(\\*|\\([^)]*\\)|"
    + identifier
    + "(?: as "
    + identifier
    + ")?(?:, *"
    + identifier
    + ")*))?",
)
#let definition-pattern = regex("(?m)^#let (" + identifier + ")\\s*(\\(?)")

#let resolve-path(file, relative) = {
  let parts = file.split("/").slice(0, -1)
  for part in relative.split("/") {
    if part == ".." {
      let _ = parts.pop()
    } else if part != "." {
      parts.push(part)
    }
  }
  parts.join("/")
}

#let parse-source(file) = {
  let source = read(file)
  let imports = (:)
  let wildcard-files = ()
  for match in source.matches(import-pattern) {
    let (path, alias, items) = match.captures
    let external = path.starts-with("@")
    let target = if external { path } else { resolve-path(file, path) }
    if alias != none or items == none {
      let name = if alias != none { alias } else {
        path.split("/").last().split(".").first()
      }
      imports.insert(name, (kind: "module", file: target, external: external))
    }
    if items == "*" {
      if not external { wildcard-files.push(target) }
    } else if items != none {
      for item in items
        .trim(regex("[()]"))
        .split(",")
        .map(str.trim)
        .filter(x => x != "") {
        let names = item.split(" as ")
        imports.insert(names.last(), (
          kind: "import",
          file: target,
          name: names.first(),
          external: external,
        ))
      }
    }
  }

  // Tidy only discovers documented definitions. Add an empty doc-comment to
  // undocumented declarations so new public functions/options cannot disappear.
  let lines = source.split("\n")
  let annotated = ()
  for (index, line) in lines.enumerate() {
    if (
      line.starts-with("#let ")
        and (
          index == 0 or not lines.at(index - 1).trim().starts-with("///")
        )
    ) {
      annotated.push("///")
    }
    annotated.push(line)
  }
  let parsed = tidy.parse-module(
    annotated.join("\n"),
    enable-curried-functions: false,
  )
  let definitions = (:)
  let matches = source.matches(definition-pattern)
  for (index, match) in matches.enumerate() {
    let name = match.captures.first()
    let end = if index + 1 < matches.len() {
      matches.at(index + 1).start
    } else { source.len() }
    let doc = (parsed.functions + parsed.variables).find(x => x.name == name)
    definitions.insert(name, (
      kind: "definition",
      file: file,
      name: name,
      doc: doc,
      code: source.slice(match.end, end).trim(),
      function: match.captures.at(1) == "(",
    ))
  }
  (imports: imports, wildcards: wildcard-files, definitions: definitions)
}

// Resolve a binding in its source scope, including imports used by aliases.
#let lookup(file, name) = {
  let source = parse-source(file)
  if name in source.definitions { return source.definitions.at(name) }
  if name in source.imports {
    let binding = source.imports.at(name)
    if binding.kind == "import" and not binding.external {
      return lookup(binding.file, binding.name)
    }
    return binding
  }
  for wildcard in source.wildcards.rev() {
    let binding = lookup(wildcard, name)
    if binding != none { return binding }
  }
  none
}

#let lookup-expression(file, expression) = {
  let parts = expression.split(".")
  let binding = lookup(file, parts.first())
  for part in parts.slice(1) {
    if binding == none or binding.kind != "module" or binding.external {
      return none
    }
    binding = lookup(binding.file, part)
  }
  binding
}

#let public-bindings(file) = {
  let source = parse-source(file)
  let bindings = (:)
  for wildcard in source.wildcards {
    bindings += public-bindings(wildcard)
  }
  if file.ends-with("/lib.typ") {
    for (name, binding) in source.imports {
      bindings.insert(name, if binding.kind == "import"
        and not binding.external {
        lookup(binding.file, binding.name)
      } else { binding })
    }
  }
  bindings += source.definitions
  bindings.pairs().filter(((name, _)) => not name.starts-with("_")).to-dict()
}

// Inherit the signature of aliases and of the anonymous function returned by a
// factory (e.g. component.body.header = make-header("body")). The factory's own
// scope argument is deliberately not part of the public function signature.
#let definition-doc(binding) = {
  let doc = binding.doc
  assert(
    doc != none,
    message: "Could not parse public definition: " + binding.name,
  )
  if not binding.function {
    let expression = binding.code.trim(regex("[=\\s]"), at: start)
    let alias = expression.match(regex(
      "^(" + identifier + "(?:\\." + identifier + ")*)\\s*(\\(?)",
    ))
    if alias != none {
      let parent = lookup-expression(binding.file, alias.captures.first())
      if parent != none and parent.kind == "definition" {
        let inherited = if alias.captures.at(1) == "(" {
          let anonymous = parent.code.match(regex("(?s)^.*?=\\s*\\{\\s*\\("))
          assert(
            anonymous != none,
            message: "Unsupported public function factory: " + binding.name,
          )
          let signature = (
            "///\n#let " + binding.name + "(" + parent.code.slice(anonymous.end)
          )
          tidy
            .parse-module(signature, enable-curried-functions: false)
            .functions
            .first()
        } else {
          definition-doc(parent)
        }
        if "args" in inherited {
          doc.args = inherited.args
          doc.return-types = if "type" in doc { (doc.type,) } else {
            inherited.at("return-types", default: none)
          }
          if "type" in doc { let _ = doc.remove("type") }
          if doc.description == "" { doc.description = inherited.description }
        }
      }
    }
  }
  doc
}

#let collect-api(file, namespace: "") = {
  let modules = ()
  let definitions = ()
  let packages = ()
  let bindings = public-bindings(file)
  for (name, binding) in bindings {
    let qualified = if namespace == "" { name } else { namespace + "." + name }
    assert(
      binding != none,
      message: "Could not resolve public export: " + qualified + " in " + file,
    )
    if binding.kind == "module" {
      if binding.external {
        packages.push((name: qualified, package: binding.file))
      } else {
        modules += collect-api(binding.file, namespace: qualified)
      }
    } else {
      let value = eval("oderso." + qualified, scope: (oderso: oderso))
      let doc = if type(value) == function { definition-doc(binding) } else {
        binding.doc
      }
      assert(
        doc != none,
        message: "Could not parse public definition: " + qualified,
      )
      assert(
        type(value) != function or "args" in doc,
        message: "Could not resolve public function signature: " + qualified,
      )
      doc.name = qualified
      // References in doc-comments are local to the documented namespace.
      let qualify-refs(value) = value.replace(
        regex("@(" + identifier + ")"),
        match => {
          let target = match.captures.first()
          if namespace != "" and target in bindings {
            "@" + namespace + "." + target
          } else { match.text }
        },
      )
      doc.description = qualify-refs(doc.description)
      if "args" in doc {
        for (arg, info) in doc.args {
          if "description" in info {
            info.description = qualify-refs(info.description)
          }
          doc.args.insert(arg, info)
        }
      } else {
        // Include preset expressions verbatim: repr() rounds relative lengths,
        // which would obscure the exact typography values configured here.
        doc.type = str(type(value))
        doc.description = (
          qualify-refs(binding.doc.description)
            + "\n\n```typc\n"
            + binding.code.trim(regex("[=\\s]"), at: start)
            + "\n```"
        )
      }
      definitions.push(doc)
    }
  }
  if definitions.len() > 0 or packages.len() > 0 {
    // Examples use their original unqualified names and the actual module
    // scope; the public entrypoint is also available for qualified examples.
    let scope = eval("import " + repr(file) + " as source; dictionary(source)")
    modules.insert(0, (
      name: if namespace == "" { "Template entrypoint" } else { namespace },
      label-prefix: "api-",
      scope: scope + (oderso: oderso),
      preamble: "",
      functions: definitions.filter(x => "args" in x),
      variables: definitions.filter(x => "args" not in x),
      packages: packages,
    ))
  }
  modules
}

#let api = collect-api("template/template/lib.typ")

#set document(title: "ODERSO — API reference")
#set text(lang: "en", size: 10pt)
#set page(paper: "a4", margin: 2cm, numbering: "1")
#set heading(numbering: none)
#show heading.where(level: 1): set text(size: 1.5em)
#show heading.where(level: 2): set text(size: 1.15em)
#show heading.where(level: 3): set heading(outlined: false)
#show heading.where(level: 4): set heading(outlined: false)
#show link: it => {
  if type(it.dest) == str {
    set text(fill: gray.darken(80%))
    underline(
      stroke: (paint: gray, thickness: 0.5pt, dash: "densely-dashed"),
      offset: 4pt,
      it,
    )
  } else { it }
}

#align(center)[
  #v(3em)
  #text("ODERSO", size: 2.5em, weight: "bold")

  Organized Documentation for Experimental Research and Scientific Outputs

  #v(1em)
  #grid(
    columns: 2,
    column-gutter: 5em,
    sys.inputs.at("version", default: "v?.?.?"),
    datetime.today().display("[month repr:long] [day], [year]"),
  )
  #link("https://github.com/dhbw-typst/oderso-template")
  #v(2em)
  #pad(x: 10%)[
    *ODERSO* is an academic Typst template for DHBW Karlsruhe, with adapters
    for DHBW Mannheim and IHK. This reference is generated from the public
    template exports, function signatures, defaults, and source doc-comments.
  ]
]
#v(2em)
#outline(title: [Contents], depth: 1)
#pagebreak()

= Getting started

Import the public entrypoint and compose configuration dictionaries with
`project`. Configurations are merged recursively from left to right: later
values override earlier values, while omitted options preserve the previous
layer. Options whose default is `config.util.default-value` are *unset*, not
literal document defaults. Theme and institution setup functions supply defaults.

```typ
#import "template/lib.typ": *

#show: project.with(
  theme.spotless(),
  institution.dhbw-ka.setup(
    title-long: "My thesis",
    title-short: "My thesis",
    thesis-type: "Bachelorarbeit",
    authors: ((
      firstname: "Jane",
      lastname: "Doe",
      matriculation-number: "1234567",
      course: "TINF24B1",
    ),),
    processing-period-weeks: 12,
    university-supervisor: "Dr. Example",
  ),
  general.typography.body(size: 12pt),
)

= Introduction
Your content goes here.
```

For institution-specific documents, add `institution.dhbw-ka.setup(...)`,
`institution.dhbw-ma.setup(...)`, or `institution.ihk.setup(...)` after the theme
and before your customizations. Institution-specific sections live under
`institution.<name>.frontbackmatter`, not the general `frontbackmatter` namespace.
See the bundled `main-dhbw-ka.typ`, `main-dhbw-ma.typ`, and `main-ihk.typ` examples
for complete metadata and section configurations.

Configuration functions return dictionaries to pass to `project.with(...)`;
utility functions such as `tablefigure` produce content to use in the body.
Front/back matter positions below zero render before the body; nonnegative
positions render after it, in ascending order. Headers and footers receive
the configuration and the last page number; section generators receive the
configuration. Show rules receive content and return content.

The following sections mirror the public namespaces. Internal dependencies
and underscore-prefixed definitions are excluded. Functions without source
doc-comments still appear with their signatures and defaults.

= Customization contract

`project.with()` supports a minimal body without a theme or institution.
Structural containers are empty; they do not create covers, running components,
matter, or appendix pages. Presets establish defaults, while customization
functions emit only supplied fields. Merge order is exactly positional order;
the customary order is structural defaults, theme, institution, user patches.

- Omitted arguments inherit. Dictionaries merge recursively; an empty dictionary
  does not delete inherited values. Arrays replace, so `entries: ()` explicitly
  clears a configured collection.
- `enable: false` disables a cover, header, footer, TOC, or matter entry while
  retaining its settings. `generator-function: none` clears the generator;
  optional `none` content clears only that content. Replacing a generator is not
  necessary for disabling. Empty matter content continues to be skipped.
- Page settings and running components inherit shared settings, then merge
  section-local patches. Margin precedence within a patch is explicit side,
  then `x`/`y`, then `rest`. Unspecified sides inherit and are completed only
  after resolution. A patch cannot mix `left`/`right` with `inside`/`outside`.
  Switching horizontal modes between layers maps inherited left to inside and
  right to outside, or conversely. `auto` margins are unsupported because
  reserved header/footer heights require arithmetic.
- Matter sorts by ascending signed position: negative before the body,
  nonnegative after it. Equal positions preserve the entry's original insertion
  order. Explicit empty appendix entries create no appendix scaffolding.

Institution setup stores semantic metadata. Later `general.metadata(...)`
patches reach cover rows, declarations, signatures, and AI forms. Datetime
submission dates use the final `submission-date-format`. Explicit `submission-info`
and `misc-key-value` are still cover presentation overrides; `none` or an empty
array clears these where applicable. Required author fields are checked only
when their enabled built-in generator renders.

Built-in covers derive presentation at render time; custom generators read final
semantic metadata or explicitly supplied presentation overrides, rather than
expecting setup to have materialized presentation fields.

Heading `sizes` are an explicit array for levels 1 onward. Modular-scale presets
calculate concrete sizes from the supplied calibrated font preset, not from
future body overrides. Body `spacing` and `leading` are independent. Paper,
justification, and block-quote policy are configurable with `general.layout`.
Spotless preserves the academic defaults; unthemed documents retain Typst's
visual defaults. Shared academic appearance and watermark presets are available
under `theme.shared`. Watermark content alone works with spotless (or
`theme.shared.watermark()`); an explicit `watermark-generator: none` suppresses it.

== Generators and scoped rules

Cover and matter generators receive `(cfg)`. Header/footer generators receive
`(cfg, last-page)`, where the last page is the total in that section's reset page
counter, not the total of the entire document. These signatures remain compatible.
Inside section and running-component generators, `cfg.resolved-section` contains
`name`, effective `page`, `header`, `footer`, and section `show-rules`.
`cfg.resolved-sections` holds all four section specifications. The effective
page margin excludes reserved heights; `reserved-margin` includes heights of
enabled running components. No private inheritance reconstruction is necessary.

Global rules apply throughout the document. Each section has its own
`component.<section>.show-rules(...)` helper; local header, footer, cover, and
appendix TOC hooks wrap only their own component. Rules with different keys
accumulate. Repeated keys merge field by field: replacing the function retains
its order, and an order-only patch retains its function. `show-enable: false`
disables an inherited keyed rule, while `show-fun: none` clears its callback.
An enabled new key needs a callback. Equal orders retain key insertion order.

Callbacks compose in ascending order, with later callbacks forming *outer*
wrappers. Callback execution order is therefore different from nesting and
effective style precedence: an earlier inner `set` rule can override a later
outer `set` rule. Component-local styles remain local; they do not leak to the body.

Spotless's total-page convenience argument sets the same `show-total-pages`
field that `component.body.footer` patches. Its footer uses resolved page
numbering, supports strings, callbacks, and `none`, and formats current and total
pages independently rather than concatenating numbering patterns. As in Typst's
page API, numbering callbacks receive `(current, total)` (use an ignored second
argument for a current-only formatter). The convenience suffix reapplies the
formatter to `(total, total)`; leave `show-total-pages: false` if the callback
already includes a complete current/total display itself.

== Compilable customization example

The following fixture is compiled by the regression suite. It demonstrates
partial margins, moving configured AI matter, disabling inherited components,
typography and footer overrides, keyed rule management, and generator replacement.

#raw(
  read("tests/customization-example.typ").replace(
    "../template/template/lib.typ",
    "template/lib.typ",
  ),
  lang: "typ",
  block: true,
)

== Migration from adapters

Replace `dhbw-ka-adapter(...)`, `dhbw-ma-adapter(...)`, or `ihk-adapter(...)`
with the corresponding `institution.<name>.setup(...)` configuration in
`project.with(theme.spotless(), institution.<name>.setup(...), ...)`.
Institution-specific matter is configured through
`institution.<name>.frontbackmatter`; general matter remains under
`frontbackmatter`. Remove old adapter-specific named arguments to `project` and
compose producer dictionaries positionally instead. Generators keep their
existing signatures. New disabling and rule-patching fields are additive;
explicit `none` generator suppression is now consistently supported.

Intentional corrections include preserved partial arrays and margins, independent
footer spacing, parity-aware heading breaks, no empty appendix scaffold, and
render-time metadata. The default appendix TOC belongs to spotless rather than
the unthemed renderer; explicit suppression no longer invokes a fallback.

#for module-doc in api {
  pagebreak(weak: true)
  tidy.show-module(
    module-doc,
    first-heading-level: 1,
    show-outline: false,
    omit-private-definitions: true,
    omit-private-parameters: true,
    omit-empty-param-descriptions: false,
    break-param-descriptions: true,
  )
  for package in module-doc.packages {
    let spec = package.package.trim("@preview/", at: start).split(":")
    heading(package.name, level: 2)
    [Re-export of #raw(package.package). See the
      #link(
        "https://typst.app/universe/package/" + spec.first() + "/",
      )[upstream reference]
      for its functions and options.]
  }
}
