import Foundation
import Combine
import SwiftUI


// MARK: - FeedbackStore

@MainActor
class FeedbackStore: ObservableObject {
    static let shared = FeedbackStore()

    // MARK: - Published State
    @Published var ratings: [FeedbackRating] = []
    @Published var todayRating: FeedbackRating? = nil

    // MARK: - Persistence Keys
    private let ratingsKey = "feedback_ratings_v1"
    private let factorsKey = "feedback_factors_v1"

    // MARK: - Factor Korridor
    private let factorMin: Double = 0.8
    private let factorMax: Double = 1.3
    private let factorStep: Double = 0.05
    private let consecutiveDownThreshold = 3

    // MARK: - Init
    private init() {
        load()
        refreshTodayRating()
    }

    // MARK: - Factor für einen Key lesen/schreiben
    func factor(forKey key: String) -> Double {
        let dict = UserDefaults.standard.dictionary(forKey: factorsKey) as? [String: Double] ?? [:]
        return dict[key] ?? 1.0
    }

    private func setFactor(_ value: Double, forKey key: String) {
        var dict = UserDefaults.standard.dictionary(forKey: factorsKey) as? [String: Double] ?? [:]
        dict[key] = min(factorMax, max(factorMin, value))
        UserDefaults.standard.set(dict, forKey: factorsKey)
    }

    // MARK: - Bewertung setzen
    /// Schreibt oder überschreibt die Bewertung für heute. Toggle: erneutes Tippen setzt zurück auf .none.
    func rate(key: String, value: FeedbackRatingValue, contextValues: [String: Int] = [:]) {
        let today = Calendar.current.startOfDay(for: Date())

        if let idx = ratings.firstIndex(where: {
            Calendar.current.isDate($0.date, inSameDayAs: today) && $0.templateKey == key
        }) {
            // Toggle: Selbe Bewertung erneut → zurück auf .none
            if ratings[idx].rating == value {
                ratings[idx].rating = .none
            } else {
                ratings[idx].rating = value
            }
            ratings[idx].ratedAt = Date()
        } else {
            var newRating = FeedbackRating(date: today, templateKey: key, contextValues: contextValues)
            newRating.rating = value
            ratings.insert(newRating, at: 0)
        }

        save()
        refreshTodayRating()

        // Faktor-Regler: Prüfen ob 3x hintereinander "down" für denselben Key
        if value == .down {
            adjustFactorIfNeeded(forKey: key)
        }
    }

    // MARK: - Faktor-Regler
    private func adjustFactorIfNeeded(forKey key: String) {
        // Letzte n Ratings für diesen Key holen
        let keyRatings = ratings
            .filter { $0.templateKey == key }
            .sorted { $0.ratedAt > $1.ratedAt }
            .prefix(consecutiveDownThreshold)

        let allDown = keyRatings.count == consecutiveDownThreshold
            && keyRatings.allSatisfy { $0.rating == .down }

        if allDown {
            let current = factor(forKey: key)
            setFactor(current + factorStep, forKey: key)
        }
    }

    // MARK: - Heutiges Rating refreshen
    func refreshTodayRating() {
        let today = Calendar.current.startOfDay(for: Date())
        todayRating = ratings.first {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }
    }

    /// Gibt die aktuelle Bewertung für einen spezifischen Key zurück (für heute)
    func todayRatingValue(forKey key: String) -> FeedbackRatingValue {
        let today = Calendar.current.startOfDay(for: Date())
        return ratings.first(where: {
            Calendar.current.isDate($0.date, inSameDayAs: today) && $0.templateKey == key
        })?.rating ?? .none
    }

    // MARK: - Persistenz
    private func save() {
        if let data = try? JSONEncoder().encode(ratings) {
            UserDefaults.standard.set(data, forKey: ratingsKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: ratingsKey),
              let decoded = try? JSONDecoder().decode([FeedbackRating].self, from: data) else {
            return
        }
        ratings = decoded
    }
}
