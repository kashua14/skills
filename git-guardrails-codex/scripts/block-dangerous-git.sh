#!/bin/bash

COMMAND="$*"

SELF_PATH="${0:A}"
REAL_GIT="/usr/bin/git"

if [ ! -x "$REAL_GIT" ]; then
  REAL_GIT="$(which -a git | grep -v "$SELF_PATH" | head -n 1)"
fi

if [ -z "$REAL_GIT" ] || [ ! -x "$REAL_GIT" ]; then
  echo "BLOCKED: could not find the real git binary behind the guard wrapper." >&2
  exit 2
fi

DANGEROUS_PATTERNS=(
  "git push"
  "git reset --hard"
  "git clean -fd"
  "git clean -f"
  "git branch -D"
  "git checkout \."
  "git restore \."
  "push --force"
  "reset --hard"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "BLOCKED: '$COMMAND' matches dangerous pattern '$pattern'. The user has prevented you from doing this." >&2
    exit 2
  fi
done

exec "$REAL_GIT" "$@"
