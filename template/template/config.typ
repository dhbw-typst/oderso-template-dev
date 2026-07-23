
// ============================================================
//                        INTERNALS
// ============================================================

// Recusively adds `addition` to `base`. Largely copied from #link(https://github.com/touying-typ/touying/blob/a8abe0d832024038c4174d9bb8182f202bde1209/src/utils.typ#L42-L61)[touying]. Base is modified and returned. -> dictionary
#let __merge-config(
  // The base dictionary. Will be modified -> dictionary
  base,
  // The dictionary to merge into base -> dictionary
  addition,
) = {
  for key in addition.keys() {
    if (
      key in base
        and type(base.at(key)) == dictionary
        and type(addition.at(key)) == dictionary
    ) {
      base.insert(key, __merge-config(base.at(key), addition.at(key)))
    } else {
      base.insert(key, addition.at(key))
    }
  }

  return base
}

// Recusively adds `additions` to `base`. Largely copied from #link(https://github.com/touying-typ/touying/blob/a8abe0d832024038c4174d9bb8182f202bde1209/src/utils.typ#L42-L61)[touying]. Base is modified and returned. -> dictionary
#let __merge-configs(
  // The base dictionary. -> dictionary
  base,
  // The dictionaries to merge into base -> dictionary
  ..additions
) = {
  for addition in additions.pos() {
    base = __merge-config(base, addition)
  }
  return base
}

#let __default = metadata((kind: "touying-default"))

// Asserts that `position` is either the default sentinel or one of "frontmatter" / "backmatter",
// and that `order` is either the default sentinel or an integer.
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

// Asserts that `enable` is either the default sentinel or a boolean.
#let __validate-enable(enable) = {
  assert(
    enable == __default or type(enable) == bool,
    message: "`enable` must be a boolean, got " + repr(enable) + " of type " + str(type(enable)),
  )
}

// Returns a copy of the provided dict but only with entries that do not have the value of `__default`. Largely copied from #link(https://github.com/touying-typ/touying/blob/a8abe0d832024038c4174d9bb8182f202bde1209/src/utils.typ#L42-L61)[touying]. Base is modified and returned. -> dictionary
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

// Configure general page settings -> dictionary
#let configure-page(
  // Page margins. See #link(https://typst.app/docs/reference/layout/page/#parameters-margin)[the typst documentation] for more information -> auto | relative | dictionary
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

// Configure abbreviations. Using #link(https://typst.app/universe/package/glossarium/)[glossarium] as underlying library. -> dicitionary
#let configure-abbreviations(
  // The abbreviation entries. See #link(https://typst.app/universe/package/glossarium/)[glossarium] for more information on entry format. -> array
  abbreviations: __default,
  // Print options passed to `print-glossary`. See #link(https://typst.app/universe/package/glossarium/)[glossarium] available options.
  print-options: __default,
  // Where the abbreviation listing should be displayed. -> "frontmatter" | "backmatter"
  position: __default,
  // What order the abbreviation listing should have. -> int
  order: __default,
) = {
  assert(
    abbreviations == __default or type(abbreviations) == array,
    message: "`abbreviations` must be an array of glossarium entries, got "
      + repr(abbreviations)
      + " of type "
      + str(type(abbreviations)),
  )
  __validate-position-order(position, order)
  return (
    front-back-matter: (
      abbreviations: __get-dict-without-default((
        entries: abbreviations,
        print-options: print-options,
        position: position,
        order: order,
      )),
    ),
  )
}

// Configure glossary. Using #link(https://typst.app/universe/package/glossarium/)[glossarium] as underlying library. -> dicitionary
#let configure-glossary(
  // The glossary entries. See #link(https://typst.app/universe/package/glossarium/)[glossarium] for more information on entry format. -> array
  glossary: __default,
  // Print options passed to `print-glossary`. See #link(https://typst.app/universe/package/glossarium/)[glossarium] available options.
  print-options: __default,
  // Where the glossary listing should be displayed. -> "frontmatter". | "backmatter"
  position: __default,
  // What order the glossary listing should have. -> int
  order: __default,
) = {
  assert(
    glossary == __default or type(glossary) == array,
    message: "`glossary` must be an array of glossarium entries, got "
      + repr(glossary)
      + " of type "
      + str(type(glossary)),
  )
  __validate-position-order(position, order)
  return (
    front-back-matter: (
      glossary: __get-dict-without-default((
        entries: glossary,
        print-options: print-options,
        position: position,
        order: order,
      )),
    ),
  )
}

// Configure an acknowledgments section. -> dictionary
#let configure-acknowledgements(
  // The text to display. -> content
  text: __default,
  // Where the acknowledgements should be displayed. -> "frontmatter" | "backmatter"
  position: __default,
  // What order the acknowledgements should have. -> int
  order: __default,
) = {
  __validate-position-order(position, order)
  return (
    front-back-matter: (
      acknowledgements: __get-dict-without-default((
        text: text,
        position: position,
        order: order,
      )),
    ),
  )
}

