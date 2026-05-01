#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${BRAIN_TARBALL:-}" ]]; then
  echo "Set BRAIN_TARBALL to a packed @rizom/brain .tgz file." >&2
  exit 1
fi

if [[ ! -f "$BRAIN_TARBALL" ]]; then
  echo "BRAIN_TARBALL does not exist: $BRAIN_TARBALL" >&2
  exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work_dir="$(mktemp -d "${TMPDIR:-/tmp}/brain-plugin-hello-smoke.XXXXXX")"
plugin_dir="$work_dir/plugin"
artifacts_dir="$work_dir/artifacts"
instance_dir="$work_dir/instance"
log_file="$instance_dir/brain-start.log"

cleanup() {
  rm -rf "$work_dir"
}
trap cleanup EXIT

mkdir -p "$plugin_dir" "$artifacts_dir" "$instance_dir"
cp "$repo_root/package.json" "$plugin_dir/package.json"
cp "$repo_root/tsconfig.json" "$plugin_dir/tsconfig.json"
cp "$repo_root/README.md" "$plugin_dir/README.md"
cp "$repo_root/LICENSE" "$plugin_dir/LICENSE"
cp -R "$repo_root/src" "$plugin_dir/src"

printf 'Installing plugin dependencies against %s...\n' "$BRAIN_TARBALL"
(
  cd "$plugin_dir"
  bun add --dev "@rizom/brain@file:$BRAIN_TARBALL"
  bun install
  bun run typecheck
  bun run build
  bun pm pack --destination "$artifacts_dir"
)

plugin_tgz="$(find "$artifacts_dir" -maxdepth 1 -name 'rizom-brain-plugin-hello-*.tgz' | sort | tail -n 1)"
if [[ -z "$plugin_tgz" ]]; then
  echo "Could not find packed hello plugin tarball" >&2
  exit 1
fi

cat > "$instance_dir/package.json" <<EOF_INSTANCE_PACKAGE
{
  "name": "brain-hello-instance-smoke",
  "private": true,
  "type": "module",
  "dependencies": {
    "@rizom/brain": "file:$BRAIN_TARBALL",
    "@rizom/brain-plugin-hello": "file:$plugin_tgz",
    "zod": "^3.25.76"
  }
}
EOF_INSTANCE_PACKAGE

cat > "$instance_dir/brain.yaml" <<'EOF_BRAIN_YAML'
brain: rover
preset: core

plugins:
  hello:
    package: "@rizom/brain-plugin-hello"
    config:
      greeting: "Hello from outside the monorepo"
      audience: "Rizom"
EOF_BRAIN_YAML

printf 'Installing temporary brain instance in %s...\n' "$instance_dir"
(
  cd "$instance_dir"
  bun install
)

printf 'Starting temporary brain instance until hello plugin is ready...\n'
set +e
(
  cd "$instance_dir"
  AI_API_KEY=dummy timeout 20s bun node_modules/.bin/brain start > "$log_file" 2>&1
)
status=$?
set -e

if [[ "$status" != "0" && "$status" != "124" ]]; then
  cat "$log_file" >&2
  exit "$status"
fi

if ! grep -q "Hello plugin registered" "$log_file"; then
  cat "$log_file" >&2
  echo "Missing hello plugin registration log" >&2
  exit 1
fi

if ! grep -q "Hello plugin ready" "$log_file"; then
  cat "$log_file" >&2
  echo "Missing hello plugin ready log" >&2
  exit 1
fi

printf 'External hello plugin smoke proof passed.\n'
