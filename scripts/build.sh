#!/usr/bin/env bash
# Orchestrates install + prune + build for PXT Maker (ESP32-S2).
# No Cloud Build substitutions; everything is local shell.
set -euo pipefail

# Always run from repo root (/workspace in Cloud Build)
cd "$(dirname "$0")/.."

phase="${1:-all}"

install_deps() {
  echo "==> Installing system deps (compiler, libudev) ..."
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get install -y --no-install-recommends build-essential g++ libudev-dev
  # Ensure C++17 for native modules (e.g., usb)
  export CXXFLAGS="-std=gnu++17"

  echo "==> npm install (no audit/fund noise) ..."
  npm install --unsafe-perm --no-audit --fund=false
}

prune_and_build() {
  echo "==> Ensure branch tracks origin/master (pxt update expects this) ..."
  git checkout -B master
  git fetch origin master
  git branch --set-upstream-to=origin/master master || true

  echo "==> Minimal prune to only keep springbot (esp32-s2) and its transitive deps ..."
  bash scripts/prune-minimal.sh

  echo "==> Remove @types/node to avoid TS syntax mismatches with PXT's TS version ..."
  rm -rf node_modules/@types/node || true

  # Relax TS checks that aren't relevant to our target build
  export PXT_TSARGS="--skipLibCheck"

  echo "==> pxt update (align target, core, and packages) ..."
  npx -y pxt@latest update

  echo "==> pxt staticpkg (package editor/site for hosting) ..."
  npx -y pxt@latest staticpkg
}

case "${phase}" in
  install)
    install_deps
    ;;
  build)
    prune_and_build
    ;;
  all)
    install_deps
    prune_and_build
    ;;
  *)
    echo "Unknown phase: ${phase}" >&2
    exit 2
    ;;
esac
