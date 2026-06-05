import Foundation

public enum RunMode: String, Equatable {
    case dryRun = "dry-run"
    case once
    case loop
    case axDryRun = "ax-dry-run"
    case axOnce = "ax-once"
    case axLoop = "ax-loop"
    case activeOnce = "active-once"
    case activeLoop = "active-loop"
}

public struct Arguments: Equatable {
    public let mode: RunMode
    public let windowTitle: String
    public let intervalMs: Int
    public let promptForAccessibility: Bool

    public static func parse(_ raw: [String]) throws -> Arguments {
        var mode: RunMode = .dryRun
        var windowTitle = WindowTargetOptions.defaultTitle
        var intervalMs = EnterIntervalOptions.defaultValue
        var promptForAccessibility = false

        var index = 0
        while index < raw.count {
            switch raw[index] {
            case "--mode":
                index += 1
                guard index < raw.count, let parsed = RunMode(rawValue: raw[index]) else {
                    throw HelperError("invalid mode")
                }
                mode = parsed
            case "--window-title":
                index += 1
                guard index < raw.count else {
                    throw HelperError("missing window title")
                }
                windowTitle = raw[index]
            case "--interval-ms":
                index += 1
                guard index < raw.count, let parsed = Int(raw[index]) else {
                    throw HelperError("invalid interval")
                }
                intervalMs = parsed
            case "--prompt-for-accessibility":
                promptForAccessibility = true
            default:
                throw HelperError("unknown argument: \(raw[index])")
            }
            index += 1
        }

        guard intervalMs >= EnterIntervalOptions.minimum else {
            throw HelperError("interval must be >= \(EnterIntervalOptions.minimum)ms")
        }

        return Arguments(
            mode: mode,
            windowTitle: windowTitle,
            intervalMs: intervalMs,
            promptForAccessibility: promptForAccessibility
        )
    }
}
