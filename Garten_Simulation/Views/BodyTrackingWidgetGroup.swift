import SwiftUI

enum BodyTrackingType {
    case weight
    case measurements
}

enum BodyDataTimeRange: String, CaseIterable, Identifiable {
    case t    = "T"
    case w    = "W"
    case m    = "M"
    case sixM = "6 M."
    case j    = "J"
    var id: String { rawValue }
}

enum BodyMeasurementCategory: String, CaseIterable, Identifiable {
    case bizeps      = "body.measure.bizeps"
    case unterarm    = "body.measure.unterarm"
    case schultern   = "body.measure.schultern"
    case oberschenkel = "body.measure.oberschenkel"
    case waden       = "body.measure.waden"
    case taille      = "body.measure.taille"

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .bizeps:       return String(localized: "body.measure.bizeps",       defaultValue: "Bizeps (Oberarm)")
        case .unterarm:     return String(localized: "body.measure.unterarm",     defaultValue: "Unterarm")
        case .schultern:    return String(localized: "body.measure.schultern",    defaultValue: "Schultern")
        case .oberschenkel: return String(localized: "body.measure.oberschenkel", defaultValue: "Oberschenkel")
        case .waden:        return String(localized: "body.measure.waden",        defaultValue: "Waden")
        case .taille:       return String(localized: "body.measure.taille",       defaultValue: "Taille (Bauch)")
        }
    }
}

struct BodyTrackingWidgetGroup: View {
    @ObservedObject var pflanze: HabitModel
    @EnvironmentObject var gardenStore: GardenStore
    
    var body: some View {
        VStack(spacing: 24) {
            if pflanze.showWeight {
                BodyTrackingModuleCard(
                    title: String(localized: "body.tracking.weight", defaultValue: "Gewicht"),
                    type: .weight,
                    pflanze: pflanze
                )
            }
            if pflanze.showMeasurements {
                BodyTrackingModuleCard(
                    title: String(localized: "body.tracking.measurements", defaultValue: "Körperumfänge"),
                    type: .measurements,
                    pflanze: pflanze
                )
            }
        }
    }
}

struct BodyTrackingModuleCard: View {
    let title: String
    let type: BodyTrackingType
    @ObservedObject var pflanze: HabitModel
    
    var body: some View {
        NavigationLink(destination: BodyDataFactoryView(pflanze: pflanze, type: type)) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(String(localized: "body.tracking.tap_to_view", defaultValue: "Tippen für Statistik & Eingabe"))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 24)
        }
        .buttonStyle(.plain)
    }
}
