import SwiftUI

struct ErfolgeDetailView: View {
    @EnvironmentObject var achievementStore: AchievementStore
    @EnvironmentObject var settings: SettingsStore
    @State private var ausgewaehlterErfolg: Erfolg? = nil
    @State private var showInfoSheet = false
    
    // Grid: 2 Spalten für größere, tiefere Darstellung
    let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
    
    var alleErfolge: [Erfolg] {
        achievementStore.alleErfolge
    }
    
    var freigeschaltet: [Erfolg] { alleErfolge.filter { $0.istFreigeschaltet } }
    var gesperrt: [Erfolg] { alleErfolge.filter { !$0.istFreigeschaltet } }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // Freigeschaltete Erfolge
                if !freigeschaltet.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(settings.localizedString(for: "erfolge.freigeschaltet"))
                            .font(.headline.weight(.bold))
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 32) {
                            ForEach(freigeschaltet) { erfolg in
                                Button(action: { ausgewaehlterErfolg = erfolg }) {
                                    ErfolgGridItem(erfolg: erfolg, istFreigeschaltet: true)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Gesperrte Erfolge
                if !gesperrt.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(settings.localizedString(for: "erfolge.gesperrt"))
                            .font(.headline.weight(.bold))
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 32) {
                            ForEach(gesperrt) { erfolg in
                                Button(action: { ausgewaehlterErfolg = erfolg }) {
                                    ErfolgGridItem(erfolg: erfolg, istFreigeschaltet: false)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(settings.localizedString(for: "erfolge.titel"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showInfoSheet = true
                } label: {
                    Image(systemName: "info")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                }
            }
        }
        .standardNavigationX()
        .background(Color.appHintergrund)
        .fullScreenCover(item: $ausgewaehlterErfolg) { erfolg in
            ErfolgDetailSheet(erfolg: erfolg, istFreigeschaltet: erfolg.istFreigeschaltet)
        }
        .sheet(isPresented: $showInfoSheet) {
            ErfolgeInfoSheet()
        }
    }
}

// Grid-Item mit Badge + Label
struct ErfolgGridItem: View {
    @EnvironmentObject var achievementStore: AchievementStore
    @EnvironmentObject var settings: SettingsStore
    let erfolg: Erfolg
    let istFreigeschaltet: Bool
    
    @State private var isVisible = false
    
    var tierLabel: String {
        switch erfolg.tier {
        case .bronze: return "Bronze"
        case .silber: return "Silber"
        case .gold: return "Gold"
        case .diamant: return "Diamant"
        case .master, .max: return "Master"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tier Label clearly visible at the top!
            Text(tierLabel.uppercased())
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(erfolg.tier.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(erfolg.tier.color.opacity(0.12))
                .clipShape(Capsule())
                .opacity(istFreigeschaltet ? 1.0 : 0.6)
                .offset(y: erfolg.tier != .bronze ? 4 : 0) // Visual offset adjustment for flat-winged badges (silver/gold/diamond)
            
            ErfolgBadgeView(erfolg: erfolg, istFreigeschaltet: istFreigeschaltet)
                .scaleEffect(isVisible ? 1.0 : 0.5)
                .opacity(isVisible ? 1.0 : 0.0)
            
            Text(settings.localizedString(for: erfolg.titelKey))
                .font(.caption.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(istFreigeschaltet ? .primary : .secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 110)  // Minimum width for better layout
            
            // Fortschrittsbalken unter dem Badge
            if !istFreigeschaltet {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 4)
                        Capsule()
                            .fill(erfolg.tier.color)
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
