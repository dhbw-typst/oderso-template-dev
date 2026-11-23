// LTeX: enabled=false
#import "@preview/tidy:0.4.3"
#import "template/template/lib.typ" as oderso

// Follow the public facade instead of maintaining a second list of exports.
// lib.typ files and import-only modules expose their imports; implementation
// files expose declarations and wildcard re-exports, not their dependencies.
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
  if file.ends-with("/lib.typ") or source.definitions.len() == 0 {
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
      name: namespace,
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
// Longer configuration contracts and compiled extension-point examples live in
// docs/customization.typ; keep this generated document focused on the API.

#let api-style = (
  dictionary(tidy.styles.default)
    + (
      show-function: (fn, style-args) => {
        // Only package/API headings participate in numbering and navigation.
        show heading.where(
          level: style-args.first-heading-level + 2,
        ): set heading(
          numbering: none,
          outlined: false,
          bookmarked: false,
        )
        show heading.where(
          level: style-args.first-heading-level + 3,
        ): set heading(
          numbering: none,
          outlined: false,
          bookmarked: false,
        )
        tidy.styles.default.show-function(fn, style-args)
      },
    )
)

#set document(title: "ODERSO — API reference")
#set text(lang: "en", size: 10pt)
#set page(paper: "a4", margin: 2cm, numbering: "1")
#set heading(numbering: "1.1.")
#show heading.where(level: 1): set text(size: 1.5em)
#show heading.where(level: 2): set text(size: 1.15em)
#show heading: it => {
  // Preserve the complete path for body headings, bookmarks, and references.
  // Fade only its ancestors; the current segment and numbering stay opaque.
  if it.body.func() == text and "." in it.body.text {
    let ancestors = it.body.text.split(".").slice(0, -1).join(".") + "."
    show ancestors: text.with(fill: black.transparentize(35%))
    it
  } else { it }
}
#show outline.entry: it => {
  // Shorten only the displayed TOC title, preserving its numbering and link.
  if it.element.func() == heading and it.element.body.func() == text {
    let path = it.element.body.text
    show path: path.split(".").last()
    it
  } else { it }
}
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

  API reference

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
    Configuration contracts and advanced examples are in `docs/customization.typ`.
  ]
]
#pagebreak()
#outline(title: [Contents], depth: 2)
#pagebreak()

#let shown-namespaces = ()
#for module-doc in api {
  let parts = if module-doc.name == "" { () } else {
    module-doc.name.split(".")
  }
  let level = parts.len()
  if parts.len() > 0 {
    // Some facade modules contain only child modules (e.g. institution/lib.typ).
    // Emit those parents too, even though they have no definitions of their own.
    for (index, part) in parts.enumerate() {
      let namespace = parts.slice(0, index + 1).join(".")
      if namespace not in shown-namespaces {
        if index == 0 { pagebreak(weak: true) }
        heading(namespace, level: index + 1)
        shown-namespaces.push(namespace)
      }
    }
  }
  tidy.show-module(
    module-doc,
    style: api-style,
    first-heading-level: level,
    show-module-name: false,
    show-outline: false,
    omit-private-definitions: true,
    omit-private-parameters: true,
    omit-empty-param-descriptions: false,
    break-param-descriptions: true,
  )
  for (index, package) in module-doc.packages.enumerate() {
    let spec = package.package.trim("@preview/", at: start).split(":")
    if parts.len() == 0 and index == 0 { pagebreak(weak: true) }
    heading(package.name, level: parts.len() + 1)
    [Re-export of #raw(package.package). See the
      #link(
        "https://typst.app/universe/package/" + spec.first() + "/",
      )[upstream reference]
      for its functions and options.]
  }
}
