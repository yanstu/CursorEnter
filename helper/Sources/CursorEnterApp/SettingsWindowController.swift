import AppKit
import Foundation
import cursor_enter_helper

@MainActor
final class SettingsWindowController: NSWindowController, NSWindowDelegate, NSTextFieldDelegate {
    var onHotKeyChange: (() -> Void)?
    var onWindowTitleChange: (() -> Void)?

    private let preferences: AppPreferencesStore
    private let hotKeyManager: GlobalHotKeyManager
    private let windowTitleField = NSTextField(string: "")
    private let shortcutButton = NSButton(title: "", target: nil, action: nil)
    private let hintLabel = NSTextField(labelWithString: "Click the box below, then press a shortcut with Command / Control / Option / Shift.")
    private let clearButton = NSButton(title: "Clear", target: nil, action: nil)
    private var eventMonitor: Any?

    init(
        preferences: AppPreferencesStore,
        hotKeyManager: GlobalHotKeyManager
    ) {
        self.preferences = preferences
        self.hotKeyManager = hotKeyManager

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 320),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Settings"
        window.center()
        super.init(window: window)
        window.delegate = self
        shouldCascadeWindows = false
        buildUI()
        refresh()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showSettings() {
        NSApp.activate(ignoringOtherApps: true)
        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        if eventMonitor != nil {
            stopRecording(message: "Recording cancelled")
        }
    }

