#import "@preview/glossarium:0.5.10": print-glossary
#import "utils.typ": __linguify-content

// ============================================================
//                        INTERNALS
// ============================================================

/// Recusively adds `addition` to `base`. Largely copied from #link("https://github.com/touying-typ/touying/blob/a8abe0d832024038c4174d9bb8182f202bde1209/src/utils.typ#L42-L61")[touying]. Base is modified and returned. -> dictionary
#let __merge-config(
  /// The base dictionary. Will be modified -> dictionary
  base,
  /// The dictionary to merge into base -> dictionary
  addition,
) = {
  for key in addition.keys() {
    if (
      key in base and type(base.at(key)) == dictionary and type(addition.at(key)) == dictionary
    ) {
      base.insert(key, __merge-config(base.at(key), addition.at(key)))
    } else {
      base.insert(key, addition.at(key))
    }
  }

  return base
}

/// Recusively adds `additions` to `base`. Largely copied from #link("https://github.com/touying-typ/touying/blob/a8abe0d832024038c4174d9bb8182f202bde1209/src/utils.typ#L42-L61")[touying]. Base is modified and returned. -> dictionary
#let __merge-configs(
  /// The base dictionary. -> dictionary
  base,
  /// The dictionaries to merge into base -> dictionary
  ..additions,
) = {
  for addition in additions.pos() {
    base = __merge-config(base, addition)
  }
  return base
}

#let __default = metadata((kind: "touying-default"))

/// Asserts that `position` is either the default sentinel or one of "frontmatter" / "backmatter",
/// and that `order` is either the default sentinel or an integer.
#let __validate-position-order(position, order) = {
  assert(
    position == __default or position == "frontmatter" or position == "backmatter",
    message: "`position` must be either \"frontmatter\" or \"backmatter\", got: " + repr(position),
  )
  assert(
    order == __default or type(order) == int,
    message: "`order` must be an integer, got " + repr(order) + " of type " + str(type(order)),
  )
}

/// Asserts that `enable` is either the default sentinel or a boolean.
#let __validate-enable(enable) = {
  assert(
    enable == __default or type(enable) == bool,
    message: "`enable` must be a boolean, got " + repr(enable) + " of type " + str(type(enable)),
  )
}

/// Asserts that `generator-function` is either the default sentinel or a function.
#let __validate-generator(generator-function) = {
  assert(
    generator-function == __default or type(generator-function) == function,
    message: "`generator-function` must be a function, got "
      + repr(generator-function)
      + " of type "
      + str(type(generator-function)),
  )
}

/// Returns a copy of the provided dict but only with entries that do not have the value of `__default`. Largely copied from #link("https://github.com/touying-typ/touying/blob/a8abe0d832024038c4174d9bb8182f202bde1209/src/utils.typ#L42-L61")[touying]. -> dictionary
#let __get-dict-without-default(dict) = {
  let new-dict = (:)
  for (key, value) in dict.pairs() {
    if value != __default {
      new-dict.insert(key, value)
    }
  }
  return new-dict
}

#let __get-config(key, config) = {
  if key == "" or key == none {
    return config
  }

  let first-dot = key.position(".")
  if first-dot == none {
    if key in config.keys() {
      return config.at(key)
    } else {
      panic("The provided config key '" + key + "' does not exist")
    }
  } else {
    let this-key = key.slice(0, first-dot)
    let rest-key = key.slice(first-dot + 1)
    if this-key in config.keys() {
      return __get-config(rest-key, config.at(this-key))
    }
  }
}


// ============================================================
//                          BASE
// ============================================================

/// Configure general page settings -> dictionary
#let configure-page(
  /// Page margins. See #link("https://typst.app/docs/reference/layout/page/#parameters-margin")[the typst documentation] for more information -> auto | relative | dictionary
  margin: __default,
) = {
  assert(
    margin == __default
      or margin == auto
      or type(margin) == dictionary
      or type(margin) == relative
      or type(margin) == length
      or type(margin) == ratio,
    message: "`margin` must be `auto`, a length, a ratio, a relative length, or a dictionary, got "
      + repr(margin)
      + " of type "
      + str(type(margin)),
  )
  return (
    page: __get-dict-without-default((
      margin: margin,
    )),
  )
}

