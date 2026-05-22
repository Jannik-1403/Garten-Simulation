import SwiftUI

struct IgelView: View {
    let customization: IgelCustomization
    let size: CGFloat

    var body: some View {
        ZStack {

            // Layer 1: Igel Körper
            Image(koerperAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)

            // Layer 2: Gesicht
            Image(gesichtAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: size * gesichtScale, height: size * gesichtScale)
                .rotationEffect(.degrees(gesichtRotation))
                .offset(x: gesichtOffset.x, y: gesichtOffset.y)
            
            // Layer 3: Accessoire (Temporär deaktiviert)
            /*
            if customization.accessoire != .keins {
                Image(accessoireAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * accessoireScale, height: size * accessoireScale)
                    .rotationEffect(.degrees(gesichtRotation))
                    .offset(x: accessoireOffset.x, y: accessoireOffset.y)
            }
            */
        }
        .frame(width: size, height: size)
    }

    // MARK: - Asset Namen

    var koerperAssetName: String {
        return customization.pose.assetName
    }

    var gesichtAssetName: String {
        switch customization.gesicht {
        case .froh:      return "Igel_Gesicht_Froh"
        case .cool:      return "Igel_Gesicht_Cool"
        case .schlafrig: return "Igel_Gesicht_Muede"
        case .verliebt:  return "Igel_Gesicht_Verliebt"
        case .stolz:     return "Igel_Gesicht_Stolz"
        }
    }

    var accessoireAssetName: String {
        switch customization.accessoire {
        case .keins:   return ""
        case .hut:     return "Igel_Acc_Hut"
        case .brille:  return "Igel_Acc_Brille"
        case .schal:   return ""
        case .blume:   return ""
        }
    }

    // MARK: - Gesicht Positionierung
    var gesichtScale: CGFloat {
        switch customization.pose {
        case .schlafen: return 0.45
        case .stehend:  return 0.28
        case .astronaut, .ninja, .sportler: return 0.35 // Kleiner für Helm/Maske/Sportler
        case .schlafanzug: return 0.30 // Noch kleiner für den Schlafanzug
        case .rennen: return 0.35 // Auch für die Renn-Pose kleiner
        default:        return 0.42 // Für winken, liegen
        }
    }

    var gesichtRotation: Double {
        switch customization.pose {
        case .schlafen: return 35
        case .schlafanzug: return -65 // Wieder ein Stück zurück gedreht
        default:        return 0
        }
    }

    var gesichtOffset: CGPoint {
        var baseOffset = CGPoint(x: 0, y: -size * 0.05)
        
        switch customization.pose {
        case .schlafen:
            baseOffset.x += size * 0.10
            baseOffset.y -= size * 0.06
        case .stehend:
            break
        case .astronaut:
            baseOffset.y -= size * 0.09 // Noch höher
        case .ninja:
            baseOffset.y -= size * 0.11 // Deutlich höher für die Maske
        case .schlafanzug:
            baseOffset.x -= size * 0.17 // Ein kleines Stück nach links
            baseOffset.y += size * 0.11 // Ein kleines Stück nach oben
        case .rennen:
            baseOffset.y -= size * 0.05
        default:
            // Für liegen, winken, sportler
            baseOffset.y -= size * 0.05
        }
        
        return baseOffset
    }

    // MARK: - Accessoire Positionierung
    var accessoireScale: CGFloat {
        switch customization.accessoire {
        case .hut:
            return 0.85
        case .brille: 
            return 0.38
        default:      
            return 0.5
        }
    }

    var accessoireOffset: CGPoint {
        var offset = gesichtOffset
        
        // 1. Basis-Versatz je nach Accessoire (relativ zum Gesicht)
        switch customization.accessoire {
        case .hut:
            // Der Hut muss über dem Gesicht sitzen, aber tief genug um die Stacheln zu bedecken
            offset.y -= size * 0.10 // Etwas tiefer als vorher (-0.12)
            
            // Pose-spezifische Korrekturen für den Hut
            switch customization.pose {
            case .schlafen:
                offset.x += size * 0.08
                offset.y += size * 0.01
            case .rennen, .winken, .liegen:
                offset.y += size * 0.02
            default:
                break
            }
            
        case .brille:
            // Brille sitzt direkt auf Augenhöhe
            offset.y -= size * 0.01 
            
        default:
            break
        }
        
        return offset
    }
}
