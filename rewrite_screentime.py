import re

with open('Garten_Simulation/Views/ScreenTimeSettingsView.swift', 'r', encoding='utf-8') as f:
    content = f.read()

# First replace settingsScrollView
new_scroll_view = """    private var settingsScrollView: some View {
        ScrollView {
            VStack(spacing: 32) {
                ebene1Section
                ebene2Section
                ebene3Section
                ebene4Section
                infoSection
                
                // Bottom Authorization Link
                if !manager.isAuthorized {
                    Button(action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text(String(localized: "screenTime.auth.request", defaultValue: "Bildschirmzeit-Zugriff erlauben"))
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.orange)
                            .underline()
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
            .padding(.vertical)
        }
    }
    
    private func sectionHeader3D(level: String, title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(level.uppercased())
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                
                ZStack(alignment: .topLeading) {
                    Text(title)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Color.blauPrimary.opacity(0.35))
                        .offset(y: 3)
                    
                    Text(title)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Color.blauPrimary)
                }
            }
            
            Text(description)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }"""

content = re.sub(r'    private var settingsScrollView: some View \{.*?(?=    // MARK: - Ebene 1: Zeitlimit)', new_scroll_view + '\n\n', content, flags=re.DOTALL)

# Now rewrite ebene1Section (formerly dailyLimitSection)
ebene1 = """    // MARK: - Ebene 1: Zeitlimit
    private var ebene1Section: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader3D(
                level: String(localized: "screenTime.layer1.level", defaultValue: "Ebene 1"),
                title: String(localized: "screenTime.layer1.title", defaultValue: "Tägliches Limit"),
                description: String(localized: "screenTime.layer1.desc", defaultValue: "Nach Ablauf dieser Zeit werden die ausgewählten Apps für den Rest des Tages blockiert.")
            )
            
            HStack {
                Item3DButton(
                    farbe: Color.gruenPrimary,
                    sekundaerFarbe: Color.gruenPrimary.darker(),
                    groesse: 36,
                    shadowDepthFactor: 0.15,
                    isRectangular: true,
                    aktion: { isDailyLimitPickerPresented = true }
                ) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                }
                .familyActivityPicker(isPresented: $isDailyLimitPickerPresented, selection: $dailyLimitSelection)
                
                Spacer()
                
                if !dailyLimitSelection.applicationTokens.isEmpty || !dailyLimitSelection.categoryTokens.isEmpty || !dailyLimitSelection.webDomainTokens.isEmpty {
                    Item3DButton(
                        farbe: Color.orange,
                        sekundaerFarbe: Color.orange.darker(),
                        groesse: 36,
                        shadowDepthFactor: 0.15,
                        isRectangular: true,
                        aktion: { walkOfShameContext = 1 }
                    ) {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.open.fill")
                            Text(String(localized: "screenTime.layer1.unblock.short", defaultValue: "Entsperren"))
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 4)
            
            if !dailyLimitSelection.applicationTokens.isEmpty || !dailyLimitSelection.categoryTokens.isEmpty || !dailyLimitSelection.webDomainTokens.isEmpty {
                let count = dailyLimitSelection.applicationTokens.count + dailyLimitSelection.categoryTokens.count + dailyLimitSelection.webDomainTokens.count
                DisclosureGroup(String(localized: "screenTime.blockedApps", defaultValue: "Geblockte Apps") + " (\(count))", isExpanded: $isEbene1Expanded) {"""

content = re.sub(r'    // MARK: - Ebene 1: Zeitlimit\s*private var dailyLimitSection: some View \{.*?DisclosureGroup\(String\(localized: "screenTime\.blockedApps", defaultValue: "Geblockte Apps"\) \+ " \(\\\(count\)\)", isExpanded: \$isEbene1Expanded\) \{', ebene1, content, flags=re.DOTALL)

