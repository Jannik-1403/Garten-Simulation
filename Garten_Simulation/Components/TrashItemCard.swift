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





