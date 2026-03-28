import SwiftUI

struct CoinTransaction: Identifiable {
    let id = UUID()
    let datum: Date
    let beschreibung: String
    let betrag: Int        // positiv = verdient, negativ = ausgegeben
    let icon: String       // SF Symbol
    let farbe: Color
}
