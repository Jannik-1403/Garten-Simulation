import SwiftUI

struct PfadTagDetailView: View {
    let tag: PfadTag
    @EnvironmentObject var pfadStore: GartenPfadStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    let headerKey = settings.localizedString(for: "pfad_tag_header")
                    Text(String(format: headerKey, tag.tagNummer))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                    Text(settings.localizedString(for: "pfad_phase_tag_titel_\(tag.phase.rawValue)"))
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(tag.phase.farbe)
                }
                Spacer()
                
                LiquidGlassDismissButton {
                    dismiss()
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            Divider().padding(.horizontal, 24)
            
            // Content
            VStack(alignment: .leading, spacing: 16) {
                Text(settings.localizedString(for: tag.titel))
                    .font(.system(size: 28, weight: .black, design: .rounded))
                
                Text(settings.localizedString(for: tag.beschreibung))
                    .font(.system(size: 18, design: .rounded))
                    .foregroundStyle(.primary.opacity(0.85))
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            
            // Active Plants
            VStack(alignment: .leading, spacing: 14) {
                Text(settings.localizedString(for: "pfad_aktive_pflanzen"))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
                
                HStack(spacing: 16) {
                    ForEach(tag.pflanzenIDs, id: \.self) { plantID in
                        if let plant = GameDatabase.allPlants.first(where: { $0.id == plantID }) {
                            VStack(spacing: 8) {
                                // 3D Asset Container
                                ZStack {
                                    // Shadow/Depth layer
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color(uiColor: .systemGray4).opacity(0.5))
                                        .frame(width: 60, height: 60)
                                        .offset(y: 4)
                                    
                                    // Main glass layer
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(.regularMaterial)
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(.white.opacity(0.2), lineWidth: 1)
                                        )
                                    
                                    // Asset
                                    if let assetName = plant.assetName {
                                        Image(assetName)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 44, height: 44)
                                    } else {
                                        Text(plant.symbol)
                                            .font(.system(size: 32))
                                    }
                                }
                                
                                Text(settings.localizedString(for: plant.name))
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Action Button
            if tag.istErledigt {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text(settings.localizedString(for: "pfad_tag_erledigt"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
                .padding(.bottom, 20)
            } else if isToday(tag: tag) {
                Button {
                    pfadStore.tagErledigen(tag: tag, gardenStore: gardenStore, settings: settings)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        dismiss()
                    }
                } label: {
                    Text(settings.localizedString(for: "pfad_tag_erledigen"))
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    backgroundColor: Color.blauPrimary,
                    shadowColor: Color.blauPrimary.darker(),
                    foregroundColor: .white
                ))
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            } else if let hintID = tag.neuerPflanzenHinweis, !isOwned(hintID) {
                Button {
                    // Open Shop logic or navigate to shop
                    gardenStore.selectedTab = 1 // Shop tab
                    dismiss()
                } label: {
                    Text(settings.localizedString(for: "pfad_pflanze_kaufen"))
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .large,
                    backgroundColor: Color.orange,
                    shadowColor: Color.orange.darker(),
                    foregroundColor: .white
                ))
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            } else {
                if let datum = tag.datum, datum > Date() {
                    Text(countdownText(for: datum))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 40)
                } else {
                    Text(settings.localizedString(for: "pfad_tag_gesperrt"))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 40)
                }
            }
        }
    }
    
    private func isToday(tag: PfadTag) -> Bool {
        guard let datum = tag.datum else { return false }
        return Calendar.current.isDateInToday(datum)
    }
    
    private func isOwned(_ plantID: String) -> Bool {
        gardenStore.pflanzen.contains { $0.plantID == plantID }
    }
    
    private func countdownText(for datum: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: settings.appLanguage)
        formatter.unitsStyle = .abbreviated
        let zeitText = formatter.localizedString(for: datum, relativeTo: Date())
        let pattern = settings.localizedString(for: "pfad_tag_verfuegbar_in")
        return String(format: pattern, zeitText)
    }
}

// Placeholder for LiquidGlassDismissButton if it doesn't exist, but I saw it in other files (usually renamed or similar)
// Let's check for it.
