import SwiftUI

enum TagStatus {
    case erledigt
    case verpasst
    case zukunft
}

struct SternPartikel: Identifiable {
    let id = UUID()
    var x: CGFloat = CGFloat.random(in: -80...80)
    var y: CGFloat = CGFloat.random(in: -100...100)
    var opazitaet: Double = Double.random(in: 0.5...1.0)
    var groesse: CGFloat = CGFloat.random(in: 6...14)
}

struct PflanzenDetailView: View {
    let name: String
    let bildName: String
    let seltenheit: Seltenheit
    let streak: Int
    let fortschritt: Double
    let thirstSystem: ThirstSystem
    let gesamtGegossen: Int
    let stuermUeberlebt: Int
    let erledigteTageDaten: [Bool] // true = erledigt, false = nicht
    var onLoeschen: (() -> Void)? = nil

    @State private var pulsieren = false
    @State private var partikelFall: CGFloat = -130
    @State private var zeigeErinnerungPicker = false
    @State private var erinnerungsZeit = Date()
    @State private var zeigeNotizEditor = false
    @State private var notizText = ""
    @State private var zeigeLoeschenDialog = false
    private let partikel = (0..<10).map { _ in SternPartikel() }

    private var prozentText: String {
        "\(Int((fortschritt * 100).rounded()))%"
    }

    private var naechsteStufeName: String {
        switch seltenheit {
        case .bronze: return "Silber"
        case .silber: return "Gold"
        case .gold: return "Diamant"
        case .diamant: return "Meisterform"
        }
    }

    private var tageBisNaechsteStufe: Int {
        max(0, Int(ceil((1 - fortschritt) * 10)))
    }

    private var heuteTageIndex: Int {
        min(
            30,
            Calendar.current.dateComponents(
                [.day],
                from: Date().addingTimeInterval(-30 * 24 * 3600),
                to: Date()
            ).day ?? 0
        )
    }

