import Foundation
import cursor_enter_helper

@MainActor
final class EnterLoopController {
    private let engine = TargetedEnterEngine()
    private var windowTitle: String
    private var timer: Timer?

    var onStateChange: (() -> Void)?
    private(set) var isRunning = false
    private(set) var statusMessage = "Stopped"
    private(set) var intervalMs: Int

    init(
        windowTitle: String = WindowTargetOptions.defaultTitle,
        intervalMs: Int = EnterIntervalOptions.defaultValue
    ) {
        self.windowTitle = WindowTargetOptions.normalizedTitle(windowTitle)
        self.intervalMs = max(EnterIntervalOptions.minimum, intervalMs)
    }

    func setWindowTitle(_ value: String) {
        windowTitle = WindowTargetOptions.normalizedTitle(value)
        publish()
    }

    func start() {
        guard !isRunning else {
            return
        }

        guard AccessibilityPermission.ensureTrusted(prompt: true) else {
            statusMessage = "Accessibility permission required"
            publish()
            return
        }

        scheduleTimer()
        isRunning = true
        statusMessage = "Running (\(intervalMs)ms)"
        publish()
        tick()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        statusMessage = "Stopped"
        publish()
    }

    func setIntervalMs(_ value: Int) {
        intervalMs = max(EnterIntervalOptions.minimum, value)

        if isRunning {
            scheduleTimer()
            statusMessage = "Running (\(intervalMs)ms)"
        }

        publish()
    }

    private func tick() {
        do {
            let delivered = try engine.sendEnter(
                windowTitle: windowTitle,
                requireAXTarget: true
            )

            statusMessage = delivered
                ? "Running (\(intervalMs)ms)"
                : "Waiting for \(windowTitle) (\(intervalMs)ms)"
            publish()
        } catch {
            timer?.invalidate()
            timer = nil
            isRunning = false
            statusMessage = "Error: \(error.localizedDescription)"
            publish()
        }
    }

    private func publish() {
        onStateChange?()
    }

    private func scheduleTimer() {
        timer?.invalidate()

        let timer = Timer.scheduledTimer(
            withTimeInterval: Double(intervalMs) / 1_000.0,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }

        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
}
