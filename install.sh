#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude/skills"
mkdir -p "$DEST"
for skill in "$SCRIPT_DIR"/skills/*/; do
  name=$(basename "$skill")
  if [ -d "$DEST/$name" ]; then
    rm -r "$DEST/$name"
    printf '\033[33mUpdating\033[0m %s\n' "$name"
  else
    printf '\033[32mInstalling\033[0m %s\n' "$name"
  fi
  cp -r "$skill" "$DEST/$name"
done
printf 'Done. Installed %d skills.\n' "$(ls -d "$DEST"/*/ 2>/dev/null | wc -l)"
