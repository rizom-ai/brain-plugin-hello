import { ServicePlugin, type ServicePluginContext } from "@rizom/brain/plugins";
import { z } from "zod";

const packageInfo = {
  name: "@rizom/brain-plugin-hello",
  version: "0.1.0",
  description: "Minimal external plugin example for @rizom/brain.",
};

const HelloPluginConfigSchema = z.object({
  greeting: z.string().default("Hello from an external plugin"),
  audience: z.string().default("brain"),
});

export type HelloPluginConfig = z.input<typeof HelloPluginConfigSchema>;

type ResolvedHelloPluginConfig = z.output<typeof HelloPluginConfigSchema>;

export class HelloPlugin extends ServicePlugin<ResolvedHelloPluginConfig> {
  private readonly config: ResolvedHelloPluginConfig;

  constructor(config: HelloPluginConfig = {}) {
    const parsedConfig = HelloPluginConfigSchema.parse(config);
    super("hello", packageInfo, parsedConfig, HelloPluginConfigSchema);
    this.config = parsedConfig;
  }

  protected override async onRegister(
    context: ServicePluginContext,
  ): Promise<void> {
    context.logger.info("Hello plugin registered", {
      greeting: this.config.greeting,
      audience: this.config.audience,
    });
    context.registerInstructions(
      `When asked about the hello plugin, say: ${this.config.greeting}, ${this.config.audience}.`,
    );
  }

  protected override async onReady(context: ServicePluginContext): Promise<void> {
    const identity = context.identity.get();
    context.logger.info("Hello plugin ready", {
      characterName: identity.name,
      greeting: this.config.greeting,
      audience: this.config.audience,
    });
  }
}

export function helloPlugin(config: HelloPluginConfig = {}): HelloPlugin {
  return new HelloPlugin(config);
}

export default helloPlugin;
