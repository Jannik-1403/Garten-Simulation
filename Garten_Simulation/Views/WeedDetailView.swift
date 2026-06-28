import SwiftUI

struct WeedDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var shopStore: ShopStore

    @State private var selectedPowerUp: ShopDetailPayload?
    @State private var shieldedDotIndices: Set<Int> = []
    @State private var showInfoPopover = false

    private var stylizedBodyText: AttributedString {
        let raw = String(format: String(localized: "weed_popup_body"), gardenStore.weedEffectiveRewardPercent,
            GameConstants.habitsRequiredPerWeed)
        var attr = AttributedString(raw)
        
        let terms = [
            "\(gardenStore.weedEffectiveRewardPercent)% XP",
            "\(gardenStore.weedEffectiveRewardPercent)%",
            "\(GameConstants.habitsRequiredPerWeed) Gewohnheiten",
            "\(GameConstants.habitsRequiredPerWeed) habits",
            "\(GameConstants.habitsRequiredPerWeed) hábitos",
            "\(GameConstants.habitsRequiredPerWeed) abitudini",
            "\(GameConstants.habitsRequiredPerWeed) habitudes",
            "Coins", "coins", "pièces", "monedas", "monete"
        ]
        
        for term in terms {
            if let range = attr.range(of: term, options: .caseInsensitive) {
                attr[range].font = .system(size: 16, weight: .black, design: .rounded)
                attr[range].foregroundColor = .orange
            }
        }
        
        return attr
    }

    /// Inventar-Power-up gewählt oder Schutz läuft bereits (Deko-Schutz etc.)
    private var canUseShieldDrag: Bool {
        selectedPowerUp != nil || gardenStore.blocksNewWeedSpawns
    }

    private var ritualComplete: Bool {
        shieldedDotIndices.count >= GameConstants.habitsRequiredPerWeed
    }

    private var hasWeedPowerUpsInInventory: Bool {
        !gardenStore.availableWeedPowerUpItems.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                Color.clear.background(.ultraThinMaterial).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer().frame(height: 40)
                        headerSection

                        if gardenStore.hasWeedShieldOption {
                            shieldDragSection
                        } else {
                            wateringProgressSection
                        }

                        if hasWeedPowerUpsInInventory {
                            WeedPowerUpSection(selectedPowerUp: $selectedPowerUp)
                                .onChange(of: selectedPowerUp?.id) { _, _ in
                                    if !ritualComplete {
                                        shieldedDotIndices.removeAll()
                                    }
                                }
                        }
                        
                        if !canUseShieldDrag && gardenStore.weedRemovalCost > 0 {
                            Button(action: {
                                if gardenStore.removeFrontWeedWithCoins() {
                                    dismiss()
                                }
                            }) {
                                HStack {
                                    Text(String(localized: "weed_popup_pay"))
                                        .font(.system(size: 15, weight: .bold))
                                    Image("coin")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                    Text("\(gardenStore.weedRemovalCost)")
                                        .font(.system(size: 15, weight: .black))
                                }
                            }
                            .buttonStyle(DuolingoButtonStyle(
                                size: .large,
                                backgroundColor: gardenStore.coins >= gardenStore.weedRemovalCost ? .orange : Color(uiColor: .systemGray4),
                                shadowColor: gardenStore.coins >= gardenStore.weedRemovalCost ? .orange.darker() : Color(uiColor: .systemGray3),
                                foregroundColor: .white
                            ))
                            .disabled(gardenStore.coins < gardenStore.weedRemovalCost)
                        }
                    }
                    .padding(24)
                    .padding(.top, 40)
                }
            }
            .standardNavigationX()
        }
        .onAppear {
            shieldedDotIndices.removeAll()
            applyPendingPowerUpSelection()
            preselectWeedPowerUpIfNeeded()
        }
        .onChange(of: gardenStore.gekaufteItems.count) { _, _ in
            preselectWeedPowerUpIfNeeded()
        }
        .onChange(of: ritualComplete) { _, complete in
            if complete { finishShieldRitual() }
        }
    }

    private func applyPendingPowerUpSelection() {
        guard let pending = gardenStore.pendingWeedPowerUpForRitual else { return }
        selectedPowerUp = pending
        gardenStore.pendingWeedPowerUpForRitual = nil
    }

    /// Beim Öffnen direkt Zauberstab/Gartenschutz wählen – kein Extra-Tap nötig.
    private func preselectWeedPowerUpIfNeeded() {
        guard selectedPowerUp == nil else { return }
        let items = gardenStore.availableWeedPowerUpItems
        guard !items.isEmpty else { return }

        if let wand = items.first(where: { $0.id == PowerUpWeedSupport.zauberstabID }) {
            selectedPowerUp = wand
        } else if let shield = items.first(where: { $0.id == PowerUpWeedSupport.gartenschutzID }) {
            selectedPowerUp = shield
        } else {
            selectedPowerUp = items.first
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 10) {
            Button {
                showInfoPopover.toggle()
            } label: {
                Text(String(localized: "weed_popup_title"))
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .popover(isPresented: $showInfoPopover) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Text(stylizedBodyText)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                        
                        if gardenStore.hasWeedShieldOption {
                            Text(
                                gardenStore.blocksNewWeedSpawns && selectedPowerUp == nil
                                    ? String(localized: "weed.shield.ritual.drag_active")
                                    : String(localized: "weed.shield.ritual.drag")
                            )
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        }
            
                        if gardenStore.isComebackBoostActive {
                            Label(
                                String(format: String(localized: "weed.comeback.banner"), gardenStore.comebackBoostRewardPercent),
                                systemImage: "bolt.fill"
                            )
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.gruenPrimary)
                        }
            
                        if gardenStore.weedCount > 1 {
                            Text(
                                String(format: String(localized: "weed_queue_position"), 1,
                                    gardenStore.weedCount)
                            )
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)
                            .multilineTextAlignment(.center)
                        }
                    }
                    .padding(24)
                }
                .frame(minWidth: 280, idealWidth: 320, maxWidth: 320)
                .frame(minHeight: 200, idealHeight: 220, maxHeight: 300)
                .presentationCompactAdaptation(.popover)
            }

            if gardenStore.weedCount > 1 {
                WeedQueueStrip(weeds: gardenStore.activeWeeds)
                    .padding(.horizontal, 4)
                    .padding(.top, 8)
            }
        }
    }

    // MARK: - Shield drag (wie Wassertropfen)

    private var shieldDragSection: some View {
        VStack(spacing: 8) {
            if !canUseShieldDrag && hasWeedPowerUpsInInventory {
                Text(String(localized: "weed.shield.ritual.pick_first"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            DragShieldToWeed(
                shieldedIndices: shieldedDotIndices,
                onShieldApplied: { index in
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.65)) {
                        _ = shieldedDotIndices.insert(index)
                    }
                },
                isDisabled: !canUseShieldDrag
            )
            .opacity(canUseShieldDrag ? 1 : 0.4)

            if canUseShieldDrag {
                Text(
                    String(format: String(localized: "weed.shield.ritual.progress"), shieldedDotIndices.count,
                        GameConstants.habitsRequiredPerWeed)
                )
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }
        }
    }

    // MARK: - Normaler Gieß-Fortschritt (ohne Schutz)

    private var wateringProgressSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                ForEach(0..<GameConstants.habitsRequiredPerWeed, id: \.self) { index in
                    let isCompleted = index < gardenStore.dailyQuestsCompletedSinceWeed
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isCompleted
                                  ? Color(red: 0.1, green: 0.6, blue: 0.2)
                                  : Color(red: 0.6, green: 0.6, blue: 0.6))
                            .frame(width: 52, height: 52)
                            .offset(y: 4)

                        RoundedRectangle(cornerRadius: 14)
                            .fill(isCompleted
                                  ? Color(red: 0.2, green: 0.78, blue: 0.35)
                                  : Color(red: 0.82, green: 0.82, blue: 0.82))
                            .frame(width: 52, height: 52)
                            .offset(y: isCompleted ? 2 : 0)

                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                                .offset(y: 2)
                        } else {
                            Text("\(index + 1)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }
            }

            Text(
                String(format: String(localized: "weed_progress_label"), gardenStore.dailyQuestsCompletedSinceWeed,
                    GameConstants.habitsRequiredPerWeed)
            )
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGroupedBackground))
        )
    }

    // MARK: - Bottom
    // Bottom actions removed per user request

    private func finishShieldRitual() {
        if let item = selectedPowerUp {
            guard gardenStore.applyWeedPowerUpAfterRitual(item: item) else { return }
            shopStore.removeFromPurchased(id: item.id)
            selectedPowerUp = nil
        } else {
            gardenStore.completeShieldRitualUsingActiveProtection()
        }
    }
}

#Preview {
    WeedDetailView()
        .environmentObject(GardenStore())
        .environmentObject(SettingsStore())
        .environmentObject(ShopStore())
}
