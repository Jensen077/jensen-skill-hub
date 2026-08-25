#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: $0 [--category <cat>] [--tag <tag>] [--keyword <kw>]"
  echo ""
  echo "Options:"
  echo "  --category   Filter by category (ai-agent-skills|ai-coding-skills|ai-tools|ai-wiki)"
  echo "  --tag        Filter by tag"
  echo "  --keyword    Search in name and description"
  echo ""
  echo "Examples:"
  echo "  $0 --category ai-agent-skills"
  echo "  $0 --tag debugging"
  echo "  $0 --keyword brainstorm"
  exit 0
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

CATEGORY=""
TAG=""
KEYWORD=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --category) CATEGORY="$2"; shift 2 ;;
    --tag) TAG="$2"; shift 2 ;;
    --keyword) KEYWORD="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

SEARCH_DIRS=("ai-agent-skills" "ai-coding-skills" "ai-tools" "ai-wiki")

if [ -n "$CATEGORY" ]; then
  SEARCH_DIRS=("$CATEGORY")
fi

FOUND=0
for dir in "${SEARCH_DIRS[@]}"; do
  if [ ! -d "$PROJECT_DIR/$dir" ]; then
    continue
  fi
  for skill_dir in "$PROJECT_DIR/$dir"/*/; do
    [ -d "$skill_dir" ] || continue
    META=""
    for f in "$skill_dir/skill.json" "$skill_dir/wiki.json" "$skill_dir/tool.json"; do
      if [ -f "$f" ]; then
        META="$f"
        break
      fi
    done
    if [ -z "$META" ]; then
      continue
    fi

    NAME=$(python3 -c "import json; print(json.load(open('$META'))['name'])" 2>/dev/null || echo "")
    DESC=$(python3 -c "import json; print(json.load(open('$META'))['description'])" 2>/dev/null || echo "")
    TAGS=$(python3 -c "import json; print(' '.join(json.load(open('$META'))['tags']))" 2>/dev/null || echo "")

    MATCH=1
    if [ -n "$TAG" ]; then
      if ! echo "$TAGS" | grep -qi "$TAG"; then
        MATCH=0
      fi
    fi
    if [ -n "$KEYWORD" ]; then
      if ! echo "$NAME $DESC" | grep -qi "$KEYWORD"; then
        MATCH=0
      fi
    fi

    if [ "$MATCH" -eq 1 ]; then
      echo "[$dir] $NAME — $DESC"
      echo "  Tags: $TAGS"
      echo "  Path: $skill_dir"
      echo ""
      FOUND=$((FOUND + 1))
    fi
  done
done

if [ "$FOUND" -eq 0 ]; then
  echo "No skills found."
fi
