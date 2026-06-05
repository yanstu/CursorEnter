import Foundation

public enum EnterIntervalOptions {
    public static let all = [40, 80, 120, 180, 250, 300]
    public static let minimum = 40
    public static let defaultValue = 120

    public static func normalized(_ value: Int) -> Int {
        all.contains(value) ? value : defaultValue
    }
}

public struct ToggleHotKey: Codable, Equatable {
    public let keyCode: UInt32
    public let modifiers: UInt32
    public let keyDisplay: String?

    public init(keyCode: UInt32, modifiers: UInt32, keyDisplay: String? = nil) {
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.keyDisplay = keyDisplay
    }
}
