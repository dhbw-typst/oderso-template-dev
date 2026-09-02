#import "../config/lib.typ" as config
/// Configure abbreviations. Using #link("https://typst.app/universe/package/glossarium/")[glossarium] as underlying library. -> dicitionary
#let abbreviations(
  /// The abbreviation entries. See #link("https://typst.app/universe/package/glossarium/")[glossarium] for more information on entry format. -> array
  abbreviations: config.util.default-value,
  /// Print options passed to `print-glossary`. See #link("https://typst.app/universe/package/glossarium/")[glossarium] available options.
  print-options: config.util.default-value,
  /// Where and when the abbreviation listing should be displayed. Negative = frontmatter, zero or positive = backmatter. The value determines render order within its section. -> int
  position: config.util.default-value,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the abbreviations section `content` (or `none` to skip). -> function
  generator-function: config.util.default-value,
) = {
  assert(
    abbreviations == config.util.default-value or type(abbreviations) == array,
    message: "`abbreviations` must be an array of glossarium entries, got "
      + repr(abbreviations)
      + " of type "
      + str(type(abbreviations)),
  )
  config.validation.validate-position(position)
  config.validation.validate-generator(generator-function)
  return (
    front-back-matter: (
      abbreviations: config.util.get-dict-without-default((
        entries: abbreviations,
        print-options: print-options,
        position: position,
        generator: generator-function,
      )),
    ),
  )
}

/// Configure glossary. Using #link("https://typst.app/universe/package/glossarium/")[glossarium] as underlying library. -> dicitionary
#let glossary(
  /// The glossary entries. See #link("https://typst.app/universe/package/glossarium/")[glossarium] for more information on entry format. -> array
  glossary: config.util.default-value,
  /// Print options passed to `print-glossary`. See #link("https://typst.app/universe/package/glossarium/")[glossarium] available options.
  print-options: config.util.default-value,
  /// Where and when the glossary listing should be displayed. Negative = frontmatter, zero or positive = backmatter. The value determines render order within its section. -> int
  position: config.util.default-value,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the glossary section `content` (or `none` to skip). -> function
  generator-function: config.util.default-value,
) = {
  assert(
    glossary == config.util.default-value or type(glossary) == array,
    message: "`glossary` must be an array of glossarium entries, got "
      + repr(glossary)
      + " of type "
      + str(type(glossary)),
  )
  config.validation.validate-position(position)
  config.validation.validate-generator(generator-function)
  return (
    front-back-matter: (
      glossary: config.util.get-dict-without-default((
        entries: glossary,
        print-options: print-options,
        position: position,
        generator: generator-function,
      )),
    ),
  )
}

/// Configure an acknowledgments section. -> dictionary
#let acknowledgements(
  /// The text to display. -> content
  text: config.util.default-value,
  /// Where and when the acknowledgements should be displayed. Negative = frontmatter, zero or positive = backmatter. The value determines render order within its section. -> int
  position: config.util.default-value,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the acknowledgements section `content` (or `none` to skip). -> function
  generator-function: config.util.default-value,
) = {
  config.validation.validate-position(position)
  config.validation.validate-generator(generator-function)
  return (
    front-back-matter: (
      acknowledgements: config.util.get-dict-without-default((
        text: text,
        position: position,
        generator: generator-function,
      )),
    ),
  )
}

