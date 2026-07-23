import re

file_path = 'Garten_Simulation/Stores/SettingsStore.swift'
with open(file_path, 'r') as f:
    content = f.read()

# Add Enum before the class
enum_code = """
enum AutoBackupInterval: String, Codable, CaseIterable, Identifiable {
    case never = "nie"
    case onSave = "beiSpeicherung"
    case daily = "täglich"
    case weekly = "wöchentlich"
    case monthly = "monatlich"
    
    var id: String { rawValue }
    
    var localizedName: String {
        switch self {
        case .never: return String(localized: "backup.interval.never", defaultValue: "Nie")
        case .onSave: return String(localized: "backup.interval.onSave", defaultValue: "Bei jeder Speicherung")
        case .daily: return String(localized: "backup.interval.daily", defaultValue: "Täglich")
        case .weekly: return String(localized: "backup.interval.weekly", defaultValue: "Wöchentlich")
        case .monthly: return String(localized: "backup.interval.monthly", defaultValue: "Monatlich")
        }
    }
}

"""

if "enum AutoBackupInterval" not in content:
    content = content.replace("class SettingsStore: ObservableObject {", enum_code + "class SettingsStore: ObservableObject {")

# Add property
prop = """
    @Published var autoBackupInterval: AutoBackupInterval {
        didSet {
            SharedUserDefaults.suite.set(autoBackupInterval.rawValue, forKey: "autoBackupInterval")
        }
    }
"""
if "var autoBackupInterval" not in content:
    content = content.replace("    @Published var appLanguage: String", prop + "    @Published var appLanguage: String")

# Add to init
init_line = """
        if let intervalString = SharedUserDefaults.suite.string(forKey: "autoBackupInterval"),
           let interval = AutoBackupInterval(rawValue: intervalString) {
            self.autoBackupInterval = interval
        } else {
            self.autoBackupInterval = .never
        }
"""
if "self.autoBackupInterval = " not in content:
    content = content.replace("        self.appLanguage = ", init_line + "\n        self.appLanguage = ")

with open(file_path, 'w') as f:
    f.write(content)
