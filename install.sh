#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
for DEST in "$HOME/.claude/skills" "$HOME/.cursor/skills"; do
  mkdir -p "$DEST"
  printf '\n\033[1m%s\033[0m\n' "$DEST"
  for skill in "$SCRIPT_DIR"/skills/*/; do
    name=$(basename "$skill")
    if [ -d "$DEST/$name" ]; then
      rm -r "$DEST/$name"
      printf '  \033[33mUpdating\033[0m %s\n' "$name"
    else
      printf '  \033[32mInstalling\033[0m %s\n' "$name"
    fi
    cp -r "$skill" "$DEST/$name"
  done
done
printf '\nDone. Skills installed to ~/.claude/skills/ and ~/.cursor/skills/.\n'