/// Configures one or more abstracts. -> dictionary
#let abstracts(
  /// List of abstracts. Entries must have `lang` (string), the language of the text as #link("https://en.wikipedia.org/wiki/ISO_639")[ISO 639] code, `lang-display` (content | none), the language name to display above the text, `text` (content), the abstracts text. -> array
  abstracts: config.util.default-value,
  /// Where and when the abstracts should be displayed. Negative = frontmatter, zero or positive = backmatter. The value determines render order within its section. -> int
  position: config.util.default-value,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the abstracts section `content` (or `none` to skip). -> function
  generator-function: config.util.default-value,
) = {
  if abstracts != config.util.default-value {
    assert(
      type(abstracts) == array,
      message: "`abstracts` must be an array, got "
        + repr(abstracts)
        + " of type "
        + str(type(abstracts)),
    )
    for (i, entry) in abstracts.enumerate() {
      assert(
        type(entry) == dictionary,
        message: "`abstracts` entry at index "
          + str(i)
          + " must be a dictionary, got "
          + repr(entry),
      )
      if "lang" not in entry {
        panic(
          "`abstracts` entry at index "
            + str(i)
            + " is missing required key `lang`",
        )
      }
      if "lang-display" not in entry {
        panic(
          "`abstracts` entry at index "
            + str(i)
            + " is missing required key `lang-display`",
        )
      }
      if "text" not in entry {
        panic(
          "`abstracts` entry at index "
            + str(i)
            + " is missing required key `text`",
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
  config.validation.validate-position(position)
  config.validation.validate-generator(generator-function)
  return (
    front-back-matter: (
      abstracts: config.util.get-dict-without-default((
        entries: abstracts,
        position: position,
        generator: generator-function,
      )),
    ),
  )
}

/// Configure the bibliography listing. -> dictionary
#let bibliography(
  /// The bibliography content, typically produced via `bibliography("refs.bib")`. -> content | none
  library: config.util.default-value,
  /// Where and when the bibliography listing should be displayed. Negative = frontmatter, zero or positive = backmatter. The value determines render order within its section. -> int
  position: config.util.default-value,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the bibliography section `content` (or `none` to skip). -> function
  generator-function: config.util.default-value,
) = {
  config.validation.validate-position(position)
  config.validation.validate-generator(generator-function)
  return (
    front-back-matter: (
      bibliography: config.util.get-dict-without-default((
        library: library,
        position: position,
        generator: generator-function,
      )),
    ),
  )
}

/// Configure the figure listings. -> dictionary
#let figure-listings(
  /// Whether to show the figure listing. -> bool
  figure-listing: config.util.default-value,
  /// Whether to show the figure listing .-> bool
  table-listing: config.util.default-value,
  /// Whether to show the figure listing. -> bool
  code-listing: config.util.default-value,
  /// Where and when the listings should be displayed. Negative = frontmatter, zero or positive = backmatter. The value determines render order within its section. -> int
  position: config.util.default-value,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the listings section `content` (or `none` to skip). -> function
  generator-function: config.util.default-value,
) = {
  assert(
    figure-listing == config.util.default-value or type(figure-listing) == bool,
    message: "`figure-listing` must be a boolean, got "
      + repr(figure-listing)
      + " of type "
      + str(type(figure-listing)),
  )
  assert(
    table-listing == config.util.default-value or type(table-listing) == bool,
    message: "`table-listing` must be a boolean, got "
      + repr(table-listing)
      + " of type "
      + str(type(table-listing)),
  )
  assert(
    code-listing == config.util.default-value or type(code-listing) == bool,
    message: "`code-listing` must be a boolean, got "
      + repr(code-listing)
      + " of type "
      + str(type(code-listing)),
  )
  config.validation.validate-position(position)
  config.validation.validate-generator(generator-function)
  return (
    front-back-matter: (
      listings: config.util.get-dict-without-default((
        figure-listing: figure-listing,
        table-listing: table-listing,
        code-listing: code-listing,
        position: position,
        generator: generator-function,
      )),
    ),
  )
}

/// Configure the table of contents. -> dictionary
#let toc(
  /// Where and when the table of contents should be displayed. Negative = frontmatter, zero or positive = backmatter. The value determines render order within its section. -> int
  position: config.util.default-value,
  /// A function receiving a single positional argument `config` holding the configuration dictionary and returning the table of contents section `content` (or `none` to skip). -> function
  generator-function: config.util.default-value,
) = {
  config.validation.validate-position(position)
  config.validation.validate-generator(generator-function)
  return (
    front-back-matter: (
      toc: config.util.get-dict-without-default((
        position: position,
        generator: generator-function,
      )),
    ),
  )
}