# Rewrite ebene4Section (formerly permanentBlockSection)
ebene4 = """    // MARK: - Ebene 4: Permanent Block Section
    private var ebene4Section: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader3D(
                level: String(localized: "screenTime.layer4.level", defaultValue: "Ebene 4"),
                title: String(localized: "screenTime.layer4.title", defaultValue: "Immer blockiert"),
                description: String(localized: "screenTime.layer4.desc", defaultValue: "Diese Apps und Webseiten sind immer blockiert und können nur durch den Notfall-Unlock entsperrt werden.")
            )
            
            HStack {
                Item3DButton(
                    farbe: Color.gruenPrimary,
                    sekundaerFarbe: Color.gruenPrimary.darker(),
                    groesse: 36,
                    shadowDepthFactor: 0.15,
                    isRectangular: true,
                    aktion: { isPermanentPickerPresented = true }
                ) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                }
                .familyActivityPicker(isPresented: $isPermanentPickerPresented, selection: $permanentBlockSelection)
                
                Spacer()
                
                if !permanentBlockSelection.applicationTokens.isEmpty || !permanentBlockSelection.categoryTokens.isEmpty || !permanentBlockSelection.webDomainTokens.isEmpty {
                    Item3DButton(
                        farbe: Color.orange,
                        sekundaerFarbe: Color.orange.darker(),
                        groesse: 36,
                        shadowDepthFactor: 0.15,
                        isRectangular: true,
                        aktion: { walkOfShameContext = 2 }
                    ) {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.open.fill")
                            Text(String(localized: "screenTime.layer1.unblock.short", defaultValue: "Entsperren"))
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 4)
            
            if !permanentBlockSelection.applicationTokens.isEmpty ||
               !permanentBlockSelection.categoryTokens.isEmpty ||
               !permanentBlockSelection.webDomainTokens.isEmpty {
                let count = permanentBlockSelection.applicationTokens.count + permanentBlockSelection.categoryTokens.count + permanentBlockSelection.webDomainTokens.count
                DisclosureGroup(String(localized: "screenTime.blockedApps", defaultValue: "Geblockte Apps") + " (\(count))", isExpanded: $isEbene2Expanded) {"""

content = re.sub(r'    // MARK: - Ebene 2: Permanent Block Section\s*private var permanentBlockSection: some View \{.*?DisclosureGroup\(String\(localized: "screenTime\.blockedApps", defaultValue: "Geblockte Apps"\) \+ " \(\\\(count\)\)", isExpanded: \$isEbene2Expanded\) \{', ebene4, content, flags=re.DOTALL)

# Rewrite ebene3Section (formerly adultFilterSection)
ebene3 = """    // MARK: - Ebene 3: Adult Filter Section
    @ViewBuilder
    private var ebene3Section: some View {
        if FeatureFlags.isProVersionEnabled {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader3D(
                    level: String(localized: "screenTime.layer3.level", defaultValue: "Ebene 3"),
                    title: String(localized: "screenTime.safariFilter.title", defaultValue: "Systemweiter Erwachsenen-Filter"),
                    description: String(localized: "screenTime.safariFilter.desc", defaultValue: "Blockiert pornografische Webseiten systemweit in allen Browsern.")
                )
                
                let isActive = isAdultFilterEnabled
                
                HStack {
                    Item3DButton(
                        farbe: isActive ? Color.orange : Color.gruenPrimary,
                        sekundaerFarbe: isActive ? Color.orange.darker() : Color.gruenPrimary.darker(),
                        groesse: 36,
                        shadowDepthFactor: 0.15,
                        isRectangular: true,
                        aktion: {
                            if isActive {
                                walkOfShameContext = 3
                            } else {
                                isAdultFilterEnabled = true
                            }
                        }
                    ) {
                        HStack(spacing: 4) {
                            Image(systemName: isActive ? "lock.open.fill" : "lock.fill")
                            Text(isActive ? String(localized: "screenTime.layer1.unblock.short", defaultValue: "Entsperren") : String(localized: "common.activate", defaultValue: "Aktivieren"))
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
        }
    }"""

content = re.sub(r'    // MARK: - Adult Filter Section\s*@ViewBuilder\s*private var adultFilterSection: some View \{.*?\.padding\(\.top, 4\)\s*\}\s*\}\s*\}', ebene3, content, flags=re.DOTALL)


