# Feature examples

Each top-level `.typ` file is a standalone, compilable example of the local
template's public API. These complement the assertions in `tests/` with small
documents whose rendered output can be compared when the template changes.
No CI configuration is changed by this collection.

| File | Features to inspect |
| --- | --- |
| `minimal.typ` | Base template without a theme or institution |
| `spotless.typ` | Theme-only cover, outline, running header, total-page footer |
| `dhbw-karlsruhe.typ` | German cover, multiple authors, declarations, AI acknowledgement |
| `dhbw-mannheim.typ` | English cover, supervisor metadata, per-author AI declaration form |
| `ihk.typ` | Training occupation, examinee number, IHK declarations |
| `typography.typ` | Body, headings, captions, code, math, and paragraph spacing |
| `page-layout.typ` | A5 paper, mirrored margins, partial margin patches, odd-page chapters, numbering callback |
| `front-back-matter.typ` | Acknowledgements, bilingual abstracts, signed positions, Roman/alphabetic page numbers |
| `appendices.typ` | Appendix outline, references, nested headings, appendix-specific header/footer |
| `custom-components.typ` | Replacement cover/header/footer generators and component-local styling |
| `show-rules.typ` | Global and section-local rules, keyed replacement, ordering, disabling/re-enabling |
| `figures-tables-code.typ` | Source-aware captions, styled tables, code figures, lists of figures/tables/code |
| `references.typ` | Citations, bibliography, glossary, abbreviations, inline glossary, equation references |
| `drafting.typ` | Watermark, margin/inline notes, automatic list of notes |
| `disabled-components.typ` | Explicit disabling, `none` generators, empty appendix entries |

## Compile locally

Run from the repository root so imports can reach `template/`:

```sh
typst compile --root . examples/typography.typ examples/typography.pdf
```

Compile every example into a separate output directory:

```sh
output_dir="$(mktemp -d)"
for file in examples/*.typ; do
  name="$(basename "$file" .typ)"
  typst compile --root . "$file" "$output_dir/$name.pdf" || exit 1
done
echo "PDFs: $output_dir"
```

For page-by-page visual comparisons, export PNGs instead:

```sh
typst compile --root . examples/page-layout.typ 'examples/page-layout-{p}.png'
```

Use the same Typst version and fonts for both revisions. The examples use fixed
submission dates and local fixtures in `assets/`, without random or
date-dependent body content. Most use Typst's bundled fonts; the Mannheim AI form
uses the template's Arial/Inter fallback and needs the same font available on
both machines. Typst downloads the template's pinned `@preview` dependencies on
first compilation. Generated PDFs and page images are not source fixtures and
should not be committed.
