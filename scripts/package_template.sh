#!/usr/bin/env bash
set -eo pipefail

usage() {
    echo "Usage: $0 [options]"
    echo "  -t, --target-dir <path>     install destination (default: typst local packages path)"
    echo "  -p, --preview               rewrite example imports as @preview/... (default: @local/...)"
    echo "  -f, --force                 overwrite the target directory if it already exists and is non-empty"
    echo "  -h, --help"
    exit 1
}

# Verifies that a command is available in PATH, exits with a descriptive error
# if not.
# Usage: require_cmd <command> [hint]
require_cmd() {
    local cmd="$1"
    local hint="${2:-}"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: required command '$cmd' was not found in PATH." >&2
        if [[ -n "$hint" ]]; then
            echo "  $hint" >&2
        fi
        exit 1
    fi
}

TARGET_DIR=""
TOML="typst.toml"
PREVIEW=0
FORCE=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|--target-dir)       TARGET_DIR="$2"; shift 2 ;;
        -p|--preview)          PREVIEW=1; shift ;;
        -f|--force)            FORCE=1; shift ;;
        -h|--help)             usage ;;
        *) echo "Unknown option: $1" >&2; usage ;;
    esac
done

if [[ "$PREVIEW" -eq 1 ]]; then
    IMPORT_NAMESPACE="preview"
else
    IMPORT_NAMESPACE="local"
fi

# --- dependency check ---------------------------------------------------------
require_cmd find
require_cmd cp
require_cmd mkdir
require_cmd basename
require_cmd sed
if [[ -z "$TARGET_DIR" ]]; then
    require_cmd typst "Install Typst (https://github.com/typst/typst) or pass --target-dir."
    require_cmd jq    "Install jq (https://stedolan.github.io/jq/) or pass --target-dir."
fi

# Pick a TOML reader. Either mikefarah's Go `yq` or kislyuk's Python `tomlq`
# must be available; both expose jq-style path syntax.
if command -v yq >/dev/null 2>&1 && yq --version 2>&1 | grep -qiE 'mikefarah|github\.com/mikefarah'; then
    TOML_READER="mikefarah-yq"
elif command -v tomlq >/dev/null 2>&1; then
    TOML_READER="tomlq"
else
    echo "Error: no TOML parser found." >&2
    echo "  Install one of:" >&2
    echo "    - mikefarah/yq (Go):     https://github.com/mikefarah/yq" >&2
    echo "    - kislyuk/yq   (Python): https://github.com/kislyuk/yq (provides 'tomlq')" >&2
    exit 1
fi
# -----------------------------------------------------------------------------

# Reads a string field from the [package] section of $TOML.
# Usage: read_pkg_field <key>
read_pkg_field() {
    local key="$1"
    local val
    case "$TOML_READER" in
        mikefarah-yq) val=$(yq    -p toml -oy ".package.${key}" "$TOML") ;;
        tomlq)        val=$(tomlq -r          ".package.${key}" "$TOML") ;;
    esac
    if [[ -z "$val" || "$val" == "null" ]]; then
        echo "Error: could not read .package.${key} from $TOML." >&2
        exit 1
    fi
    printf '%s\n' "$val"
}

if [[ -z "$TARGET_DIR" ]]; then
    if [[ "$PREVIEW" -eq 1 ]]; then
        PKG_PATH=$(typst info -f json 2>/dev/null | jq -r '.packages["package-cache-path"]')
        TARGET_DIR="${PKG_PATH}/preview"
    else
        PKG_PATH=$(typst info -f json 2>/dev/null | jq -r '.packages["package-path"]')
        TARGET_DIR="${PKG_PATH}/local"
    fi
fi

