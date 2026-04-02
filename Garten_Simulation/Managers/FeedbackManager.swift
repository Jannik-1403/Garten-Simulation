import SwiftUI
import UIKit

/// Central manager for haptic feedback.
/// Respects user settings for 'isHapticEnabled'.
class FeedbackManager {
    static let shared = FeedbackManager()
    
    // Using @AppStorage would be better, but FeedbackManager is not an ObservableObject.
    // We check UserDefaults directly in triggerFeedback.
    
    private init() {}
    
    // MARK: - Generic Feedback
    
    /// Subtle tap for buttons
    func playTap() {
        triggerHaptic(style: .light)
    }
    
    /// Success feedback (e.g., watering complete, purchase successful)
    func playSuccess() {
        triggerHaptic(style: .medium)
    }
    
    /// Level up fanfare strong feedback
    func playLevelUp() {
        triggerHaptic(style: .heavy)
    }
    
    /// Error/Insufficient funds feedback
    func playError() {
        triggerHaptic(style: .rigid)
    }
    
    /// Coin collection feedback
    func playCoins() {
        triggerHaptic(style: .light)
    }
    
    /// Feedback for watering action
    func playWatering() {
        triggerHaptic(style: .soft)
    }
    
    /// Ticking haptic for the wheel of fortune
    func playTick() {
        triggerHaptic(style: .light)
    }

    // MARK: - Private Helpers
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        // Refresh settings from UserDefaults
        // If the key doesn't exist yet, we default to 'true' (matching SettingsStore)
        let hapticOn = UserDefaults.standard.object(forKey: "isHapticEnabled") as? Bool ?? true
        
        if hapticOn {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
    }
}
