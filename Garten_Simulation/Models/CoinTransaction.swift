import SwiftUI

struct CoinTransaction: Identifiable, Codable {
    let id: UUID
    let datum: Date
    let beschreibung: String
    let betrag: Int        // positiv = verdient, negativ = ausgegeben
    let icon: String       // SF Symbol
    let farbeHex: String   // Persistent hex string

    var farbe: Color {
        Color(hex: farbeHex)
    }

    init(id: UUID = UUID(), datum: Date, beschreibung: String, betrag: Int, icon: String, farbeHex: String) {
        self.id = id
        self.datum = datum
        self.beschreibung = beschreibung
        self.betrag = betrag
        self.icon = icon
        self.farbeHex = farbeHex
    }
}
