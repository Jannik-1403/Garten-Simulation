import SwiftUI

struct WasserDetailView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header mit LiquidGlassDismissButton oben rechts
                HStack {
                    Spacer()
                    LiquidGlassDismissButton {
                        dismiss()
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Header-Bereich
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.blauPrimary.opacity(0.15))
                                    .frame(width: 100, height: 100)
                                
                                Image("Drop water")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                            }
                            
                            VStack(spacing: 8) {
                                Text(String(key: "wasser.titel", value: "Gießwasser", comment: ""))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)
                                
                                Text(gardenStore.gesamtLiterFormatiert)
                                    .font(.system(size: 52, weight: .heavy))
                                    .foregroundStyle(Color.blauPrimary)
                                    .contentTransition(.numericText())
                                
                                Text(String(format: String(key: "wasser.entspricht", value: "Das entspricht %d Gießvorgängen", comment: ""),
                                            Int(gardenStore.gesamtMlGegossen / 300)))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.top, 10)
                        
                        // Liste — "Meist gegossene Pflanzen"
                        VStack(alignment: .leading, spacing: 12) {
                            Text(String(key: "wasser.meine.pflanzen", value: "Meine Pflanzen", comment: ""))
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .padding(.top, 8)
                                .padding(.bottom, 4)
                            
                            if gardenStore.pflanzen.isEmpty || gardenStore.gesamtMlGegossen == 0 {
                                // Leerer Zustand
                                VStack(spacing: 16) {
                                    Image("Drop water")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .opacity(0.5)
                                    
                                    VStack(spacing: 4) {
                                        Text(String(key: "wasser.leer.titel", value: "Noch nichts gegossen", comment: ""))
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                        Text(String(key: "wasser.leer.body", value: "Gieße deine erste Pflanze!", comment: ""))
                                            .font(.system(size: 14))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                                .background(Color(UIColor.systemBackground).opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .padding(.horizontal, 20)
                            } else {
                                VStack(spacing: 0) {
                                    let sorted = gardenStore.pflanzenNachMlSortiert
                                    ForEach(Array(sorted.enumerated()), id: \.element.id) { index, habit in
                                        WasserRankingRow(rank: index + 1, habit: habit)
                                        
                                        if index < sorted.count - 1 {
                                            Divider()
                                                .padding(.leading, 70)
                                        }
                                    }
                                }
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer().frame(height: 32)
                    }
                }
            }
        }
        .presentationDetents([.large])
    }
}

struct WasserRankingRow: View {
    let rank: Int
    let habit: HabitModel
    
    private var rankColor: Color {
        switch rank {
        case 1:  return Color.goldPrimary
        case 2:  return Color(white: 0.75)
        case 3:  return Color(red: 0.7, green: 0.4, blue: 0.2)
        default: return Color.secondary.opacity(0.3)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rang-Nummer in einem kleinen Kreis
            ZStack {
                Circle()
                    .fill(rank <= 3 ? rankColor : Color.secondary.opacity(0.3))
                    .frame(width: 32, height: 32)
                
                Text("\(rank)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(rank <= 3 ? .white : .secondary)
            }
            
            // Pflanzen-Symbol (SF Symbol)
            Image(systemName: habit.symbolName)
                .font(.title2)
                .foregroundStyle(habit.seltenheit.farbe)
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 2) {
                let plant = GameDatabase.shared.plant(for: habit.plantID)
                let name = plant?.localizedName ?? habit.name
                
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                let zyklen = Int(habit.totalMlGegossen / 300)
                let cycleText = zyklen == 1 
                    ? String(key: "wasser.zyklus.singular", value: "1 Gießvorgang", comment: "")
                    : String(format: String(key: "wasser.zyklus.plural", value: "%d Gießvorgänge", comment: ""), zyklen)
                
                Text(cycleText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Wert (ml oder Liter)
            Text(formatVolume(habit.totalMlGegossen))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.blauPrimary.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func formatVolume(_ ml: Double) -> String {
        let liter = ml / 1000
        if liter < 1 {
            return String(format: "%.0f ml", ml)
        } else {
            return String(format: "%.1f Liter", liter)
        }
    }
}

#Preview {
    WasserDetailView()
        .environmentObject(GardenStore())
        .environmentObject(SettingsStore())
}
