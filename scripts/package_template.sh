#!/usr/bin/env bash
set -eo pipefail

usage() {
    echo "Usage: $0 [options]"
    echo "  -t, --target-dir <path>     install destination (default: typst local packages path)"
    echo "  -h, --help"
    exit 1
}

TARGET_DIR=""
TOML="typst.toml"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|--target-dir)       TARGET_DIR="$2"; shift 2 ;;
        -h|--help)             usage ;;
        *) echo "Unknown option: $1" >&2; usage ;;
    esac
done

if [[ -z "$TARGET_DIR" ]]; then
    PKG_PATH=$(typst info -f json 2>/dev/null | jq -r '.packages["package-path"]')
    TARGET_DIR="${PKG_PATH}/local"
fi

PKG_NAME=$(yq -p toml -oy '.package.name' "$TOML")
PKG_VERSION=$(yq -p toml -oy '.package.version' "$TOML")

BASE="${TARGET_DIR}/${PKG_NAME}/${PKG_VERSION}"

echo "PACKAGE_DIR=$BASE" >> "${GITHUB_ENV:-/dev/null}"
echo "Installing to: $BASE"
mkdir -p "$BASE/template" "$BASE/example"

copy_files() {
    local dest="$1"
    shift
    for f in "$@"; do
        cp -r "$f" "$dest/"
        echo "  copied: $f -> $dest/"
    done
}

PKG_FILES=( template/template/* )

EXAMPLE_FILES=(
    template/abstracts
    template/assets
    template/chapters
    template/glossary.typ
    template/main-dhbw-ka.typ
    template/main-dhbw-ma.typ
    template/main-ihk.typ
    template/refs.bib
)

ADDITIONAL_FILES=(
    thumbnail.png
    typst.toml
    template/LICENSE
    template/README.md
)

copy_files "$BASE/template" "${PKG_FILES[@]}"
copy_files "$BASE/example"  "${EXAMPLE_FILES[@]}"
copy_files "$BASE"          "${ADDITIONAL_FILES[@]}"

find "${BASE}/example" \
    -name "*.typ" \
    -exec sed -i -E 's|#import "[./]*(template/)?lib\.typ"|#import "'"@preview/${PKG_NAME}:${PKG_VERSION}"'"|g' {} + \
    -exec sed -i -E 's|#import \\"[./]*(template/)?lib\.typ\\"|#import \\"'"@preview/${PKG_NAME}:${PKG_VERSION}"'\\"|g' {} +
