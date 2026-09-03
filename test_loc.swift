import SwiftUI

func test(_ key: String) -> String {
    return String(localized: String.LocalizationValue(key))
}
