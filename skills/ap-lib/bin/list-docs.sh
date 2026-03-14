#!/usr/bin/env bash
# List documentation files in the project.
# Usage: list-docs.sh [project_dir]
# Output: one line per doc file — "path | size_lines"
set -euo pipefail

DIR="${1:-.}"

if [ "$DIR" = "." ]; then
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
else
  ROOT="$DIR"
fi

found=0
for pattern in \
  "$ROOT/README.md" \
  "$ROOT/README.rst" \
  "$ROOT/AGENTS.md" \
  "$ROOT/CLAUDE.md" \
  "$ROOT/CLAUDE.local.md" \
  "$ROOT/CHANGELOG.md" \
  "$ROOT/CONTRIBUTING.md" \
  "$ROOT/API.md" \
  "$ROOT/LICENSE.md"; do
  [ -f "$pattern" ] || continue
  found=1
  lines=$(wc -l < "$pattern" | tr -d ' ')
  printf '%s | %s lines\n' "$pattern" "$lines"
done

# docs/ directory
if [ -d "$ROOT/docs" ]; then
  while IFS= read -r f; do
    found=1
    lines=$(wc -l < "$f" | tr -d ' ')
    printf '%s | %s lines\n' "$f" "$lines"
  done < <(find "$ROOT/docs" -name '*.md' -not -path '*/plans/*' 2>/dev/null | sort)
fi

if [ "$found" -eq 0 ]; then
  echo "(no documentation files found)"
fi