/// Configure abbreviations. Using #link("https://typst.app/universe/package/glossarium/")[glossarium] as underlying library. -> dicitionary
#let configure-abbreviations(
  /// The abbreviation entries. See #link("https://typst.app/universe/package/glossarium/")[glossarium] for more information on entry format. -> array
  abbreviations: __default,
  /// Print options passed to `print-glossary`. See #link("https://typst.app/universe/package/glossarium/")[glossarium] available options.
  print-options: __default,
  /// Where the abbreviation listing should be displayed. -> "frontmatter" | "backmatter"
  position: __default,
  /// What order the abbreviation listing should have. -> int
  order: __default,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the abbreviations section `content` (or `none` to skip). -> function
  generator-function: __default,
) = {
  assert(
    abbreviations == __default or type(abbreviations) == array,
    message: "`abbreviations` must be an array of glossarium entries, got "
      + repr(abbreviations)
      + " of type "
      + str(type(abbreviations)),
  )
  __validate-position-order(position, order)
  __validate-generator(generator-function)
  return (
    front-back-matter: (
      abbreviations: __get-dict-without-default((
        entries: abbreviations,
        print-options: print-options,
        position: position,
        order: order,
        generator: generator-function,
      )),
    ),
  )
}

/// Configure glossary. Using #link("https://typst.app/universe/package/glossarium/")[glossarium] as underlying library. -> dicitionary
#let configure-glossary(
  /// The glossary entries. See #link("https://typst.app/universe/package/glossarium/")[glossarium] for more information on entry format. -> array
  glossary: __default,
  /// Print options passed to `print-glossary`. See #link("https://typst.app/universe/package/glossarium/")[glossarium] available options.
  print-options: __default,
  /// Where the glossary listing should be displayed. -> "frontmatter". | "backmatter"
  position: __default,
  /// What order the glossary listing should have. -> int
  order: __default,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the glossary section `content` (or `none` to skip). -> function
  generator-function: __default,
) = {
  assert(
    glossary == __default or type(glossary) == array,
    message: "`glossary` must be an array of glossarium entries, got "
      + repr(glossary)
      + " of type "
      + str(type(glossary)),
  )
  __validate-position-order(position, order)
  __validate-generator(generator-function)
  return (
    front-back-matter: (
      glossary: __get-dict-without-default((
        entries: glossary,
        print-options: print-options,
        position: position,
        order: order,
        generator: generator-function,
      )),
    ),
  )
}

/// Configure an acknowledgments section. -> dictionary
#let configure-acknowledgements(
  /// The text to display. -> content
  text: __default,
  /// Where the acknowledgements should be displayed. -> "frontmatter" | "backmatter"
  position: __default,
  /// What order the acknowledgements should have. -> int
  order: __default,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the acknowledgements section `content` (or `none` to skip). -> function
  generator-function: __default,
) = {
  __validate-position-order(position, order)
  __validate-generator(generator-function)
  return (
    front-back-matter: (
      acknowledgements: __get-dict-without-default((
        text: text,
        position: position,
        order: order,
        generator: generator-function,
      )),
    ),
  )
}

/// Configures one or more abstracts. -> dictionary
#let configure-abstracts(
  /// List of abstracts. Entries must have `lang` (string), the language of the text as #link("https://en.wikipedia.org/wiki/ISO_639")[ISO 639] code, `lang-display` (content | none), the language name to display above the text, `text` (content), the abstracts text. -> array
  abstracts: __default,
  /// Where the abstracts should be displayed. -> "frontmatter" | "backmatter"
  position: __default,
  /// What order the abstract should have. -> int
  order: __default,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the abstracts section `content` (or `none` to skip). -> function
  generator-function: __default,
) = {
  if abstracts != __default {
    assert(
      type(abstracts) == array,
      message: "`abstracts` must be an array, got " + repr(abstracts) + " of type " + str(type(abstracts)),
    )
    for (i, entry) in abstracts.enumerate() {
      assert(
        type(entry) == dictionary,
        message: "`abstracts` entry at index " + str(i) + " must be a dictionary, got " + repr(entry),
      )
      if "lang" not in entry {
        panic(
          "`abstracts` entry at index " + str(i) + " is missing required key `lang`",
        )
      }
      if "lang-display" not in entry {
        panic(
          "`abstracts` entry at index " + str(i) + " is missing required key `lang-display`",
        )
      }
      if "text" not in entry {
        panic(
          "`abstracts` entry at index " + str(i) + " is missing required key `text`",
        )
      }
      assert(
        type(entry.lang) == str,
        message: "`abstracts` entry at index "
          + str(i)
          + " has `lang` of type "
          + str(type(entry.lang))
          + ", expected string (ISO 639 code)",
      )
    }
  }
  __validate-position-order(position, order)
  __validate-generator(generator-function)
  return (
    front-back-matter: (
      abstracts: __get-dict-without-default((
        entries: abstracts,
        position: position,
        order: order,
        generator: generator-function,
      )),
    ),
  )
}

