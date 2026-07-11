import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var iapStore: IAPStore
    @Environment(\.dismiss) var dismiss

    @State private var selectedProductId: String = "com.jannik.grovy.pro.yearly"

    var monthlyProduct: Product? {
        if iapStore.isProUser && iapStore.activeProSubscriptionID != nil { return nil }
        return iapStore.products.first(where: { $0.id == "com.jannik.grovy.pro.monthly" })
    }
    
    var yearlyProduct: Product? {
        if iapStore.isProUser && (iapStore.activeProSubscriptionID == "com.jannik.grovy.pro.yearly" || iapStore.activeProSubscriptionID == "com.jannik.grovy.pro.lifetime") { return nil }
        return iapStore.products.first(where: { $0.id == "com.jannik.grovy.pro.yearly" })
    }
    
    var lifetimeProduct: Product? {
        if iapStore.isProUser && iapStore.activeProSubscriptionID == "com.jannik.grovy.pro.lifetime" { return nil }
        return iapStore.products.first(where: { $0.id == "com.jannik.grovy.pro.lifetime" })
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Bright Background
                Color.appHintergrund
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Header Icon
                        Image("ProFeature")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .scaleEffect(2.0)
                            .padding(.top, 60)
                            .padding(.bottom, -60)

                        // Title
                        VStack(spacing: 8) {
                            Text(String(localized: "paywall.title", defaultValue: "Grovy Pro"))
                                .font(.system(size: 38, weight: .black, design: .rounded))
                                .foregroundStyle(Color.primary)
                            
                            Text(String(localized: "paywall.subtitle", defaultValue: "Schalte das volle Potenzial deines Gartens frei."))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        
                        // Feature Cards
                        VStack(spacing: 16) {
                            featureRow(
                                icon: "ProIconHealth",
                                title: String(localized: "paywall.feature.health.title", defaultValue: "Apple Health Integration"),
                                bullets: [
                                    String(localized: "paywall.feature.health.bullet1", defaultValue: "Verbinde deine Bewegung direkt mit deinem Fokus."),
                                    String(localized: "paywall.feature.health.bullet2", defaultValue: "Schließe Ringe und schalte extra Belohnungen frei."),
                                    String(localized: "paywall.feature.health.bullet3", defaultValue: "Körper und Geist wachsen synchron.")
                                ],
                                color: .red
                            )
                            
                            featureRow(
                                icon: "ProIconCalendar",
                                title: String(localized: "paywall.feature.calendar.title", defaultValue: "Apple Kalender Sync"),
                                bullets: [
                                    String(localized: "paywall.feature.calendar.bullet1", defaultValue: "Blockt Fokus-Zeiten automatisch in deinem Kalender."),
                                    String(localized: "paywall.feature.calendar.bullet2", defaultValue: "Vermeidet Doppelbuchungen & schützt deine Zeit."),
                                    String(localized: "paywall.feature.calendar.bullet3", defaultValue: "Voller Überblick über deine Tagesplanung.")
                                ],
                                color: .goldPrimary
                            )
                            
                            featureRow(
                                icon: "ProIconAnalytics",
                                title: String(localized: "paywall.feature.weekly_report.title", defaultValue: "Detaillierte Analysen"),
                                bullets: [
                                    String(localized: "paywall.feature.weekly_report.bullet1", defaultValue: "Erkenne, an welchen Tagen du am produktivsten bist."),
                                    String(localized: "paywall.feature.weekly_report.bullet2", defaultValue: "Verfolge deinen Fortschritt mit interaktiven Graphen."),
                                    String(localized: "paywall.feature.weekly_report.bullet3", defaultValue: "Optimiere deine Arbeitsweise anhand deiner Daten.")
                                ],
                                color: .blauPrimary,
                                scale: 2.3
                            )
                            
                            featureRow(
                                icon: "ProIconSounds",
                                title: String(localized: "paywall.feature.focus_sounds.title", defaultValue: "Premium Fokus-Klänge"),
                                bullets: [
                                    String(localized: "paywall.feature.focus_sounds.bullet1", defaultValue: "Zugriff auf alle wissenschaftlich fundierten Sounds."),
                                    String(localized: "paywall.feature.focus_sounds.bullet2", defaultValue: "Bringe dein Gehirn schneller in den Flow-Zustand."),
                                    String(localized: "paywall.feature.focus_sounds.bullet3", defaultValue: "Blende störende Hintergrundgeräusche effektiv aus.")
                                ],
                                color: .green
                            )

                            featureRow(
                                icon: "ProIconGardener",
                                title: String(localized: "paywall.feature.pro_gardener.title", defaultValue: "Pro-Gärtner Vorteile"),
                                bullets: [
                                    String(localized: "paywall.feature.pro_gardener.bullet1", defaultValue: "Alle Pflanzen kosten dauerhaft 50% weniger Münzen."),
                                    String(localized: "paywall.feature.pro_gardener.bullet2", defaultValue: "Erhalte 25% mehr Münzen für jeden Timer & Aufgabe."),
                                    String(localized: "paywall.feature.pro_gardener.bullet3", defaultValue: "Schalte seltene Dekorationen viel schneller frei.")
                                ],
                                color: .orange
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        
                        Spacer(minLength: 24)
                        
                        // Purchase Button Area
                        VStack(spacing: 16) {
                            if iapStore.isPurchasing {
                                ProgressView()
                                    .scaleEffect(1.2)
                            } else if monthlyProduct != nil || yearlyProduct != nil || lifetimeProduct != nil {
                                // Options
                                VStack(spacing: 16) {
                                    if let yearly = yearlyProduct {
                                        paywallOptionRow(
                                            product: yearly,
                                            title: String(localized: "paywall.option.yearly", defaultValue: "Jährlich"),
                                            subtitle: String(localized: "paywall.option.yearly.desc", defaultValue: "Am beliebtesten"),
                                            isSelected: selectedProductId == yearly.id
                                        )
                                    }
                                    if let monthly = monthlyProduct {
                                        paywallOptionRow(
                                            product: monthly,
                                            title: String(localized: "paywall.option.monthly", defaultValue: "Monatlich"),
                                            subtitle: String(localized: "paywall.option.monthly.desc", defaultValue: "Jederzeit kündbar"),
                                            isSelected: selectedProductId == monthly.id
                                        )
                                    }
                                    if let lifetime = lifetimeProduct {
                                        paywallOptionRow(
                                            product: lifetime,
                                            title: String(localized: "paywall.option.lifetime", defaultValue: "Lifetime"),
                                            subtitle: String(localized: "paywall.option.lifetime.desc", defaultValue: "Einmalzahlung"),
                                            isSelected: selectedProductId == lifetime.id
                                        )
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 12)
                                
                                Button {
                                    if let selected = iapStore.products.first(where: { $0.id == selectedProductId }) {
                                        Task {
                                            await iapStore.purchase(selected, gardenStore: GardenStore())
                                            if iapStore.isProUser {
                                                dismiss()
                                            }
                                        }
                                    }
                                } label: {
                                    Text(String(localized: "paywall.button.unlock", defaultValue: "Jetzt freischalten"))
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .buttonStyle(
                                    DuolingoButtonStyle(
                                        size: .large,
                                        fillWidth: true,
                                        backgroundColor: Color.goldPrimary,
                                        shadowColor: Color.goldPrimary.darker(),
                                        foregroundColor: .white
                                    )
                                )
                                .padding(.horizontal, 24)
                                
                            } else {
                                Text(String(localized: "paywall.loading", defaultValue: "Lade Produkte..."))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color.secondary)
                                
                                #if DEBUG
                                debugUnlockButton
                                #else
                                #if targetEnvironment(simulator)
                                debugUnlockButton
                                #endif
                                #endif
                            }
                        }

                    }
                    .padding(.bottom, 60)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    LiquidGlassDismissButton {
                        dismiss()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                if !iapStore.hasLoaded {
                    Task { await iapStore.loadProducts() }
                }
            }
        }
    }

    private func paywallOptionRow(product: Product, title: String, subtitle: String, isSelected: Bool) -> some View {
        Button {
            let impactLight = UIImpactFeedbackGenerator(style: .soft)
            impactLight.impactOccurred(intensity: 0.8)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                selectedProductId = product.id
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(isSelected ? .white : Color.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(isSelected ? .white.opacity(0.9) : Color.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(isSelected ? Color.white.opacity(0.2) : Color.gray.opacity(0.1))
                        )
                }
                Spacer()
                Text(product.displayPrice)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(isSelected ? .white : Color.primary)
            }
            .padding(20)
        }
        .buttonStyle(PaywallOptionButtonStyle(isSelected: isSelected))
    }

    private func featureRow(icon: String, title: String, bullets: [String], color: Color, scale: CGFloat = 2.0) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .scaleEffect(scale)
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(Color.primary)
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(bullets, id: \.self) { bullet in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(color)
                            Text(bullet)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(UIColor.systemGray4))
                    .offset(y: 5)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color(UIColor.systemGray5), lineWidth: 2)
                    )
            }
        )
        .padding(.bottom, 5)
    }
    
    @ViewBuilder
    private var debugUnlockButton: some View {
        Button {
            iapStore.isProUser = true
            UserDefaults.standard.set(true, forKey: "debug_isProUser")
            UserDefaults.standard.set(true, forKey: "isProUser_active")
            UserDefaults.standard.synchronize()
            dismiss()
        } label: {
            Text(String(localized: "paywall.button.debug", defaultValue: "DEBUG: Pro Freischalten"))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue.opacity(0.1))
                .foregroundStyle(.blue)
                .clipShape(Capsule())
        }
        .padding(.top, 16)
    }
}

struct PaywallOptionButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        let mainColor = isSelected ? Color.goldPrimary : Color(UIColor.systemBackground)
        let shadowColor = isSelected ? Color.goldPrimary.darker() : Color(UIColor.systemGray4)
        let strokeColor = isSelected ? Color.white.opacity(0.3) : Color(UIColor.systemGray5)
        
        ZStack {
            // Shadow / Base layer
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(shadowColor)
                .offset(y: 6)
            
            // Top layer
            configuration.label
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(mainColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(strokeColor, lineWidth: 2)
                )
                .offset(y: isPressed ? 6 : 0)
        }
        .padding(.bottom, 6)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
    }
}
