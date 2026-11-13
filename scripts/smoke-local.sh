#!/usr/bin/env bash
# Smoke-test the plugin against a packed @rizom/brain tarball.
set -euo pipefail

if [[ -z "${BRAIN_TARBALL:-}" ]]; then
  echo "Set BRAIN_TARBALL to a packed @rizom/brain .tgz file." >&2
  exit 1
fi

if [[ ! -f "$BRAIN_TARBALL" ]]; then
  echo "BRAIN_TARBALL does not exist: $BRAIN_TARBALL" >&2
  exit 1
fi

BRAIN_SPEC="file:$(cd "$(dirname "$BRAIN_TARBALL")" && pwd)/$(basename "$BRAIN_TARBALL")" \
  exec "$(dirname "${BASH_SOURCE[0]}")/smoke.sh"
