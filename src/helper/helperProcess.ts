import { spawn } from "node:child_process";

type StreamLike = {
  on(event: string, listener: (...args: unknown[]) => void): void;
};

type ChildLike = {
  exitCode: number | null;
  kill(signal?: NodeJS.Signals | number): boolean;
  once(event: string, listener: (...args: unknown[]) => void): void;
  stdout?: StreamLike;
  stderr?: StreamLike;
};

type SpawnLike = (
  command: string,
  args: string[],
  options: { stdio: ["ignore", "pipe", "pipe"] }
) => ChildLike;

export class HelperProcess {
  private child: ChildLike | undefined;
  private stderrBuffer = "";

  constructor(
    private readonly options: {
      spawn?: SpawnLike;
      helperPath: string;
      intervalMs: number;
      windowTitle: string;
      onStderrLine?: (line: string) => void;
      onExit?: (code: number | null) => void;
    }
  ) {}

  isRunning(): boolean {
    return Boolean(this.child && this.child.exitCode === null);
  }

  async start(): Promise<void> {
    if (this.isRunning()) {
      return;
    }

    const spawnFn = this.options.spawn ?? spawn;
    const child = spawnFn(
      this.options.helperPath,
      [
        "--mode",
        "active-loop",
        "--window-title",
        this.options.windowTitle,
        "--interval-ms",
        String(this.options.intervalMs)
      ],
      { stdio: ["ignore", "pipe", "pipe"] }
    );

    child.once("exit", (code) => {
      if (this.child === child) {
        this.child = undefined;
      }

      this.options.onExit?.(typeof code === "number" ? code : null);
    });

    child.stderr?.on("data", (chunk) => {
      this.stderrBuffer += String(chunk);

      const lines = this.stderrBuffer.split("\n");
      this.stderrBuffer = lines.pop() ?? "";

      for (const line of lines) {
        if (line.length > 0) {
          this.options.onStderrLine?.(line);
        }
      }
    });

    this.child = child;
  }

  async stop(): Promise<void> {
    if (!this.child) {
      return;
    }

    this.child.kill("SIGTERM");
    this.child = undefined;
    this.stderrBuffer = "";
  }
}
