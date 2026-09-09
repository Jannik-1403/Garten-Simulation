import Foundation
import SwiftUI
import Combine

class WaterGoalManager: ObservableObject {
    static let shared = WaterGoalManager()
    
    @AppStorage("water_custom_min_ml") var customMinGoal: Double = 0.0
    @AppStorage("water_custom_max_ml") var customMaxGoal: Double = 0.0
    
    @Published var currentGoal: Double = 2000.0
    @Published var baseGoal: Double = 2000.0
    @Published var stepBonus: Double = 0.0
    @Published var strengthBonus: Double = 0.0
    @Published var enduranceBonus: Double = 0.0
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Observe changes in HealthManager to recalculate goal
        let hm = HealthManager.shared
        Publishers.CombineLatest4(hm.$latestBodyMass, hm.$todaysSteps, hm.$todaysRunning, hm.$todaysStrengthTraining)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bodyMass, steps, running, strength in
                self?.recalculateGoal(bodyMass: bodyMass, steps: steps, enduranceMinutes: running, strengthMinutes: strength)
            }
            .store(in: &cancellables)
            
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                let hm = HealthManager.shared
                self?.recalculateGoal(bodyMass: hm.latestBodyMass, steps: hm.todaysSteps, enduranceMinutes: hm.todaysRunning, strengthMinutes: hm.todaysStrengthTraining)
            }
            .store(in: &cancellables)
    }
    
    func recalculateGoal(bodyMass: Double?, steps: Double, enduranceMinutes: Double, strengthMinutes: Double) {
        // 1. Base Goal
        let weight = bodyMass ?? 70.0 // Default 70kg if unknown
        baseGoal = weight * 33.0 // 33 ml per kg
        
        // 2. Step Bonus
        // e.g. + 150ml per 1000 steps above 8000
        let stepThreshold = 8000.0
        if steps > stepThreshold {
            let extraSteps = steps - stepThreshold
            stepBonus = (extraSteps / 1000.0) * 150.0
        } else {
            stepBonus = 0.0
        }
        
        // 3. Strength Bonus
        // e.g. + 200ml per 15 minutes of strength training
        strengthBonus = (strengthMinutes / 15.0) * 200.0
        
        // 4. Endurance Bonus
        // e.g. + 400ml per 15 minutes of running/cycling
        enduranceBonus = (enduranceMinutes / 15.0) * 400.0
        
        // Combine
        var rawGoal = baseGoal + stepBonus + strengthBonus + enduranceBonus
        
        // 5. Clamping
        var effectiveMax = 4000.0
        
        // Increase max if heavy endurance workout (e.g. > 45 minutes)
        if enduranceMinutes > 45.0 {
            effectiveMax = min(6000.0, 4000.0 + ((enduranceMinutes - 45.0) / 15.0) * 400.0)
        }
        
        // Apply logic clamps
        rawGoal = max(1500.0, rawGoal)
        rawGoal = min(effectiveMax, rawGoal)
        
        // Apply user custom limits if set (overrides logic)
        if customMinGoal > 0 {
            rawGoal = max(customMinGoal, rawGoal)
        }
        if customMaxGoal > 0 {
            rawGoal = min(customMaxGoal, rawGoal)
        }
        
        currentGoal = rawGoal
    }
}
