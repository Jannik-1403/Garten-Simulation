import SwiftUI

struct PlantTimelineView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss
    
    var onClose: (() -> Void)? = nil
    
    // Sort plants by reminderTime. Plants without a timer go to the bottom.
    var timelinePlants: [HabitModel] {
        gardenStore.pflanzen
            .filter { $0.reminderTime != nil }
            .sorted { (p1, p2) -> Bool in
                guard let t1 = p1.reminderTime, let t2 = p2.reminderTime else { return false }
                
                let h1 = Calendar.current.component(.hour, from: t1)
                let m1 = Calendar.current.component(.minute, from: t1)
                
                let h2 = Calendar.current.component(.hour, from: t2)
                let m2 = Calendar.current.component(.minute, from: t2)
                
                if h1 != h2 { return h1 < h2 }
                return m1 < m2
            }
    }
    
    var otherPlants: [HabitModel] {
        gardenStore.pflanzen.filter { $0.reminderTime == nil }
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    
                    // MARK: - Timeline Section
                    if !timelinePlants.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Geplante Benachrichtigungen")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 0) {
                                ForEach(Array(timelinePlants.enumerated()), id: \.element.id) { index, pflanze in
                                    NavigationLink {
                                        TimerEditSheetView(pflanze: pflanze)
                                            .environmentObject(gardenStore)
                                            .environmentObject(settings)
                                    } label: {
                                        TimelineRow(pflanze: pflanze, isLast: index == timelinePlants.count - 1)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 24)
                    }
                    
                    // MARK: - Other Plants Section
                    if !otherPlants.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Weitere Pflanzen")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 24)
                            
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(otherPlants) { pflanze in
                                    NavigationLink {
                                        TimerEditSheetView(pflanze: pflanze)
                                            .environmentObject(gardenStore)
                                            .environmentObject(settings)
                                    } label: {
                                        SimplePlantCell(pflanze: pflanze)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, timelinePlants.isEmpty ? 24 : 0)
                    }
                    
                    if gardenStore.pflanzen.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "leaf")
                                .font(.system(size: 40))
                                .foregroundStyle(.tertiary)
                            Text(settings.localizedString(for: "garden.empty.subtitle"))
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("Zeitleiste")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if let onClose = onClose {
                        onClose()
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(.primary)
                        .padding(8)
                }
            }
        }
    }
}

// MARK: - Timeline Row Component
struct TimelineRow: View {
    @EnvironmentObject var settings: SettingsStore
    let pflanze: HabitModel
    let isLast: Bool
    
    var timeString: String {
        guard let date = pflanze.reminderTime else { return "--:--" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Time Column
            VStack {
                Text(timeString)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)
                    .frame(width: 55, alignment: .trailing)
                    .padding(.top, 14)
                
                if !isLast {
                    Rectangle()
                        .fill(Color.primary.opacity(0.1))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.top, 4)
                }
            }
            
            // Plant Card
            HStack(spacing: 12) {
                Item3DButton(
                    icon: pflanze.plantImageName,
                    farbe: pflanze.color,
                    sekundaerFarbe: pflanze.color.darker(),
                    groesse: 50,
                    iconSkalierung: 0.6,
                    aktion: nil
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(settings.showHabitInsteadOfName 
                        ? settings.localizedString(for: pflanze.habitName)
                        : settings.localizedString(for: pflanze.name))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    if let message = pflanze.customReminderMessage, !message.isEmpty {
                        Text(message)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    } else {
                        let pflanzName = settings.showHabitInsteadOfName 
                            ? settings.localizedString(for: pflanze.habitName)
                            : settings.localizedString(for: pflanze.name)
                        Text(String(format: settings.localizedString(for: "timer.preview.body.example"), pflanzName))
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
            .padding(.bottom, isLast ? 0 : 16)
        }
    }
}

// MARK: - Simple Plant Cell for Grid
struct SimplePlantCell: View {
    @EnvironmentObject var settings: SettingsStore
    let pflanze: HabitModel
    
    var body: some View {
        VStack(spacing: 12) {
            Item3DButton(
                icon: pflanze.plantImageName,
                farbe: pflanze.color,
                sekundaerFarbe: pflanze.color.darker(),
                groesse: 70,
                iconSkalierung: 0.6,
                aktion: nil
            )
            
            Text(settings.showHabitInsteadOfName 
                ? settings.localizedString(for: pflanze.habitName)
                : settings.localizedString(for: pflanze.name))
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}
