import SwiftUI

struct PfadIgelView: View {
    let day: Int
    let groesse: CGFloat
    
    // Alle verfügbaren Igel-Themen
    private let allIgels = [
        "Igel-Backen", "Igel-Code", "Igel-Duschen", "Igel-Essen", "Igel-Fischen",
        "Igel-Foto", "Igel-Golf", "Igel-Kochen", "Igel-König", "Igel-Lesen",
        "Igel-Malen", "Igel-Meditieren", "Igel-Musik", "Igel-PflanzeGießen",
        "Igel-Schach", "Igel-Schlafen", "Igel-Schlagzeug", "Igel-Schreiben",
        "Igel-Skatboard", "Igel-Sport", "Igel-Surfen", "Igel-Töpfern",
        "Igel-Welttraum", "Igel-Zelten"
    ]
    
    var body: some View {
        let asset = allIgels[abs(day - 1) % allIgels.count]
        
        VStack(spacing: 0) {
            Image(asset)
                .resizable()
                .scaledToFit()
                .frame(width: groesse, height: groesse)
            
            // Shadow
            Ellipse()
                .fill(Color.black.opacity(0.08))
                .frame(width: groesse * 0.6, height: groesse * 0.12)
        }
    }
}
