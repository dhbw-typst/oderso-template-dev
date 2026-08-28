#import "template/template/general/typography/font.typ": *

= Font Comparison

This document provides a testbed to adjust the size and spacing of different fonts to a baseline. The used baseline is Arial with a text size and spacing adjusted to match 12pt and 1.5 line spacing in word. See #underline(link("https://github.com/dhbw-typst/oderso-template-dev/pull/64")[here]) for more info.

#let show-arial = true

#let fonts = (
  arial,
  new-computer-modern,
  libertinus-serif,
  source-serif-4,
  source-sans-3,
)

#let body = {
  box(height: 100pt, grid(columns: (
      () => {
        let columns = ()
        for _ in range(26) {
          columns.push(1fr)
        }
        return columns
      }
    )())[A][B][C][D][E][F][G][H][I][J][K][L][M][N][O][P][Q][R][S][T][U][V][W][X][Y][Z])

  box(height: 100pt, grid(columns: (
      () => {
        let columns = ()
        for _ in range(26) {
          columns.push(1fr)
        }
        return columns
      }
    )())[a][b][c][d][e][f][g][h][i][j][k][l][m][n][o][p][q][r][s][t][u][v][w][x][y][z])

  box(height: 100pt, width: 100%)[
    A line\
    Another line\
    And a third line\
  ]

  box(height: 100pt, width: 100%)[
    A paragraph with a few words

    Another paragraph

    And a third paragraph
  ]
}

#for font in fonts {
  pagebreak()

  let font-a(body) = {
    set text(font: font.font, size: font.size)
    set par(spacing: font.spacing, leading: font.leading)
    body
  }

  let font-b(body) = {
    set text(font: arial.font, size: arial.size)
    set par(spacing: arial.spacing, leading: arial.leading)
    body
  }

  set page(
    background: place(dy: 4cm, top + left, float: true, scope: "column", pad(
      rest: 2cm,
      {
        show: font-b.with()
        set text(fill: red)
        if show-arial {
          body
        }
      },
    )),
    foreground: place(dy: 4cm, top + left, float: true, scope: "column", pad(
      rest: 2cm,
      {
        show: font-a.with()
        set text(fill: black.transparentize(30%))
        body
      },
    )),
  )

  [
    #set text(font: font.font)
    = #font.font
  ]
}






