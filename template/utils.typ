// LTeX: enabled=false

/// codefigure creates a figure with a caption.
/// figures created using this function will also appear in the
/// source-code table of contents.
///
/// * The `caption` parameter is optional and can be used to add a caption to the figure.
/// * The `reference` parameter is optional and can be used to reference the figure
/// * The `v-space` parameter is optional and can be used to add vertical space after the figure.
#let codefigure(body, caption: none, reference: none) = {
  [
    #figure(
      body,
      caption: caption,
      outlined: true,
      supplement: [Code],
    )
    #if reference != none {
      label(reference)
    }
  ]
}

/// codefigurefile is an alias to `codefigure` that reads the content of a file and uses it as the body.
/// The `file` parameter is required and should be the path to the file.
/// If you don't specify the `lang` parameter, the language will be extracted from the file extension.
///
/// * The `caption` parameter is optional and can be used to add a caption to the figure.
///
/// * The `reference` parameter is optional and can be used to reference the figure
#let codefigurefile(
  file,
  caption: none,
  reference: none,
  lang: none,
) = {
  // extract language from file name if no lang was specified
  if lang == none {
    if file.contains(".") {
      lang = file.split(".").last()
    }
  }
  codefigure(
    raw(read(file), lang: lang, block: true),
    caption: caption,
    reference: reference,
  )
}

/// `hr` creates a horizontal line.
#let hr = line(length: 100%, stroke: (paint: gray))

#let __in-outline = state("in-outline", false)
// usage: caption-with-source("text", [@source])
// prevents the using of the source in the outlines, to enable right sorting when using ieee for bibliography
#let caption-with-source(caption-text, source) = context {
  if __in-outline.at(here()) {
    caption-text
  } else {
    caption-text + " " + source
  }
}

#let table-hline-spaced(space, columns, ..hline-args) = {
  return (
    table.cell(colspan: columns, inset: space, {}),
    table.hline(..hline-args),
    table.cell(colspan: columns, inset: space, {}),
  )
}

#let tablefigure-raw(
  caption: none,
  reference: none,
  body,
) = {
  set figure(numbering: "I")
  show figure.where(kind: table): it => {
    set figure(numbering: "1") // Unsert "I" numbering for nested figures inside tables
    block({
      if it.caption != none {
        [#upper(it.caption.supplement) #it.caption.counter.display()]
        linebreak()
        smallcaps(it.caption.body)
      }
      it.body
    })
  }
  [
    #figure(
      body,
      caption: caption,
      kind: table,
    )
    #if reference != none {
      label(reference)
    }
  ]
}

#let styled-table(
  table-content: (),
  columns: auto,
  ..args,
) = {
  // General styling
  set table(align: left, stroke: none)
  show table: set par(justify: false)
  let col-count = if type(columns) == array { columns.len() } else if (
    type(columns) == int
  ) { columns } else { 1 }
  let additional-v-space = .2em

  // heading-content stroke
  let last-heading-row = -1
  for (index, item) in table-content.enumerate() {
    if type(item) == content and item.func() == table.header {
      last-heading-row = index
    }
  }

  if last-heading-row != -1 {
    for item in table-hline-spaced(additional-v-space, col-count) {
      table-content.insert(last-heading-row + 1, item)
    }
  }

  // Top and bottom double line strokes
  table-content.insert(0, table.cell(
    colspan: col-count,
    inset: additional-v-space,
    {},
  ))
  table-content.insert(0, table.hline())
  table-content.insert(0, table.cell(colspan: col-count, inset: 2pt, {}))
  table-content.insert(0, table.hline())
  table-content.push(table.cell(
    colspan: col-count,
    inset: additional-v-space,
    {},
  ))
  table-content.push(table.hline())
  table-content.push(table.cell(colspan: col-count, inset: 2pt, {}))
  table-content.push(table.hline())
  table(
    columns: columns,
    ..table-content,
    ..args,
  )
}

#let tablefigure(
  table-content: (),
  caption: none,
  reference: none,
  ..args,
) = {
  tablefigure-raw(caption: caption, reference: reference, styled-table(
    table-content: table-content,
    ..args,
  ))
}
