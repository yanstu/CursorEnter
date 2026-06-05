import Foundation
import cursor_enter_helper

final class AppPreferencesStore {
    private enum Keys {
        static let intervalMs = "intervalMs"
        static let toggleHotKey = "toggleHotKey"
        static let windowTitle = "windowTitle"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var intervalMs: Int {
        get {
            let value = defaults.object(forKey: Keys.intervalMs) as? Int ?? EnterIntervalOptions.defaultValue
            return EnterIntervalOptions.normalized(value)
        }
        set {
            defaults.set(EnterIntervalOptions.normalized(newValue), forKey: Keys.intervalMs)
        }
    }

    var windowTitle: String {
        get {
            WindowTargetOptions.normalizedTitle(defaults.string(forKey: Keys.windowTitle) ?? "")
        }
        set {
            defaults.set(WindowTargetOptions.normalizedTitle(newValue), forKey: Keys.windowTitle)
        }
    }

    var toggleHotKey: ToggleHotKey? {
        get {
            guard let data = defaults.data(forKey: Keys.toggleHotKey) else {
                return nil
            }

            return try? JSONDecoder().decode(ToggleHotKey.self, from: data)
        }
        set {
            guard let newValue else {
                defaults.removeObject(forKey: Keys.toggleHotKey)
                return
            }

            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Keys.toggleHotKey)
            }
        }
    }
}
