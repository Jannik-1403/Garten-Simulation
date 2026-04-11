import SwiftUI

struct DecorationCard: View {
    let decoration: DecorationItem
    @EnvironmentObject var settings: SettingsStore
    @AppStorage("isHapticEnabled") private var isHapticEnabled: Bool = true
    
    var body: some View {
        VStack(spacing: 8) {
            // MARK: Icon Container
            ZStack {
                if UIImage(named: decoration.sfSymbol) != nil {
                    Image(decoration.sfSymbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                } else {
                    Image(systemName: decoration.sfSymbol)
                        .font(.system(size: 55, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 100, height: 100)
                }
            }
            .frame(width: 110, height: 110)
            
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
    let minGartenLevel: Int

    init(
        id: String,
        nameKey: String,
        descriptionKey: String,
        sfSymbol: String,
        price: Int,
        category: DecorationCategory,
        minGartenLevel: Int = 1
    ) {
        self.id = id
        self.nameKey = nameKey
        self.descriptionKey = descriptionKey
        self.sfSymbol = sfSymbol
        self.price = price
        self.category = category
        self.minGartenLevel = minGartenLevel
    }
}

enum DecorationCategory: String, CaseIterable, Codable {
    case moebel
    case wasser
    case tiere
    case pfade
    case beleuchtung
    case deko
    case pflanzen

    var localizationKey: String {
        "decoration.category.\(self.rawValue)"
    }
}


