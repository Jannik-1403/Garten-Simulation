import SwiftUI

struct PflanzeDetailSheet: View {
    @ObservedObject var pflanze: HabitModel
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var shopStore: ShopStore
    @Environment(\.dismiss) private var dismiss
    var onLoeschen: (() -> Void)? = nil

    @State private var zeigeVerkaufenDialog = false
    @State private var zeigeNotizSheet = false
    @State private var zeigeTimerSheet = false
    @State private var pulsieren = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {

                // MARK: - Hero: 3D Pflanze mit XP-Ring
                ZStack {
                    // Hintergrund-Ring (grau)
                    Circle()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 8)
                        .frame(width: 170, height: 170)

                    // Fortschritts-Ring (Seltenheits-Farbe)
                    Circle()
                        .trim(from: 0, to: pflanze.ringFortschritt)
                        .stroke(
                            pflanze.seltenheit.farbe,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 170, height: 170)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6), value: pflanze.ringFortschritt)

                    // 3D Pflanze Button (wie auf der Gartenseite)
                    PflanzenButton(
                        symbolName: pflanze.symbolName,
                        farbe: pflanze.color,
                        sekundaerFarbe: pflanze.color.darker(),
                        groesse: 130
                    )
                    .scaleEffect(pulsieren ? 1.03 : 1.0)
                    .allowsHitTesting(false)
                }
                .padding(.top, 24)

                // MARK: - Name + Kategorie + Seltenheit
                VStack(spacing: 8) {
                    Text(settings.localizedString(for: pflanze.name))
                        .font(.system(size: 28, weight: .black, design: .rounded))

                    HStack(spacing: 8) {
                        Text(settings.localizedString(for: pflanze.habitCategory.rawValue))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(pflanze.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(pflanze.color.opacity(0.12)))

                        Text(pflanze.seltenheit.lokalisiertTitel)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(pflanze.seltenheit.farbe)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(pflanze.seltenheit.farbe.opacity(0.12)))

                        // Stufe-Badge
                        HStack(spacing: 3) {
                            Image(systemName: pflanze.stufe.sfSymbol)
                                .font(.system(size: 10, weight: .bold))
                            Text(settings.localizedString(for: pflanze.stufe.labelKey))
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(pflanze.stufe.farbe)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(pflanze.stufe.farbe.opacity(0.12)))
                    }
                }

                // MARK: - Stats: Streak + XP (3D Buttons)
                HStack(spacing: 16) {
                    // Streak Stat
                    stat3DCard(
                        icon: "flame.fill",
                        value: "\(pflanze.streak)",
                        label: settings.localizedString(for: "plant.detail.streak"),
                        farbe: .orange
                    )

                    // XP Stat
                    stat3DCard(
                        icon: "star.fill",
                        value: "\(pflanze.currentXP)",
                        label: settings.localizedString(for: "plant.detail.xp"),
                        farbe: .yellow
                    )
                }
                .padding(.horizontal, 24)

                // MARK: - Notiz-Vorschau (wenn vorhanden)
                if !pflanze.notiz.isEmpty {
                    HStack(spacing: 10) {
                        Image(systemName: "note.text")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                        Text(pflanze.notiz)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.primary.opacity(0.8))
                            .lineLimit(2)
                        Spacer()
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                }

                // MARK: - Timer-Vorschau (wenn aktiv)
                if let timerDate = pflanze.timerDatum, timerDate > Date() {
                    HStack(spacing: 10) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(settings.localizedString(for: "plant.detail.timer.active"))
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text("\(timerDate, style: .date) · \(timerDate, style: .time)")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        Spacer()
                        Button {
                            gardenStore.timerEntfernen(pflanze: pflanze)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.orange.opacity(0.15), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                }

                // MARK: - Action Buttons
                VStack(spacing: 14) {

                    // Notiz Button
                    Button {
                        zeigeNotizSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 16, weight: .bold))
                            Text(settings.localizedString(for: "plant.detail.note"))
                        }
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        size: .medium,
                        fillWidth: true,
                        backgroundColor: .blauPrimary,
                        shadowColor: .blauPrimary.darker(),
                        foregroundColor: .white
                    ))

                    // Timer Button
                    Button {
                        zeigeTimerSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "bell.badge")
                                .font(.system(size: 16, weight: .bold))
                            Text(settings.localizedString(for: "plant.detail.timer"))
                        }
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        size: .medium,
                        fillWidth: true,
                        backgroundColor: .orangePrimary,
                        shadowColor: .orangePrimary.darker(),
                        foregroundColor: .white
                    ))

                    // Verkaufen Button
                    let refund = Int(Double(pflanze.basePrice) * 0.5)
                    Button {
                        zeigeVerkaufenDialog = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "tag.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text(settings.localizedString(for: "plant.detail.sell"))
                            Text("•")
                            HStack(spacing: 3) {
                                Image("Coin")
                                    .resizable().scaledToFit().frame(width: 14, height: 14)
                                Text("+\(refund)")
                                    .font(.system(size: 14, weight: .black, design: .rounded))
                            }
                        }
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        size: .medium,
                        fillWidth: true,
                        backgroundColor: .rotPrimary,
                        shadowColor: .rotPrimary.darker(),
                        foregroundColor: .white
                    ))
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                Spacer().frame(height: 20)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulsieren = true
            }
        }
        // MARK: - Verkaufen Dialog
        .confirmationDialog(
            settings.localizedString(for: "plant.detail.sell.confirm"),
            isPresented: $zeigeVerkaufenDialog,
            titleVisibility: .visible
        ) {
            let refund = Int(Double(pflanze.basePrice) * 0.5)
            Button("\(settings.localizedString(for: "plant.detail.sell.action")) (+\(refund) Coins)", role: .destructive) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                shopStore.sell(id: pflanze.id, price: pflanze.basePrice, title: settings.localizedString(for: pflanze.name))
                onLoeschen?()
            }
            Button(settings.localizedString(for: "button.cancel"), role: .cancel) { }
        }
        // MARK: - Notiz Sheet
        .sheet(isPresented: $zeigeNotizSheet) {
            NotizSheetView(pflanze: pflanze)
                .environmentObject(gardenStore)
                .environmentObject(settings)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
                .presentationBackground(.ultraThinMaterial)
        }
        // MARK: - Timer Sheet
        .sheet(isPresented: $zeigeTimerSheet) {
            TimerSheetView(pflanze: pflanze)
                .environmentObject(gardenStore)
                .environmentObject(settings)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
                .presentationBackground(.ultraThinMaterial)
        }
    }

    // MARK: - 3D Stat Card
    private func stat3DCard(icon: String, value: String, label: String, farbe: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(farbe)

            Text(value)
                .font(.system(size: 32, weight: .black, design: .rounded))

            Text(label)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(farbe.opacity(0.15))
                    .offset(y: 4)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(farbe.opacity(0.15), lineWidth: 1)
                    )
            }
        )
    }
}

