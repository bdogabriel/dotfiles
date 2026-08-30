#!/usr/bin/env bash
set -euo pipefail

# resolve through symlinks so this works both before and after it's been linked into $HOME
SCRIPT_REAL="$(readlink -f "$0")"
REPO_ROOT="$(cd "$(dirname "$(dirname "$(dirname "$SCRIPT_REAL")")")" && pwd)"

if ! command -v stow >/dev/null 2>&1; then
    echo "stow not found; install it (e.g. dnf install stow / apt install stow) and rerun" >&2
    exit 1
fi

mkdir -p "$HOME/.config"

stow --restow --target="$HOME" --dir="$REPO_ROOT" root
stow --restow --no-folding --target="$HOME/.config" --dir="$REPO_ROOT" config
