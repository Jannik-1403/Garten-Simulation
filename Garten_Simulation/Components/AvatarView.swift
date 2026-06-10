import SwiftUI

struct AvatarView: View {
    let profile: CharacterProfile
    
    var body: some View {
        GeometryReader { geo in
            // Body intrinsic size is ~83x100 (aspect ratio 0.83).
            // We use the available height to scale everything proportionally.
            let h = geo.size.height
            let w = h * 0.83
            
            // Center everything in the container
            ZStack {
                // 1. Body (Ganz unten)
                Image("Character\(profile.bodyIndex)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: w, height: h)
                
                // 2. Eyes (Danach die Augen)
                Image("eye\(profile.eyeIndex)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: w, height: h)
                
                // 3. Glasses (Über den Augen, unter den Haaren)
                if profile.hasGlasses {
                    Image("glasses")
                        .resizable()
                        .scaledToFit()
                        .frame(width: w, height: h)
                }
                
                // 4. Hair (Danach die Haare - Schatten liegt nun richtig)
                Image("Hair\(profile.hairIndex)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: w, height: h)
                
                // 5. Mouth (Ganz zum Schluss der Mund)
                Image("mund\(profile.mouthIndex)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: w, height: h)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .offset(y: h * 0.075) // Offset to push the character down and hide the 7.5% empty space at the bottom of the SVGs
        }
    }
}
