import SwiftUI
import StoreKit

enum CharacterCategory: String, CaseIterable {
    case body = "Körper"
    case hair = "Haare"
    case eyes = "Augen"
    case mouth = "Mund"
    case background = "Hintergrund"
    case extras = "Extras"

    var localizedName: String {
        switch self {
        case .body: return String(localized: "character.category.body", defaultValue: "Körper")
        case .hair: return String(localized: "character.category.hair", defaultValue: "Haare")
        case .eyes: return String(localized: "character.category.eyes", defaultValue: "Augen")
        case .mouth: return String(localized: "character.category.mouth", defaultValue: "Mund")
        case .background: return String(localized: "character.category.background", defaultValue: "Hintergrund")
        case .extras: return String(localized: "character.category.extras", defaultValue: "Extras")
        }
    }
}

struct CharacterCustomizationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var characterStore: CharacterStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @StateObject private var iapStore = IAPStore()
    
    @State private var selectedCategory: CharacterCategory = .body
    @State private var showPurchaseDialog = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // TOP SECTION: Real Character Preview
                    ZStack {
                        Color(UIColor.secondarySystemGroupedBackground)
                            .ignoresSafeArea(edges: .top)
                        Item3DButton(
                            farbe: Color.characterBackground(for: characterStore.profile.backgroundIndex),
                            sekundaerFarbe: Color.secondaryCharacterBackground(for: characterStore.profile.backgroundIndex),
                            groesse: 280,
                            shadowDepthFactor: 0.02,
                            aktion: nil
                        ) {
                            AvatarView(profile: characterStore.profile)
                                .frame(width: 280, height: 280, alignment: .top)
                                .clipShape(Circle())
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                    }
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                    .zIndex(1)
                    
                    // Category Picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(CharacterCategory.allCases, id: \.self) { category in
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedCategory = category
                                    }
                                } label: {
                                    Text(category.localizedName)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            selectedCategory == category 
                                            ? Color.blauPrimary 
                                            : Color(UIColor.secondarySystemGroupedBackground)
                                        )
                                        .foregroundStyle(selectedCategory == category ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(BadgeBounceButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    
                    // BOTTOM SECTION: Selection Options
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            switch selectedCategory {
                            case .body:
                                ForEach(1...6, id: \.self) { index in
                                    OptionButton(
                                        imageName: "Character\(index)",
                                        isSelected: characterStore.profile.bodyIndex == index
                                    ) {
                                        characterStore.profile.bodyIndex = index
                                    }
                                }
                            case .hair:
                                ForEach(1...6, id: \.self) { index in
                                    OptionButton(
                                        imageName: "Hair\(index)",
                                        isSelected: characterStore.profile.hairIndex == index
                                    ) {
                                        characterStore.profile.hairIndex = index
                                    }
                                }
                            case .eyes:
                                ForEach(1...4, id: \.self) { index in
                                    OptionButton(
                                        imageName: "eye\(index)",
                                        isSelected: characterStore.profile.eyeIndex == index
                                    ) {
                                        characterStore.profile.eyeIndex = index
                                    }
                                }
                            case .mouth:
                                ForEach(1...7, id: \.self) { index in
                                    OptionButton(
                                        imageName: "mund\(index)",
                                        isSelected: characterStore.profile.mouthIndex == index
                                    ) {
                                        characterStore.profile.mouthIndex = index
                                    }
                                }
                            case .background:
                                ForEach(1...6, id: \.self) { index in
                                    Item3DButton(
                                        farbe: Color.characterBackground(for: index),
                                        sekundaerFarbe: Color.secondaryCharacterBackground(for: index),
                                        groesse: 80,
                                        shadowDepthFactor: 0.04,
                                        aktion: { characterStore.profile.backgroundIndex = index }
                                    ) {
                                        if characterStore.profile.backgroundIndex == index {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 32, weight: .bold))
                                                .foregroundStyle(.white)
                                        } else {
                                            Color.clear
                                        }
                                    }
                                }
                            case .extras:
                                OptionButton(
                                    imageName: "glasses",
                                    isSelected: characterStore.profile.hasGlasses,
                                    isLocked: !characterStore.unlockedGlasses
                                ) {
                                    if characterStore.unlockedGlasses {
                                        characterStore.profile.hasGlasses.toggle()
                                    } else {
                                        showPurchaseDialog = true
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 40)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle(String(localized: "profile.edit.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text(String(localized: "button.done"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                }
            }
            .sheet(isPresented: $showPurchaseDialog) {
                GlassesPurchaseSheet(iapStore: iapStore)
                    .environmentObject(gardenStore)
                    .environmentObject(characterStore)
                    .environmentObject(settings)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

struct GlassesPurchaseSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var characterStore: CharacterStore
    @EnvironmentObject var settings: SettingsStore
    @ObservedObject var iapStore: IAPStore
    
    var body: some View {
        VStack(spacing: 24) {
            Image("glasses")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100) // Small layout footprint
                .scaleEffect(3.0) // Visually huge without breaking the sheet layout
                .offset(y: 50) // Visually pushed down
                .padding(.bottom, 30) // Just enough padding for the text
            
            Text(String(localized: "glasses.unlock.title"))
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                // Buy with Coins
                Item3DButton(
                    farbe: gardenStore.coins >= 1000 ? Color.orangePrimary : Color.gray,
                    sekundaerFarbe: gardenStore.coins >= 1000 ? Color.orangeSecondary : Color.gray.opacity(0.8),
                    groesse: 56,
                    shadowDepthFactor: 0.08,
                    isRectangular: true,
                    isDisabled: gardenStore.coins < 1000,
                    aktion: {
                        if gardenStore.coins >= 1000 {
                            gardenStore.coinsAbziehen(amount: 1000, beschreibung: String(localized: "glasses.unlock.title"))
                            characterStore.unlockedGlasses = true
                            dismiss()
                        }
                    }
                ) {
                    HStack {
                        Image("coin")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text(String(localized: "glasses.unlock.coins"))
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .font(.headline)
                }
                .disabled(gardenStore.coins < 1000)
                
                // Buy with IAP
                if let product = iapStore.products.first(where: { $0.id == "com.gartenapp.cosmetics.glasses" }) {
                    Item3DButton(
                        farbe: Color.blauPrimary,
                        sekundaerFarbe: Color.blauSecondary,
                        groesse: 56,
                        shadowDepthFactor: 0.08,
                        isRectangular: true,
                        aktion: {
                            Task {
                                await iapStore.purchase(product, gardenStore: gardenStore, characterStore: characterStore)
                                if characterStore.unlockedGlasses {
                                    dismiss()
                                }
                            }
                        }
                    ) {
                        HStack {
                            Text(product.displayPrice)
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .font(.headline)
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .padding(.top, 32)
        .background(Color.appHintergrund.ignoresSafeArea())
    }
}

struct OptionButton: View {
    let imageName: String
    let isSelected: Bool
    var isLocked: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
                
                if isSelected {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.blauPrimary, lineWidth: 3)
                }
                
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding(10)
                
                if isLocked {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.black.opacity(0.4))
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(width: 100, height: 100)
        }
        .buttonStyle(BadgeBounceButtonStyle())
    }
}

