import SwiftUI

struct WeedPowerUpSection: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore

    @Binding var selectedPowerUp: ShopDetailPayload?

    private var items: [ShopDetailPayload] {
        gardenStore.availableWeedPowerUpItems
    }

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(settings.localizedString(for: "weed.powerup.section"))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)

                ForEach(items, id: \.id) { item in
                    powerUpSelectRow(item: item)
                }
            }
        }
    }

    @ViewBuilder
    private func powerUpSelectRow(item: ShopDetailPayload) -> some View {
        let isActive = gardenStore.hasActivePowerUp(powerUpId: item.id)
        let isSelected = selectedPowerUp?.id == item.id
        let hintKey = item.id == PowerUpWeedSupport.zauberstabID
            ? "weed.powerup.hint.zauberstab"
            : "weed.powerup.hint.unkraut_schild"

        Button {
            guard !isActive else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedPowerUp = isSelected ? nil : item
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            HStack(spacing: 12) {
                Group {
                    if item.id == PowerUpWeedSupport.zauberstabID {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(isSelected ? .white : item.color)
                    } else {
                        Image(PowerUpWeedSupport.unkrautSchildAssetName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                    }
                }
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? item.color : item.color.opacity(0.15))
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(settings.localizedString(for: item.titleKey))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    Text(settings.localizedString(for: hintKey))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.gruenPrimary)
                } else if isSelected {
                    Image(systemName: "hand.tap.fill")
                        .foregroundStyle(item.color)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? item.color : Color.clear, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.secondarySystemGroupedBackground))
                    )
            )
        }
        .disabled(isActive)
        .buttonStyle(.plain)
    }
}
