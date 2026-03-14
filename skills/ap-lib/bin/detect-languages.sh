#!/usr/bin/env bash
# Detect project languages from file extensions and manifest files.
# Usage: detect-languages.sh [project_dir]
# Output: one line per language — "language | confidence | evidence"
#   confidence: high (manifest found) or medium (files found)
set -euo pipefail

DIR="${1:-.}"
RESULTS=""

has_lang() {
  echo "$RESULTS" | grep -q "^$1 |" 2>/dev/null && return 0 || return 1
}

add_result() {
  local lang="$1" confidence="$2" evidence="$3"
  if ! has_lang "$lang"; then
    RESULTS="${RESULTS}${lang} | ${confidence} | ${evidence}
"
  fi
}

check_manifest() {
  local file="$1" lang="$2"
  if [ -f "$DIR/$file" ]; then add_result "$lang" "high" "$file"; fi
}

check_glob_manifest() {
  local pattern="$1" lang="$2"
  if compgen -G "$DIR"/$pattern >/dev/null 2>&1; then add_result "$lang" "high" "$pattern found"; fi
}

check_extensions() {
  local ext="$1" lang="$2"
  if has_lang "$lang"; then return; fi
  local count
  count=$(find "$DIR" -maxdepth 3 -name "*.$ext" -not -path '*/node_modules/*' \
    -not -path '*/.git/*' -not -path '*/vendor/*' -not -path '*/venv/*' \
    -not -path '*/__pycache__/*' -not -path '*/bin/*' -not -path '*/obj/*' \
    2>/dev/null | head -5 | wc -l | tr -d ' ')
  if [ "$count" -gt 0 ]; then add_result "$lang" "medium" "*.$ext files found"; fi
}

# Manifests (high confidence)
check_manifest "pyproject.toml" "python"
check_manifest "setup.py" "python"
check_manifest "requirements.txt" "python"
check_manifest "Pipfile" "python"
check_manifest "package.json" "javascript"
check_manifest "tsconfig.json" "typescript"
check_manifest "go.mod" "go"
check_manifest "Cargo.toml" "rust"
check_manifest "Gemfile" "ruby"
check_manifest "composer.json" "php"
check_manifest "build.gradle" "java"
check_manifest "pom.xml" "java"
check_manifest "mix.exs" "elixir"
check_manifest "pubspec.yaml" "dart"
check_manifest "Package.swift" "swift"
check_glob_manifest "*.csproj" "csharp"
check_glob_manifest "*.sln" "csharp"
check_glob_manifest "*.fsproj" "fsharp"

# Extensions (medium confidence, only if no manifest)
check_extensions "py" "python"
check_extensions "js" "javascript"
check_extensions "ts" "typescript"
check_extensions "go" "go"
check_extensions "rs" "rust"
check_extensions "rb" "ruby"
check_extensions "php" "php"
check_extensions "java" "java"
check_extensions "cs" "csharp"
check_extensions "fs" "fsharp"
check_extensions "ex" "elixir"
check_extensions "dart" "dart"
check_extensions "swift" "swift"
check_extensions "kt" "kotlin"
check_extensions "scala" "scala"
check_extensions "cpp" "cpp"
check_extensions "c" "c"
check_extensions "zig" "zig"
check_extensions "lua" "lua"

if [ -z "$RESULTS" ]; then
  echo "(no languages detected)"
  exit 0
fi

printf '%s' "$RESULTS" | grep -v '^$' | sort || true
