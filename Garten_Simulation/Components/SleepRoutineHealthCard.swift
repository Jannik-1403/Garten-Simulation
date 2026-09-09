import SwiftUI

struct SleepRoutineHealthCard: View {
    @ObservedObject var healthManager = HealthManager.shared
    var onUnlink: (() -> Void)? = nil
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack(spacing: 8) {
                    Text(String(localized: "sleep.routine.title", defaultValue: "Schlafroutine"))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.blauPrimary)
                    
                    Spacer()
                }
                
                if let regularity = healthManager.sleepRegularityPercentage {
                    // Regelmäßigkeit (Prozent)
                    VStack(alignment: .center, spacing: 12) {
                        ZStack {
                            Circle()
                                .stroke(Color(UIColor.systemGray5), lineWidth: 8)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(regularity))
                                .stroke(Color.blauPrimary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(), value: regularity)
                            
                            Text("\(Int(regularity * 100))%")
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundStyle(Color.blauPrimary)
                        }
                        .frame(width: 90, height: 90)
                        
                        VStack(alignment: .center, spacing: 4) {
                            Text(String(localized: "sleep.routine.regularity.title", defaultValue: "Schlaf-Regelmäßigkeit"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                            
                            Text(String(localized: "sleep.routine.regularity.desc", defaultValue: "Gleichmäßige Bettgehzeiten verbessern deine Tiefschlafphasen enorm."))
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Divider()
                
                // Letzte Nacht
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(localized: "sleep.routine.lastnight.title", defaultValue: "Letzte Nacht"))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                    if let start = healthManager.latestSleepStart, let end = healthManager.latestSleepEnd {
                        HStack(spacing: 0) {
                            // Eingeschlafen
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 4) {
                                    Circle().fill(Color.blauPrimary).frame(width: 6, height: 6)
                                    Text(String(localized: "sleep.routine.bedtime", defaultValue: "Eingeschlafen"))
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.blauPrimary)
                                }
                                Text(dateFormatter.string(from: start))
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Dauer
                            VStack(spacing: 2) {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.secondary)
                                
                                let hours = end.timeIntervalSince(start) / 3600.0
                                Text(String(format: "%.1f h", hours))
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 50)
                            
                            // Aufgewacht
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 4) {
                                    Circle().fill(Color.orangePrimary).frame(width: 6, height: 6)
                                    Text(String(localized: "sleep.routine.wakeuptime", defaultValue: "Aufgewacht"))
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.orangePrimary)
                                }
                                Text(dateFormatter.string(from: end))
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    } else {
                        // Keine Daten
                        HStack(spacing: 8) {
                            Image(systemName: "moon.zzz")
                                .font(.system(size: 20))
                                .foregroundStyle(Color(UIColor.systemGray3))
                            
                            Text(String(localized: "sleep.routine.nodata", defaultValue: "Keine ausreichenden Schlafdaten für die letzte Nacht gefunden."))
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding(20)
            
            if let onUnlink = onUnlink {
                Item3DButton(
                    farbe: .red,
                    sekundaerFarbe: Color.red.opacity(0.7),
                    groesse: 36,
                    isRectangular: false,
                    aktion: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onUnlink()
                    }
                ) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.top, 10)
                .padding(.trailing, 10)
            }
        }
        .modifier(Item3DContainerModifier(
            farbe: Color(UIColor.systemBackground),
            sekundaerFarbe: Color(UIColor.systemGray5),
            shadowDepth: 6
        ))
        .onAppear {
            healthManager.fetchSleep()
        }
    }
}
