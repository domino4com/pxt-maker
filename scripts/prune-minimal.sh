#!/usr/bin/env bash
# Prunes the repo's libs/ tree to ONLY what's required for the springbot (ESP32-S2) board.
# It resolves transitive dependencies by reading pxt.json files.
set -euo pipefail
cd "$(dirname "$0")/.."

LIBS_DIR="libs"
BOARD_DIR="${LIBS_DIR}/springbot"

if [[ ! -d "${BOARD_DIR}" || ! -f "${BOARD_DIR}/board.json" ]]; then
  echo "ERROR: '${BOARD_DIR}' not found or missing board.json. Aborting prune." >&2
  exit 1
fi

echo "==> Resolving transitive dependencies from ${BOARD_DIR}/pxt.json ..."

# Build the list of libs to keep by walking pxt.json -> dependencies recursively.
# We prefer "file:../<lib>" when present; otherwise if a dep key matches a local lib dir, keep it.
KEEP_LIST=$(
  node <<'NODE'
const fs = require('fs');
const path = require('path');

const root = process.cwd();
const libsDir = path.join(root, 'libs');

function readJSON(p) {
  try { return JSON.parse(fs.readFileSync(p, 'utf8')); }
  catch { return null; }
}

function depsOf(libName) {
  const dir = path.join(libsDir, libName);
  const pj = path.join(dir, 'pxt.json');
  if (!fs.existsSync(pj)) return [];
  const j = readJSON(pj) || {};
  const deps = j.dependencies || {};
  const out = [];
  for (const [k, v] of Object.entries(deps)) {
    let name = null;
    if (typeof v === 'string' && v.startsWith('file:../')) {
      name = v.replace(/^file:\.\.\//, '');
    } else if (fs.existsSync(path.join(libsDir, k))) {
      name = k;
    }
    if (name) out.push(name);
  }
  return out;
}

const seed = 'springbot';
const keep = new Set();
const stack = [seed];

while (stack.length) {
  const lib = stack.pop();
  const dir = path.join(libsDir, lib);
  if (!fs.existsSync(dir)) continue;
  if (keep.has(lib)) continue;
  keep.add(lib);
  for (const d of depsOf(lib)) stack.push(d);
}

/**
 * Some core/runtime libs are commonly omitted in custom targets'
 * package.json but are required by core---esp32s2 stacks. Add them if present.
 * (We only keep them if directories exist to avoid false positives.)
 */
[
  'core', 'base',
  'core---esp32s2', 'esp32',
  'settings', 'settings---esp32',
  'serial', 'storage',
  'wifi---esp32'
].forEach(n => {
  if (fs.existsSync(path.join(libsDir, n))) keep.add(n);
});

// Print one per line for the shell caller.
console.log(Array.from(keep).sort().join('\n'));
NODE
)

# Convert to a grep-friendly pattern (anchor to full dir names)
KEEP_REGEX="^($(echo "${KEEP_LIST}" | tr '\n' '|' | sed 's/|$//'))$"
echo "==> Will keep these libs:"
echo "${KEEP_LIST:-<none>}" | sed 's/^/   - /'

echo "==> Removing all other libs/* directories ..."
shopt -s nullglob
for d in ${LIBS_DIR}/*; do
  base="$(basename "$d")"
  if [[ ! -d "$d" ]]; then
    continue
  fi
  # Never delete the libs root or non-dirs; only top-level library folders.
  if echo "${base}" | grep -Eq "${KEEP_REGEX}"; then
    continue
  fi
  rm -rf "$d"
done

echo "==> Remaining libs after prune:"
find "${LIBS_DIR}" -maxdepth 1 -mindepth 1 -type d -printf "   - %f\n" | sort
