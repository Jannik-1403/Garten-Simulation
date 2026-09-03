// AppStrings.swift
// Single source of truth for all app translations.

import SwiftUI

enum AppStrings {

    // MARK: - Lookup

    static func getLocalizedTrigger(_ triggerKey: String, language: String) -> String {
        for (key, dict) in all {
            if key.hasPrefix("trigger.") {
                if dict.values.contains(triggerKey) {
                    return dict[language] ?? triggerKey
                }
            }
        }
        return get(triggerKey, language: language)
    }

    static func get(_ key: String, language: String) -> String {
        // 1. Check the static dictionary first
        if let entry = all[key] {
            return entry[language] ?? entry["de"] ?? key
        }
        
        // 2. Fallback to system localization (Localizable.strings)
        // We try to find the bundle for the specific language
        let uniqueFallback = "___KEY_NOT_FOUND___"
        if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            let localized = bundle.localizedString(forKey: key, value: uniqueFallback, table: nil)
            if localized != uniqueFallback {
                return localized
            }
        }
        
        // Final fallback to standard NSLocalizedString
        return NSLocalizedString(key, comment: "")
    }

    // MARK: - All Strings
    static let all: [String: [String: String]] = [:]
}