// Configures one or more abstracts. -> dictionary
#let configure-abstracts(
  // List of abstracts. Entries must have `lang` (string), the language of the text as #link(https://en.wikipedia.org/wiki/ISO_639)[ISO 639] code, `lang-display` (content | none), the language name to display above the text, `text` (content), the abstracts text. -> array
  abstracts: __default,
  // Where the abstracts should be displayed. -> "frontmatter" | "backmatter"
  position: __default,
  // What order the abstract should have. -> int
  order: __default,
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
        panic("`abstracts` entry at index " + str(i) + " is missing required key `lang`")
      }
      if "lang-display" not in entry {
        panic("`abstracts` entry at index " + str(i) + " is missing required key `lang-display`")
      }
      if "text" not in entry {
        panic("`abstracts` entry at index " + str(i) + " is missing required key `text`")
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
  return (
    front-back-matter: (
      abstracts: __get-dict-without-default((
        entries: abstracts,
        position: position,
        order: order,
      )),
    ),
  )
}

// Configure the bibliography listing. -> dictionary
#let configure-bibliography(
  // The bibliography content, typically produced via `bibliography("refs.bib")`. -> content | none
  library: __default,
  // Where the bibliography listing should be displayed. -> "frontmatter" | "backmatter"
  position: __default,
  // What order the bibliography listing should have. -> int
  order: __default,
) = {
  __validate-position-order(position, order)
  return (
    front-back-matter: (
      bibliography: __get-dict-without-default((
        library: library,
        position: position,
        order: order,
      )),
    ),
  )
}

// Configure the figure listings. -> dictionary
#let configure-figure-listings(
  // Whether to show the figure listing. -> bool
  figure-listing: __default,
  // Whether to show the figure listing .-> bool
  table-listing: __default,
  // Whether to show the figure listing. -> bool
  code-listing: __default,
  // Where the listings should be displayed. -> "frontmatter" | "backmatter"
  position: __default,
  // What order the listings should have. -> int
  order: __default,
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
    message: "`table-listing` must be a boolean, got "
      + repr(table-listing)
      + " of type "
      + str(type(table-listing)),
  )
  assert(
    code-listing == __default or type(code-listing) == bool,
    message: "`code-listing` must be a boolean, got "
      + repr(code-listing)
      + " of type "
      + str(type(code-listing)),
  )
  __validate-position-order(position, order)
  return (
    front-back-matter: (
      listings: __get-dict-without-default((
        figure-listing: figure-listing,
        table-listing: table-listing,
        code-listing: code-listing,
        position: position,
        order: order,
      )),
    ),
  )
}

// Configure the table of contents. -> dictionary
#let configure-toc(
  // Where the table of contents should be displayed. -> "frontmatter" | "backmatter"
  position: __default,
  // What order the table of contents should have. -> int
  order: __default,
) = {
  __validate-position-order(position, order)
  return (
    front-back-matter: (
      toc: __get-dict-without-default((
        position: position,
        order: order,
      )),
    ),
  )
}

// Configure the appendices. -> dictionary
#let configure-appendices(
  // List of appendices. Entries must have `title` (content), `reference` (string), by which the appendix can be referenced, and text (content). -> array
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
        panic("`appendices` entry at index " + str(i) + " is missing required key `title`")
      }
      if "text" not in entry {
        panic("`appendices` entry at index " + str(i) + " is missing required key `text`")
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


// ============================================================
//                    SHARED ADAPTERS
// ============================================================
// Configuration for front/back matter sections that every adapter
// (`dhbw-ka`, `dhbw-ma`, `ihk`) provides.

// Configure the statutory declaration section (shared across all adapters). -> dictionary
#let configure-statutory-declaration(
  // Whether the statutory declaration section is rendered. -> bool
  enable: __default,
  // Where the statutory declaration should be displayed. -> "frontmatter" | "backmatter"
  position: __default,
  // What order the statutory declaration should have. -> int
  order: __default,
  // Whether the thesis is submitted digitally. Controls whether the signature
  // line is pre-filled with the author's name/signature or left blank for
  // handwritten signing. -> bool
  digital-submission: __default,
  // Whether the thesis is submitted digitally only (no printed copy). Affects
  // the wording of the DHBW statutory declaration. -> bool
  digital-only: __default,
  // City shown on every signature line in this section. -> str
  signature-city: __default,
) = {
  __validate-enable(enable)
  __validate-position-order(position, order)
  assert(
    digital-submission == __default or type(digital-submission) == bool,
    message: "`digital-submission` must be a boolean, got "
      + repr(digital-submission)
      + " of type "
      + str(type(digital-submission)),
  )
  assert(
    digital-only == __default or type(digital-only) == bool,
    message: "`digital-only` must be a boolean, got "
      + repr(digital-only)
      + " of type "
      + str(type(digital-only)),
  )
  assert(
    signature-city == __default or type(signature-city) == str,
    message: "`signature-city` must be a string, got "
      + repr(signature-city)
      + " of type "
      + str(type(signature-city)),
  )
  return (
    front-back-matter: (
      statutory-declaration: __get-dict-without-default((
        enable: enable,
        digital-submission: digital-submission,
        digital-only: digital-only,
        signature-city: signature-city,
        position: position,
        order: order,
      )),
    ),
  )
}

