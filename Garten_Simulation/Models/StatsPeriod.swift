import SwiftUI

enum StatsPeriod: String, CaseIterable {
    case week = "Woche"
    case month = "Monat"
    case year = "Jahr"
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }
    
    var localizationKey: String {
        switch self {
        case .week: return "statistik_periode_woche"
        case .month: return "statistik_periode_monat"
        case .year: return "statistik_periode_jahr"
        }
    }
    
    var thisPeriodKey: String {
        switch self {
        case .week: return "stats.period.this_week_simple"
        case .month: return "stats.period.this_month_simple"
        case .year: return "stats.period.this_year_simple"
        }
    }
}
