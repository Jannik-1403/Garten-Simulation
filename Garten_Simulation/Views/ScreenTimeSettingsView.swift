import SwiftUI
import FamilyControls

struct ScreenTimeSettingsView: View {
    @StateObject private var manager = ScreenTimeManager.shared
    @Environment(\.dismiss) var dismiss
    
    // Local state for time pickers, bound to AppStorage via Manager when saved
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var isScheduleActive: Bool = false
    
    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()
            
            if manager.isCurrentlyInBlockWindow {
                // Blocked state - user cannot change settings
                VStack(spacing: 24) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.red)
                    
                    Text(String(localized: "screenTime.blocked.title", defaultValue: "Bildschirmzeit blockiert"))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    
                    Text(String(localized: "screenTime.blocked.desc", defaultValue: "Du befindest dich gerade in deiner aktiven Block-Zeit. Du kannst diese Einstellungen erst ändern, wenn die Block-Zeit abgelaufen ist."))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            } else {
                // Normal settings
                ScrollView {
                    VStack(spacing: 24) {
                        if !manager.isAuthorized {
                            Button {
                                Task {
                                    await manager.requestAuthorization()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.yellow)
                                    Text(String(localized: "screenTime.auth.request", defaultValue: "Bildschirmzeit-Zugriff erlauben"))
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(16)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Toggle(String(localized: "screenTime.schedule.active", defaultValue: "Block-Zeitplan aktivieren"), isOn: $isScheduleActive)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .tint(.gruenPrimary)
                                .onChange(of: isScheduleActive) { _, newValue in
                                    manager.isScheduleActive = newValue
                                }
                            
                            if isScheduleActive {
                                Divider()
                                
                                DatePicker(String(localized: "screenTime.schedule.start", defaultValue: "Startzeit"), selection: $startTime, displayedComponents: .hourAndMinute)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .onChange(of: startTime) { _, newTime in
                                        let calendar = Calendar.current
                                        manager.blockStartHour = calendar.component(.hour, from: newTime)
                                        manager.blockStartMinute = calendar.component(.minute, from: newTime)
                                    }
                                
                                DatePicker(String(localized: "screenTime.schedule.end", defaultValue: "Endzeit"), selection: $endTime, displayedComponents: .hourAndMinute)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .onChange(of: endTime) { _, newTime in
                                        let calendar = Calendar.current
                                        manager.blockEndHour = calendar.component(.hour, from: newTime)
                                        manager.blockEndMinute = calendar.component(.minute, from: newTime)
                                    }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "screenTime.info.title", defaultValue: "Wie funktioniert das?"))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                            
                            Text(String(localized: "screenTime.info.desc", defaultValue: "Während der aktiven Block-Zeit kannst du den Blocker hier nicht mehr deaktivieren. Wenn du ein Tagesziel überschreitest, wird automatisch die Gewohnheit 'Zu viel Bildschirmzeit' gekauft/abgehakt. Hältst du das Ziel ein, wird deine Pflanze automatisch am Tagesende gegossen."))
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 8)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(String(localized: "screenTime.title", defaultValue: "Bildschirmzeit"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                LiquidGlassDismissButton { dismiss() }
            }
        }
        .onAppear {
            isScheduleActive = manager.isScheduleActive
            
            let calendar = Calendar.current
            if let start = calendar.date(bySettingHour: manager.blockStartHour, minute: manager.blockStartMinute, second: 0, of: Date()) {
                startTime = start
            }
            if let end = calendar.date(bySettingHour: manager.blockEndHour, minute: manager.blockEndMinute, second: 0, of: Date()) {
                endTime = end
            }
        }
    }
}
