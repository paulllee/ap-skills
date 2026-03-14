#!/usr/bin/env bash
# Create the next AP-N plan file and print its path to stdout.
# Usage: ap-next-plan.sh [plans_dir]
#   plans_dir  defaults to docs/plans relative to repo root (git) or cwd.
set -euo pipefail

if [ -n "${1:-}" ]; then
  PLANS_DIR="$1"
else
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  PLANS_DIR="$ROOT/docs/plans"
fi

mkdir -p "$PLANS_DIR"

# Find the highest existing AP-N number
NEXT=1
for f in "$PLANS_DIR"/AP-*.md; do
  [ -e "$f" ] || continue
  NUM=$(basename "$f" | sed -n 's/^AP-\([0-9]*\)\.md$/\1/p')
  [ -n "$NUM" ] && [ "$NUM" -ge "$NEXT" ] && NEXT=$((NUM + 1))
done

FILE="$PLANS_DIR/AP-${NEXT}.md"
touch "$FILE"
echo "$FILE"
