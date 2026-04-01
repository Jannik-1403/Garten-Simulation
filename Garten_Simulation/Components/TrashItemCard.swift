import SwiftUI

struct DecorationCard: View {
    let decoration: DecorationItem
    @EnvironmentObject var settings: SettingsStore
    @AppStorage("isHapticEnabled") private var isHapticEnabled: Bool = true
    
    var body: some View {
        VStack(spacing: 8) {
            // MARK: Icon Container
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(UIColor.systemGroupedBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                Image(systemName: decoration.sfSymbol)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 80, height: 80)
            
            // MARK: Name
            Text(settings.localizedString(for: decoration.nameKey))
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        Color.appHintergrund.ignoresSafeArea()
        DecorationCard(
            decoration: DecorationItem(
                id: "test",
                nameKey: "deko.bank.name",
                descriptionKey: "deko.bank.desc",
                sfSymbol: "chair.fill",
                price: 15,
                category: .moebel
            )
        )
        .environmentObject(SettingsStore())
    }
}

struct DecorationItem: Identifiable, Codable {
    let id: String
    let nameKey: String
    let descriptionKey: String
    let sfSymbol: String
    let price: Int
    let category: DecorationCategory
}

enum DecorationCategory: String, CaseIterable, Codable {
    case moebel
    case deko
    case pflanzen

    var localizationKey: String {
        switch self {
        case .moebel:   return "deko.category.moebel"
        case .deko:     return "deko.category.deko"
        case .pflanzen: return "deko.category.pflanzen"
        }
    }
}

