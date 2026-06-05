import Foundation
import cursor_enter_helper

nonisolated(unsafe) private var stopRequested: sig_atomic_t = 0

@main
enum CursorEnterHelperMain {
    static func main() throws {
        let args = try Arguments.parse(Array(CommandLine.arguments.dropFirst()))

        guard AccessibilityPermission.ensureTrusted(prompt: args.promptForAccessibility) else {
            fputs("{\"level\":\"error\",\"reason\":\"accessibility_not_granted\"}\n", stderr)
            exit(2)
        }

        signal(SIGINT) { _ in stopRequested = 1 }
        signal(SIGTERM) { _ in stopRequested = 1 }

        let appScanner = CursorRunningAppScanner()
        let axScanner = AXWindowScanner()
        let engine = TargetedEnterEngine()
        let foregroundEngine = ForegroundWindowEnterEngine()

        func runLoop(_ body: () throws -> Void) rethrows {
            let interval = Double(args.intervalMs) / 1_000.0

            while stopRequested == 0 {
                let start = Date()
                try body()

                if stopRequested != 0 {
                    break
                }

                let remaining = interval - Date().timeIntervalSince(start)
                if remaining > 0 {
                    usleep(useconds_t(remaining * 1_000_000))
                }
            }
        }

        switch args.mode {
        case .dryRun:
            guard let match = appScanner.findCursorAgentsApp(
                windowTitle: args.windowTitle,
                axScanner: axScanner
            ) else {
                print("NOT_FOUND")
                return
            }

            print("\(match.localizedName)\t\(args.windowTitle)\t\(match.pid)")
        case .once:
            _ = try engine.sendEnter(windowTitle: args.windowTitle, requireAXTarget: false)
        case .loop:
            try runLoop {
                _ = try engine.sendEnter(windowTitle: args.windowTitle, requireAXTarget: false)
            }
        case .axDryRun:
            guard let match = appScanner.findCursorAgentsApp(
                windowTitle: args.windowTitle,
                axScanner: axScanner
            ) else {
                print("NOT_FOUND")
                return
            }

            let rows = axScanner.debugRows(for: match.pid)
            for row in rows {
                print("\(row.title)\t\(row.role)\t\(row.subrole)")
            }
        case .axOnce:
            _ = try engine.sendEnter(windowTitle: args.windowTitle, requireAXTarget: true)
        case .axLoop:
            try runLoop {
                _ = try engine.sendEnter(windowTitle: args.windowTitle, requireAXTarget: true)
            }
        case .activeOnce:
            _ = try foregroundEngine.sendEnter(windowTitle: args.windowTitle)
        case .activeLoop:
            try runLoop {
                _ = try foregroundEngine.sendEnter(windowTitle: args.windowTitle)
            }
        }
    }
}
