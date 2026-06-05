import { describe, expect, it } from "vitest";
import { getStatusBarText } from "../ui/statusBar";

describe("getStatusBarText", () => {
  it("shows enabled state clearly", () => {
    expect(getStatusBarText(true)).toBe("$(debug-pause) Cursor Enter: ON");
  });

  it("shows disabled state clearly", () => {
    expect(getStatusBarText(false)).toBe("$(circle-slash) Cursor Enter: OFF");
  });
});
