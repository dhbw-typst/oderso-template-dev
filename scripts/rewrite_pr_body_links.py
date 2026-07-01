#!/usr/bin/env python3
"""Rewrite short issue/PR references in a Markdown file to fully qualified URLs.

The release body is authored in the context of this template repo, so `#123`
and `GH-123` refer to issues/PRs here. When that body is embedded verbatim in
a PR opened against `typst/packages` (see `.github/workflows/publishToUniverse.yml`),
those short references would otherwise resolve against `typst/packages` instead.
This script rewrites them so links keep pointing back at the origin repo.

Rules:
  * `#123`        -> https://github.com/<repo>/issues/123
  * `GH-123`      -> https://github.com/<repo>/issues/123
  * `owner/repo#123` is left alone (already fully qualified).
  * References inside inline `code` spans and ``` fenced ``` code blocks
    are left alone.
  * GitHub auto-redirects `/issues/<n>` to `/pull/<n>` when `<n>` is a PR,
    so a single URL form is enough for both.

Usage:
    rewrite_pr_body_links.py <input_file> <output_file> <owner/repo>
"""

from __future__ import annotations

import re
import sys


def rewrite(text: str, repo: str) -> str:
    base = f"https://github.com/{repo}/issues"

    # Split off fenced code blocks so we don't rewrite inside them.
    fence_re = re.compile(r"(^```.*?^```)", re.DOTALL | re.MULTILINE)
    parts = fence_re.split(text)

    # `#123` not preceded by a word char (so `foo#1` is skipped) and not part
    # of `owner/repo#123` (excluded via the negative lookbehind on `/`).
    hash_re = re.compile(r"(?<![\w/`])#(\d+)\b")
    gh_re = re.compile(r"(?<![\w`])GH-(\d+)\b")
    # Inline code spans (single-line `...`) — content is left verbatim.
    inline_code_re = re.compile(r"`[^`\n]*`")

    def rewrite_segment(segment: str) -> str:
        placeholders: list[str] = []

        def stash(m: re.Match[str]) -> str:
            placeholders.append(m.group(0))
            return f"\x00{len(placeholders) - 1}\x00"

        stashed = inline_code_re.sub(stash, segment)
        stashed = hash_re.sub(lambda m: f"{base}/{m.group(1)}", stashed)
        stashed = gh_re.sub(lambda m: f"{base}/{m.group(1)}", stashed)

        def unstash(m: re.Match[str]) -> str:
            return placeholders[int(m.group(1))]

        return re.sub(r"\x00(\d+)\x00", unstash, stashed)

    out: list[str] = []
    for i, part in enumerate(parts):
        if i % 2 == 1:
            # Fenced code block — leave verbatim.
            out.append(part)
        else:
            out.append(rewrite_segment(part))

    return "".join(out)


def main(argv: list[str]) -> int:
    if len(argv) != 4:
        print(
            f"usage: {argv[0]} <input_file> <output_file> <owner/repo>",
            file=sys.stderr,
        )
        return 2

    src, dst, repo = argv[1], argv[2], argv[3]
    with open(src, "r", encoding="utf-8") as f:
        text = f.read()
    with open(dst, "w", encoding="utf-8") as f:
        f.write(rewrite(text, repo))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
