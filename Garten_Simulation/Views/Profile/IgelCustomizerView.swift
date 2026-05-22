import SwiftUI

struct IgelCustomizerView: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @Environment(\.dismiss) var dismiss

    enum Kategorie: CaseIterable {
        case pose, accessoire, gesicht, hintergrund

        var icon: String {
            switch self {
            case .pose:       return "figure.walk"
            case .accessoire: return "theatermasks.fill"
            case .gesicht:    return "face.smiling.fill"
            case .hintergrund: return "paintbrush.fill"
            }
        }

        var labelKey: String {
            switch self {
            case .pose:       return "igel_pose_titel"
            case .accessoire: return "igel_accessoire_titel"
            case .gesicht:    return "igel_gesicht_titel"
            case .hintergrund: return "igel_hintergrund_titel"
            }
        }
    }

    @State private var aktiveKategorie: Kategorie = .pose
    @State private var zeigeNameEditOverlay = false
    @State private var zeigeZweiteBestaetigung = false
    @State private var tempName: String = ""
    
    // Sheet State
    @State private var sheetOffset: CGFloat = 380
    @State private var dragOffset: CGFloat = 0
    private let minSheetOffset: CGFloat = 100
    private let maxSheetOffset: CGFloat = 750 // Fast ganz unten
    
    var currentOffset: CGFloat {
        max(minSheetOffset, min(maxSheetOffset, sheetOffset + dragOffset))
    }

    var nameChangeCost: Int {
        let count = settings.igelCustomization.nameChangeCount
        if count == 0 { return 0 }
        
        // Startet bei 100, dann +50% pro Änderung
        var cost = 100.0
        for _ in 1..<count {
            cost *= 1.5
        }
        return Int(cost)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack(alignment: .top) {
                    // MARK: - Igel Vorschau (Hintergrund)
                    ZStack(alignment: .center) {
                        settings.igelCustomization.background.color
                            .ignoresSafeArea()
                        
                            // Responsive Preview
                            IgelView(
                                customization: settings.igelCustomization, 
                                size: geo.size.width * (isLargePose(settings.igelCustomization.pose) ? 1.35 : 1.1)
                            )
                            .offset(y: 40)
                            .padding(.bottom, 60)
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                    
                    // MARK: - Draggable Options Sheet
                    VStack(spacing: 0) {
                        // Drag Handle
                        Capsule()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 40, height: 6)
                            .padding(.top, 12)
                            .padding(.bottom, 8)
                        
                        // Namens-Anzeige (In der Leiste oben)
                        Button(action: {
                            tempName = settings.igelCustomization.name
                            zeigeZweiteBestaetigung = false
                            zeigeNameEditOverlay = true
                        }) {
                            HStack {
                                Text(settings.igelCustomization.name.isEmpty 
                                     ? settings.localizedString(for: "igel_name_placeholder") 
                                     : settings.igelCustomization.name)
                                    .font(.system(.headline, design: .rounded, weight: .bold))
                                    .foregroundStyle(settings.igelCustomization.name.isEmpty ? .secondary : .primary)
                                
                                Spacer()
                                
                                Image(systemName: "pencil")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                        
                        Divider().padding(.top, 4)

                        // MARK: - Kategorie Tabs (Horizontal Scrollbar)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(Kategorie.allCases, id: \.self) { kategorie in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            aktiveKategorie = kategorie
                                        }
                                    }) {
                                        VStack(spacing: 6) {
                                            Image(systemName: kategorie.icon)
                                                .font(.system(size: 20))
                                            Text(settings.localizedString(for: kategorie.labelKey))
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                        }
                                        .foregroundStyle(aktiveKategorie == kategorie ? Color.blauPrimary : Color.secondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 12)
                                        .background(aktiveKategorie == kategorie ? Color.blauPrimary.opacity(0.1) : Color.clear)
                                        .cornerRadius(12)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 8)
                        
                        Divider()

                        // MARK: - Optionen Grid (Größere Kacheln)
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 20),
                                GridItem(.flexible(), spacing: 20)
                            ], spacing: 24) {
                                switch aktiveKategorie {
                                case .pose:
                                    ForEach(IgelPose.allCases, id: \.self) { pose in
                                        poseKachel(pose)
                                    }
                                case .accessoire:
                                    VStack(spacing: 20) {
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: 40))
                                            .foregroundStyle(.secondary)
                                        Text(settings.localizedString(for: "igel_accessoire_coming_soon"))
                                            .font(.system(.headline, design: .rounded))
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 300)
                                    .gridCellColumns(2)
                                case .gesicht:
                                    ForEach(IgelGesicht.allCases, id: \.self) { gesicht in
                                        gesichtKachel(gesicht)
                                    }
                                case .hintergrund:
                                    ForEach(IgelPortraitBackground.allCases, id: \.self) { bg in
                                        hintergrundKachel(bg)
                                    }
                                }
                            }
                            .padding(24)
                        }
                        .background(Color(.systemBackground))
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .shadow(color: .black.opacity(0.12), radius: 15, y: -5)
                    .offset(y: currentOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.height
                            }
                            .onEnded { value in
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    sheetOffset += value.translation.height
                                    dragOffset = 0
                                    
                                    let bottomLimit = geo.size.height - 120
                                    
                                    // Snapping
                                    if sheetOffset < (geo.size.height * 0.4) {
                                        sheetOffset = minSheetOffset
                                    } else if sheetOffset > (geo.size.height * 0.7) {
                                        sheetOffset = bottomLimit
                                    } else {
                                        sheetOffset = 380 // Standard
                                    }
                                }
                            }
                    )
                    
                    // MARK: - Name Edit Overlay
                    if zeigeNameEditOverlay {
                        nameEditOverlay
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                            .zIndex(100)
                    }
                }
            }
            .navigationTitle(settings.localizedString(for: "igel_customizer_titel"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }

    // MARK: - Name Edit Overlay View
    private var nameEditOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    if !zeigeZweiteBestaetigung {
                        withAnimation { zeigeNameEditOverlay = false }
                    }
                }
            
            VStack(spacing: 24) {
                HStack {
                    if zeigeZweiteBestaetigung {
                        Button(action: {
                            withAnimation { zeigeZweiteBestaetigung = false }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                                .foregroundStyle(.black)
                        }
                    }
                    Spacer()
                    Button(action: {
                        withAnimation { 
                            zeigeNameEditOverlay = false 
                            zeigeZweiteBestaetigung = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(.primary)
                    }
                }
                .padding(.bottom, -10)
                
                if !zeigeZweiteBestaetigung {
                    VStack(spacing: 8) {
                        Text(settings.localizedString(for: "igel_name_edit_title"))
                            .font(.system(size: 24, weight: .black, design: .rounded))
                        
                        Text(settings.localizedString(for: settings.igelCustomization.nameChangeCount == 0 ? "igel_name_edit_hint_free" : "igel_name_edit_hint_paid"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    TextField(settings.localizedString(for: "igel_name_placeholder"), text: $tempName)
                        .font(.headline)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blauPrimary.opacity(0.2), lineWidth: 1)
                        )
                    
                    Button(action: {
                        withAnimation { zeigeZweiteBestaetigung = true }
                    }) {
                        Text(settings.localizedString(for: "common_continue"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        backgroundColor: .blauPrimary,
                        shadowColor: .blauSecondary,
                        foregroundColor: .white
                    ))
                    .disabled(tempName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                } else {
                    // Zweite Bestätigung
                    VStack(spacing: 16) {
                        Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        Text(settings.localizedString(for: "igel_name_confirm_title"))
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .multilineTextAlignment(.center)
                        
                        Text(String(format: settings.localizedString(for: "igel_name_confirm_hint"), tempName))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    let cost = nameChangeCost
                    let canAfford = gardenStore.coins >= cost
                    
                    Button(action: {
                        if canAfford {
                            if cost > 0 {
                                gardenStore.coins -= cost
                            }
                            settings.igelCustomization.name = tempName
                            settings.igelCustomization.nameChangeCount += 1
                            withAnimation { 
                                zeigeNameEditOverlay = false 
                                zeigeZweiteBestaetigung = false
                            }
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    }) {
                        HStack(spacing: 12) {
                            if cost == 0 {
                                Text(settings.localizedString(for: "igel_name_edit_button_free"))
                            } else {
                                Image("coin")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                                Text("\(cost)")
                            }
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        backgroundColor: (canAfford || cost == 0) ? .blauPrimary : .gray,
                        shadowColor: (canAfford || cost == 0) ? .blauSecondary : .gray.darker(),
                        foregroundColor: .white
                    ))
                    .disabled(!canAfford)
                }
            }
            .padding(24)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            .padding(30)
        }
    }

    // MARK: - Pose Kachel
    func poseKachel(_ pose: IgelPose) -> some View {
        let ausgewaehlt = settings.igelCustomization.pose == pose
        return Button(action: {
            settings.igelCustomization.pose = pose
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            ZStack {
                settings.igelCustomization.background.color
                
                IgelView(
                    customization: IgelCustomization(
                        pose: pose,
                        accessoire: settings.igelCustomization.accessoire,
                        gesicht: settings.igelCustomization.gesicht,
                        background: settings.igelCustomization.background
                    ),
                    size: isLargePose(pose) ? 280 : 160
                )
                .offset(y: 0)
            }
            .frame(width: 160, height: 160)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(ausgewaehlt ? Color.blauPrimary : Color.black.opacity(0.08), lineWidth: ausgewaehlt ? 3 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Accessoire Kachel
    func accessoireKachel(_ acc: IgelAccessoire) -> some View {
        let ausgewaehlt = settings.igelCustomization.accessoire == acc
        return Button(action: {
            settings.igelCustomization.accessoire = acc
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            ZStack {
                settings.igelCustomization.background.color
                
                IgelView(
                    customization: IgelCustomization(
                        pose: settings.igelCustomization.pose,
                        accessoire: acc,
                        gesicht: settings.igelCustomization.gesicht,
                        background: settings.igelCustomization.background
                    ),
                    size: isLargePose(settings.igelCustomization.pose) ? 280 : 160
                )
                .offset(y: 0)
            }
            .frame(width: 160, height: 160)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(ausgewaehlt ? Color.blauPrimary : Color.black.opacity(0.08), lineWidth: ausgewaehlt ? 3 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Gesicht Kachel
    func gesichtKachel(_ gesicht: IgelGesicht) -> some View {
        let ausgewaehlt = settings.igelCustomization.gesicht == gesicht
        return Button(action: {
            settings.igelCustomization.gesicht = gesicht
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            ZStack {
                settings.igelCustomization.background.color
                
                IgelView(
                    customization: IgelCustomization(
                        pose: settings.igelCustomization.pose,
                        accessoire: settings.igelCustomization.accessoire,
                        gesicht: gesicht,
                        background: settings.igelCustomization.background
                    ),
                    size: isLargePose(settings.igelCustomization.pose) ? 280 : 160
                )
                .offset(y: 0)
            }
            .frame(width: 160, height: 160)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(ausgewaehlt ? Color.blauPrimary : Color.black.opacity(0.08), lineWidth: ausgewaehlt ? 3 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Hintergrund Kachel
    func hintergrundKachel(_ bg: IgelPortraitBackground) -> some View {
        let ausgewaehlt = settings.igelCustomization.background == bg
        return Button(action: {
            settings.igelCustomization.background = bg
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            ZStack {
                bg.color
                
                IgelView(
                    customization: IgelCustomization(
                        pose: settings.igelCustomization.pose,
                        accessoire: settings.igelCustomization.accessoire,
                        gesicht: settings.igelCustomization.gesicht,
                        background: bg
                    ),
                    size: isLargePose(settings.igelCustomization.pose) ? 280 : 160
                )
                .offset(y: 0)
            }
            .frame(width: 160, height: 160)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(ausgewaehlt ? Color.blauPrimary : Color.black.opacity(0.08), lineWidth: ausgewaehlt ? 3 : 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func isLargePose(_ pose: IgelPose) -> Bool {
        switch pose {
        case .stehend:
            return true
        default:
            return false
        }
    }
}
