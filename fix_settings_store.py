import re

filepath = "Garten_Simulation/Stores/SettingsStore.swift"
with open(filepath, "r") as f:
    content = f.read()

old_func = """    var localizedName: String {
        switch self {
        case .never: return String(localized: "backup.interval.never", defaultValue: "Nie")
        case .onSave: return String(localized: "backup.interval.onSave", defaultValue: "Bei jeder Speicherung")
        case .daily: return String(localized: "backup.interval.daily", defaultValue: "Täglich")
        case .weekly: return String(localized: "backup.interval.weekly", defaultValue: "Wöchentlich")
        case .monthly: return String(localized: "backup.interval.monthly", defaultValue: "Monatlich")
        }
    }"""

new_func = """    var localizedName: String {
        return localizedName(for: Locale.current.identifier)
    }
    
    func localizedName(for localeIdentifier: String) -> String {
        let loc = Locale(identifier: localeIdentifier)
        switch self {
        case .never: return String(localized: "backup.interval.never", defaultValue: "Nie", locale: loc)
        case .onSave: return String(localized: "backup.interval.onSave", defaultValue: "Bei jeder Speicherung", locale: loc)
        case .daily: return String(localized: "backup.interval.daily", defaultValue: "Täglich", locale: loc)
        case .weekly: return String(localized: "backup.interval.weekly", defaultValue: "Wöchentlich", locale: loc)
        case .monthly: return String(localized: "backup.interval.monthly", defaultValue: "Monatlich", locale: loc)
        }
    }"""

content = content.replace(old_func, new_func)

with open(filepath, "w") as f:
    f.write(content)
print("Updated SettingsStore.swift")
