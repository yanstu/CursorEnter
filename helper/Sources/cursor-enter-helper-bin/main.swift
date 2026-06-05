import Foundation
import cursor_enter_helper

@main
enum CursorEnterHelperMain {
    static func main() throws {
        let args = try Arguments.parse(Array(CommandLine.arguments.dropFirst()))

        guard AccessibilityPermission.ensureTrusted(prompt: args.promptForAccessibility) else {
            fputs("{\"level\":\"error\",\"reason\":\"accessibility_not_granted\"}\n", stderr)
            exit(2)
        }

        let appScanner = CursorRunningAppScanner()
        let axScanner = AXWindowScanner()
        let engine = TargetedEnterEngine()
        let foregroundEngine = ForegroundWindowEnterEngine()

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
            while true {
                _ = try engine.sendEnter(windowTitle: args.windowTitle, requireAXTarget: false)
                usleep(useconds_t(args.intervalMs * 1_000))
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
            while true {
                _ = try engine.sendEnter(windowTitle: args.windowTitle, requireAXTarget: true)
                usleep(useconds_t(args.intervalMs * 1_000))
            }
        case .activeOnce:
            _ = try foregroundEngine.sendEnter(windowTitle: args.windowTitle)
        case .activeLoop:
            while true {
                _ = try foregroundEngine.sendEnter(windowTitle: args.windowTitle)
                usleep(useconds_t(args.intervalMs * 1_000))
            }
        }
    }
}
