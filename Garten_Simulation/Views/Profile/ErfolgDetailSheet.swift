import SwiftUI

struct ErfolgDetailSheet: View {
    let erfolg: Erfolg
    let istFreigeschaltet: Bool
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: SettingsStore
    
    // Helper to format the date
    private func formatDate(_ date: Date, language: String) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: language)
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea() 
            
            // Subtle backdrop glow
            if istFreigeschaltet {
                Circle()
                    .fill(erfolg.farbe.opacity(0.15))
                    .frame(width: 350, height: 350)
                    .blur(radius: 70)
                    .offset(y: -80)
            }
            
            VStack(spacing: 0) {
                // Header (Close Button)
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(.secondary)
                            .padding(10)
                            .background(Color.secondary.opacity(0.1), in: Circle())
                    }
                    .padding(20)
                }
                
                Spacer()
                
                // Very Large Custom Badge
                Image(erfolg.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 240, height: 240) // Even larger as requested
                    .shadow(color: istFreigeschaltet ? erfolg.farbe.opacity(0.4) : .clear, radius: 40, y: 20)
                    .grayscale(istFreigeschaltet ? 0 : 1)
                    .opacity(istFreigeschaltet ? 1 : 0.6)
                    .overlay {
                        if !istFreigeschaltet {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 50, weight: .black))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                        }
                    }
                    .padding(.bottom, 50)
                
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text(settings.localizedString(for: erfolg.titelKey))
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        if istFreigeschaltet, let date = erfolg.freigeschaltetAm {
                            Text(String(format: settings.localizedString(for: "erfolge.erreicht_am"), formatDate(date, language: settings.appLanguage)))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 16)
                                .background(Color.secondary.opacity(0.08), in: Capsule())
                        }
                    }
                    
                    VStack(spacing: 12) {
                        Text(settings.localizedString(for: erfolg.beschreibungKey))
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .lineSpacing(4)
                    }
                }
                
                Spacer()
                
                // Status Section
                VStack(spacing: 20) {
                    if istFreigeschaltet {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.title)
                                .foregroundStyle(.green)
                            
                            Text(settings.localizedString(for: "erfolge.freigeschaltet"))
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundStyle(.green)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 32)
                        .background(Color.green.opacity(0.1), in: Capsule())
                        .overlay(Capsule().stroke(Color.green.opacity(0.2), lineWidth: 1))
                    } else {
                        VStack(spacing: 12) {
                            HStack {
                                Text(settings.localizedString(for: "erfolge.fortschritt"))
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(erfolg.aktuellerWert) / \(erfolg.zielWert)")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(.primary)
                            }
                            .frame(width: 280)
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.secondary.opacity(0.1))
                                    
                                    Capsule()
                                        .fill(erfolg.farbe)
                                        .frame(width: geo.size.width * CGFloat(min(Double(erfolg.aktuellerWert) / Double(erfolg.zielWert), 1.0)))
                                        .shadow(color: erfolg.farbe.opacity(0.3), radius: 4, x: 0, y: 0)
                                }
                            }
                            .frame(width: 280, height: 14)
                        }
                    }
                }
                .padding(.bottom, 60)
            }
        }
    }
}
