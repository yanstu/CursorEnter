import { describe, expect, it, vi } from "vitest";
import { ToggleController } from "../state/toggleController";

describe("ToggleController", () => {
  it("starts helper when enabling from disabled state", async () => {
    const helper = { start: vi.fn(), stop: vi.fn(), isRunning: () => false };
    const controller = new ToggleController(helper);

    await controller.enable();

    expect(helper.start).toHaveBeenCalledTimes(1);
  });

  it("stops helper when disabling from enabled state", async () => {
    const helper = { start: vi.fn(), stop: vi.fn(), isRunning: () => true };
    const controller = new ToggleController(helper);

    await controller.disable();

    expect(helper.stop).toHaveBeenCalledTimes(1);
  });

  it("reconciles enabled state by starting helper", async () => {
    const helper = { start: vi.fn(), stop: vi.fn(), isRunning: () => false };
    const controller = new ToggleController(helper);

    await controller.setEnabled(true);

    expect(helper.start).toHaveBeenCalledTimes(1);
    expect(helper.stop).not.toHaveBeenCalled();
  });

  it("reconciles disabled state by stopping helper", async () => {
    const helper = { start: vi.fn(), stop: vi.fn(), isRunning: () => true };
    const controller = new ToggleController(helper);

    await controller.setEnabled(false);

    expect(helper.stop).toHaveBeenCalledTimes(1);
    expect(helper.start).not.toHaveBeenCalled();
  });
});
