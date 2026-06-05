import AppKit
import cursor_enter_helper

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let preferences = AppPreferencesStore()
    private let menu = NSMenu()
    private let statusRow = NSMenuItem(title: "Stopped", action: nil, keyEquivalent: "")
    private let frequencyRow = NSMenuItem(title: "Frequency", action: nil, keyEquivalent: "")
    private let toggleRow = NSMenuItem(title: "Start Cursor Agents Enter", action: nil, keyEquivalent: "")
    private let settingsRow = NSMenuItem(title: "Settings...", action: nil, keyEquivalent: ",")
    private let quitRow = NSMenuItem(title: "Quit", action: nil, keyEquivalent: "q")
    private var statusItem: NSStatusItem?
    private let frequencyMenu = NSMenu()
    private var frequencyItems: [Int: NSMenuItem] = [:]
    private lazy var loopController = EnterLoopController(
        windowTitle: preferences.windowTitle,
        intervalMs: preferences.intervalMs
    )
    private let hotKeyManager = GlobalHotKeyManager()
    private lazy var settingsWindowController = SettingsWindowController(
        preferences: preferences,
        hotKeyManager: hotKeyManager
    )

    func applicationDidFinishLaunching(_ notification: Notification) {
        loopController.onStateChange = { [weak self] in
            self?.refreshMenu()
        }
        hotKeyManager.onToggle = { [weak self] in
            Task { @MainActor [weak self] in
                self?.toggleLoop()
            }
        }
        hotKeyManager.register(preferences.toggleHotKey)
        settingsWindowController.onHotKeyChange = { [weak self] in
            self?.refreshMenu()
        }
        settingsWindowController.onWindowTitleChange = { [weak self] in
            guard let self else {
                return
            }

            self.loopController.setWindowTitle(self.preferences.windowTitle)
            self.refreshMenu()
        }

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.imagePosition = .imageOnly
        statusItem?.button?.target = self
        statusItem?.button?.action = #selector(handleStatusButtonClick)
        statusItem?.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])

        statusRow.isEnabled = false

        frequencyRow.submenu = frequencyMenu
        frequencyRow.image = Self.menuSymbol("timer")
        buildFrequencyMenu()

        toggleRow.target = self
        toggleRow.action = #selector(toggleLoop)

        settingsRow.target = self
        settingsRow.action = #selector(openSettings)
        settingsRow.image = Self.menuSymbol("gearshape")

        quitRow.target = self
        quitRow.action = #selector(quitApp)
        quitRow.image = Self.menuSymbol("power")

        menu.addItem(statusRow)
        menu.addItem(frequencyRow)
        menu.addItem(.separator())
        menu.addItem(toggleRow)
        menu.addItem(settingsRow)
        menu.addItem(quitRow)

        refreshMenu()
    }

    func applicationWillTerminate(_ notification: Notification) {
        loopController.stop()
    }

    @objc
    private func handleStatusButtonClick() {
        guard let event = NSApp.currentEvent,
              event.type == .rightMouseUp,
              let button = statusItem?.button else {
            toggleLoop()
            return
        }

        menu.popUp(
            positioning: nil,
            at: NSPoint(x: 0, y: button.bounds.height + 4),
            in: button
        )
    }

    @objc
    private func toggleLoop() {
        if loopController.isRunning {
            loopController.stop()
        } else {
            loopController.start()
        }
    }

    @objc
    private func quitApp() {
        loopController.stop()
        NSApp.terminate(nil)
    }

    @objc
    private func selectFrequency(_ sender: NSMenuItem) {
        guard sender.tag > 0 else {
            return
        }

        loopController.setIntervalMs(sender.tag)
        preferences.intervalMs = sender.tag
    }

    private func buildFrequencyMenu() {
        for interval in EnterIntervalOptions.all {
            let item = NSMenuItem(
                title: "\(interval) ms",
                action: #selector(selectFrequency),
                keyEquivalent: ""
            )
            item.target = self
            item.tag = interval
            frequencyMenu.addItem(item)
            frequencyItems[interval] = item
        }
    }

    @objc
    private func openSettings() {
        settingsWindowController.showSettings()
    }

    private func refreshMenu() {
        let running = loopController.isRunning

        if let button = statusItem?.button {
            let statusImage = Self.statusImage(running: running)
            button.image = statusImage
            button.title = statusImage == nil ? (running ? "CE On" : "CE Off") : ""
            button.contentTintColor = running ? .controlAccentColor : nil
            button.toolTip = running ? "CursorEnter: On" : "CursorEnter: Off"
        }

        statusRow.title = loopController.statusMessage
        statusRow.image = Self.menuSymbol(running ? "checkmark.circle.fill" : "circle")
        frequencyRow.title = "Frequency (\(loopController.intervalMs)ms)"
        toggleRow.title = running
            ? "Stop Cursor Agents Enter"
            : "Start Cursor Agents Enter"
        toggleRow.image = Self.menuSymbol(running ? "stop.fill" : "play.fill")

        for (interval, item) in frequencyItems {
            item.state = interval == loopController.intervalMs ? .on : .off
        }
    }

    private static func menuSymbol(_ name: String) -> NSImage? {
        let image = NSImage(systemSymbolName: name, accessibilityDescription: nil)
        image?.isTemplate = true
        return image
    }

    private static func statusImage(running: Bool) -> NSImage? {
        let candidates = running
            ? ["return.circle.fill", "return", "arrow.turn.down.left"]
            : ["return.circle", "return", "arrow.turn.down.left"]

        for name in candidates {
            if let image = NSImage(
                systemSymbolName: name,
                accessibilityDescription: running ? "CursorEnter On" : "CursorEnter Off"
            ) {
                image.isTemplate = true
                return image
            }
        }

        return nil
    }
}