# Always resolve TARGET_DIR to an absolute path so PACKAGE_DIR (and any consumer
# of it, e.g. GitHub Actions) gets a stable, location-independent path.
if [[ "$TARGET_DIR" != /* ]]; then
    TARGET_DIR="$PWD/$TARGET_DIR"
fi

PKG_NAME=$(read_pkg_field name)
PKG_VERSION=$(read_pkg_field version)

BASE="${TARGET_DIR}/${PKG_NAME}/${PKG_VERSION}"

echo "PACKAGE_DIR=$BASE" >> "${GITHUB_ENV:-/dev/null}"
echo "TARGET_DIR"="$TARGET_DIR" >> "${GITHUB_ENV:-/dev/null}"
echo "PKG_NAME=$PKG_NAME" >> "${GITHUB_ENV:-/dev/null}"
echo "PKG_VERSION=$PKG_VERSION" >> "${GITHUB_ENV:-/dev/null}"
echo "Installing to: $BASE"
echo "Import namespace: @${IMPORT_NAMESPACE}"

# Refuse to clobber an existing install unless --force was given.
if [[ -d "$BASE" ]] && [[ -n "$(ls -A "$BASE" 2>/dev/null)" ]]; then
    if [[ "$FORCE" -eq 1 ]]; then
        echo "Target directory is not empty; --force given, removing existing contents."
        rm -rf "$BASE"
    else
        echo "Error: target directory '$BASE' already exists and is not empty." >&2
        echo "  Pass --force to overwrite it." >&2
        exit 1
    fi
fi

mkdir -p "$BASE/template" "$BASE/example"

# Copies the contents of <src> into <dest>, omitting any paths matching the
# given exclude patterns. Patterns are matched against either the basename
# (when no '/' is present) or the path relative to <dest>. A trailing '/**'
# or '/*' is stripped so that the directory itself is removed.
# Usage: copy_dir <dest> <src> [exclude_pattern...]
copy_dir() {
    local dest="$1"
    local src="$2"
    shift 2

    mkdir -p "$dest"
    # Trailing '/.' makes cp copy the *contents* of src into dest.
    cp -R "${src%/}/." "$dest/"

    local pattern stripped
    for pattern in "$@"; do
        stripped="${pattern%/\*\*}"
        stripped="${stripped%/\*}"
        # Translate any remaining '**' to '*' (find's -path/-name globs treat
        # '*' as matching across '/' for -path).
        stripped="${stripped//\*\*/\*}"
        if [[ "$stripped" == */* ]]; then
            find "$dest" -path "$dest/$stripped" -prune -exec rm -rf {} + 2>/dev/null || true
        else
            find "$dest" -name "$stripped" -prune -exec rm -rf {} + 2>/dev/null || true
        fi
    done

    echo "  copied: $src -> $dest/"
}

# Copies each given file flat into <dest> (preserving only the basename),
# regardless of how deeply the source path is nested.
# Usage: copy_files_flat <dest> [file...]
copy_files_flat() {
    local dest="$1"
    shift
    for f in "$@"; do
        cp -r "$f" "$dest/"
        echo "  copied: $f -> $dest/$(basename "$f")"
    done
}

PKG_FILES_DIR="template/template/"
PKG_FILES_EXCLUDE=(
    'README.md'
)

EXAMPLE_FILES_DIR="template/"
EXAMPLE_FILES_EXCLUDE=(
    'template/**'
    '.vscode/**'
    'LICENSE'
    '.gitignore'
)

ADDITIONAL_FILES=(
    'thumbnail.png'
    'typst.toml'
    'template/LICENSE'
    'template/README.md'
)

# Merge .gitignore patterns into the EXCLUDE arrays, if present.
if [[ -f .gitignore ]]; then
    while IFS= read -r line; do
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        PKG_FILES_EXCLUDE+=("$line")
        EXAMPLE_FILES_EXCLUDE+=("$line")
    done < .gitignore
fi

copy_dir        "$BASE/template" "$PKG_FILES_DIR"     "${PKG_FILES_EXCLUDE[@]}"
copy_dir        "$BASE/example"  "$EXAMPLE_FILES_DIR" "${EXAMPLE_FILES_EXCLUDE[@]}"
copy_files_flat "$BASE"          "${ADDITIONAL_FILES[@]}"

# Replace imports from relative paths to package imports.
# `sed -i` differs between GNU sed (`-i` with no arg = no backup) and BSD sed
# (`-i` requires a suffix arg, empty string = no backup), so detect and adapt.
if sed --version >/dev/null 2>&1; then
    SED_INPLACE=(sed -i)
else
    SED_INPLACE=(sed -i '')
fi

find "${BASE}/example" \
    -name "*.typ" \
    -exec "${SED_INPLACE[@]}" -E 's|#import "[./]*(template/)?lib\.typ"|#import "'"@${IMPORT_NAMESPACE}/${PKG_NAME}:${PKG_VERSION}"'"|g' {} + \
    -exec "${SED_INPLACE[@]}" -E 's|#import \\"[./]*(template/)?lib\.typ\\"|#import \\"'"@${IMPORT_NAMESPACE}/${PKG_NAME}:${PKG_VERSION}"'\\"|g' {} +
