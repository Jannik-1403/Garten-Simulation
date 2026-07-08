import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var iapStore: IAPStore
    @Environment(\.dismiss) var dismiss

    
    @State private var selectedProductId: String = "com.gartenapp.pro.yearly"

    var monthlyProduct: Product? {
        iapStore.products.first(where: { $0.id == "com.gartenapp.pro.monthly" })
    }
    
    var yearlyProduct: Product? {
        iapStore.products.first(where: { $0.id == "com.gartenapp.pro.yearly" })
    }
    
    var lifetimeProduct: Product? {
        iapStore.products.first(where: { $0.id == "com.gartenapp.pro.lifetime" })
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Premium Dark Mode Background
            Color(red: 0.05, green: 0.05, blue: 0.08)
                .ignoresSafeArea()
            
            // Subtle ambient glows
            Circle()
                .fill(Color.orangePrimary.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: -100, y: -200)
            
            Circle()
                .fill(Color.blauPrimary.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: 100, y: 200)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header Icon
                    Image("ProFeature")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .padding(.top, 40)
                        .padding(.bottom, -15)


                    
                    // Title
                    VStack(spacing: 8) {
                        Text(String(localized: "paywall.title", defaultValue: "Grovy Pro"))
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text(String(localized: "paywall.subtitle", defaultValue: "Schalte das volle Potenzial deines Gartens frei."))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    // Feature List
                    VStack(alignment: .leading, spacing: 24) {
                        featureRow(
                            icon: "heart.text.square.fill",
                            title: String(localized: "paywall.feature.health.title", defaultValue: "Dein täglicher Rhythmus"),
                            description: String(localized: "paywall.feature.health.desc", defaultValue: "Verbinde deine Bewegung mit deinem Fokus. Dein Körper und dein Geist wachsen synchron."),
                            color: .red
                        )
                        
                        featureRow(
                            icon: "calendar.badge.plus",
                            title: String(localized: "paywall.feature.calendar.title", defaultValue: "Kalender Synchronisation"),
                            description: String(localized: "paywall.feature.calendar.desc", defaultValue: "Synchronisiere deine Gewohnheiten und Timer direkt mit deinem Apple Kalender."),
                            color: .goldPrimary
                        )
                        
                        featureRow(
                            icon: "chart.bar.doc.horizontal.fill",
                            title: String(localized: "paywall.feature.weekly_report.title", defaultValue: "Erkenne deine Muster"),
                            description: String(localized: "paywall.feature.weekly_report.desc", defaultValue: "Lerne dich selbst besser kennen. Entdecke, wann du am produktivsten bist und feiere deinen Fortschritt."),
                            color: .blauPrimary
                        )
                        
                        featureRow(
                            icon: "waveform.circle.fill",
                            title: String(localized: "paywall.feature.focus_sounds.title", defaultValue: "Tiefste Konzentration"),
                            description: String(localized: "paywall.feature.focus_sounds.desc", defaultValue: "Blend den Alltag aus. Wissenschaftlich fundierte Klänge bringen dein Gehirn sofort in den Flow-State."),
                            color: .green
                        )

                        featureRow(
                            icon: "tag.fill",
                            title: String(localized: "paywall.feature.shop_discount.title", defaultValue: "Belohne dich schneller"),
                            description: String(localized: "paywall.feature.shop_discount.desc", defaultValue: "Hol dir doppelt so schnell neue Pflanzen. Dein Erfolg wird direkt sichtbar belohnt (400 statt 800 Münzen)."),
                            color: .orange
                        )
                        
                        featureRow(
                            icon: "arrow.up.circle.fill",
                            title: String(localized: "paywall.feature.coin_bonus.title", defaultValue: "+25% Münz-Bonus"),
                            description: String(localized: "paywall.feature.coin_bonus.desc", defaultValue: "Verdiene bei jedem Gießen und Erledigen von Aufgaben 25% mehr Münzen, um deinen Garten schneller wachsen zu lassen."),
                            color: .yellow
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    Spacer(minLength: 40)
                    
                    // Purchase Button Area
                    VStack(spacing: 16) {
                        if iapStore.isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else if monthlyProduct != nil || yearlyProduct != nil || lifetimeProduct != nil {
                            // Options
                            VStack(spacing: 12) {
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
                            .padding(.bottom, 8)
                            
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
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.5))
                            
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
            selectedProductId = product.id
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(isSelected ? .black : .white)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(isSelected ? .black.opacity(0.7) : .white.opacity(0.7))
                }
                Spacer()
                Text(product.displayPrice)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(isSelected ? .black : .white)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.white : Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.goldPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private func featureRow(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
                .frame(width: 32, alignment: .center)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
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
                .background(Color.blue.opacity(0.3))
                .foregroundStyle(.blue)
                .clipShape(Capsule())
        }
        .padding(.top, 16)
    }
}
