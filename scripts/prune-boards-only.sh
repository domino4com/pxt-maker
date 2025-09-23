#!/usr/bin/env bash
# Deletes *board packages* (dirs in libs/ with a board.json) except libs/springbot.
# Leaves all non-board libs intact so PXT bundled packages (base---light, game, etc.)
# remain available for staticpkg/doc generation.
set -euo pipefail
cd "$(dirname "$0")/.."

LIBS="libs"
KEEP_BOARD="springbot"

if [[ ! -d "${LIBS}/${KEEP_BOARD}" || ! -f "${LIBS}/${KEEP_BOARD}/board.json" ]]; then
  echo "ERROR: '${LIBS}/${KEEP_BOARD}' not found or missing board.json. Aborting prune." >&2
  exit 1
fi

echo "==> Removing other board packages (keep '${KEEP_BOARD}') ..."
shopt -s nullglob
for d in ${LIBS}/*; do
  [[ -d "$d" ]] || continue
  if [[ -f "${d}/board.json" ]]; then
    base="$(basename "$d")"
    if [[ "$base" != "${KEEP_BOARD}" ]]; then
      rm -rf "$d"
    fi
  fi
done

echo "==> Remaining board packages:"
find "${LIBS}" -maxdepth 1 -type d -exec test -f '{}/board.json' ';' -printf "   - %f\n" | sort || true

echo "==> Non-board libs preserved (not listed):"
