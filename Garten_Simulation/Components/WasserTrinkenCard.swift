import SwiftUI
import HealthKit

struct WasserTrinkenCard: View {
    @ObservedObject var healthManager = HealthManager.shared
    @ObservedObject var goalManager = WaterGoalManager.shared
    @StateObject private var viewModel = WaterTrackerViewModel()
    
    @State private var zeigeHinzufuegenSheet = false
    @State private var manuelleMenge: String = ""
    @State private var showGoalDetails = false
    @State private var showEditGoalSheet = false
    
    var onUnlink: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .center, spacing: 24) {
                    // Title
                    HStack {
                        Text(String(localized: "water.title", defaultValue: "Wasser"))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        Spacer()
                        Item3DButton(
                            farbe: .cyan,
                            sekundaerFarbe: .cyan.opacity(0.8),
                            groesse: 40,
                            isRectangular: false,
                            aktion: { showGoalDetails = true }
                        ) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Progress Ring
                    ChunkyProgressRing(progress: healthManager.todaysWater, goal: goalManager.currentGoal)
                        .frame(width: 200, height: 200)
                    
                    // Text
                    Text("\(Int(healthManager.todaysWater)) / \(Int(goalManager.currentGoal)) ml")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.blue)
                    
                    // Add Button
                    Item3DButton(
                        farbe: .cyan,
                        sekundaerFarbe: .cyan.opacity(0.8),
                        groesse: 56,
                        isRectangular: true,
                        aktion: {
                            zeigeHinzufuegenSheet = true
                        }
                    ) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text(String(localized: "water.add.button", defaultValue: "Wasser hinzufügen"))
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                    }
                    .frame(height: 56)
                }
                .padding(24)
                
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
            .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
        }
        .sheet(isPresented: $zeigeHinzufuegenSheet) {
            NavigationStack {
                VStack(spacing: 24) {
                    Text(String(localized: "water.add.title", defaultValue: "Wie viel ml hast du getrunken?"))
                        .font(.headline)
                        .padding(.top, 32)
                    
                    HStack(spacing: 8) {
                        TextField(String(localized: "water.add.placeholder", defaultValue: "250"), text: $manuelleMenge)
                            .keyboardType(.numberPad)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                        
                        Text("ml")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 40)
                    
                    Item3DButton(
                        farbe: .cyan,
                        sekundaerFarbe: .cyan.opacity(0.8),
                        groesse: 56,
                        isRectangular: true,
                        aktion: {
                            if let amount = Double(manuelleMenge), amount > 0 {
                                // Optimistic UI update
                                healthManager.todaysWater += amount
                                viewModel.addWater(ml: amount)
                                manuelleMenge = ""
                                zeigeHinzufuegenSheet = false
                            }
                        }
                    ) {
                        Text(String(localized: "common.save", defaultValue: "Speichern"))
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(height: 56)
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { zeigeHinzufuegenSheet = false }) {
                            Text(String(localized: "common.cancel", defaultValue: "Abbrechen"))
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .presentationDetents([.height(350)])
        }
        .sheet(isPresented: $showEditGoalSheet) {
            EditWaterGoalSheet(goalManager: goalManager)
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showGoalDetails) {
            WaterSettingsSheet(goalManager: goalManager, onEditGoal: {
                showEditGoalSheet = true
            })
        }
    }
}

struct WaterSettingsSheet: View {
    @ObservedObject var goalManager: WaterGoalManager
    @Environment(\.dismiss) var dismiss
    var onEditGoal: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    // Erklär-Block auf weißem 3D Hintergrund
                    VStack(alignment: .leading, spacing: 16) {
                        Text(String(localized: "water.goal.explanation", defaultValue: "Dein Tagesziel berechnet sich dynamisch: Dein Körpergewicht × 33 ml als Basisbedarf. Pro 1.000 Schritte (ab 8.000) kommen 150 ml hinzu. Pro 15 Min. Ausdauer gibt es +400 ml und pro 15 Min. Krafttraining +200 ml. Du kannst es aber auch manuell überschreiben."))
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            
                        GoalDetailRow(title: String(localized: "water.goal.base", defaultValue: "Basisbedarf"), amount: goalManager.baseGoal)
                        
                        if goalManager.stepBonus > 0 {
                            GoalDetailRow(title: String(localized: "water.goal.steps", defaultValue: "Schritte Bonus"), amount: goalManager.stepBonus, color: .orange)
                        }
                        if goalManager.strengthBonus > 0 {
                            GoalDetailRow(title: String(localized: "water.goal.strength", defaultValue: "Krafttraining Bonus"), amount: goalManager.strengthBonus, color: .purple)
                        }
                        if goalManager.enduranceBonus > 0 {
                            GoalDetailRow(title: String(localized: "water.goal.endurance", defaultValue: "Ausdauer Bonus"), amount: goalManager.enduranceBonus, color: .red)
                        }
                        
                        Divider()
                        
                        Button(action: {
                            onEditGoal()
                        }) {
                            HStack {
                                Text(String(localized: "water.goal.total", defaultValue: "Heutiges Ziel"))
                                    .font(.system(size: 16, weight: .black, design: .rounded))
                                    .foregroundColor(.primary)
                                Spacer()
                                HStack(spacing: 4) {
                                    Text("\(Int(goalManager.currentGoal)) ml")
                                        .font(.system(size: 16, weight: .black, design: .rounded))
                                        .foregroundColor(.primary)
                                    Image(systemName: "pencil")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        if goalManager.customMinGoal > 0 || goalManager.customMaxGoal > 0 {
                            Text(String(localized: "water.goal.manual_active", defaultValue: "Manuelles Ziel ist aktiv."))
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(24)
                    .item3DContainer(farbe: .white, sekundaerFarbe: Color(UIColor.systemGray5))
                    .padding(.horizontal, 24)
                    
                    VStack(spacing: 16) {
                        // Zurücksetzen Button
                        Button {
                            goalManager.customMinGoal = 0
                            goalManager.customMaxGoal = 0
                            goalManager.recalculateGoal(bodyMass: HealthManager.shared.latestBodyMass, steps: HealthManager.shared.todaysSteps, enduranceMinutes: HealthManager.shared.todaysRunning, strengthMinutes: HealthManager.shared.todaysStrengthTraining)
                        } label: {
                            Text(String(localized: "water.goal.edit_reset", defaultValue: "Auf automatisch zurücksetzen"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.red)
                                .underline()
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.vertical, 32)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(String(localized: "water.goal.details", defaultValue: "Tagesziel-Berechnung"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                            .font(.system(size: 16, weight: .bold))
                    }
                }
            }
        }
    }
}
