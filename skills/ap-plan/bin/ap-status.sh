#!/usr/bin/env bash
# Print a summary of all AP-N plans: path | title | date | status | current_phase
# Usage: ap-status.sh [plans_dir]
set -euo pipefail

if [ -n "${1:-}" ]; then
  PLANS_DIR="$1"
else
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  PLANS_DIR="$ROOT/docs/plans"
fi

if [ ! -d "$PLANS_DIR" ]; then
  echo "No plans directory found at $PLANS_DIR"
  exit 0
fi

found=0
for f in "$PLANS_DIR"/AP-*.md; do
  [ -e "$f" ] || continue
  found=1
  title=""; date=""; status=""; phase=""
  while IFS= read -r line; do
    case "$line" in
      "# AP-"*) title="${line#*: }" ;;
      "**Date:"*) date=$(echo "$line" | sed 's/\*\*Date:\*\* *//') ;;
      "**Status:"*) status=$(echo "$line" | sed 's/\*\*Status:\*\* *//') ;;
      "**Current Phase:"*) phase=$(echo "$line" | sed 's/\*\*Current Phase:\*\* *//') ;;
    esac
    # Stop after finding all four
    [ -n "$title" ] && [ -n "$date" ] && [ -n "$status" ] && [ -n "$phase" ] && break
  done < "$f"
  printf '%s | %s | %s | %s | %s\n' "$f" "${title:-(untitled)}" "${date:-(no date)}" "${status:-(no status)}" "${phase:-(none)}"
done

if [ "$found" -eq 0 ]; then
  echo "No AP plans found in $PLANS_DIR"
fi
