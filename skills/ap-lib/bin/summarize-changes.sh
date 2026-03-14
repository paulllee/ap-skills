#!/usr/bin/env bash
# Summarize recent git changes: diff stats and recent commits.
# Usage: summarize-changes.sh [commit_range]
#   commit_range  defaults to HEAD~1 (last commit)
# Output: DIFF section then LOG section, machine-readable.
set -euo pipefail

RANGE="${1:-HEAD~1}"

# Handle edge cases
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR | not a git repository"
  exit 1
fi

COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo 0)
if [ "$COMMIT_COUNT" -eq 0 ]; then
  echo "ERROR | no commits yet"
  exit 1
fi

if [ "$COMMIT_COUNT" -eq 1 ]; then
  RANGE="$(git rev-list --max-parents=0 HEAD)"
fi

# Diff stats
echo "=== DIFF ==="
git diff --stat "$RANGE" 2>/dev/null || echo "(no diff available)"

echo ""
echo "=== CHANGED FILES ==="
git diff --name-only "$RANGE" 2>/dev/null || echo "(none)"

echo ""
echo "=== CATEGORIES ==="
docs=0; code=0; config=0; tests=0
while IFS= read -r file; do
  case "$file" in
    *.md|docs/*|README*|CHANGELOG*) docs=$((docs + 1)) ;;
    *test*|*spec*|*_test.*|*.test.*) tests=$((tests + 1)) ;;
    *.json|*.yml|*.yaml|*.toml|*.ini|*.cfg|.git*|Dockerfile*|docker-compose*) config=$((config + 1)) ;;
    *) code=$((code + 1)) ;;
  esac
done < <(git diff --name-only "$RANGE" 2>/dev/null)
echo "docs=$docs code=$code config=$config tests=$tests"

echo ""
echo "=== LOG ==="
git log --oneline -5 2>/dev/null || echo "(no log)"
