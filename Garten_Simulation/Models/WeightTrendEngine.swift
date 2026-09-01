import Foundation

public struct WeightTrendConfig {
    public var emaAlpha: Double = 0.1
    public var minLogDays: Int = 14
    public var minLogCount: Int = 5
    public var toleranceAbs: Double = 0.1
    public var toleranceRel: Double = 0.3
    public var deviationWeeks: Int = 3
    public var aheadMultiplier: Double = 2.0
    public var plateauThreshold: Double = 0.1
    public var plateauWeeks: Int = 3
    public var goalCloseMargin: Double = 0.5
    public var goalReachedMargin: Double = 0.1
    public var scheduleBufferDays: Int = 7
    public var kcalPerUnit: Double = 7700
    public var kcalRoundTo: Int = 25
    
    public static let shared = WeightTrendConfig()
}

public struct WeightLogEntry {
    public let date: Date
    public let weight: Double
    
    public init(date: Date, weight: Double) {
        self.date = date
        self.weight = weight
    }
}

public struct WeightTrendEntry {
    public let date: Date
    public let raw: Double
    public let trend: Double
}

public struct WeightGoal {
    public let targetWeight: Double
    public let targetDate: Date
    
    public init(targetWeight: Double, targetDate: Date) {
        self.targetWeight = targetWeight
        self.targetDate = targetDate
    }
}

public enum WeightTrendMessage {
    case insufficientData(daysRemaining: Int)
    case trendOnTrack(trendChange: String, unit: String)
    case trendStableWeeklyNoise(trendChange: String, unit: String)
    case calorieDecreaseSuggested(weeks: Int, kcal: Int, targetDate: String)
    case calorieIncreaseSuggested(weeks: Int, kcal: Int, targetDate: String)
    case plateauWarning(weeks: Int)
    case goalClose(remaining: String, goalWeight: String, unit: String)
    case goalReached(goalWeight: String, unit: String)
    case goalDateUnrealistic(goalWeight: String, unit: String, targetDate: String)
    case goalDateAheadOfSchedule(targetDate: String)
    case goalUpdated(goalWeight: String, unit: String, targetDate: String, targetChange: String)
    
    public var localizedText: String {
        switch self {
        case .insufficientData(let days):
            return String(format: String(localized: "insufficient_data", defaultValue: "Noch nicht genügend Daten. Trag dein Gewicht weiter täglich ein – in etwa %@ Tagen kannst du einen verlässlichen Trend sehen."), "\(days)")
        case .trendOnTrack(let change, let unit):
            return String(format: String(localized: "trend_on_track", defaultValue: "Du bist auf Kurs. Dein Trend liegt bei %@ %@/Woche – genau im Rahmen deines Ziels."), change, unit)
        case .trendStableWeeklyNoise(let change, let unit):
            return String(format: String(localized: "trend_stable_weekly_noise", defaultValue: "Der Wert dieser Woche ist eine normale Schwankung (Wasser, Nahrung, Hormone). Dein zugrunde liegender Trend liegt weiterhin bei %@ %@/Woche – keine Anpassung nötig."), change, unit)
        case .calorieDecreaseSuggested(let weeks, let kcal, let targetDate):
            return String(format: String(localized: "calorie_decrease_suggested", defaultValue: "Basierend auf deinem Trend der letzten %@ Wochen empfehlen wir, deine täglichen Kalorien um etwa %@ kcal zu senken, um dein Ziel bis %@ zu erreichen."), "\(weeks)", "\(kcal)", targetDate)
        case .calorieIncreaseSuggested(let weeks, let kcal, let targetDate):
            return String(format: String(localized: "calorie_increase_suggested", defaultValue: "Basierend auf deinem Trend der letzten %@ Wochen empfehlen wir, deine täglichen Kalorien um etwa %@ kcal zu erhöhen, um dein Ziel bis %@ zu erreichen."), "\(weeks)", "\(kcal)", targetDate)
        case .plateauWarning(let weeks):
            return String(format: String(localized: "plateau_warning", defaultValue: "Dein Trend hat sich in den letzten %@ Wochen kaum verändert. Das kann passieren, auch wenn du alles richtig machst – hält es an, schlagen wir bald eine Kalorienanpassung vor."), "\(weeks)")
        case .goalClose(let remaining, let goalWeight, let unit):
            return String(format: String(localized: "goal_close", defaultValue: "Fast geschafft – nur noch %@ %@ bis zu deinem Ziel von %@ %@."), remaining, unit, goalWeight) // Note: original json has %1$@ %2$@ for remaining/unit and %3$@ %2$@ for goal/unit. So passing remaining, unit, goal.
        case .goalReached(let goalWeight, let unit):
            return String(format: String(localized: "goal_reached", defaultValue: "Du hast dein Zielgewicht von %@ %@ erreicht! 🎉"), goalWeight, unit)
        case .goalDateUnrealistic(let goalWeight, let unit, let targetDate):
            return String(format: String(localized: "goal_date_unrealistic", defaultValue: "Bei deinem aktuellen Trend ist es unwahrscheinlich, dass du %@ %@ bis %@ erreichst. Passe dein Zieldatum oder deine täglichen Kalorien an."), goalWeight, unit, targetDate)
        case .goalDateAheadOfSchedule(let targetDate):
            return String(format: String(localized: "goal_date_ahead_of_schedule", defaultValue: "Du liegst vor dem Zeitplan – bei diesem Tempo könntest du dein Ziel schon vor dem %@ erreichen."), targetDate)
        case .goalUpdated(let goalWeight, let unit, let targetDate, let targetChange):
            return String(format: String(localized: "goal_updated", defaultValue: "Ziel aktualisiert: %@ %@ bis %@ (Zieltempo: %@ %@/Woche)."), goalWeight, unit, targetDate, targetChange)
        }
    }
}

