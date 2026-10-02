import Foundation
import WidgetKit

extension DailyFeedbackViewModel {
    @MainActor
    static func calculateAndSaveWidgetScore(activeHabits: [HabitModel]) {
        let targetDate = Date()
        let hm = HealthManager.shared
        let wgm = WaterGoalManager.shared
        let nim = NutrientIndexManager.shared
        let store = FeedbackStore.shared

        let strengthDaysAgo: Int?
        if let lastDate = hm.lastStrengthWorkoutDate {
            let days = Calendar.current.dateComponents([.day],
                from: Calendar.current.startOfDay(for: lastDate),
                to: Calendar.current.startOfDay(for: targetDate)).day ?? 999
            strengthDaysAgo = days
        } else {
            strengthDaysAgo = nil
        }

        let worstMineral = nim.minerals
            .filter { $0.isEnabled && $0.targetDGE > 0 }
            .min(by: { $0.score < $1.score })

        var hasWaterPlant = false
        var hasSleepPlant = false
        var hasStrengthPlant = false
        var hasRunningPlant = false
        var hasNutritionPlant = false
        var hasGratitudePlant = false

        var waterPlant: HabitModel?
        var sleepPlant: HabitModel?
        var strengthPlant: HabitModel?
        var runningPlant: HabitModel?
        var fiberPlant: HabitModel?
        var energyPlant: HabitModel?
        var proteinPlant: HabitModel?
        var gratitudePlant: HabitModel?

        for plant in activeHabits {
            let lowerName = plant.name.lowercased()
            let lowerHabitName = plant.habitName.lowercased()
            
            let eff = plant.effectiveHealthMetric
            let link = plant.linkedHealthMetric
            let auto = plant.automaticHealthMetric
            
            if eff == .water || link == .water || auto == .water {
                hasWaterPlant = true
                if waterPlant == nil { waterPlant = plant }
            }
            if eff == .sleep || link == .sleep || auto == .sleep {
                hasSleepPlant = true
                if sleepPlant == nil { sleepPlant = plant }
            }
            if eff == .strengthTraining || link == .strengthTraining || auto == .strengthTraining || lowerName.contains("kraft") {
                hasStrengthPlant = true
                if strengthPlant == nil { strengthPlant = plant }
            }
            if eff == .steps || eff == .running || link == .steps || link == .running || auto == .steps || auto == .running || lowerName.contains("laufen") || lowerName.contains("joggen") || lowerName.contains("schritt") {
                hasRunningPlant = true
                if runningPlant == nil { runningPlant = plant }
            }
            
            let isNutrition = eff == .energy || link == .energy || auto == .energy ||
                              eff == .fiber || link == .fiber || auto == .fiber ||
                              lowerName.contains("gemüse") || lowerName.contains("kochen") || lowerHabitName.contains("koch") ||
                              lowerName.contains("ernährung") || lowerHabitName.contains("ernaehrung") || lowerHabitName.contains("nutrition")
            if isNutrition {
                hasNutritionPlant = true
            }
            if eff == .fiber || link == .fiber || auto == .fiber {
                if fiberPlant == nil { fiberPlant = plant }
            }
            let isEnergy = eff == .energy || link == .energy || auto == .energy || lowerName.contains("kochen") || lowerHabitName.contains("koch") || lowerName.contains("ernährung") || lowerHabitName.contains("ernaehrung") || lowerHabitName.contains("nutrition")
            if isEnergy {
                if energyPlant == nil { energyPlant = plant }
            }
            if lowerName.contains("protein") {
                if proteinPlant == nil { proteinPlant = plant }
            }
            if plant.habitName == "habit.dankbarkeit" {
                hasGratitudePlant = true
                if gratitudePlant == nil { gratitudePlant = plant }
            }
        }

        let proteinGoal = UserDefaults.standard.double(forKey: "goal_protein")
        let strengthGoalMinutes = strengthPlant?.healthTarget ?? 30.0
        let stepsGoal = runningPlant?.healthTarget ?? 10000.0
        let fiberGoal = fiberPlant?.healthTarget ?? 30.0
        
        let gratitudeTodayDone = gratitudePlant?.journalEntries.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: targetDate) }) ?? false
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: targetDate) ?? targetDate
        let gratitudeYesterdayEntry = gratitudePlant?.journalEntries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: yesterday) })

        let energyGoal = energyPlant?.effectiveHealthTarget ?? UserDefaults.standard.double(forKey: "goal_energy")



        let hasSetGoals = UserDefaults.standard.bool(forKey: "has_set_nutrition_goals")
        let isGoalValid = hm.weightGoalType != 0 && hm.weightGoalTargetKg > 0 && hm.weightGoalDateInterval > 0
        let showNutrition = hasSetGoals && isGoalValid
        
        func getManualOrHealth(plant: HabitModel?, healthValue: Double, goal: Double) -> Double {
            guard let p = plant else { return healthValue }
            if p.effectiveHealthMetric == nil {
                let todaysManualProgress = p.intradayProgressHistory
                    .filter { Calendar.current.isDate($0.timestamp, inSameDayAs: targetDate) }
                    .last?.progress ?? 0.0
                return todaysManualProgress * goal
            }
            if !Calendar.current.isDateInToday(targetDate) {
                 let todaysManualProgress = p.intradayProgressHistory
                     .filter { Calendar.current.isDate($0.timestamp, inSameDayAs: targetDate) }
                     .last?.progress ?? 0.0
                 return todaysManualProgress * goal
            }
            return healthValue
        }
        
        let effectiveWater = getManualOrHealth(plant: waterPlant, healthValue: hm.todaysWater, goal: wgm.currentGoal)
        let sleepGoal = UserDefaults.standard.double(forKey: "goal_sleep") > 0 ? UserDefaults.standard.double(forKey: "goal_sleep") : 8.0
        let effectiveSleep = getManualOrHealth(plant: sleepPlant, healthValue: hm.todaysSleep, goal: sleepGoal)
        let effectiveStrength = getManualOrHealth(plant: strengthPlant, healthValue: hm.todaysStrengthTraining, goal: strengthGoalMinutes)
        let effectiveSteps = getManualOrHealth(plant: runningPlant, healthValue: hm.todaysSteps, goal: stepsGoal)
        let effectiveEnergy = getManualOrHealth(plant: energyPlant, healthValue: hm.todaysEnergy, goal: energyGoal > 0 ? energyGoal : 2000.0)
        let effectiveProtein = getManualOrHealth(plant: proteinPlant, healthValue: hm.todaysProtein, goal: proteinGoal > 0 ? proteinGoal : 120.0)
        let effectiveFiber = getManualOrHealth(plant: fiberPlant, healthValue: hm.todaysFiber, goal: fiberGoal)
        
        var effectiveStrengthDaysAgo = strengthDaysAgo
        if let p = strengthPlant, p.effectiveHealthMetric == nil {
            let todaysManualProgress = p.intradayProgressHistory
                .filter { Calendar.current.isDate($0.timestamp, inSameDayAs: targetDate) }
                .last?.progress ?? 0.0
            if todaysManualProgress > 0 {
                effectiveStrengthDaysAgo = 0
            }
        }
        
        let input = FeedbackScoringEngine.EvaluationInput(
            hasWaterPlant: hasWaterPlant,
            hasSleepPlant: hasSleepPlant,
            hasStrengthPlant: hasStrengthPlant,
            hasRunningPlant: hasRunningPlant,
            hasNutritionPlant: hasNutritionPlant,
            hasGratitudePlant: hasGratitudePlant,
            gratitudeTodayDone: gratitudeTodayDone,
            gratitudeYesterdayEntry: gratitudeYesterdayEntry,

            waterToday: effectiveWater,
            waterGoal: wgm.currentGoal,
            waterHistory7Days: hm.waterHistory7Days,
            sleepHoursToday: effectiveSleep,
            sleepGoalHours: sleepGoal,
            sleepRegularity: hm.sleepRegularityPercentage,
            sleepAvgBedtimeString: hm.sleepAvgBedtimeString,
            sleepTargetWakeUpString: hm.sleepTargetWakeUpString,
            strengthDaysAgo: effectiveStrengthDaysAgo,
            hasStrengthHistory: hm.hasAnyWorkoutHistory,
            strengthTodayMinutes: effectiveStrength,
            strengthGoalMinutes: strengthGoalMinutes,
            stepsToday: effectiveSteps,
            stepsGoal: stepsGoal,
            energyToday: (showNutrition || energyPlant?.effectiveHealthMetric == nil) ? effectiveEnergy : 0.0,
            energyGoal: energyGoal > 0 ? energyGoal : 2000.0,
            proteinToday: (showNutrition || proteinPlant?.effectiveHealthMetric == nil) ? effectiveProtein : 0.0,
            proteinGoal: proteinGoal > 0 ? proteinGoal : 120.0,
            fiberToday: effectiveFiber,
            fiberGoal: fiberGoal,
            worstMineralName: worstMineral?.name,
            worstMineralScore: worstMineral?.score ?? 100,
            userFactors: { store.factor(forKey: $0) }
        )

        let feedbacks = FeedbackScoringEngine.evaluateAll(input: input)
        let availableFeedbacks = feedbacks.filter { $0.status != CategoryStatus.unavailable }
        
        var dailyScore = 0
        if !availableFeedbacks.isEmpty {
            let total = availableFeedbacks.reduce(0.0) { sum, fb in
                var scoreForCategory: Double = 0
                if fb.category == FitnessCategory.gratitude {
                    scoreForCategory = fb.status == .good ? 100 : 0
                } else {
                    let progress = fb.progress ?? 0
                    let goal = fb.goal ?? 0
                    let pct = goal > 0 ? (progress / goal) : 0
                    scoreForCategory = min(100.0, pct * 100.0)
                }
                return sum + scoreForCategory
            }
            dailyScore = Int(total / Double(availableFeedbacks.count))
        }

        SharedUserDefaults.suite.set(dailyScore, forKey: "widget_daily_score")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