# Rewrite ebene2Section (formerly scheduleSection)
ebene2 = """    // MARK: - Ebene 2: Schedule Section
    
    @State private var isEbeneScheduleExpanded: Bool = false
    
    /// Wahr, wenn der Zeitplan gerade läuft – dann ist alles read-only
    private var isScheduleLocked: Bool {
        manager.isCurrentlyInBlockWindow
    }

    private var ebene2Section: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader3D(
                level: String(localized: "screenTime.layer2.level", defaultValue: "Ebene 2"),
                title: String(localized: "screenTime.schedule.title", defaultValue: "Block-Zeitplan"),
                description: String(localized: "screenTime.schedule.desc", defaultValue: "Erzwinge Fokus zu bestimmten Zeiten.")
            )
            
            HStack {
                let isActive = isScheduleActive
                Item3DButton(
                    farbe: isActive ? Color.orange : Color.gruenPrimary,
                    sekundaerFarbe: isActive ? Color.orange.darker() : Color.gruenPrimary.darker(),
                    groesse: 36,
                    shadowDepthFactor: 0.15,
                    isRectangular: true,
                    isDisabled: isScheduleLocked,
                    aktion: {
                        if isActive {
                            walkOfShameContext = 4
                        } else {
                            isScheduleActive = true
                        }
                    }
                ) {
                    HStack(spacing: 4) {
                        Image(systemName: isActive ? "lock.open.fill" : "lock.fill")
                        Text(isActive ? String(localized: "screenTime.layer1.unblock.short", defaultValue: "Entsperren") : String(localized: "common.activate", defaultValue: "Aktivieren"))
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, -4)

            if isScheduleActive {
                VStack(spacing: 8) {

                    // Lock-Banner wenn Zeitplan gerade aktiv
                    if isScheduleLocked {
                        Item3DButton(
                            farbe: Color(UIColor.secondarySystemGroupedBackground),
                            sekundaerFarbe: Color(UIColor.tertiarySystemGroupedBackground),
                            groesse: 64,
                            shadowDepthFactor: 0.05,
                            isRectangular: true,
                            isDisabled: true
                        ) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(String(localized: "screenTime.schedule.locked.title", defaultValue: "Zeitplan läuft gerade"))
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                    Text(String(localized: "screenTime.schedule.locked.info", defaultValue: "Während der aktiven Zeit können keine Änderungen vorgenommen werden."))
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                        }
                        .padding(.horizontal)
                    } else {
                        // Quick Copy Buttons – nur wenn nicht gesperrt
                        HStack(spacing: 8) {
                            quickApplyButton(
                                label: String(localized: "screenTime.schedule.applyWeekdays", defaultValue: "Mo–Fr gleich"),
                                action: applyWeekdaysToAll
                            )
                            quickApplyButton(
                                label: String(localized: "screenTime.schedule.applyWeekend", defaultValue: "Sa–So gleich"),
                                action: applyWeekendToAll
                            )
                        }
                        .padding(.horizontal)
                    }

                    // Per-Day Rows
                    ForEach(allWeekdays, id: \.0) { (dayInt, short, full) in
                        DayScheduleRow(
                            dayName: full,
                            shortName: short,
                            schedule: binding(for: dayInt),
                            isExpanded: expandedDay == dayInt && !isScheduleLocked,
                            isLocked: isScheduleLocked,
                            onToggleExpand: {
                                guard !isScheduleLocked else { return }
                                withAnimation(.spring(response: 0.3)) {
                                    expandedDay = expandedDay == dayInt ? nil : dayInt
                                }
                            }
                        )
                        .padding(.horizontal)
                    }

                    // App-Picker – nur wenn nicht gesperrt
                    if !isScheduleLocked {
                        HStack {
                            Item3DButton(
                                farbe: Color.gruenPrimary,
                                sekundaerFarbe: Color.gruenPrimary.darker(),
                                groesse: 36,
                                shadowDepthFactor: 0.15,
                                isRectangular: true,
                                aktion: { isPickerPresented = true }
                            ) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 16)
                            }
                            .familyActivityPicker(isPresented: $isPickerPresented, selection: $blockSelection)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    }

                    // Liste der ausgewählten Apps
                    if !blockSelection.applicationTokens.isEmpty ||
                       !blockSelection.categoryTokens.isEmpty ||
                       !blockSelection.webDomainTokens.isEmpty {
                        let count = blockSelection.applicationTokens.count + blockSelection.categoryTokens.count + blockSelection.webDomainTokens.count
                        DisclosureGroup(String(localized: "screenTime.blockedApps", defaultValue: "Geblockte Apps") + " (\(count))", isExpanded: $isEbeneScheduleExpanded) {
                            VStack(spacing: 8) {
                                ForEach(Array(blockSelection.applicationTokens), id: \.self) { token in
                                    ScheduleBlockRow { Label(token) }
                                }
                                ForEach(Array(blockSelection.categoryTokens), id: \.self) { token in
                                    ScheduleBlockRow { Label(token) }
                                }
                                ForEach(Array(blockSelection.webDomainTokens), id: \.self) { token in
                                    ScheduleBlockRow { Label(token) }
                                }
                            }
                            .padding(.top, 8)
                        }
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .accentColor(.gruenPrimary)
                        .padding(.horizontal)
                    }
                }
            }
        }
    }"""

content = re.sub(r'    // MARK: - Schedule Section\s*/// Wahr, wenn der Zeitplan gerade läuft.*?\}\s*\}\s*\}\s*\}', ebene2, content, flags=re.DOTALL)

with open('Garten_Simulation/Views/ScreenTimeSettingsView.swift', 'w', encoding='utf-8') as f:
    f.write(content)