// MARK: - Notiz Sheet
struct NotizSheetView: View {
    @ObservedObject var pflanze: HabitModel
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    @State private var notizText: String = ""

    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(settings.localizedString(for: "plant.detail.note"))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                    Text(settings.localizedString(for: pflanze.name))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.blauPrimary)
            }
            .padding(.top, 20)

            // Text Editor
            TextEditor(text: $notizText)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .scrollContentBackground(.hidden)
                .padding(16)
                .frame(minHeight: 140)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.primary.opacity(0.04))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if notizText.isEmpty {
                        Text(settings.localizedString(for: "plant.detail.note.placeholder"))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.tertiary)
                            .padding(20)
                            .allowsHitTesting(false)
                    }
                }

            Spacer()

            // Speichern Button
            Button {
                gardenStore.notizSpeichern(pflanze: pflanze, notiz: notizText)
                dismiss()
            } label: {
                Text(settings.localizedString(for: "plant.detail.note.save"))
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large,
                fillWidth: true,
                backgroundColor: .blauPrimary,
                shadowColor: .blauPrimary.darker()
            ))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .onAppear {
            notizText = pflanze.notiz
        }
    }
}

// MARK: - Timer Sheet
struct TimerSheetView: View {
    @ObservedObject var pflanze: HabitModel
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    @State private var ausgewaehltesDatum: Date = Date().addingTimeInterval(3600) // +1h default

    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(settings.localizedString(for: "plant.detail.timer"))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                    Text(settings.localizedString(for: pflanze.name))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "bell.badge")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.orangePrimary)
            }
            .padding(.top, 20)

            // DatePicker
            DatePicker(
                "",
                selection: $ausgewaehltesDatum,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.wheel)
            .labelsHidden()

            Spacer()

            // Aktiven Timer löschen (wenn vorhanden)
            if let existing = pflanze.timerDatum, existing > Date() {
                Button {
                    gardenStore.timerEntfernen(pflanze: pflanze)
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .bold))
                        Text(settings.localizedString(for: "plant.detail.timer.delete"))
                    }
                }
                .buttonStyle(DuolingoButtonStyle(
                    size: .medium,
                    fillWidth: true,
                    backgroundColor: .rotPrimary,
                    shadowColor: .rotPrimary.darker()
                ))
            }

            // Timer setzen Button
            Button {
                NotificationManager.shared.requestPermission { _ in
                    gardenStore.timerSetzen(pflanze: pflanze, datum: ausgewaehltesDatum)
                    dismiss()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 14, weight: .bold))
                    Text(settings.localizedString(for: "plant.detail.timer.set"))
                }
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large,
                fillWidth: true,
                backgroundColor: .orangePrimary,
                shadowColor: .orangePrimary.darker()
            ))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .onAppear {
            if let existing = pflanze.timerDatum, existing > Date() {
                ausgewaehltesDatum = existing
            }
        }
    }
}
