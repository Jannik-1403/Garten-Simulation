import SwiftUI

enum BodyTrackingType {
    case weight
    case measurements
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