    private func buildUI() {
        guard let contentView = window?.contentView else {
            return
        }

        let windowTitleLabel = NSTextField(labelWithString: "Target Window Title")
        windowTitleLabel.font = .boldSystemFont(ofSize: 13)

        windowTitleField.placeholderString = WindowTargetOptions.defaultTitle
        windowTitleField.delegate = self
        windowTitleField.translatesAutoresizingMaskIntoConstraints = false

        let windowTitleHint = NSTextField(labelWithString: "Only the Cursor window whose title matches exactly receives Enter.")
        windowTitleHint.textColor = .secondaryLabelColor
        windowTitleHint.font = .systemFont(ofSize: 11)
        windowTitleHint.maximumNumberOfLines = 2

        let titleLabel = NSTextField(labelWithString: "Toggle Shortcut")
        titleLabel.font = .boldSystemFont(ofSize: 13)

        shortcutButton.target = self
        shortcutButton.action = #selector(toggleRecording)
        shortcutButton.isBordered = false
        shortcutButton.bezelStyle = .regularSquare
        shortcutButton.setButtonType(.momentaryChange)
        shortcutButton.wantsLayer = true
        shortcutButton.layer?.cornerRadius = 12
        shortcutButton.layer?.borderWidth = 1
        shortcutButton.layer?.borderColor = NSColor.separatorColor.cgColor
        shortcutButton.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        shortcutButton.translatesAutoresizingMaskIntoConstraints = false

        hintLabel.textColor = .secondaryLabelColor
        hintLabel.maximumNumberOfLines = 2

        clearButton.target = self
        clearButton.action = #selector(clearShortcut)

        let buttonStack = NSStackView(views: [clearButton])
        buttonStack.orientation = .horizontal
        buttonStack.spacing = 12
        buttonStack.alignment = .leading

        let stack = NSStackView(views: [
            windowTitleLabel,
            windowTitleField,
            windowTitleHint,
            titleLabel,
            shortcutButton,
            hintLabel,
            buttonStack
        ])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            windowTitleField.widthAnchor.constraint(equalTo: stack.widthAnchor),
            shortcutButton.widthAnchor.constraint(equalTo: stack.widthAnchor),
            shortcutButton.heightAnchor.constraint(equalToConstant: 84)
        ])
    }

    @objc
    private func toggleRecording() {
        if eventMonitor == nil {
            startRecording()
        } else {
            stopRecording(message: "Recording cancelled")
        }
    }

    @objc
    private func clearShortcut() {
        preferences.toggleHotKey = nil
        hotKeyManager.unregister()
        stopRecording(message: "Shortcut cleared")
        refresh()
        onHotKeyChange?()
    }

    private func startRecording() {
        hintLabel.stringValue = "Press your shortcut now. Esc cancels. At least one modifier is required."

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.capture(event: event)
            return nil
        }

        refreshShortcutButton()
    }

    private func stopRecording(message: String) {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }

        hintLabel.stringValue = message
        refreshShortcutButton()
    }

    private func capture(event: NSEvent) {
        if event.keyCode == 53 {
            stopRecording(message: "Recording cancelled")
            return
        }

        let modifierFlags = event.modifierFlags.intersection([.control, .option, .shift, .command])
        let carbonModifiers = GlobalHotKeyManager.carbonModifiers(from: modifierFlags)

        guard carbonModifiers != 0 else {
            NSSound.beep()
            hintLabel.stringValue = "Shortcut must include at least one modifier."
            return
        }

        let keyDisplay = event.charactersIgnoringModifiers?.uppercased()
        let hotKey = ToggleHotKey(
            keyCode: UInt32(event.keyCode),
            modifiers: carbonModifiers,
            keyDisplay: keyDisplay
        )

        let previousHotKey = preferences.toggleHotKey
        guard hotKeyManager.register(hotKey) else {
            _ = hotKeyManager.register(previousHotKey)
            NSSound.beep()
            hintLabel.stringValue = "Shortcut unavailable. Try another one."
            return
        }

        preferences.toggleHotKey = hotKey
        stopRecording(message: "Saved \(ToggleHotKeyFormatter.string(for: hotKey))")
        refresh()
        onHotKeyChange?()
    }

    func controlTextDidEndEditing(_ notification: Notification) {
        guard (notification.object as? NSTextField) === windowTitleField else {
            return
        }

        let normalized = WindowTargetOptions.normalizedTitle(windowTitleField.stringValue)
        windowTitleField.stringValue = normalized

        guard preferences.windowTitle != normalized else {
            return
        }

        preferences.windowTitle = normalized
        onWindowTitleChange?()
    }

    private func refresh() {
        windowTitleField.stringValue = preferences.windowTitle
        clearButton.isEnabled = preferences.toggleHotKey != nil
        refreshShortcutButton()
    }

    private func refreshShortcutButton() {
        let primaryText: String
        let secondaryText: String

        if eventMonitor != nil {
            primaryText = "Type shortcut"
            secondaryText = "Recording... click again to cancel"
            shortcutButton.layer?.borderColor = NSColor.controlAccentColor.cgColor
            shortcutButton.layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.10).cgColor
        } else if let hotKey = preferences.toggleHotKey {
            primaryText = ToggleHotKeyFormatter.string(for: hotKey)
            secondaryText = "Click to record a new shortcut"
            shortcutButton.layer?.borderColor = NSColor.separatorColor.cgColor
            shortcutButton.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        } else {
            primaryText = "Record shortcut"
            secondaryText = "Click to set a global toggle shortcut"
            shortcutButton.layer?.borderColor = NSColor.separatorColor.cgColor
            shortcutButton.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        }

        shortcutButton.attributedTitle = makeShortcutButtonTitle(
            primaryText: primaryText,
            secondaryText: secondaryText
        )
    }

    private func makeShortcutButtonTitle(
        primaryText: String,
        secondaryText: String
    ) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let result = NSMutableAttributedString(
            string: primaryText,
            attributes: [
                .font: NSFont.systemFont(ofSize: 24, weight: .semibold),
                .foregroundColor: NSColor.labelColor,
                .paragraphStyle: paragraphStyle
            ]
        )

        result.append(
            NSAttributedString(
                string: "\n\(secondaryText)",
                attributes: [
                    .font: NSFont.systemFont(ofSize: 12, weight: .regular),
                    .foregroundColor: NSColor.secondaryLabelColor,
                    .paragraphStyle: paragraphStyle
                ]
            )
        )

        return result
    }
}
