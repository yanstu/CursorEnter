export interface HelperRunner {
  start(): Promise<void>;
  stop(): Promise<void>;
  isRunning(): boolean;
}

export class ToggleController {
  constructor(private readonly helper: HelperRunner) {}

  async enable(): Promise<void> {
    if (!this.helper.isRunning()) {
      await this.helper.start();
    }
  }

  async disable(): Promise<void> {
    if (this.helper.isRunning()) {
      await this.helper.stop();
    }
  }

  async toggle(): Promise<void> {
    if (this.helper.isRunning()) {
      await this.disable();
      return;
    }

    await this.enable();
  }

  async setEnabled(enabled: boolean): Promise<void> {
    if (enabled) {
      await this.enable();
      return;
    }

    await this.disable();
  }
}
