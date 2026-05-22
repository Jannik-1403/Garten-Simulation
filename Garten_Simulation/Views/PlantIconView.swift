import SwiftUI

struct PlantIconView: View {
    let plant: Plant
    let seltenheit: PflanzenSeltenheit
    var size: CGFloat = 40
    var alwaysShowFullGrown: Bool = false

    var body: some View {
        Group {
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
        .frame(width: size, height: size)
    }
}
