import SwiftUI

struct ErfolgeDetailView: View {
    @State private var ausgewaehlteKategorie: ErfolgKategorie = .streak
    @EnvironmentObject var achievementStore: AchievementStore
    
    // Alle Erfolge aus dem Model
    var alleErfolge: [ErfolgModel] { achievementStore.alleErfolge }
    
    // Statistik
    var freigeschaltetAnzahl: Int { alleErfolge.filter { $0.istFreigeschaltet }.count }
    var gesamtAnzahl: Int { alleErfolge.count }
    
    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: Hero-Karte — Fortschritt
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(Color.lilaPrimary.opacity(0.1), lineWidth: 10)
                                .frame(width: 100, height: 100)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(freigeschaltetAnzahl) / CGFloat(max(1, gesamtAnzahl)))
                                .stroke(Color.lilaPrimary, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                .frame(width: 100, height: 100)
                                .rotationEffect(.degrees(-90))
                            
                            VStack(spacing: 0) {
                                Text("\(freigeschaltetAnzahl)")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                HStack(spacing: 2) {
                                    Text("common.of", bundle: .main)
                                    Text("\(gesamtAnzahl)")
                                }
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                            }
                        }
                        
                        Text("profile.achievements.unlocked", bundle: .main)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .background(Color(UIColor.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: .black.opacity(0.06), radius: 0, x: 0, y: 4)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 20)
                    
                    // MARK: Kategorien-Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ErfolgKategorie.allCases) { kategorie in
                                FilterButton(
                                    titel: kategorie.titel,
                                    icon: kategorie.icon,
                                    istAktiv: ausgewaehlteKategorie == kategorie
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        ausgewaehlteKategorie = kategorie
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // MARK: Erfolgs-Grid
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ],
                        spacing: 16
                    ) {
                        ForEach(alleErfolge.filter { $0.kategorie == ausgewaehlteKategorie }) { erfolg in
                            ErfolgCard(erfolg: erfolg)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle(Text("profile.achievements", bundle: .main))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Filter Button Component
struct FilterButton: View {
    let titel: String
    let icon: String
    let istAktiv: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(titel)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(istAktiv ? Color.lilaPrimary : Color(UIColor.systemBackground))
            .foregroundStyle(istAktiv ? .white : .primary)
            .clipShape(Capsule())
            .shadow(color: istAktiv ? Color.lilaPrimary.opacity(0.3) : .black.opacity(0.05), radius: 4, y: 2)
        }
    }
}

// MARK: - Erfolg Card Component
struct ErfolgCard: View {
    let erfolg: ErfolgModel

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(erfolg.istFreigeschaltet
                          ? erfolg.farbe.opacity(0.15)
                          : Color.gray.opacity(0.1))
                    .frame(width: 64, height: 64)

                if erfolg.istFreigeschaltet {
                    Image(systemName: erfolg.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(erfolg.farbe)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.gray.opacity(0.3))
                }
            }

            if erfolg.istFreigeschaltet {
                Text(LocalizedStringKey(erfolg.titel))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 34, alignment: .top)

                Text(LocalizedStringKey(erfolg.beschreibung))
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 28, alignment: .top)

                if let datum = erfolg.freigeschaltetAm {
                    Text(datum, style: .date)
                        .font(.system(size: 10))
                        .foregroundStyle(erfolg.farbe.opacity(0.7))
                        .padding(.top, 4)
                }

            } else {
                Text("???")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.gray.opacity(0.35))
                    .frame(height: 34, alignment: .top)

                Text("profile.achievements.locked_desc", bundle: .main)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.gray.opacity(0.3))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 28, alignment: .top)

                VStack(spacing: 3) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.12))
                                .frame(height: 5)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: geo.size.width * erfolg.fortschritt, height: 5)
                        }
                    }
                    .frame(height: 5)

                    Text("\(erfolg.aktuell) / \(erfolg.ziel)")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.gray.opacity(0.4))
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 0, x: 0, y: 2)
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 1)
        .opacity(erfolg.istFreigeschaltet ? 1.0 : 0.75)
    }
}