/// Configure the bibliography listing. -> dictionary
#let configure-bibliography(
  /// The bibliography content, typically produced via `bibliography("refs.bib")`. -> content | none
  library: __default,
  /// Where the bibliography listing should be displayed. -> "frontmatter" | "backmatter"
  position: __default,
  /// What order the bibliography listing should have. -> int
  order: __default,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the bibliography section `content` (or `none` to skip). -> function
  generator-function: __default,
) = {
  __validate-position-order(position, order)
  __validate-generator(generator-function)
  return (
    front-back-matter: (
      bibliography: __get-dict-without-default((
        library: library,
        position: position,
        order: order,
        generator: generator-function,
      )),
    ),
  )
}

/// Configure the figure listings. -> dictionary
#let configure-figure-listings(
  /// Whether to show the figure listing. -> bool
  figure-listing: __default,
  /// Whether to show the figure listing .-> bool
  table-listing: __default,
  /// Whether to show the figure listing. -> bool
  code-listing: __default,
  /// Where the listings should be displayed. -> "frontmatter" | "backmatter"
  position: __default,
  /// What order the listings should have. -> int
  order: __default,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the listings section `content` (or `none` to skip). -> function
  generator-function: __default,
) = {
  assert(
    figure-listing == __default or type(figure-listing) == bool,
    message: "`figure-listing` must be a boolean, got "
      + repr(figure-listing)
      + " of type "
      + str(type(figure-listing)),
  )
  assert(
    table-listing == __default or type(table-listing) == bool,
    message: "`table-listing` must be a boolean, got " + repr(table-listing) + " of type " + str(type(table-listing)),
  )
  assert(
    code-listing == __default or type(code-listing) == bool,
    message: "`code-listing` must be a boolean, got " + repr(code-listing) + " of type " + str(type(code-listing)),
  )
  __validate-position-order(position, order)
  __validate-generator(generator-function)
  return (
    front-back-matter: (
      listings: __get-dict-without-default((
        figure-listing: figure-listing,
        table-listing: table-listing,
        code-listing: code-listing,
        position: position,
        order: order,
        generator: generator-function,
      )),
    ),
  )
}

/// Configure the table of contents. -> dictionary
#let configure-toc(
  /// Where the table of contents should be displayed. -> "frontmatter" | "backmatter"
  position: __default,
  /// What order the table of contents should have. -> int
  order: __default,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the table of contents section `content` (or `none` to skip). -> function
  generator-function: __default,
) = {
  __validate-position-order(position, order)
  __validate-generator(generator-function)
  return (
    front-back-matter: (
      toc: __get-dict-without-default((
        position: position,
        order: order,
        generator: generator-function,
      )),
    ),
  )
}

/// Configure the appendices. -> dictionary
#let configure-appendices(
  /// List of appendices. Entries must have `title` (content), `reference` (string), by which the appendix can be referenced, and text (content). -> array
  appendices: __default,
) = {
  if appendices != __default {
    assert(
      type(appendices) == array,
      message: "`appendices` must be an array, got " + repr(appendices) + " of type " + str(type(appendices)),
    )
    let validated = ()
    for (i, entry) in appendices.enumerate() {
      assert(
        type(entry) == dictionary,
        message: "`appendices` entry at index " + str(i) + " must be a dictionary, got " + repr(entry),
      )
      if "title" not in entry {
        panic(
          "`appendices` entry at index " + str(i) + " is missing required key `title`",
        )
      }
      if "text" not in entry {
        panic(
          "`appendices` entry at index " + str(i) + " is missing required key `text`",
        )
      }
      let normalized = entry
      if "reference" not in normalized {
        normalized.insert("reference", none)
      } else {
        assert(
          normalized.reference == none or type(normalized.reference) == str,
          message: "`appendices` entry at index "
            + str(i)
            + " has `reference` of type "
            + str(type(normalized.reference))
            + ", expected string or none",
        )
      }
      validated.push(normalized)
    }
    appendices = validated
  }
  return (
    appendices: __get-dict-without-default((
      entries: appendices,
    )),
  )
}

/// Configure options regarding drafting.
/// This includes notes and the watermark.
/// This tempalte uses #ling
/// -> dictionary
#let configure-drafting(
  /// A watermark to show on the document margins -> content
  watermark: __default,
  /// Generator function used to display the watermark -> function
  watermark-generator: __default,
  /// Whether to display a list of notes at the very first page of the document. -->
  notes-listing: __default,
) = {
  __validate-enable(notes-listing)
  return (
    drafting: __get-dict-without-default((
      watermark: watermark,
      notes-listing: notes-listing,
    )),
  )
}

/// Configure arbitrary metadata of the document, used by adapters and components. Low level configuration, is only called from adapters but may be used modify internal behaviour. -> dictionary
#let configure-metadata(
  metadata: __default,
) = {
  assert(
    metadata == __default or type(metadata) == dictionary,
    message: "`metadata` must be a dictionary, got " + repr(metadata) + " of type " + str(type(metadata)),
  )

  if metadata == __default {
    return (
      metadata: (:),
    )
  } else {
    return (
      metadata: metadata,
    )
  }
}


