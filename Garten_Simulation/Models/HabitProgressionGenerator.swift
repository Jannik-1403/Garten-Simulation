import Foundation

struct HabitProgression {
    let plantID: String
    let strategy: HabitProgressionStrategy
}

class HabitProgressionGenerator {
    static let progressions: [String: HabitProgression] = [
        // Fitness
        "plant.wildgras": HabitProgression(plantID: "plant.wildgras", strategy: RunningProgressionStrategy()),
        "plant.bambus": HabitProgression(plantID: "plant.bambus", strategy: StrengthProgressionStrategy()),
        "plant.efeu": HabitProgression(plantID: "plant.efeu", strategy: StretchingProgressionStrategy()),
        
        // Mental
        "plant.lotus": HabitProgression(plantID: "plant.lotus", strategy: MeditationProgressionStrategy()),
        "plant.klee": HabitProgression(plantID: "plant.klee", strategy: GratitudeProgressionStrategy()),
        "plant.mystic_seed": HabitProgression(plantID: "plant.mystic_seed", strategy: BreathworkProgressionStrategy()),
        
        // Health
        "plant.zitronenbaum": HabitProgression(plantID: "plant.zitronenbaum", strategy: WaterProgressionStrategy()),
        "plant.erdbeerpflanze": HabitProgression(plantID: "plant.erdbeerpflanze", strategy: NutritionProgressionStrategy()),
        "plant.kaktus": HabitProgression(plantID: "plant.kaktus", strategy: ColdShowerProgressionStrategy()),
        "plant.minzpflanze": HabitProgression(plantID: "plant.minzpflanze", strategy: TeethProgressionStrategy()),
        "plant.weinrebe": HabitProgression(plantID: "plant.weinrebe", strategy: NoAlcoholProgressionStrategy()),
        "plant.apfelbaum": HabitProgression(plantID: "plant.apfelbaum", strategy: CookingProgressionStrategy()),
        
        // Lifestyle
        "plant.weizenfeld": HabitProgression(plantID: "plant.weizenfeld", strategy: DeepWorkProgressionStrategy()),
        "plant.chrysantheme": HabitProgression(plantID: "plant.chrysantheme", strategy: CleaningProgressionStrategy()),
        "plant.mandelbaum": HabitProgression(plantID: "plant.mandelbaum", strategy: SavingProgressionStrategy()),
        "plant.kirschbaum": HabitProgression(plantID: "plant.kirschbaum", strategy: SelfcareProgressionStrategy()),
        "plant.aloe_vera": HabitProgression(plantID: "plant.aloe_vera", strategy: ScreentimeProgressionStrategy()),
        "plant.lavendel": HabitProgression(plantID: "plant.lavendel", strategy: SleepProgressionStrategy()),
        "plant.sonnenblume": HabitProgression(plantID: "plant.sonnenblume", strategy: WakeUpProgressionStrategy())
    ]
    
    static func generateProgression(for plantID: String, dayNum: Int, difficulty: String, language: String) -> ProgressionData? {
        guard let prog = progressions[plantID.lowercased()] else { return nil }
        return prog.strategy.generateProgression(dayNum: dayNum, difficulty: difficulty)
    }
}
