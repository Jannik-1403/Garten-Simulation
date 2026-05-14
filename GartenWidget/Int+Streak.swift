import Foundation

extension Int {
    var streakLabel: String {
        if self == 1 {
            return String(localized: "streak.singular", defaultValue: "1 Tag")
        } else {
            let formatString = String(localized: "streak.plural", defaultValue: "%lld Tage")
            return String(format: formatString, self)
        }
    }
}

extension String {
    init(key: String, tableName: String? = nil, bundle: Bundle = .main, value: String = "", comment: String = "") {
        self = bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}