// ============================================================
//                DEFAULT SECTION GENERATORS
// ============================================================
// Each default generator receives the fully-merged configuration dictionary
// and returns the section `content` (or `none` to skip rendering). They are
// installed on the base config by `base.typ` via the `generator-function`
// parameter of the matching `configure-*` function.

/// Default generator for the acknowledgements section. Renders a centered
/// acknowledgements page with the configured text, or `none` if no text was
/// provided. -> content | none
#let __acknowledgements-default-generator(config) = {
  let ack = config.front-back-matter.acknowledgements
  if ack.at("text", default: none) == none {
    return none
  }
  align(center + horizon, {
    heading(outlined: false, numbering: none, [#text(
      0.85em,
      smallcaps(__linguify-content("acknowledgments")),
    )\ ])
    align(left, ack.text)
    v(20%)
  })
}

/// Default generator for the abstracts section. Renders one centered page
/// per abstract entry, or `none` if no entries were configured. -> content | none
#let __abstracts-default-generator(config) = {
  let entries = config.front-back-matter.abstracts.at("entries", default: ())
  if entries.len() == 0 {
    return none
  }
  for a in entries {
    pagebreak(weak: true)
    align(center + horizon, {
      heading(outlined: false, numbering: none, [#text(
          0.85em,
          smallcaps(__linguify-content("abstract")),
        )\ #text(
          0.75em,
          weight: "light",
          style: "italic",
          [\- #a.lang-display -],
        )])
      align(left, text(lang: a.lang, a.text))
      v(20%)
    })
  }
}

/// Default generator for the table of contents section. Renders an outline of
/// all headings placed before the appendix. -> content
#let __toc-default-generator(config) = {
  // show level 1 headings in outline in a fancier way
  show outline.entry.where(level: 1): strong
  set par(leading: 0.65em)
  outline(
    title: __linguify-content("table-of-contents"),
    depth: 3,
    indent: auto,
    target: selector(heading).before(<__appendix-start>),
  )
}

/// Default generator for the bibliography section. Renders the configured
/// `library` content (typically produced via `bibliography("refs.bib")`), or
/// `none` if no library was provided. -> content | none
#let __bibliography-default-generator(config) = {
  let library = config.front-back-matter.bibliography.at("library", default: none)
  if library == none {
    return none
  }
  library
}

/// Default generator for the glossary section. Renders the glossary heading
/// followed by `print-glossary` output, or `none` if no entries were
/// configured. -> content | none
#let __glossary-default-generator(config) = {
  let gloss = config.front-back-matter.glossary
  let entries = gloss.at("entries", default: ())
  if entries.len() == 0 {
    return none
  }
  heading(__linguify-content("glossary"))
  print-glossary(entries, ..gloss.at("print-options", default: (:)))
}

/// Default generator for the abbreviations section. Renders the abbreviations
/// heading followed by `print-glossary` output, or `none` if no entries were
/// configured. -> content | none
#let __abbreviations-default-generator(config) = {
  let abbr = config.front-back-matter.abbreviations
  let entries = abbr.at("entries", default: ())
  if entries.len() == 0 {
    return none
  }
  heading(__linguify-content("abbreviations"))
  print-glossary(entries, ..abbr.at("print-options", default: (:)))
}

/// Default generator for the figure listings section. Renders lists of
/// figures, tables and code blocks appearing before the appendix, subject to
/// the corresponding enable flags. Uses `context` because the presence of
/// each listing depends on document queries resolved during layout. -> content
#let __listings-default-generator(config) = context {
  let listings = config.front-back-matter.listings

  // list of figures
  if (
    listings.at("figure-listing", default: false) and query(figure.where(kind: image)).len() > 0
  ) {
    pagebreak(weak: true)
    heading(__linguify-content("list-of-figures"))
    outline(
      target: figure.where(kind: image).before(<__appendix-start>),
      title: none,
    )
  }

  // list of tables
  if (
    listings.at("table-listing", default: false) and query(figure.where(kind: table)).len() > 0
  ) {
    pagebreak(weak: true)
    heading(__linguify-content("list-of-tables"))
    outline(
      target: figure.where(kind: table).before(<__appendix-start>),
      title: none,
    )
  }

  // list of source code
  if (
    listings.at("code-listing", default: false) and query(figure.where(kind: raw)).len() > 0
  ) {
    pagebreak(weak: true)
    heading(__linguify-content("list-of-code"))
    outline(
      target: figure.where(kind: raw).before(<__appendix-start>),
      title: none,
    )
  }
}
