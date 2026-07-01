import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var iapStore: IAPStore
    @Environment(\.dismiss) var dismiss

    
    var proProduct: Product? {
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
                        .frame(width: 120, height: 120)
                        .padding(.top, 40)

                    
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
                            title: String(localized: "paywall.feature.health.title", defaultValue: "Apple Health Sync"),
                            description: String(localized: "paywall.feature.health.desc", defaultValue: "Verknüpfe deine Schritte und Wasserziele direkt mit dem Garten."),
                            color: .red
                        )
                        
                        featureRow(
                            icon: "calendar.badge.plus",
                            title: String(localized: "paywall.feature.calendar.title", defaultValue: "Kalender Synchronisation"),
                            description: String(localized: "paywall.feature.calendar.desc", defaultValue: "Synchronisiere deine Gewohnheiten und Timer direkt mit deinem Apple Kalender."),
                            color: .goldPrimary
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
                        } else if let product = proProduct {
                            Button {
                                Task {
                                    // Dummy CharacterStore since Paywall doesn't need to pass one for Pro
                                    await iapStore.purchase(product, gardenStore: GardenStore())
                                    if iapStore.isProUser {
                                        dismiss()
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(String(localized: "paywall.button.unlock", defaultValue: "Jetzt Freischalten"))
                                        .font(.system(size: 18, weight: .black, design: .rounded))
                                    Spacer()
                                    Text(product.displayPrice)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .opacity(0.9)
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: [Color.goldPrimary, Color.orangePrimary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .shadow(color: Color.goldPrimary.opacity(0.3), radius: 15, y: 8)
                            }
                            .padding(.horizontal, 24)
                            
                            Text(String(localized: "paywall.description.lifetime", defaultValue: "Einmalzahlung. Lifetime Zugriff."))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.5))
                            
                        } else {
                            Text(String(localized: "paywall.loading", defaultValue: "Lade Produkte..."))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.5))
                            
                            #if DEBUG
                            Button {
                                iapStore.isProUser = true
                                UserDefaults.standard.set(true, forKey: "debug_isProUser")
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
}
