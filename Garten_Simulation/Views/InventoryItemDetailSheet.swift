import SwiftUI

struct InventoryItemDetailSheet: View {
    let item: ShopDetailPayload
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var shopStore: ShopStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var animateIcon = false
    @State private var showPlantPicker = false
    @State private var showSuccessPill = false
    @State private var successMessage = ""

    private var powerUp: PowerUpItem? {
        GameDatabase.allPowerUps.first(where: { $0.id == item.id })
    }

    private var activePowerUp: ActivePowerUp? {
        gardenStore.activePowerUps.first {
            $0.isActive && $0.powerUpId == item.id
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 32) {
                // Icon Area
                Group {
                    if UIImage(named: item.icon) != nil {
                        Image(item.icon)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image(systemName: item.icon)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(item.color)
                    }
                }
                .frame(width: 120, height: 120)
                .padding(.top, 40)
                .scaleEffect(animateIcon ? 1.05 : 1.0)
                
                VStack(spacing: 8) {
                    Text(settings.localizedString(for: item.title))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    
                    Text(settings.localizedString(for: item.description))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .lineSpacing(4)
                        .padding(.horizontal, 40)
                }
                

                
                Spacer()
                
                // MARK: Button-Bereich
                if let active = activePowerUp {
                    // Aktiv-Zustand: Timer-Pill
                    HStack(spacing: 8) {
                        Image(systemName: "timer")
                        Text(active.timeRemainingFormatted)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.regularMaterial, in: Capsule())
                    .overlay(Capsule().stroke(Color.primary.opacity(0.1), lineWidth: 0.5))
                    .foregroundColor(.primary)
                    .padding(.bottom, 32)
                } else {
                    // Normal: Verwenden-Button
                    Button {
                        // 3D-Animation läuft, dann nach 0.20s Aktion
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                            if let p = powerUp {
                                if p.target == .plant {
                                    showPlantPicker = true
                                } else {
                                    // Sofort auf Garten anwenden
                                    gardenStore.applyPowerUp(p)
                                    gardenStore.itemVerbrauchen(shopItem: item)
                                    shopStore.removeFromPurchased(id: item.id)
                                    
                                    let duration = Int(p.durationHours ?? 24)
                                    successMessage = String(format: settings.localizedString(for: "powerup.active.garden"), duration)
                                    
                                    withAnimation(.spring()) {
                                        showSuccessPill = true
                                    }
                                    
                                    // Kurze Verzögerung zum Anzeigen, dann Schließen
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                                        dismiss()
                                    }
                                }
                            } else {
                                dismiss()
                            }
                        }
                    } label: {
                        Text(item.itemType == .powerUp ? settings.localizedString(for: "button.use") : settings.localizedString(for: "button.ok"))
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        size: .large,
                        fillWidth: true,
                        backgroundColor: item.color,
                        shadowColor: item.color.darker()
                    ))
                    .padding(.horizontal, 24)
                    
                    // Sell Button
                    let sellPrice = Int(Double(item.price) * 0.5)
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        shopStore.sell(id: item.id, price: item.price, title: settings.localizedString(for: item.title))
                        gardenStore.itemEntfernen(id: item.id)
                        dismiss()
                    } label: {
                        VStack(spacing: 2) {
                            Text(settings.localizedString(for: "shop.item.sell"))
                                .font(.system(size: 14, weight: .bold))
                            HStack(spacing: 4) {
                                Image("coin")
                                    .resizable().scaledToFit().frame(width: 14, height: 14)
                                Text("+\(sellPrice)")
                                    .font(.system(size: 14, weight: .black))
                            }
                        }
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Capsule().stroke(Color.red.opacity(0.3), lineWidth: 2))
                    }
                    .padding(.horizontal, 44)
                    .padding(.bottom, 32)
                }
            }
            .padding(.horizontal)
            .blur(radius: showSuccessPill ? 2 : 0)
            
            // Erfolgspille (Toast)
            if showSuccessPill {
                Text(successMessage)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.gruenPrimary, in: Capsule())
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 20)
                    .zIndex(10)
            }
        }
        .sheet(isPresented: $showPlantPicker) {
            if let p = powerUp {
                PowerUpPlantPickerSheet(
                    powerUp: p,
                    onSelect: { plant in
                        gardenStore.applyPowerUp(p, targetPlantId: plant.id)
                        gardenStore.itemVerbrauchen(shopItem: item)
                        shopStore.removeFromPurchased(id: item.id)
                        showPlantPicker = false
                        
                        let duration = Int(p.durationHours ?? 24)
                        let plantDisplayName = settings.showHabitInsteadOfName 
                            ? settings.localizedString(for: plant.habitName)
                            : settings.localizedString(for: plant.name)
                        successMessage = String(format: settings.localizedString(for: "powerup.active.plant"), plantDisplayName, duration)
                        
                        // Kurze Verzögerung damit Sheet schließt, dann Pill zeigen
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            withAnimation(.spring()) {
                                showSuccessPill = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                                dismiss()
                            }
                        }
                    }
                )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                animateIcon = true
            }
        }
    }
}

#Preview {
    InventoryItemDetailSheet(
        item: ShopDetailPayload(
            id: "test",
            title: "Super-Dünger",
            subtitle: "Wachstums-Boost",
            description: "Beschleunigt das Wachstum deiner Pflanzen um 50% für die nächsten 24 Stunden.",
            price: 500,
            icon: "Powerup",
            colorHex: "#FFD000", // yellow
            symbolColor: "yellow",
            shadowColorHex: "#D9B200", // darker yellow
            tag: "POWER-UP",
            itemType: .powerUp,
            habitCategory: .fitness,
            symbolism: "Energie und schnelles Vorankommen.",
            howToUse: "item.duenger_blitz.usage"
        )
    )
    .environmentObject(GardenStore())
    .environmentObject(ShopStore())
    .environmentObject(SettingsStore())
}
