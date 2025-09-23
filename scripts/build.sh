#!/usr/bin/env bash
# Orchestrates install + prune + build for PXT Maker (ESP32-S2).
# No Cloud Build substitutions; everything is local shell.
set -euo pipefail

# Always run from repo root (/workspace in Cloud Build)
cd "$(dirname "$0")/.."

phase="${1:-all}"

strip_node_types() {
  # Remove any direct references so PXT’s TypeScript (older) won’t parse Node 18+ dts.
  npm pkg delete devDependencies["@types/node"] >/dev/null 2>&1 || true
  npm pkg delete dependencies["@types/node"] >/dev/null 2>&1 || true
  rm -rf node_modules/@types/node || true
}

install_deps() {
  echo "==> Installing system deps (compiler, libudev) ..."
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get install -y --no-install-recommends build-essential g++ libudev-dev

  # Ensure C++17 for native modules (e.g., usb)
  export CXXFLAGS="-std=gnu++17"

  echo "==> Removing @types/node (pre-install guard) ..."
  strip_node_types

  rm -rf node_modules || true # Clean up previous installations
  echo "==> npm install (no audit/fund noise) ..."
  npm install --unsafe-perm --no-audit --fund=false
}

prune_and_build() {
  echo "==> Ensure branch tracks origin/master (pxt update expects this) ..."
  git checkout -B master
  git fetch origin master
  git branch --set-upstream-to=origin/master master || true

  echo "==> Prune: keep ONLY board package libs/springbot, remove other *board* packages"
  bash scripts/prune-boards-only.sh

  echo "==> Remove @types/node again (guard around pxt update’s npm step) ..."
  strip_node_types

  # Relax TS checks to avoid incidental type noise in bundled packages
  export PXT_TSARGS="--skipLibCheck"

  echo "==> pxt update (align target, core, and packages) ..."
  npx -y pxt@latest update

  echo "==> Build local target ..."
  npx -y pxt@latest build --local

  echo "==> Final @types/node guard after update ..."
  strip_node_types

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
