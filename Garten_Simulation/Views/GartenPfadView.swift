import SwiftUI

struct GartenPfadView: View {
    @EnvironmentObject var pfadStore: GartenPfadStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    
    @Environment(\.modelContext) private var modelContext
    @State private var ausgewaehlterTag: PfadTag? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Hintergrund-Gradient (Natur-Vibe)
                LinearGradient(
                    colors: [
                        Color(hex: "#F0FAF0"),  // Sehr helles Grün oben
                        Color.appHintergrund    // Normal unten
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if !pfadStore.istPfadAktiv {
                    EmptyPfadView()
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 0) {
                                // Pfad-Canvas
                                PfadSchlangeView(
                                    pfadTage: pfadStore.pfadTage,
                                    aktuellerTagIndex: pfadStore.aktuellerTagIndex,
                                    ausgewaehlterTag: $ausgewaehlterTag
                                )
                                // Mindesthöhe damit 90 Nodes Platz haben
                                .frame(minHeight: CGFloat(pfadStore.pfadTage.count) * 90 + 200)
                            }
                            .padding(.bottom, 40)
                        }
                        .onAppear {
                            // Automatisch zum heutigen Tag scrollen
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation {
                                    proxy.scrollTo(pfadStore.aktuellerTagIndex, anchor: .center)
                                }
                            }
                        }
                    }
                }
                
                // Milestone Overlay
                if pfadStore.zeigeMeilensteinOverlay {
                    PfadMeilensteinOverlay(
                        meilensteinTitel: pfadStore.letzterMeilensteinTitel,
                        belohnung: pfadStore.belohnungsText,
                        onDismiss: {
                            withAnimation {
                                pfadStore.zeigeMeilensteinOverlay = false
                            }
                        }
                    )
                    .zIndex(100)
                }
            }
            .onAppear {
                pfadStore.setContext(modelContext, settings: settings, gardenStore: gardenStore)
            }
            .navigationTitle(settings.localizedString(for: "tab_pfad"))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $ausgewaehlterTag) { tag in
                PfadTagDetailView(tag: tag)
                    .environmentObject(pfadStore)
                    .environmentObject(gardenStore)
                    .environmentObject(settings)
                    .presentationDetents([.medium])
            }
        }
    }
}

struct EmptyPfadView: View {
    @EnvironmentObject var settings: SettingsStore
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.green.gradient)
                .shadow(radius: 10)
            
            VStack(spacing: 12) {
                Text(settings.localizedString(for: "pfad_leer_titel"))
                    .font(.system(size: 28, weight: .black, design: .rounded))
                
                Text(settings.localizedString(for: "pfad_leer_beschreibung"))
                    .font(.system(size: 17, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}
