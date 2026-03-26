import SwiftData
import SwiftUI
import Observation
import UIKit

enum Seltenheit: String, Codable {
    case bronze
    case silber
    case gold
    case diamant

    var bezeichnung: String {
        switch self {
        case .bronze: return "Bronze"
        case .silber: return "Silber"
        case .gold: return "Gold"
        case .diamant: return "Diamant"
        }
    }

    var ringFarbe: Color {
        switch self {
        case .bronze: return .bronzePrimary
        case .silber: return .silberPrimary
        case .gold: return .goldPrimary
        case .diamant: return .diamantPrimary
        }
    }

    var ringFarbeSekundaer: Color {
        switch self {
        case .bronze: return .bronzeSecondary
        case .silber: return .silberSecondary
        case .gold: return .goldSecondary
        case .diamant: return .diamantSecondary
        }
    }

    var tagHintergrund: Color {
        switch self {
        case .bronze:  return Color(red: 0.60, green: 0.20, blue: 0.00)
        case .silber:  return Color(red: 0.45, green: 0.50, blue: 0.55)
        case .gold:    return Color(red: 0.70, green: 0.50, blue: 0.00)
        case .diamant: return Color(red: 0.00, green: 0.35, blue: 0.70)
        }
    }

    var tagTextFarbe: Color {
        switch self {
        case .bronze:  return .white
        case .silber:  return .white
        case .gold:    return .white
        case .diamant: return .white
        }
    }

    var iconName: String {
        switch self {
        case .bronze: return "bonsai_stufe1"
        case .silber: return "bonsai_stufe2"
        case .gold: return "bonsai_stufe3"
        case .diamant: return "bonsai_stufe4"
        }
    }
}

@Model
class Pflanze {
    var name: String
    var bildName: String
    var streak: Int
    var gesundheit: Double
    var fortschritt: Double
    var gewaessert: Bool
    var istGesperrt: Bool
    var seltenheit: Seltenheit

    var iconName: String {
        seltenheit.iconName
    }

    init(name: String, bildName: String, seltenheit: Seltenheit = .bronze) {
        self.name = name
        self.bildName = bildName
        self.streak = 0
        self.gesundheit = 1.0
        self.fortschritt = 0.0
        self.gewaessert = false
        self.istGesperrt = false
        self.seltenheit = seltenheit
    }
}

enum ThirstState {
    case healthy
    case thirsty
    case dead
}

@Observable
final class ThirstSystem {
    private(set) var lastWatered: Date
    var baseReward: Double
    var hourlyPenaltyAfter24h: Double

    init(
        lastWatered: Date = Date(),
        baseReward: Double = 1.0,
        hourlyPenaltyAfter24h: Double = 0.04
    ) {
        self.lastWatered = lastWatered
        self.baseReward = baseReward
        self.hourlyPenaltyAfter24h = hourlyPenaltyAfter24h
    }

    func water(at date: Date = Date()) {
        lastWatered = date
    }

    func elapsedTime(at date: Date = Date()) -> TimeInterval {
        max(0, date.timeIntervalSince(lastWatered))
    }

    func state(at date: Date = Date()) -> ThirstState {
        let elapsed = elapsedTime(at: date)
        if elapsed >= 48 * 3600 { return .dead }
        if elapsed >= 24 * 3600 { return .thirsty }
        return .healthy
    }

    func remainingFraction48h(at date: Date = Date()) -> Double {
        let fullWindow = 48.0 * 3600.0
        let remaining = max(0, fullWindow - elapsedTime(at: date))
        return remaining / fullWindow
    }

    func interpolatedColor(at date: Date = Date()) -> Color {
        let elapsed = elapsedTime(at: date)
        let green = Color(hex: 0x4ADE80)
        let yellow = Color(hex: 0xFACC15)
        let red = Color(hex: 0xEF4444)

        if elapsed <= 24 * 3600 {
            let t = elapsed / (24 * 3600)
            return green.blended(with: yellow, ratio: t)
        }
        let t = min(1, (elapsed - 24 * 3600) / (24 * 3600))
        return yellow.blended(with: red, ratio: t)
    }

    func potentialReward(at date: Date = Date()) -> Double {
        let elapsedHours = elapsedTime(at: date) / 3600
        if elapsedHours <= 24 { return baseReward }
        if elapsedHours >= 48 { return 0.5 }

        let overdueHours = elapsedHours - 24
        let reward = baseReward - overdueHours * hourlyPenaltyAfter24h
        return max(0.5, reward)
    }

    func remainingTextHHMM(at date: Date = Date()) -> String {
        let total = Int(max(0, (48 * 3600) - elapsedTime(at: date)))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }

    /// Verbleibende Zeit im 48h-Fenster, als aufgerundete Stunden (0 … 48).
    func remainingWholeHours(at date: Date = Date()) -> Int {
        let remaining = max(0, 48 * 3600 - elapsedTime(at: date))
        if remaining <= 0 { return 0 }
        return min(48, Int(ceil(remaining / 3600.0)))
    }

    /// Verbleibende Zeit bis zum Ende des 48h-Fensters, in ganzen Sekunden (0 … 172800).
    func remainingSeconds(at date: Date = Date()) -> Int {
        Int(max(0, 48 * 3600 - elapsedTime(at: date)))
    }

    /// Kompakte Anzeige für die Sanduhr, z. B. `1h 0m`, `1h 30m`.
    func remainingTextHoursMinutes(at date: Date = Date()) -> String {
        let total = Int(max(0, 48 * 3600 - elapsedTime(at: date)))
        let h = total / 3600
        let m = (total % 3600) / 60
        return "\(h)h \(m)m"
    }

    func thirstyPulseDuration(at date: Date = Date()) -> Double {
        let elapsed = elapsedTime(at: date)
        let start = 24.0 * 3600.0
        let end = 48.0 * 3600.0
        guard elapsed > start else { return 1.4 }
        if elapsed >= end { return 0.45 }

        let t = (elapsed - start) / (end - start)
        return 1.4 - (0.95 * t)
    }
}

private extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }

    func blended(with color: Color, ratio: Double) -> Color {
        let lhs = UIColor(self)
        let rhs = UIColor(color)

        var lr: CGFloat = 0, lg: CGFloat = 0, lb: CGFloat = 0, la: CGFloat = 0
        var rr: CGFloat = 0, rg: CGFloat = 0, rb: CGFloat = 0, ra: CGFloat = 0
        lhs.getRed(&lr, green: &lg, blue: &lb, alpha: &la)
        rhs.getRed(&rr, green: &rg, blue: &rb, alpha: &ra)

        let t = max(0, min(1, ratio))
        return Color(
            red: Double(lr + (rr - lr) * t),
            green: Double(lg + (rg - lg) * t),
            blue: Double(lb + (rb - lb) * t),
            opacity: Double(la + (ra - la) * t)
        )
    }
}
