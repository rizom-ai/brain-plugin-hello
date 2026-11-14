import { describe, expect, it } from "bun:test";
import { use } from "@rizom/brain";
import { startTestBrain } from "@rizom/brain/testing";
import hello from "../src/index";

describe("the hello package", () => {
  it("is one service definition named hello", () => {
    expect(hello.family).toBe("service");
    expect(hello.id).toBe("hello");
  });

  it("starts in a brain with its defaults", async () => {
    const brain = await startTestBrain({ plugins: [use(hello)] });
    await brain.stop();
  });

  it("starts in a brain with a greeting and an audience", async () => {
    const brain = await startTestBrain({
      plugins: [
        use(hello, {
          greeting: "Hello from outside the monorepo",
          audience: "Rizom",
        }),
      ],
    });
    await brain.stop();
  });

  it("refuses a greeting that is not text", async () => {
    const config = { greeting: 42 } as unknown as { greeting: string };
    await expect(
      startTestBrain({ plugins: [use(hello, config)] }),
    ).rejects.toThrow(/greeting/);
  });
});