    private let heatmapSpalten = Array(repeating: GridItem(.flexible(), spacing: 8), count: 10)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    seltenheit.ringFarbe.opacity(0.05),
                    Color.clear,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    header
                    heroVisual
                        .padding(.top, 8)
                    statsCards
                    naechsteStufeCard
                    heatmapCard
                    laborSektion
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(.ultraThinMaterial)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulsieren.toggle()
            }
            if seltenheit == .diamant {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    partikelFall = 150
                }
            }
            notizText = UserDefaults.standard
                .string(forKey: "notiz_\(name)") ?? ""
            erinnerungsZeit = UserDefaults.standard
                .object(forKey: "erinnerung_\(name)")
                as? Date ?? Date()
        }
        .sheet(isPresented: $zeigeErinnerungPicker) {
            VStack(spacing: 20) {
                Text("Erinnerung setzen")
                    .font(.system(size: 20, weight: .bold, design: .rounded))

                DatePicker(
                    "",
                    selection: $erinnerungsZeit,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()

                Button("Speichern") {
                    UserDefaults.standard.set(
                        erinnerungsZeit,
                        forKey: "erinnerung_\(name)"
                    )
                    zeigeErinnerungPicker = false
                }
                .buttonStyle(DuolingoButtonStyle())
                .padding(.horizontal, 24)
            }
            .padding(24)
            .presentationDetents([PresentationDetent.medium])
            .presentationCornerRadius(32)
            .presentationBackground(.ultraThinMaterial)
        }
        .sheet(isPresented: $zeigeNotizEditor) {
            VStack(spacing: 20) {
                Text("Meine Notiz")
                    .font(.system(size: 20, weight: .bold, design: .rounded))

                TextEditor(text: $notizText)
                    .frame(minHeight: 150)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.2))
                    )

                if notizText.isEmpty {
                    Text("Warum ziehst du das durch?")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Button("Speichern") {
                    UserDefaults.standard.set(
                        notizText,
                        forKey: "notiz_\(name)"
                    )
                    zeigeNotizEditor = false
                }
                .buttonStyle(DuolingoButtonStyle())
                .padding(.horizontal, 24)
            }
            .padding(24)
            .presentationDetents([PresentationDetent.medium])
            .presentationCornerRadius(32)
            .presentationBackground(.ultraThinMaterial)
        }
        .confirmationDialog(
            "Willst du \(name) wirklich löschen?",
            isPresented: $zeigeLoeschenDialog,
            titleVisibility: .visible
        ) {
            Button("Löschen", role: .destructive) {
                onLoeschen?()
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Dein gesamter Fortschritt geht verloren.")
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text(name)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.primary)

            Text(seltenheit.bezeichnung)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(seltenheit.tagHintergrund))
                .foregroundStyle(seltenheit.tagTextFarbe)

            Spacer()
        }
    }

    private var heroVisual: some View {
        TimelineView(.periodic(from: .now, by: 60)) { timeline in
            let now = timeline.date
            let thirstState = thirstSystem.state(at: now)
            let pulseDuration = thirstSystem.thirstyPulseDuration(at: now)

            ZStack {
                if thirstState == .thirsty {
                    Circle()
                        .fill(Color.red.opacity(pulsieren ? 0.20 : 0.08))
                        .frame(width: pulsieren ? 236 : 224, height: pulsieren ? 236 : 224)
                        .blur(radius: pulsieren ? 18 : 8)
                        .animation(.easeInOut(duration: pulseDuration).repeatForever(autoreverses: true), value: pulsieren)
                }

                if seltenheit == .diamant {
                    ForEach(partikel) { partikel in
                        Image(systemName: "star.fill")
                            .font(.system(size: partikel.groesse))
                            .foregroundStyle(Color.diamantPrimary.opacity(partikel.opazitaet))
                            .offset(x: partikel.x, y: partikel.y + partikelFall)
                    }
                }

                SeltenheitProgressRing(
                    progress: CGFloat(fortschritt),
                    color: seltenheit.ringFarbe,
                    lineWidth: 12,
                    size: 200,
                    celebrateTrigger: false
                )
                .shadow(color: seltenheit.ringFarbe.opacity(0.35), radius: 8)

                ZStack {
                    Circle()
                        .fill(Color.gruenSecondary)
                        .frame(width: 176, height: 176)

                    Circle()
                        .fill(Color.gruenPrimary)
                        .frame(width: 176, height: 176)
                        .offset(y: -8)

                    Image(bildName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                        .saturation(thirstState == .dead ? 0 : (thirstState == .thirsty ? 0.7 : 1))
                        .opacity(thirstState == .dead ? 0.6 : 1)
                        .offset(y: -8)
                }

                if thirstState == .dead {
                    crackOverlay
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
    }

    private var crackOverlay: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 0, y: -70))
                path.addLine(to: CGPoint(x: 14, y: -20))
                path.addLine(to: CGPoint(x: -4, y: 18))
                path.addLine(to: CGPoint(x: 20, y: 65))
            }
            .stroke(Color.white.opacity(0.5), lineWidth: 1.5)

            Path { path in
                path.move(to: CGPoint(x: -58, y: -10))
                path.addLine(to: CGPoint(x: -20, y: 8))
                path.addLine(to: CGPoint(x: -44, y: 48))
            }
            .stroke(Color.white.opacity(0.35), lineWidth: 1.2)
        }
    }

    private var statsCards: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )

                VStack(spacing: 6) {
                    Image("Sonnen_Streak")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)

                    Text("\(streak)")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)

                    Text(streak == 1 ? "Tag Streak" : "Tage Streak")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(16)
            }
            .frame(maxWidth: .infinity)
            statCard(
                icon: "drop.fill",
                iconColor: .blauPrimary,
                value: "\(gesamtGegossen)",
                label: gesamtGegossen == 1 ? "Mal gegossen" : "Mal gegossen"
            )
            statCard(
                icon: "cloud.bolt.fill",
                iconColor: .gray,
                value: "\(stuermUeberlebt)",
                label: stuermUeberlebt == 1 ? "Sturm überlebt" : "Stürme überlebt"
            )
        }
    }

    private func statCard(icon: String, iconColor: Color, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
            Text(value)
                .font(.system(size: 24, weight: .black, design: .rounded))
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    private var naechsteStufeCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Nächste Stufe")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Spacer()
                Text(prozentText)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(seltenheit.ringFarbe)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    seltenheit.ringFarbe,
                                    seltenheit.ringFarbe.opacity(0.7),
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geo.size.width * fortschritt,
                            height: 12
                        )
                        .animation(.easeInOut(duration: 1.0), value: fortschritt)
                }
            }
            .frame(height: 12)

            Text("Noch \(tageBisNaechsteStufe) Tage bis \(naechsteStufeName)")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    private var heatmapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Die letzten 30 Tage")
                .font(.system(size: 16, weight: .bold, design: .rounded))

            LazyVGrid(columns: heatmapSpalten, spacing: 8) {
                ForEach(erledigteTageDaten.indices, id: \.self) { index in
                    let status = tagStatus(for: index)
                    ZStack {
                        switch status {
                        case .erledigt:
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.15))
                                Image("Sonnen_Streak")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 13, height: 13)
                            }
                        case .verpasst:
                            Circle()
                                .fill(Color.red.opacity(0.3))
                            Text("✕")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.red.opacity(0.8))
                        case .zukunft:
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1.5)
                                .background(Color.clear)
                        }
                    }
                    .frame(width: 24, height: 24)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    private var laborSektion: some View {
        VStack(spacing: 12) {
            Button {
                zeigeErinnerungPicker = true
            } label: {
                laborButton(icon: "bell.fill", title: "Erinnerung setzen")
            }
            .buttonStyle(.plain)

            Button {
                zeigeNotizEditor = true
            } label: {
                laborButton(icon: "note.text", title: "Notiz hinzufügen")
            }
            .buttonStyle(.plain)

            Button {
                zeigeLoeschenDialog = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "trash.fill")
                        .foregroundStyle(Color.rotPrimary)
                    Text("Gewohnheit löschen")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.rotPrimary)
                    Spacer()
                }
                .padding(16)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .tint(.primary)
        }
    }

    private func laborButton(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.primary)
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    private func tagStatus(for index: Int) -> TagStatus {
        if index >= heuteTageIndex {
            return .zukunft
        }
        return erledigteTageDaten[index] ? .erledigt : .verpasst
    }
}

#Preview {
    PflanzenDetailView(
        name: "Meditation",
        bildName: Seltenheit.gold.iconName,
        seltenheit: .gold,
        streak: 12,
        fortschritt: 0.8,
        thirstSystem: ThirstSystem(),
        gesamtGegossen: 42,
        stuermUeberlebt: 3,
        erledigteTageDaten: Array(repeating: true, count: 30)
    )
}

