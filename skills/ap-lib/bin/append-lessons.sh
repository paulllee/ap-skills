#!/usr/bin/env bash
# Append a lesson to the "## Lessons Learned" section of AGENTS.md (dedup).
# Usage: append-lessons.sh "lesson text" [agents_file]
# Exit codes: 0=appended, 1=error, 2=duplicate (already exists)
set -euo pipefail

LESSON="${1:?Usage: append-lessons.sh \"lesson text\" [agents_file]}"
AGENTS="${2:-AGENTS.md}"

if [ ! -f "$AGENTS" ]; then
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  AGENTS="$ROOT/AGENTS.md"
fi

if [ ! -f "$AGENTS" ]; then
  echo "ERROR | AGENTS.md not found"
  exit 1
fi

# Check for duplicate (case-insensitive, ignoring leading "- ")
CLEAN=$(echo "$LESSON" | sed 's/^- //' | tr '[:upper:]' '[:lower:]' | sed 's/[[:space:]]*$//')
EXISTING_LESSONS=$(sed -n '/^## Lessons Learned/,/^## /p' "$AGENTS" | grep -E '^- ' || true)
if [ -n "$EXISTING_LESSONS" ]; then
  while IFS= read -r line; do
    EXISTING=$(echo "$line" | sed 's/^- //' | tr '[:upper:]' '[:lower:]' | sed 's/[[:space:]]*$//')
    if [ "$CLEAN" = "$EXISTING" ]; then
      echo "DUPLICATE | $LESSON"
      exit 2
    fi
  done <<< "$EXISTING_LESSONS"
fi

# Find the line number of "## Lessons Learned"
SECTION_LINE=$(grep -n '^## Lessons Learned' "$AGENTS" | head -1 | cut -d: -f1 || true)
if [ -z "$SECTION_LINE" ]; then
  # Append section at end
  printf '\n## Lessons Learned\n\n- %s\n' "$LESSON" >> "$AGENTS"
  echo "ADDED | $LESSON (created section)"
  exit 0
fi

# Find the next section after Lessons Learned (or EOF)
TOTAL=$(wc -l < "$AGENTS" | tr -d ' ')
NEXT_SECTION=$(tail -n +"$((SECTION_LINE + 1))" "$AGENTS" | grep -n '^## ' | head -1 | cut -d: -f1 || true)

if [ -n "$NEXT_SECTION" ]; then
  INSERT_AT=$((SECTION_LINE + NEXT_SECTION - 1))
else
  INSERT_AT=$((TOTAL + 1))
fi

# Insert the lesson before the next section (or at EOF)
{
  head -n "$((INSERT_AT - 1))" "$AGENTS"
  echo "- $LESSON"
  tail -n +"$INSERT_AT" "$AGENTS"
} > "$AGENTS.tmp" && mv "$AGENTS.tmp" "$AGENTS"

echo "ADDED | $LESSON"