public struct WeightTrendEngine {
    
    public static func calculateTrend(logs: [WeightLogEntry], config: WeightTrendConfig = .shared) -> [WeightTrendEntry] {
        var trend = [WeightTrendEntry]()
        var prev: Double? = nil
        
        let sortedLogs = logs.sorted { $0.date < $1.date }
        
        for log in sortedLogs {
            if let p = prev {
                prev = p + config.emaAlpha * (log.weight - p)
            } else {
                prev = log.weight
            }
            trend.append(WeightTrendEntry(date: log.date, raw: log.weight, trend: round(prev ?? 0, toPlaces: 2)))
        }
        return trend
    }
    
    public static func getWeeklyTrendChange(trendSeries: [WeightTrendEntry], asOfDate: Date) -> Double? {
        guard let today = findOnOrBefore(series: trendSeries, date: asOfDate),
              let weekAgo = findOnOrBefore(series: trendSeries, date: addDays(asOfDate, days: -7)) else {
            return nil
        }
        return round(today.trend - weekAgo.trend, toPlaces: 3)
    }
    
    public static func getRequiredWeeklyRate(currentTrendWeight: Double, goal: WeightGoal, today: Date) -> Double {
        let weeksRemaining = max(Double(daysBetween(today, goal.targetDate)) / 7.0, 0.01)
        return round((goal.targetWeight - currentTrendWeight) / weeksRemaining, toPlaces: 3)
    }
    
    public static func estimateCalorieAdjustment(gapPerWeek: Double, config: WeightTrendConfig = .shared) -> Int {
        let dailyKcal = (abs(gapPerWeek) * config.kcalPerUnit) / 7.0
        return Int(Foundation.round(dailyKcal / Double(config.kcalRoundTo))) * config.kcalRoundTo
    }
    
