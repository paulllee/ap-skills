#!/usr/bin/env bash
# Detect build/task tool files and extract their targets/commands.
# Usage: detect-build-tools.sh [project_dir]
# Output: one line per tool — "file | tool_name | targets"
set -euo pipefail

DIR="${1:-.}"

detect() {
  local file="$1" name="$2"
  [ -f "$DIR/$file" ] || return 0
  local targets=""
  case "$name" in
    make)
      targets=$(grep -E '^[a-zA-Z_][a-zA-Z0-9_-]*:' "$DIR/$file" 2>/dev/null \
        | sed 's/:.*//' | sort -u | tr '\n' ' ' | sed 's/ $//' || true)
      ;;
    just)
      targets=$(grep -E '^[a-zA-Z_][a-zA-Z0-9_-]*:' "$DIR/$file" 2>/dev/null \
        | sed 's/:.*//' | sort -u | tr '\n' ' ' | sed 's/ $//' || true)
      ;;
    taskfile)
      targets=$(grep -E '^\s+[a-zA-Z_][a-zA-Z0-9_-]*:' "$DIR/$file" 2>/dev/null \
        | sed 's/:.*//' | tr -d ' ' | sort -u | tr '\n' ' ' | sed 's/ $//' || true)
      ;;
    npm)
      # Try python3/node for reliable JSON parsing, fall back to grep
      targets=$(python3 -c "import json,sys;print(' '.join(sorted(json.load(open(sys.argv[1])).get('scripts',{}).keys())))" "$DIR/$file" 2>/dev/null \
        || node -e "const p=require(process.argv[1]);console.log(Object.keys(p.scripts||{}).sort().join(' '))" "$DIR/$file" 2>/dev/null \
        || sed -n '/"scripts"/,/}/p' "$DIR/$file" 2>/dev/null \
          | grep -oE '"[a-zA-Z_][a-zA-Z0-9_-]*"\s*:' | sed 's/"//g;s/\s*://' \
          | sort -u | tr '\n' ' ' | sed 's/ $//' || true)
      ;;
    gradle)
      targets=$(grep -E '^\s*task\s+' "$DIR/$file" 2>/dev/null \
        | sed 's/.*task\s\+\([a-zA-Z0-9_]*\).*/\1/' | sort -u \
        | tr '\n' ' ' | sed 's/ $//' || true)
      ;;
    maven)
      targets="(maven lifecycle)"
      ;;
    docker)
      targets="(docker)"
      ;;
    rake)
      targets=$(grep -E '^\s*task\s+:' "$DIR/$file" 2>/dev/null \
        | sed 's/.*:\([a-zA-Z0-9_]*\).*/\1/' | sort -u \
        | tr '\n' ' ' | sed 's/ $//' || true)
      ;;
    *)
      targets=""
      ;;
  esac
  printf '%s | %s | %s\n' "$file" "$name" "${targets:-(none detected)}"
}

detect Makefile make
detect GNUmakefile make
detect Justfile just
detect Taskfile.yml taskfile
detect Taskfile.yaml taskfile
detect package.json npm
detect build.gradle gradle
detect pom.xml maven
detect Dockerfile docker
detect docker-compose.yml docker
detect compose.yml docker
detect Rakefile rake
detect Cakefile rake
detect BUILD bazel
