import SwiftUI

struct DeveloperView: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var shopStore: ShopStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @EnvironmentObject var titelStore: TitelStore
    @EnvironmentObject var achievementStore: AchievementStore
    @EnvironmentObject var pfadStore: GartenPfadStore
    @EnvironmentObject var tourManager: InteractiveTourManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Section 1: General simulation controls
                    settingsSection(title: "Allgemeine Steuerung") {
                        VStack(spacing: 0) {
                            Button {
                                gardenStore.taeglicherStreakCheck()
                                FeedbackManager.shared.playSuccess()
                            } label: {
                                settingRow(title: "Simulations-Tag (Reset)", icon: "clock.arrow.circlepath", color: .indigo)
                            }
                            
                            Divider().padding(.leading, 44)
                            
                            Button {
                                gardenStore.coinsGutschreiben(amount: 1000, beschreibung: "Debug: Coins erhalten")
                                FeedbackManager.shared.playCoins()
                            } label: {
                                settingRow(title: "1000 Coins hinzufügen", icon: "plus.circle.fill", color: .coinBlue)
                            }
                            
                            Divider().padding(.leading, 44)
                            
                            Button {
                                gardenStore.xpHinzufuegen(amount: 500)
                                FeedbackManager.shared.playSuccess()
                            } label: {
                                settingRow(title: "+500 XP hinzufügen", icon: "star.fill", color: .orange)
                            }
                            
                            Divider().padding(.leading, 44)
                            
                            Button {
                                for p in gardenStore.pflanzen {
                                    p.istBewässert = false
                                }
                                FeedbackManager.shared.playTap()
                            } label: {
                                settingRow(title: "Alle Pflanzen durstig machen", icon: "Drop water", color: .blue, isAsset: true)
                            }
                            
                            Divider().padding(.leading, 44)
                            
                            Button {
                                gardenStore.showDailySpinOverlay = true
                                FeedbackManager.shared.playSuccess()
                            } label: {
                                settingRow(title: "Unkraut-Glücksrad testen", icon: "asterisk.circle.fill", color: .orange)
                            }
                            
                            Divider().padding(.leading, 44)
                            
                            Button {
                                gardenStore.seeds += 10
                                FeedbackManager.shared.playSuccess()
                            } label: {
                                settingRow(title: "10 Samen hinzufügen", icon: "Samen", color: .purple, isAsset: true)
                            }
                        }
                    }
                    
                    // Section 2: Weeds & Power-Ups
                    settingsSection(title: "Unkraut & Power-Ups") {
                        VStack(spacing: 0) {
                            Button {
                                gardenStore.debugSpawnWeed()
                                FeedbackManager.shared.playSuccess()
                            } label: {
                                settingRow(title: "Unkraut spawnen", icon: "leaf.fill", color: .orange)
                            }
                            
                            Divider().padding(.leading, 44)
                            
                            Button {
                                gardenStore.debugClearWeeds()
                                FeedbackManager.shared.playTap()
                            } label: {
                                settingRow(title: "Unkraut entfernen", icon: "Samen", color: .green, isAsset: true)
                            }
                            
                            Divider().padding(.leading, 44)
                            
                            Button {
                                gardenStore.debugRequestOpenWeedSheet()
                                FeedbackManager.shared.playSuccess()
                            } label: {
                                settingRow(title: "Unkraut-Sheet öffnen", icon: "rectangle.bottomthird.inset.filled", color: .brown)
                            }
                            
                            Divider().padding(.leading, 44)
                            
                            Button {
                                gardenStore.debugOpenWeedSheetWithShieldPreselected()
                                FeedbackManager.shared.playSuccess()
                            } label: {
                                settingRow(title: "Schild-Ritual testen", icon: "shield.fill", color: .green)
                            }
                            
                            Divider().padding(.leading, 44)
                            
                            Button {
                                gardenStore.debugAddWeedPowerUpToInventory(
                                    powerUpId: PowerUpWeedSupport.gartenschutzID
                                )
                                FeedbackManager.shared.playSuccess()
                            } label: {
                                settingRow(title: "Unkraut-Schild ins Inventar", icon: "shield.lefthalf.filled", color: .green)
                            }
                            
                            Divider().padding(.leading, 44)
                            
                            Button {
                                gardenStore.debugAddWeedPowerUpToInventory(
                                    powerUpId: PowerUpWeedSupport.zauberstabID
                                )
                                FeedbackManager.shared.playSuccess()
                            } label: {
                                settingRow(title: "Zauberstab ins Inventar", icon: "wand.and.stars", color: .indigo)
                            }
                            
                            Divider().padding(.leading, 44)
                            
                            Button {
                                gardenStore.debugActivateGardenPowerUp(
                                    powerUpId: PowerUpWeedSupport.gartenschutzID
                                )
                                FeedbackManager.shared.playSuccess()
                            } label: {
                                settingRow(title: "Unkraut-Schild aktivieren", icon: "checkmark.shield.fill", color: .mint)
                            }
                            
                            Divider().padding(.leading, 44)
                            
                            Button {
                                gardenStore.debugClearWeedProtection()
                                FeedbackManager.shared.playTap()
                            } label: {
                                settingRow(title: "Schutz-Power-Ups beenden", icon: "shield.slash.fill", color: .gray)
                            }
                            
                            Divider().padding(.leading, 44)
                            
                            Button {
                                gardenStore.debugGrantComebackBoost()
                                FeedbackManager.shared.playSuccess()
                            } label: {
                                settingRow(title: "Comeback-Boost testen", icon: "bolt.fill", color: .yellow)
                            }
                        }
                    }
                    
                    // Section 3: Time Skip simulation
                    settingsSection(title: "Zeitsprung-Simulation") {
                        VStack(spacing: 8) {
                            Text(String(localized: "settings.timeskip_simulation"))
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                            
                            HStack(spacing: 12) {
                                debugTimeButton(title: "12h", hours: 12)
                                debugTimeButton(title: "24h", hours: 24)
                                debugTimeButton(title: "48h", hours: 48)
                            }
                            .padding(.bottom, 12)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Section 4: Titles Debug
                    settingsSection(title: "Titel-System") {
                        VStack(spacing: 0) {
                            Button {
                                // Alle Titel freischalten
                                for titel in GameDatabase.allTitles {
                                    titelStore.freigeschalteteTitelIDs.insert(titel.id)
                                }
                                titelStore.speichernPublic()
                                FeedbackManager.shared.playSuccess()
                            } label: {
                                settingRow(title: "Alle Titel freischalten", icon: "crown.fill", color: .goldPrimary)
                            }
                            
                            Divider().padding(.leading, 44)
                            
                            Button {
                                // Zurücksetzen (nur Anfänger-Titel)
                                titelStore.freigeschalteteTitelIDs = ["titel_anfaenger"]
                                titelStore.aktiverTitelID = "titel_anfaenger"
                                titelStore.speichernPublic()
                                FeedbackManager.shared.playError()
                            } label: {
                                settingRow(title: "Titel zurücksetzen", icon: "arrow.counterclockwise", color: .red)
                            }
                        }
                    }
                    
                    // Section: Pfad-System Debug
                    settingsSection(title: "Pfad-System") {
                        VStack(spacing: 0) {
                            Button {
                                pfadStore.debugJumpToDay89()
                                FeedbackManager.shared.playSuccess()
                            } label: {
                                settingRow(title: String(localized: "developer.jump_to_day_89", defaultValue: "Zu Tag 89 springen"), icon: "forward.end.fill", color: .purple)
                            }
                        }
                    }
                    // Section 5: Lives System Debug
                    settingsSection(title: "Leben-System") {
                        VStack(spacing: 0) {
                            Button {
                                let vierTageZurueck = Calendar.current.date(byAdding: .day, value: -4, to: Date())!
                                for pflanze in gardenStore.pflanzen {
                                    pflanze.letzteBewaesserung = vierTageZurueck
                                    pflanze.lebenBereitsAbgezogen = false
                                }
                                gardenStore.checkUngegossenePflanzen()
                            } label: {
                                settingRow(title: " Leben-System testen", icon: "heart.slash.fill", color: .red)
                            }
                            
                            Divider().padding(.leading, 44)
                            
                            Button {
                                for pflanze in gardenStore.pflanzen {
                                    pflanze.letzteBewaesserung = Date()
                                    pflanze.lebenBereitsAbgezogen = false
                                }
                            } label: {
                                settingRow(title: " Test zurücksetzen", icon: "arrow.counterclockwise", color: .orange)
                            }
                        }
                    }
                    
                    // Section 6: Onboarding & App-Tour
                    settingsSection(title: "Onboarding & App-Tour") {
                        VStack(spacing: 0) {
                            Button {
                                settings.onboardingAbgeschlossen = false
                                FeedbackManager.shared.playSuccess()
                                dismiss()
                            } label: {
                                settingRow(
                                    title: String(localized: "settings.onboarding.repeat"),
                                    icon: "arrow.counterclockwise.circle.fill",
                                    color: .orange
                                )
                            }
                            
                            Divider().padding(.leading, 44)
                            
                            Button {
                                gardenStore.selectedTab = 0
                                FeedbackManager.shared.playSuccess()
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    tourManager.startTour()
                                }
                            } label: {
                                settingRow(
                                    title: "App-Tour wiederholen",
                                    icon: "sparkles",
                                    color: .blue
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(String(localized: "developer.options.title", defaultValue: "Developer Options"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                LiquidGlassDismissButton { dismiss() }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.leading, 8)
            
            content()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                )
        }
    }
    
    private func settingRow(title: String, icon: String, color: Color, isAsset: Bool = false) -> some View {
        HStack(spacing: 12) {
            Group {
                if isAsset {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                } else {
                    Image(systemName: icon)
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                }
            }
            .frame(width: 28, height: 28)
            .background(Circle().fill(color))
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.quaternary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
    
    private func debugTimeButton(title: String, hours: Double) -> some View {
        Button {
            gardenStore.simulateTimeJump(hours: hours)
            FeedbackManager.shared.playSuccess()
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.indigo))
        }
    }
}
