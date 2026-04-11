import SwiftUI

struct ErfolgeDetailView: View {
    @EnvironmentObject var achievementStore: AchievementStore
    @EnvironmentObject var settings: SettingsStore
    @State private var ausgewaehlterErfolg: Erfolg? = nil
    
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
                
                // MARK: - Hero Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.15))
                            .frame(width: 110, height: 110)
                        Image("Erfolg")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .shadow(color: Color.purple.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    
                    Text("\(freigeschaltet.count)/\(alleErfolge.count)")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                    
                    Text(settings.localizedString(for: "profile.achievements"))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .tracking(1.0)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
                
                // Freigeschaltete Erfolge
                if !freigeschaltet.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(LocalizedStringKey("erfolge.freigeschaltet"))
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
                        Text(LocalizedStringKey("erfolge.gesperrt"))
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
        .navigationTitle(LocalizedStringKey("erfolge.titel"))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.appHintergrund)
        .sheet(item: $ausgewaehlterErfolg) { erfolg in
            ErfolgDetailSheet(erfolg: erfolg, istFreigeschaltet: erfolg.istFreigeschaltet)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
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
                .font(.caption2.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(istFreigeschaltet ? .primary : .secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 80)  // Minimum width for better layout
            
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
