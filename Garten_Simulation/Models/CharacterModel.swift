import Foundation
import SwiftUI
import Combine

struct CharacterProfile: Codable, Equatable {
    var bodyIndex: Int // 1...6
    var hairIndex: Int // 1...6
    var eyeIndex: Int  // 1...4
    var mouthIndex: Int // 1...7
    var hasGlasses: Bool
    var backgroundIndex: Int // 1...6 (for different colors)
    
    // Default Character
    static let `default` = CharacterProfile(
        bodyIndex: 1,
        hairIndex: 1,
        eyeIndex: 1,
        mouthIndex: 1,
        hasGlasses: false,
        backgroundIndex: 1
    )
    
    enum CodingKeys: String, CodingKey {
        case bodyIndex, hairIndex, eyeIndex, mouthIndex, hasGlasses, backgroundIndex
    }
    
    init(bodyIndex: Int, hairIndex: Int, eyeIndex: Int, mouthIndex: Int, hasGlasses: Bool, backgroundIndex: Int = 1) {
        self.bodyIndex = bodyIndex
        self.hairIndex = hairIndex
        self.eyeIndex = eyeIndex
        self.mouthIndex = mouthIndex
        self.hasGlasses = hasGlasses
        self.backgroundIndex = backgroundIndex
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bodyIndex = try container.decode(Int.self, forKey: .bodyIndex)
        hairIndex = try container.decode(Int.self, forKey: .hairIndex)
        eyeIndex = try container.decode(Int.self, forKey: .eyeIndex)
        mouthIndex = try container.decode(Int.self, forKey: .mouthIndex)
        hasGlasses = try container.decode(Bool.self, forKey: .hasGlasses)
        backgroundIndex = try container.decodeIfPresent(Int.self, forKey: .backgroundIndex) ?? 1
    }
}

class CharacterStore: ObservableObject {
    @Published var profile: CharacterProfile {
        didSet {
            save()
        }
    }
    
    @Published var unlockedGlasses: Bool {
        didSet {
            UserDefaults.standard.set(unlockedGlasses, forKey: "unlockedGlasses")
            // If glasses are locked but the profile somehow has them equipped, unequip them
            if !unlockedGlasses && profile.hasGlasses {
                profile.hasGlasses = false
            }
        }
    }
    
    private let saveKey = "SavedCharacterProfile"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let saved = try? JSONDecoder().decode(CharacterProfile.self, from: data) {
            self.profile = saved
        } else {
            self.profile = .default
        }
        self.unlockedGlasses = UserDefaults.standard.bool(forKey: "unlockedGlasses")
        
        // Ensure state consistency
        if !self.unlockedGlasses && self.profile.hasGlasses {
            self.profile.hasGlasses = false
        }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func reset() {
        self.profile = .default
        self.unlockedGlasses = false
        UserDefaults.standard.removeObject(forKey: saveKey)
        UserDefaults.standard.removeObject(forKey: "unlockedGlasses")
    }
}

extension Color {
    static func characterBackground(for index: Int) -> Color {
        switch index {
        case 1: return Color(UIColor.secondarySystemGroupedBackground) // Standard Light/Dark
        case 2: return Color(red: 0.85, green: 0.92, blue: 1.0) // Light Blue
        case 3: return Color(red: 0.88, green: 0.96, blue: 0.88) // Light Green
        case 4: return Color(red: 1.0, green: 0.9, blue: 0.8) // Light Orange
        case 5: return Color(red: 0.94, green: 0.88, blue: 1.0) // Light Purple
        case 6: return Color(red: 1.0, green: 0.88, blue: 0.92) // Light Pink
        default: return Color(UIColor.secondarySystemGroupedBackground)
        }
    }
    
    static func secondaryCharacterBackground(for index: Int) -> Color {
        switch index {
        case 1: return Color(UIColor.tertiarySystemGroupedBackground) // Darker Standard
        case 2: return Color(red: 0.65, green: 0.72, blue: 0.9) // Darker Blue
        case 3: return Color(red: 0.68, green: 0.76, blue: 0.68) // Darker Green
        case 4: return Color(red: 0.8, green: 0.7, blue: 0.6) // Darker Orange
        case 5: return Color(red: 0.74, green: 0.68, blue: 0.85) // Darker Purple
        case 6: return Color(red: 0.85, green: 0.68, blue: 0.72) // Darker Pink
        default: return Color(UIColor.tertiarySystemGroupedBackground)
        }
    }
}
