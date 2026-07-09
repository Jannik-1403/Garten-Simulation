import SwiftUI
import FamilyControls

struct ScreenTimeSettingsView: View {
    @StateObject private var manager = ScreenTimeManager.shared
    @Environment(\.dismiss) var dismiss
    
    // Local state for time pickers, bound to AppStorage via Manager when saved
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var isScheduleActive: Bool = false
    
    @State private var isPickerPresented = false
    @State private var blockSelection = FamilyActivitySelection()
    
    // Permanent Block States
    @State private var isPermanentPickerPresented = false
    @State private var permanentBlockSelection = FamilyActivitySelection()
    @State private var isAdultFilterEnabled = false
    
    @State private var showSuggestionAlert = false
    @State private var suggestionAlertTitle = ""
    @State private var suggestionAlertMessage = ""
    
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
                        
                    Button(role: .destructive) {
                        manager.isScheduleActive = false
                        isScheduleActive = false
                        manager.unblockApps()
                    } label: {
                        Text(String(localized: "screenTime.emergency.unlock", defaultValue: "Notfall-Entsperrung"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .foregroundStyle(.red)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
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
                        
                        // MARK: - Permanent Blocks (Für immer geblockt)
                        VStack(alignment: .leading, spacing: 16) {
                            Text(String(localized: "screenTime.permanent.title", defaultValue: "Für immer blockieren"))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .padding(.horizontal)
                            
                            Text(String(localized: "screenTime.permanent.desc", defaultValue: "Diese Apps & Kategorien sind unabhängig vom Zeitplan immer gesperrt."))
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    // Categories
                                    ForEach(Array(permanentBlockSelection.categoryTokens), id: \.self) { token in
                                        PermanentBlockCard { Label(token) }
                                    }
                                    // Apps
                                    ForEach(Array(permanentBlockSelection.applicationTokens), id: \.self) { token in
                                        PermanentBlockCard { Label(token) }
                                    }
                                    // Web Domains
                                    ForEach(Array(permanentBlockSelection.webDomainTokens), id: \.self) { token in
                                        PermanentBlockCard { Label(token) }
                                    }
                                    
                                    Button {
                                        isPermanentPickerPresented = true
                                    } label: {
                                        VStack(spacing: 8) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 32))
                                                .foregroundStyle(Color.gruenPrimary)
                                            Text(String(localized: "common.add", defaultValue: "Hinzufügen"))
                                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                                .foregroundStyle(.primary)
                                        }
                                        .frame(width: 120, height: 120)
                                        .background(Color(UIColor.secondarySystemGroupedBackground))
                                        .cornerRadius(24)
                                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 10)
                                        .rotation3DEffect(.degrees(10), axis: (x: 1, y: -1, z: 0))
                                    }
                                    .familyActivityPicker(isPresented: $isPermanentPickerPresented, selection: $permanentBlockSelection)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 16) // Padding for 3D shadows
                            }
                        }
                        
                        // MARK: - Suggestions (One-Click)
                        VStack(alignment: .leading, spacing: 16) {
                            Text(String(localized: "screenTime.suggestions.title", defaultValue: "Vorschläge zum Blockieren"))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                // Adult Content (Native Filter)
                                SuggestionCard(
                                    icon: "exclamationmark.shield.fill",
                                    color: .red,
                                    title: String(localized: "screenTime.suggestions.adult.title", defaultValue: "Erwachsenen-Inhalte"),
                                    isActive: isAdultFilterEnabled
                                ) {
                                    isAdultFilterEnabled.toggle()
                                }
                                
                                // Social Media
                                SuggestionCard(
                                    icon: "message.fill",
                                    color: .blue,
                                    title: String(localized: "screenTime.suggestions.social.title", defaultValue: "Social Media (TikTok etc.)"),
                                    isActive: false
                                ) {
                                    showSuggestionInstructions(title: String(localized: "screenTime.suggestions.social.title", defaultValue: "Social Media"), appName: "TikTok, Instagram")
                                }
                                
                                // Casino
                                SuggestionCard(
                                    icon: "dice.fill",
                                    color: .purple,
                                    title: String(localized: "screenTime.suggestions.casino.title", defaultValue: "Glücksspiel & Casino"),
                                    isActive: false
                                ) {
                                    showSuggestionInstructions(title: String(localized: "screenTime.suggestions.casino.title", defaultValue: "Glücksspiel"), appName: "Tipico, Casino")
                                }
                                
                                // Food Delivery
                                SuggestionCard(
                                    icon: "takeoutbag.and.cup.and.straw.fill",
                                    color: .orange,
                                    title: String(localized: "screenTime.suggestions.food.title", defaultValue: "Lieferdienste"),
                                    isActive: false
                                ) {
                                    showSuggestionInstructions(title: String(localized: "screenTime.suggestions.food.title", defaultValue: "Lieferdienste"), appName: "Lieferando, Uber Eats")
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // MARK: - Block Zeitplan
                        VStack(alignment: .leading, spacing: 16) {
                            Toggle(String(localized: "screenTime.schedule.active", defaultValue: "Block-Zeitplan aktivieren"), isOn: $isScheduleActive)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .tint(Color.gruenPrimary)
                            
                            if isScheduleActive {
                                Divider()
                                
                                DatePicker(String(localized: "screenTime.schedule.start", defaultValue: "Startzeit"), selection: $startTime, displayedComponents: .hourAndMinute)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                
                                DatePicker(String(localized: "screenTime.schedule.end", defaultValue: "Endzeit"), selection: $endTime, displayedComponents: .hourAndMinute)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    
                                Divider()
                                
                                Button {
                                    isPickerPresented = true
                                } label: {
                                    HStack {
                                        Text(String(localized: "screenTime.schedule.select_apps", defaultValue: "Apps & Kategorien auswählen"))
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .familyActivityPicker(isPresented: $isPickerPresented, selection: $blockSelection)
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
            if !manager.isCurrentlyInBlockWindow {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "common.done", defaultValue: "Fertig")) {
                        saveSettings()
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.gruenPrimary)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "common.cancel", defaultValue: "Abbrechen")) {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                }
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    LiquidGlassDismissButton { dismiss() }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            isScheduleActive = manager.isScheduleActive
            blockSelection = manager.blockSelection
            
            let calendar = Calendar.current
            if let start = calendar.date(bySettingHour: manager.blockStartHour, minute: manager.blockStartMinute, second: 0, of: Date()) {
                startTime = start
            }
            if let end = calendar.date(bySettingHour: manager.blockEndHour, minute: manager.blockEndMinute, second: 0, of: Date()) {
                endTime = end
            }
            
            permanentBlockSelection = manager.permanentBlockSelection
            isAdultFilterEnabled = manager.isAdultFilterEnabled
        }
        .alert(suggestionAlertTitle, isPresented: $showSuggestionAlert) {
            Button(String(localized: "common.understood", defaultValue: "Verstanden")) {
                showSuggestionAlert = false
            }
        } message: {
            Text(suggestionAlertMessage)
        }
    }
    
    private func showSuggestionInstructions(title: String, appName: String) {
        suggestionAlertTitle = title
        suggestionAlertMessage = String(localized: "screenTime.suggestions.instruction", defaultValue: "Apple erlaubt aus Datenschutzgründen keine automatische Sperrung. Bitte tippe bei 'Für immer blockieren' auf Hinzufügen, suche nach \(appName) und wähle es aus.")
        showSuggestionAlert = true
    }
    
    private func saveSettings() {
        let calendar = Calendar.current
        manager.blockStartHour = calendar.component(.hour, from: startTime)
        manager.blockStartMinute = calendar.component(.minute, from: startTime)
        manager.blockEndHour = calendar.component(.hour, from: endTime)
        manager.blockEndMinute = calendar.component(.minute, from: endTime)
        
        manager.blockSelection = blockSelection
        manager.isScheduleActive = isScheduleActive
        
        manager.permanentBlockSelection = permanentBlockSelection
        manager.isAdultFilterEnabled = isAdultFilterEnabled
    }
}

// MARK: - Subviews

struct PermanentBlockCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            content
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 120, height: 120)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 10)
        .rotation3DEffect(.degrees(10), axis: (x: 1, y: -1, z: 0))
    }
}

struct SuggestionCard: View {
    let icon: String
    let color: Color
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(isActive ? .white : color)
                
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(isActive ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .padding()
            .background(isActive ? color : Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(20)
            .shadow(color: isActive ? color.opacity(0.4) : .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
}
