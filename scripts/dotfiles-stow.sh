#!/usr/bin/env bash
set -euo pipefail

# resolve the script's real path through symlinks so this works both before
# and after it has been stowed into $HOME (macOS BSD readlink has no -f)
SCRIPT_REAL="$0"
while [ -L "$SCRIPT_REAL" ]; do
    target="$(readlink "$SCRIPT_REAL")"
    case "$target" in
        /*) SCRIPT_REAL="$target" ;;
        *)  SCRIPT_REAL="$(dirname "$SCRIPT_REAL")/$target" ;;
    esac
done
SCRIPT_REAL="$(cd "$(dirname "$SCRIPT_REAL")" && pwd -P)/$(basename "$SCRIPT_REAL")"
REPO_ROOT="$(cd "$(dirname "$(dirname "$SCRIPT_REAL")")" && pwd)"

if ! command -v stow >/dev/null 2>&1; then
    echo "stow not found; install it (e.g. brew install stow / apt install stow) and rerun" >&2
    exit 1
fi

mkdir -p "$HOME/.config"

# remove a single broken symlink if it points inside this repo
prune_one() {
    link="$1"
    if [ -e "$link" ]; then
        return 0
    fi
    t="$(readlink "$link")"
    if [ -z "$t" ]; then
        return 0
    fi
    case "$t" in
        /*) abs="$t" ;;
        *)  abs="$(cd "$(dirname "$link")" && pwd -P)/$t" ;;
    esac
    out=""
    old_IFS="$IFS"
    IFS='/'
    for part in $abs; do
        case "$part" in
            ''|'.') ;;
            '..') out="${out%/*}" ;;
            *)    out="$out/$part" ;;
        esac
    done
    IFS="$old_IFS"
    out="${out:-/}"
    if [[ "$out" == "$REPO_ROOT"/* ]]; then
        rm -f "$link"
        echo "pruned stale symlink: ${link#"$HOME"/}"
    fi
}

# prune broken symlinks pointing into the repo (stale entries from prior layouts)
prune_stale() {
    find "$HOME" -maxdepth 1 -type l 2>/dev/null | while IFS= read -r link; do
        prune_one "$link"
    done || true
    for d in scripts .agents .config; do
        if [ -d "$HOME/$d" ]; then
            find "$HOME/$d" -maxdepth 8 -type l 2>/dev/null | while IFS= read -r link; do
                prune_one "$link"
            done || true
        fi
    done
}

prune_stale

stow --restow --no-folding \
    --target="$HOME" \
    --dir="$REPO_ROOT" \
    --ignore='^\.git$' \
    --ignore='^README\.md$' \
    --ignore='^\.gitignore$' \
    --ignore='^\.rgignore$' \
    --ignore='\.DS_Store$' \
    .
