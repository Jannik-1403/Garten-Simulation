import SwiftUI

struct PlantIconView: View {
    let plant: Plant
    let seltenheit: PflanzenSeltenheit
    var size: CGFloat = 40
    var alwaysShowFullGrown: Bool = false

    var body: some View {
        Group {
            if alwaysShowFullGrown {
                // Shop-Modus: immer ausgewachsenes Icon
                if let assetName = plant.assetName {
                    Image(assetName)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: plant.symbolName)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.green)
                }
            } else {
                // Garten-Modus: Icon nach Seltenheitsstufe
                switch seltenheit {
                case .bronze:
                    Image("Stufe 1")
                        .resizable()
                        .scaledToFit()
                case .silber:
                    Image("Stufe 2")
                        .resizable()
                        .scaledToFit()
                case .gold, .diamant:
                    if let assetName = plant.assetName {
                        Image(assetName)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image(systemName: plant.symbolName)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .frame(width: size, height: size)
    }
}