// Configure the confidentiality clause section (shared across all adapters). -> dictionary
#let configure-confidentiality-clause(
  // Whether the confidentiality clause section is rendered. -> bool
  enable: __default,
  // Where the confidentiality clause should be displayed. -> "frontmatter" | "backmatter"
  position: __default,
  // What order the confidentiality clause should have. -> int
  order: __default,
) = {
  __validate-enable(enable)
  __validate-position-order(position, order)
  return (
    front-back-matter: (
      confidentiality-clause: __get-dict-without-default((
        enable: enable,
        position: position,
        order: order,
      )),
    ),
  )
}


// ============================================================
//                    DHBW KARLSRUHE
// ============================================================

// Configure the AI acknowledgement section for DHBW Karlsruhe theses.
// The section is rendered only when `entries` is non-empty. -> dictionary
#let configure-dhbw-ka-ai-acknowledgement(
  // Where the AI acknowledgement should be displayed. -> "frontmatter" | "backmatter"
  position: __default,
  // What order the AI acknowledgement should have. -> int
  order: __default,
  // List of AI tool entries. Each entry must have `tool` (str) and `usage`
  // (content). Empty array disables the section. -> array
  entries: (),
) = {
  __validate-position-order(position, order)
  assert(
    type(entries) == array,
    message: "`entries` must be an array of AI tool dicts, got "
      + repr(entries)
      + " of type "
      + str(type(entries)),
  )
  for (i, entry) in entries.enumerate() {
    assert(
      type(entry) == dictionary,
      message: "`entries` at index " + str(i) + " must be a dictionary, got " + repr(entry),
    )
    if "tool" not in entry {
      panic("`entries` at index " + str(i) + " is missing required key `tool`")
    }
    if "usage" not in entry {
      panic("`entries` at index " + str(i) + " is missing required key `usage`")
    }
  }
  return (
    front-back-matter: (
      ai-acknowledgement: __get-dict-without-default((
        entries: entries,
        position: position,
        order: order,
      )),
    ),
  )
}


// ============================================================
//                    DHBW MANNHEIM
// ============================================================

// Configure the AI declaration form section for DHBW Mannheim theses.
// The section is rendered only when `authors` is non-empty. -> dictionary
#let configure-dhbw-ma-ai-declaration-form(
  // Where the AI declaration form should be displayed. -> "frontmatter" | "backmatter"
  position: __default,
  // What order the AI declaration form should have. -> int
  order: __default,
  // Name of the module the AI declaration applies to. -> str | none
  module-name: __default,
  // Semester the module is offered in. -> str | none
  semester: __default,
  // Exam type: "Projektarbeit I", "Projektarbeit II", "Seminararbeit", "Bachelorarbeit". -> str | none
  exam-type: __default,
  // Submission date shown on the AI declaration form. -> str | none
  module-submission-date: __default,
  // Per-author AI declaration data, in the same order as the adapter's `authors`.
  // Each entry must be a dictionary with keys `product-name`, `topic`,
  // `topic-editing`, `research`, `design`. Empty array disables the section. -> array
  authors: (),
) = {
  __validate-position-order(position, order)
  assert(
    type(authors) == array,
    message: "`authors` must be an array of per-author AI declaration dicts, got "
      + repr(authors)
      + " of type "
      + str(type(authors)),
  )
  for (i, entry) in authors.enumerate() {
    assert(
      type(entry) == dictionary,
      message: "`authors` entry at index " + str(i) + " must be a dictionary, got " + repr(entry),
    )
    for key in ("product-name", "topic", "topic-editing", "research", "design") {
      if key not in entry {
        panic(
          "`authors` entry at index " + str(i) + " is missing required key `" + key + "`",
        )
      }
    }
  }
  return (
    front-back-matter: (
      ai-declaration-form: __get-dict-without-default((
        module-name: module-name,
        semester: semester,
        exam-type: exam-type,
        module-submission-date: module-submission-date,
        authors: authors,
        position: position,
        order: order,
      )),
    ),
  )
}
