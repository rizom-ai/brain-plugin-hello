# @rizom/brain-plugin-hello

[![CI](https://github.com/rizom-ai/brain-plugin-hello/actions/workflows/ci.yml/badge.svg)](https://github.com/rizom-ai/brain-plugin-hello/actions/workflows/ci.yml)

Minimal external plugin example for [`@rizom/brain`](https://github.com/rizom-ai/brains/tree/main/packages/brain-cli).

This package is intentionally boring. It proves that an external plugin can:

- import only public `@rizom/brain/*` APIs
- default-export one declarative definition (`defineServicePlugin`)
- build against generated public declarations
- take typed config through `use()` and hand it to the agent's instructions
- test itself on `@rizom/brain/testing`

## Install

```bash
bun add @rizom/brain-plugin-hello
```

The plugin declares `@rizom/brain` as a peer dependency. The brain owns the actual `@rizom/brain` version.

## Compose it into a brain

A brain is a definition package that composes its plugins with `use()`:

```ts
import hello from "@rizom/brain-plugin-hello";
import { defineBrain, use } from "@rizom/brain";

export default defineBrain({
  name: "my-brain",
  plugins: [
    use(hello, {
      greeting: "Hello from outside the monorepo",
      audience: "Rizom",
    }),
  ],
});
```

Both settings have defaults, so `use(hello)` needs no config object. The brain's `brain.yaml` names that definition package:

```yaml
brain: "@my-org/my-brain"
```

Then run:

```bash
bun install
brain start
```

The brain registers the service under the installed package's name, `@rizom/brain-plugin-hello:hello`, and adds its instructions to the agent's.

## Develop

```bash
bun install
bun run check
```

`check` typechecks the source and tests and runs the tests, which start the plugin in a test brain from `@rizom/brain/testing`.

## Smoke tests

The default CI path uses the published `@rizom/brain` version pinned in `devDependencies` (override with `BRAIN_VERSION`):

```bash
bun run smoke:published
```

To test against a local unpublished `@rizom/brain` build, build and pack it in the monorepo first:

```bash
cd /path/to/brains/packages/brain-cli
bun run build
bun pm pack --destination /tmp/rizom-brain-pack
```

Then run this repo's local smoke test against that tarball:

```bash
cd /path/to/brain-plugin-hello
BRAIN_TARBALL=/tmp/rizom-brain-pack/rizom-brain-<version>.tgz bun run smoke:local
```

The smoke test packs a copy of the plugin, composes it into a temporary brain definition with `use()`, installs both into a temporary brain instance, and runs `brain start --startup-check` at debug log level. It passes when the brain reports that it initialized `@rizom/brain-plugin-hello:hello` and registered its instructions.
