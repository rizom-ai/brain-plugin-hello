# @rizom/brain-plugin-hello

[![CI](https://github.com/rizom-ai/brain-plugin-hello/actions/workflows/ci.yml/badge.svg)](https://github.com/rizom-ai/brain-plugin-hello/actions/workflows/ci.yml)

Minimal external plugin example for [`@rizom/brain`](https://github.com/rizom-ai/brains/tree/main/packages/brain-cli).

This package is intentionally boring. It proves that an external plugin can:

- import only public `@rizom/brain/*` APIs
- build against generated public declarations
- load from `brain.yaml plugins:`
- receive `onRegister` and `onReady` lifecycle calls

## Install

```bash
bun add @rizom/brain-plugin-hello
```

The plugin declares `@rizom/brain` as a peer dependency. The brain instance owns the actual `@rizom/brain` version.

## Configure

Add the package to your brain instance `package.json`:

```json
{
  "dependencies": {
    "@rizom/brain": "^0.2.0-alpha.48",
    "@rizom/brain-plugin-hello": "^0.1.0"
  }
}
```

Declare the plugin in `brain.yaml`:

```yaml
brain: rover
preset: core

plugins:
  hello:
    package: "@rizom/brain-plugin-hello"
    config:
      greeting: "Hello from outside the monorepo"
      audience: "Rizom"
```

Then run:

```bash
bun install
brain start
```

For CI/smoke checks that only need to prove the plugin loads and reaches `onReady`, use:

```bash
brain start --startup-check
```

You should see lifecycle logs similar to:

```txt
[hello] Hello plugin registered
[hello] Hello plugin ready
```

## Smoke tests

The default CI path uses the published `@rizom/brain` package:

```bash
bun run smoke:published
```

To test against a local unpublished `@rizom/brain` build, build/pack it locally in the monorepo first:

```bash
cd /path/to/brains/packages/brain-cli
bun run build
bun pm pack --destination /tmp/rizom-brain-pack
```

Then run this repo's local smoke test against that tarball:

```bash
cd /path/to/brain-plugin-hello
BRAIN_TARBALL=/tmp/rizom-brain-pack/rizom-brain-0.2.0-alpha.48.tgz bun run smoke:local
```

The smoke test creates a temporary plugin copy and a temporary brain instance, installs tarballs, and runs `brain start --startup-check` to verify the hello plugin registered and reached ready.
