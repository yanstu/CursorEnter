export function getStatusBarText(enabled: boolean): string {
  return enabled
    ? "$(debug-pause) Cursor Enter: ON"
    : "$(circle-slash) Cursor Enter: OFF";
}
