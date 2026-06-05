import * as path from "node:path";
import * as vscode from "vscode";
import { HelperProcess } from "./helper/helperProcess";
import { ToggleController } from "./state/toggleController";
import { getStatusBarText } from "./ui/statusBar";

function refreshStatusBar(item: vscode.StatusBarItem, enabled: boolean): void {
  item.text = getStatusBarText(enabled);
  item.command = "cursorEnter.toggle";
  item.show();
}

function showHelperError(line: string): void {
  if (line.includes("accessibility_not_granted")) {
    void vscode.window.showErrorMessage(
      "Cursor Enter 需要辅助功能权限，请在系统设置 > 隐私与安全性 > 辅助功能中授权。"
    );
  }
}

export async function activate(context: vscode.ExtensionContext): Promise<void> {
  if (process.platform !== "darwin") {
    return;
  }

  const statusItem = vscode.window.createStatusBarItem(
    vscode.StatusBarAlignment.Right,
    100
  );
  const getConfig = (): vscode.WorkspaceConfiguration =>
    vscode.workspace.getConfiguration();
  const helper = new HelperProcess({
    helperPath: path.join(context.extensionPath, "bin", "cursor-enter-helper"),
    intervalMs: getConfig().get<number>("cursorEnter.intervalMs", 300),
    windowTitle: getConfig().get<string>("cursorEnter.windowTitle", "Cursor Agents"),
    onStderrLine: showHelperError,
    onExit: () => {
      refreshStatusBar(statusItem, false);
    }
  });
  const controller = new ToggleController(helper);
  const syncEnabled = async (enabled: boolean): Promise<void> => {
    await controller.setEnabled(enabled);
    refreshStatusBar(statusItem, enabled);
  };

  await syncEnabled(getConfig().get<boolean>("cursorEnter.enabled", false));

  const disposable = vscode.commands.registerCommand(
    "cursorEnter.toggle",
    async () => {
      try {
        const currentConfig = getConfig();
        const nextEnabled = !currentConfig.get<boolean>("cursorEnter.enabled", false);
        await currentConfig.update(
          "cursorEnter.enabled",
          nextEnabled,
          vscode.ConfigurationTarget.Workspace
        );
      } catch (error) {
        await vscode.window.showErrorMessage(String(error));
      }
    }
  );

  const enableCommand = vscode.commands.registerCommand(
    "cursorEnter.enable",
    async () => {
      try {
        await getConfig().update(
          "cursorEnter.enabled",
          true,
          vscode.ConfigurationTarget.Workspace
        );
      } catch (error) {
        await vscode.window.showErrorMessage(String(error));
      }
    }
  );

  const disableCommand = vscode.commands.registerCommand(
    "cursorEnter.disable",
    async () => {
      await getConfig().update(
        "cursorEnter.enabled",
        false,
        vscode.ConfigurationTarget.Workspace
      );
    }
  );

  const configurationListener = vscode.workspace.onDidChangeConfiguration(async (event) => {
    if (!event.affectsConfiguration("cursorEnter.enabled")) {
      return;
    }

    await syncEnabled(getConfig().get<boolean>("cursorEnter.enabled", false));
  });

  context.subscriptions.push(disposable, enableCommand, disableCommand, statusItem);
  context.subscriptions.push(configurationListener);
}

export function deactivate(): void {}
