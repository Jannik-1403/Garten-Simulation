import SwiftUI

struct ErfolgeDetailView: View {
    @EnvironmentObject var achievementStore: AchievementStore
    @EnvironmentObject var gardenStore: GardenStore
    
    // Grid: 3 Spalten
    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    var alleErfolge: [Erfolg] {
        achievementStore.alleErfolge
    }
    
    var freigeschaltet: [Erfolg] { alleErfolge.filter { $0.istFreigeschaltet } }
    var gesperrt: [Erfolg] { alleErfolge.filter { !$0.istFreigeschaltet } }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // Header-Stat
                HStack {
                    Label("\(freigeschaltet.count)/\(alleErfolge.count)",
                          systemImage: "trophy.fill")
                        .font(.headline)
                        .foregroundStyle(Color.goldPrimary)
                    Spacer()
                }
                .padding(.horizontal)
                
                // Freigeschaltete Erfolge
                if !freigeschaltet.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(LocalizedStringKey("erfolge.freigeschaltet"))
                            .font(.headline.weight(.bold))
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(freigeschaltet) { erfolg in
                                ErfolgGridItem(erfolg: erfolg, istFreigeschaltet: true)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Gesperrte Erfolge
                if !gesperrt.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(LocalizedStringKey("erfolge.gesperrt"))
                            .font(.headline.weight(.bold))
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(gesperrt) { erfolg in
                                ErfolgGridItem(erfolg: erfolg, istFreigeschaltet: false)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(LocalizedStringKey("erfolge.titel"))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.appHintergrund)
    }
}

// Grid-Item mit Badge + Label
struct ErfolgGridItem: View {
    @EnvironmentObject var achievementStore: AchievementStore
    let erfolg: Erfolg
    let istFreigeschaltet: Bool
    
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 8) {
            ErfolgBadgeView(erfolg: erfolg, istFreigeschaltet: istFreigeschaltet)
                .scaleEffect(isVisible ? 1.0 : 0.5)
                .opacity(isVisible ? 1.0 : 0.0)
            
            Text(LocalizedStringKey(erfolg.titelKey))
                .font(.caption2.weight(.bold))  // Smaller font as requested in Step 6
                .multilineTextAlignment(.center)
                .foregroundStyle(istFreigeschaltet ? .primary : .secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 80)  // Ensure minimum width for better wrapping
            
            // Fortschrittsbalken unter dem Badge
            if !istFreigeschaltet {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 4)
                        Capsule()
                            .fill(erfolg.farbe)
                            .frame(
                                width: geo.size.width * min(Double(erfolg.aktuellerWert) / Double(erfolg.zielWert), 1.0),
                                height: 4
                            )
                    }
                }
                .frame(height: 4)
            }
        }
        .onAppear {
            let index = achievementStore.alleErfolge.firstIndex(where: { $0.id == erfolg.id }) ?? 0
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.05)) {
                isVisible = true
            }
        }
    }
}
