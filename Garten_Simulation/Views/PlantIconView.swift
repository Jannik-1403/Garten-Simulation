import SwiftUI
import UIKit

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
                if UIImage(systemName: plant.symbolName) != nil {
                    Image(systemName: plant.symbolName)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.green)
                } else if UIImage(named: plant.symbolName) != nil {
                    Image(plant.symbolName)
                        .resizable()
                        .scaledToFit()
                } else {
                    Text(plant.symbolName)
                        .font(.system(size: size * 0.75))
                        .minimumScaleFactor(0.5)
                }
            }
        }
        .frame(width: size, height: size)
    }
}