    public static func selectMessage(logs: [WeightLogEntry], goal: WeightGoal, today: Date, unit: String, recentWeeklyChanges: [Double], config: WeightTrendConfig = .shared) -> WeightTrendMessage {
        
        let window = countDaysInWindow(logs: logs, today: today, windowDays: config.minLogDays)
        if window.count < config.minLogCount || window.span < config.minLogDays {
            let remaining = max(config.minLogDays - window.span, 1)
            return .insufficientData(daysRemaining: remaining)
        }
        
        let trendSeries = calculateTrend(logs: logs, config: config)
        guard let currentTrend = trendSeries.last?.trend else {
            return .insufficientData(daysRemaining: config.minLogDays)
        }
        
        let weeklyChange = getWeeklyTrendChange(trendSeries: trendSeries, asOfDate: today) ?? 0.0
        let distanceToGoal = abs(currentTrend - goal.targetWeight)
        
        // Formatters
        let fmtWeight = { (val: Double) -> String in
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.maximumFractionDigits = 1
            f.minimumFractionDigits = 1
            return f.string(from: NSNumber(value: val)) ?? "\(val)"
        }
        
        let fmtChange = { (val: Double) -> String in
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.maximumFractionDigits = 2
            f.minimumFractionDigits = 1
            f.positivePrefix = "+"
            return f.string(from: NSNumber(value: val)) ?? "\(val)"
        }
        
        let fmtDate = { (val: Date) -> String in
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .none
            return df.string(from: val)
        }
        
        if distanceToGoal <= config.goalReachedMargin {
            return .goalReached(goalWeight: fmtWeight(goal.targetWeight), unit: unit)
        }
        
        if distanceToGoal <= config.goalCloseMargin {
            return .goalClose(remaining: fmtWeight(distanceToGoal), goalWeight: fmtWeight(goal.targetWeight), unit: unit)
        }
        
        let requiredRate = getRequiredWeeklyRate(currentTrendWeight: currentTrend, goal: goal, today: today)
        let daysToTarget = daysBetween(today, goal.targetDate)
        let remainingDelta = goal.targetWeight - currentTrend
        
        let progressing = (weeklyChange != 0) && (sign(weeklyChange) == sign(remainingDelta))
        let projectedDays = progressing ? (remainingDelta / weeklyChange) * 7.0 : .infinity
        
        if projectedDays - Double(daysToTarget) > Double(config.scheduleBufferDays) {
            return .goalDateUnrealistic(goalWeight: fmtWeight(goal.targetWeight), unit: unit, targetDate: fmtDate(goal.targetDate))
        }
        
        let isMaintainGoal = abs(requiredRate) <= config.plateauThreshold
        if !isMaintainGoal && recentWeeklyChanges.count >= config.plateauWeeks {
            let recent = recentWeeklyChanges.suffix(config.plateauWeeks)
            if recent.allSatisfy({ abs($0) <= config.plateauThreshold }) {
                return .plateauWarning(weeks: config.plateauWeeks)
            }
        }
        
        let tolerance = max(config.toleranceAbs, abs(requiredRate) * config.toleranceRel)
        let gap = weeklyChange - requiredRate
        
        if abs(gap) <= tolerance {
            return .trendOnTrack(trendChange: fmtChange(weeklyChange), unit: unit)
        }
        
        var sustained = false
        if recentWeeklyChanges.count >= config.deviationWeeks {
            let recent = recentWeeklyChanges.suffix(config.deviationWeeks)
            sustained = recent.allSatisfy { w in
                let g = w - requiredRate
                return sign(g) == sign(gap) && abs(g) > tolerance
            }
        }
        
        if !sustained {
            return .trendStableWeeklyNoise(trendChange: fmtChange(weeklyChange), unit: unit)
        }
        
        if gap < 0 && abs(gap) <= tolerance * config.aheadMultiplier {
            return .goalDateAheadOfSchedule(targetDate: fmtDate(goal.targetDate))
        }
        
        let kcal = estimateCalorieAdjustment(gapPerWeek: gap, config: config)
        if gap > 0 {
            return .calorieDecreaseSuggested(weeks: config.deviationWeeks, kcal: kcal, targetDate: fmtDate(goal.targetDate))
        } else {
            return .calorieIncreaseSuggested(weeks: config.deviationWeeks, kcal: kcal, targetDate: fmtDate(goal.targetDate))
        }
    }
    
    // MARK: - Helpers
    
    private static func round(_ n: Double, toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Foundation.round(n * divisor) / divisor
    }
    
    private static func sign(_ x: Double) -> Double {
        if x < 0 { return -1 }
        if x > 0 { return 1 }
        return 0
    }
    
    private static func addDays(_ date: Date, days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: date) ?? date
    }
    
    private static func daysBetween(_ a: Date, _ b: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: a), to: Calendar.current.startOfDay(for: b))
        return components.day ?? 0
    }
    
    private static func findOnOrBefore(series: [WeightTrendEntry], date: Date) -> WeightTrendEntry? {
        let target = Calendar.current.startOfDay(for: date).timeIntervalSince1970 + 86400
        var match: WeightTrendEntry? = nil
        for point in series {
            if point.date.timeIntervalSince1970 < target {
                match = point
            } else {
                break
            }
        }
        return match
    }
    
    private static func countDaysInWindow(logs: [WeightLogEntry], today: Date, windowDays: Int) -> (count: Int, span: Int) {
        let start = addDays(today, days: -windowDays)
        let inWindow = logs.filter { $0.date >= start && $0.date <= today }
        if inWindow.isEmpty { return (0, 0) }
        
        let span = daysBetween(inWindow.first!.date, today)
        return (inWindow.count, span)
    }
}
