import { defineServicePlugin, z } from "@rizom/brain/services";

const helloConfig = z.object({
  greeting: z.string().default("Hello from an external plugin"),
  audience: z.string().default("brain"),
});

/** What `use(hello, config)` accepts; every field has a default. */
export type HelloPluginConfig = z.input<typeof helloConfig>;

/**
 * A minimal external service: its config reaches the agent's instructions.
 * The brain registers it under the installed package's name.
 */
export default defineServicePlugin(
  {
    id: "hello",
    config: helloConfig,
  },
  {
    instructions: ({ config }) =>
      `When asked about the hello plugin, say: ${config.greeting}, ${config.audience}.`,
  },
);
