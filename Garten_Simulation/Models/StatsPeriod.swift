import SwiftUI

enum StatsPeriod: String, CaseIterable {
    case day = "Tag"
    case week = "Woche"
    case month = "Monat"
    case year = "Jahr"
    case allTime = "Alle"
    
    var days: Int {
        switch self {
        case .day: return 1
        case .week: return 7
        case .month: return 30
        case .year: return 365
        case .allTime: return 10000
        }
    }
    
    var localizationKey: String {
        switch self {
        case .day: return "statistik_periode_tag"
        case .week: return "statistik_periode_woche"
        case .month: return "statistik_periode_monat"
        case .year: return "statistik_periode_jahr"
        case .allTime: return "statistik_periode_alle"
        }
    }
    
    var thisPeriodKey: String {
        switch self {
        case .day: return "stats.period.today_simple"
        case .week: return "stats.period.this_week_simple"
        case .month: return "stats.period.this_month_simple"
        case .year: return "stats.period.this_year_simple"
        case .allTime: return "stats.period.alltime_simple"
        }
    }
}
