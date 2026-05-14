import Foundation

enum RetentionGrund: String, CaseIterable, Identifiable {
    case vergessen = "vergessen"
    case keineZeit = "keineZeit"
    case keineLust = "keineLust"
    case nichtMehrNoetig = "nichtMehrNoetig"
    case nichtMotiviert = "nichtMotiviert"

    var id: String { rawValue }

    var lokaliserterText: String {
        NSLocalizedString("retention.grund.\(rawValue)", comment: "")
    }
}
