import SwiftUI

enum BodyTrackingType {
    case weight
    case measurements
}

enum BodyDataTimeRange: String, CaseIterable, Identifiable {
    case t    = "T"
    case w    = "W"
    case m    = "M"
    case sixM = "6 M."
    case j    = "J"
    var id: String { rawValue }
}

enum BodyMeasurementCategory: String, CaseIterable, Identifiable {
    case brust       = "body.measure.brust"
    case bizeps      = "body.measure.bizeps"
    case unterarm    = "body.measure.unterarm"
    case schultern   = "body.measure.schultern"
    case oberschenkel = "body.measure.oberschenkel"
    case waden       = "body.measure.waden"
    case taille      = "body.measure.taille"

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .brust:        return String(localized: "body.measure.brust",        defaultValue: "Brustumfang")
        case .bizeps:       return String(localized: "body.measure.bizeps",       defaultValue: "Bizeps (Oberarm)")
        case .unterarm:     return String(localized: "body.measure.unterarm",     defaultValue: "Unterarm")
        case .schultern:    return String(localized: "body.measure.schultern",    defaultValue: "Schultern")
        case .oberschenkel: return String(localized: "body.measure.oberschenkel", defaultValue: "Oberschenkel")
        case .waden:        return String(localized: "body.measure.waden",        defaultValue: "Waden")
        case .taille:       return String(localized: "body.measure.taille",       defaultValue: "Taille (Bauch)")
        }
    }

    var infoText: String {
        let prefix = String(localized: "body.measure.info.prefix", defaultValue: "Nimm ein flexibles Maßband, miss im kalten Zustand ohne Pump und setz das Band immer absolut waagerecht an. ")
        switch self {
        case .brust:        
            return prefix + String(localized: "body.measure.info.brust", defaultValue: "Gerade stehen, normal ausatmen. Maßband waagerecht über die breiteste Stelle der Brust (meist auf Höhe der Brustwarzen) führen.")
        case .bizeps:       
            return prefix + String(localized: "body.measure.info.bizeps", defaultValue: "Arm auf Schulterhöhe 90 Grad anwinkeln, Bizeps und Trizeps maximal anspannen. Maßband exakt um die dickste Stelle (den Peak) legen.")
        case .unterarm:     
            return prefix + String(localized: "body.measure.info.unterarm", defaultValue: "Arm anwinkeln, Faust machen und Unterarm anspannen. Maßband um die dickste Stelle direkt unterhalb des Ellenbogens legen.")
        case .schultern:    
            return prefix + String(localized: "body.measure.info.schultern", defaultValue: "Gerade stehen, Arme hängen entspannt. Band waagerecht um die absolut breiteste Stelle des Schultergürtels führen. Mach das nicht allein, lass dir von jemandem helfen, sonst verrutscht das Band.")
        case .oberschenkel: 
            return prefix + String(localized: "body.measure.info.oberschenkel", defaultValue: "Aufrecht stehen, das zu messende Bein belasten und anspannen. Das Band waagerecht an der dicksten Stelle (meist direkt unter dem Gesäßansatz) anlegen.")
        case .waden:        
            return prefix + String(localized: "body.measure.info.waden", defaultValue: "Im Stehen messen. Ferse leicht anheben, um den Muskel voll anzuspannen. Auch hier exakt die dickste Stelle des Wadenmuskels suchen.")
        case .taille:       
            return prefix + String(localized: "body.measure.info.taille", defaultValue: "Normal ausatmen, nicht den Bauch einziehen. Miss an der schmalsten Stelle deines Bauches, meist knapp über dem Bauchnabel.")
        }
    }
}

struct BodyTrackingWidgetGroup: View {
    @ObservedObject var pflanze: HabitModel
    @EnvironmentObject var gardenStore: GardenStore
    
    var body: some View {
        VStack(spacing: 12) {
            if pflanze.showWeight {
                BodyTrackingModuleCard(
                    title: String(localized: "body.tracking.weight", defaultValue: "Gewicht"),
                    type: .weight,
                    pflanze: pflanze
                )
            }
            if pflanze.showMeasurements {
                BodyTrackingModuleCard(
                    title: String(localized: "body.tracking.measurements", defaultValue: "Körperumfänge"),
                    type: .measurements,
                    pflanze: pflanze
                )
            }
        }
    }
}

struct BodyTrackingModuleCard: View {
    let title: String
    let type: BodyTrackingType
    @ObservedObject var pflanze: HabitModel
    @State private var navigateToDetail = false

    var body: some View {
        NavigationLink(destination: BodyDataFactoryView(pflanze: pflanze, type: type), isActive: $navigateToDetail) {
            EmptyView()
        }
        .hidden()

        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Spacer()
            Item3DButton(
                farbe: .pink,
                sekundaerFarbe: .pink.darker(),
                groesse: 36,
                isRectangular: false,
                aktion: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    navigateToDetail = true
                }
            ) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            navigateToDetail = true
        }
        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
        .padding(.horizontal, 24)
    }
}
