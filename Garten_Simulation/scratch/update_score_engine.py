import re

file_engine = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Models/FeedbackScoringEngine.swift'
with open(file_engine, 'r') as f:
    engine = f.read()

# 1. FitnessCategory enum
engine = engine.replace('    case nutrition', '    case nutrition\n    case gratitude')
engine = engine.replace('        case .nutrition: return "fork.knife"', '        case .nutrition: return "fork.knife"\n        case .gratitude: return "book.fill"')

# 2. EvaluationInput
old_input = """        var hasNutritionPlant: Bool

        var waterToday: Double"""
new_input = """        var hasNutritionPlant: Bool
        var hasGratitudePlant: Bool
        var gratitudeTodayDone: Bool
        var gratitudeYesterdayEntry: GratitudeJournalEntry?

        var waterToday: Double"""
engine = engine.replace(old_input, new_input)

# 3. evaluateAll logic
old_return = """        return results
    }"""
new_logic = """        // MARK: Dankbarkeit (Journal)
        if input.hasGratitudePlant {
            let gratStatus: CategoryStatus = input.gratitudeTodayDone ? .good : .warning
            
            let gratSummary = input.gratitudeTodayDone
                ? String(localized: "fitness.gratitude.summary.good", defaultValue: "Journal ✓")
                : String(localized: "fitness.gratitude.summary.missing", defaultValue: "Journal fehlt")
                
            var gratDetail: String = ""
            
            if input.gratitudeTodayDone {
                gratDetail = String(localized: "fitness.gratitude.detail.good", defaultValue: "Klasse, du hast dir heute schon Zeit für dein Journal genommen!")
            } else {
                if let yest = input.gratitudeYesterdayEntry {
                    if !yest.improveTomorrow.isEmpty {
                        gratDetail = String(format: String(localized: "fitness.gratitude.detail.yesterday.improve", defaultValue: "Heute wolltest du laut gestern das hier besser machen: %@"), yest.improveTomorrow)
                    } else {
                        if yest.mood <= 2 {
                            gratDetail = String(localized: "fitness.gratitude.detail.yesterday.low", defaultValue: "Gestern hast du dich nicht so gut gefühlt. Probier heute dich besser zu fühlen oder gestalte deinen Tag so, dass du dich besser fühlst.")
                        } else if yest.mood >= 4 {
                            gratDetail = String(localized: "fitness.gratitude.detail.yesterday.high", defaultValue: "Gestern hast du dich exzellent gefühlt, mach heute weiter so!")
                        } else {
                            gratDetail = String(localized: "fitness.gratitude.detail.yesterday.medium", defaultValue: "Nutze dein Journal, um deinen Tag zu reflektieren.")
                        }
                    }
                } else {
                    gratDetail = String(localized: "fitness.gratitude.detail.not_done", defaultValue: "Du hast heute noch kein Journal geschrieben. Halte kurz inne und reflektiere deinen Tag.")
                }
            }
            
            results.append(CategoryFeedback(category: .gratitude, status: gratStatus, summaryText: gratSummary, detailText: gratDetail, progress: input.gratitudeTodayDone ? 1.0 : 0.0, goal: 1.0))
        }

        return results
    }"""
engine = engine.replace(old_return, new_logic)

# 4. localizedCategoryName
engine = engine.replace('        case .nutrition: return String(localized: "fitness.category.nutrition", defaultValue: "Ernährung")', '        case .nutrition: return String(localized: "fitness.category.nutrition", defaultValue: "Ernährung")\n        case .gratitude: return String(localized: "fitness.category.gratitude", defaultValue: "Dankbarkeits-Check")')

with open(file_engine, 'w') as f:
    f.write(engine)

# Update DailyFeedbackViewModel.swift
file_vm = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/ViewModels/DailyFeedbackViewModel.swift'
with open(file_vm, 'r') as f:
    vm = f.read()

# Add extraction logic
old_input_prep = """        let nutritionPlant = activeHabits.first(where: { plant in"""
new_input_prep = """        let gratitudePlant = activeHabits.first(where: { $0.habitName == "habit.dankbarkeit" })
        let hasGratitudePlant = gratitudePlant != nil
        let gratitudeTodayDone = gratitudePlant?.journalEntries.contains(where: { Calendar.current.isDateInToday($0.date) }) ?? false
        let gratitudeYesterdayEntry = gratitudePlant?.journalEntries.first(where: { Calendar.current.isDateInYesterday($0.date) })

        let nutritionPlant = activeHabits.first(where: { plant in"""
vm = vm.replace(old_input_prep, new_input_prep)

# Add to EvaluationInput init
old_init = """            hasNutritionPlant: hasNutritionPlant,
            waterToday: hm.todaysWater,"""
new_init = """            hasNutritionPlant: hasNutritionPlant,
            hasGratitudePlant: hasGratitudePlant,
            gratitudeTodayDone: gratitudeTodayDone,
            gratitudeYesterdayEntry: gratitudeYesterdayEntry,
            waterToday: hm.todaysWater,"""
vm = vm.replace(old_init, new_init)

with open(file_vm, 'w') as f:
    f.write(vm)

# Update DailyFeedbackDetailView.swift
file_view = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Views/WaterTracker/DailyFeedbackView.swift'
with open(file_view, 'r') as f:
    view_content = f.read()

view_content = view_content.replace('        case .nutrition: return String(localized: "tagesanalyseHeaderErnaehrung", defaultValue: "Ernährungsanalyse")', '        case .nutrition: return String(localized: "tagesanalyseHeaderErnaehrung", defaultValue: "Ernährungsanalyse")\n        case .gratitude: return String(localized: "tagesanalyseHeaderDankbarkeit", defaultValue: "Dankbarkeits-Check")')

with open(file_view, 'w') as f:
    f.write(view_content)

print("Score engine updated.")
