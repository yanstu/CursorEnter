import { describe, expect, it, vi } from "vitest";
import { HelperProcess } from "../helper/helperProcess";

describe("HelperProcess", () => {
  it("spawns helper only once", async () => {
    const spawn = vi.fn(() => ({
      pid: 123,
      kill: vi.fn(),
      once: vi.fn(),
      stdout: { on: vi.fn() },
      stderr: { on: vi.fn() },
      exitCode: null
    }));

    const helper = new HelperProcess({
      spawn,
      helperPath: "/tmp/cursor-enter-helper",
      intervalMs: 300,
      windowTitle: "Cursor Agents"
    });

    await helper.start();
    await helper.start();

    expect(spawn).toHaveBeenCalledTimes(1);
  });

  it("uses active loop mode so Enter targets Cursor Agents via foreground fallback", async () => {
    const spawn = vi.fn(() => ({
      pid: 123,
      kill: vi.fn(),
      once: vi.fn(),
      stdout: { on: vi.fn() },
      stderr: { on: vi.fn() },
      exitCode: null
    }));

    const helper = new HelperProcess({
      spawn,
      helperPath: "/tmp/cursor-enter-helper",
      intervalMs: 300,
      windowTitle: "Cursor Agents"
    });

    await helper.start();

    expect(spawn).toHaveBeenCalledWith(
      "/tmp/cursor-enter-helper",
      [
        "--mode",
        "active-loop",
        "--window-title",
        "Cursor Agents",
        "--interval-ms",
        "300"
      ],
      { stdio: ["ignore", "pipe", "pipe"] }
    );
  });

  it("marks process stopped after child exit", async () => {
    let exitListener: ((code?: number | null) => void) | undefined;

    const child = {
      pid: 123,
      kill: vi.fn(),
      once: vi.fn((event: string, listener: (code?: number | null) => void) => {
        if (event === "exit") {
          exitListener = listener;
        }
      }),
      stdout: { on: vi.fn() },
      stderr: { on: vi.fn() },
      exitCode: null as number | null
    };

    const helper = new HelperProcess({
      spawn: vi.fn(() => child),
      helperPath: "/tmp/cursor-enter-helper",
      intervalMs: 300,
      windowTitle: "Cursor Agents"
    });

    await helper.start();
    expect(helper.isRunning()).toBe(true);

    child.exitCode = 0;
    exitListener?.(0);

    expect(helper.isRunning()).toBe(false);
  });

  it("forwards stderr lines to callback", async () => {
    let stderrListener: ((chunk: Buffer) => void) | undefined;

    const child = {
      pid: 123,
      kill: vi.fn(),
      once: vi.fn(),
      stdout: { on: vi.fn() },
      stderr: {
        on: vi.fn((event: string, listener: (chunk: Buffer) => void) => {
          if (event === "data") {
            stderrListener = listener;
          }
        })
      },
      exitCode: null
    };

    const onStderrLine = vi.fn();
    const helper = new HelperProcess({
      spawn: vi.fn(() => child),
      helperPath: "/tmp/cursor-enter-helper",
      intervalMs: 300,
      windowTitle: "Cursor Agents",
      onStderrLine
    });

    await helper.start();
    stderrListener?.(Buffer.from("{\"reason\":\"accessibility_not_granted\"}\n"));

    expect(onStderrLine).toHaveBeenCalledWith(
      "{\"reason\":\"accessibility_not_granted\"}"
    );
  });

  it("notifies exit callback when child exits", async () => {
    let exitListener: ((code?: number | null) => void) | undefined;

    const child = {
      pid: 123,
      kill: vi.fn(),
      once: vi.fn((event: string, listener: (code?: number | null) => void) => {
        if (event === "exit") {
          exitListener = listener;
        }
      }),
      stdout: { on: vi.fn() },
      stderr: { on: vi.fn() },
      exitCode: null as number | null
    };

    const onExit = vi.fn();
    const helper = new HelperProcess({
      spawn: vi.fn(() => child),
      helperPath: "/tmp/cursor-enter-helper",
      intervalMs: 300,
      windowTitle: "Cursor Agents",
      onExit
    });

    await helper.start();
    child.exitCode = 0;
    exitListener?.(0);

    expect(onExit).toHaveBeenCalledWith(0);
  });
});
