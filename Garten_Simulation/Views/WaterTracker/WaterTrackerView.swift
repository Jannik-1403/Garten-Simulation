import SwiftUI
import HealthKit

struct WaterTrackerView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @StateObject private var viewModel = WaterTrackerViewModel()
    @ObservedObject private var goalManager = WaterGoalManager.shared
    @ObservedObject private var healthManager = HealthManager.shared
    
    @State private var showGoalDetails = false
    @State private var showCustomAmounts = false
    @State private var showEditGoalSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Progress Section
                VStack(spacing: 16) {
                    ChunkyProgressRing(progress: healthManager.todaysWater, goal: goalManager.currentGoal)
                        .frame(width: 250, height: 250)

                    
                    // Goal Details Toggle
                    Button(action: {

                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showGoalDetails.toggle()
                        }
                    }) {
                        HStack {
                            Text(String(localized: "water.goal.details", defaultValue: "Tagesziel-Berechnung"))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                            Image(systemName: showGoalDetails ? "chevron.up" : "chevron.down")
                        }
                        .foregroundColor(.gray)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    
                    if showGoalDetails {
                        GoalDetailsView(goalManager: goalManager, onEditGoal: {
                            showEditGoalSheet = true
                        })
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.top, 24)
                
                // Track Buttons
                VStack(spacing: 20) {
                    HStack(spacing: 16) {
                        WaterAddButton(
                            amount: 250,
                            icon: "drop.fill",
                            title: String(localized: "water.glass", defaultValue: "Glas"),
                            color: .cyan,
                            shadowColor: .cyan.opacity(0.6)
                        ) {
                            viewModel.addWater(ml: 250)
                        }
                        
                        WaterAddButton(
                            amount: 500,
                            icon: "bottle.fill",
                            title: String(localized: "water.bottle", defaultValue: "Flasche"),
                            color: .blue,
                            shadowColor: .blue.opacity(0.6)
                        ) {
                            viewModel.addWater(ml: 500)
                        }
                    }
                    
                    Button(action: {
                        showCustomAmounts = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text(String(localized: "water.other", defaultValue: "Andere Menge"))
                        }
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .padding(.horizontal)
                }
                
                // History List
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(localized: "water.history", defaultValue: "Verlauf Heute"))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .padding(.horizontal)
                    
                    if viewModel.todaysEntries.isEmpty {
                        Text(String(localized: "water.history.empty", defaultValue: "Noch kein Wasser getrunken heute."))
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    } else {
                        ForEach(viewModel.todaysEntries) { entry in
                            HStack {
                                Image(systemName: entry.isManualAppEntry ? "drop.fill" : "apple.logo")
                                    .foregroundColor(entry.isManualAppEntry ? .blue : .red)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading) {
                                    Text("\(Int(entry.amountMl)) ml")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                    Text(entry.date, style: .time)
                                        .font(.system(size: 12, design: .rounded))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                if entry.isManualAppEntry {
                                    Text(String(localized: "water.source.app", defaultValue: "Manuell"))
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .clipShape(Capsule())
                                } else {
                                    Text(entry.source)
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.red.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, 16)
                
                Spacer(minLength: 40)
            }
            .padding(.bottom, 32)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(String(localized: "water.title", defaultValue: "Wasser"))
        .sheet(isPresented: $showCustomAmounts) {
            CustomAmountsSheet(viewModel: viewModel)
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showEditGoalSheet) {
            EditWaterGoalSheet(goalManager: goalManager)
                .presentationDragIndicator(.visible)
        }
        .onChange(of: healthManager.todaysWater) { _, newValue in
            if newValue >= goalManager.currentGoal {
                if let waterPlant = gardenStore.pflanzen.first(where: { $0.habitName == "habit.wasser_trinken" }) {
                    if !waterPlant.istBewässert {
                        gardenStore.giessen(pflanze: waterPlant)
                    }
                }
            }
        }
    }
}

struct GoalDetailsView: View {
    @ObservedObject var goalManager: WaterGoalManager
    var onEditGoal: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "water.goal.explanation", defaultValue: "Dein Tagesziel berechnet sich dynamisch anhand deines Körpergewichts und deiner Aktivität. Du kannst es aber auch manuell festlegen."))
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
                
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
            
            HStack {
                Text(String(localized: "water.goal.total", defaultValue: "Heutiges Ziel"))
                    .font(.system(size: 16, weight: .black, design: .rounded))
                Spacer()
                Text("\(Int(goalManager.currentGoal)) ml")
                    .font(.system(size: 16, weight: .black, design: .rounded))
            }
            
            if goalManager.customMinGoal > 0 || goalManager.customMaxGoal > 0 {
                Text(String(localized: "water.goal.manual_active", defaultValue: "Manuelles Ziel ist aktiv."))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.blue)
                    .padding(.top, 4)
            }
            
            Button(action: onEditGoal) {
                Text(String(localized: "water.goal.edit_button", defaultValue: "Ziel manuell bearbeiten"))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 32)
    }
}

struct GoalDetailRow: View {
    var title: String
    var amount: Double
    var color: Color = .primary
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
            Spacer()
            Text("+\(Int(amount)) ml")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
    }
}

struct WaterAddButton: View {
    var amount: Double
    var icon: String
    var title: String
    var color: Color
    var shadowColor: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Text("+\(Int(amount)) ml")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .opacity(0.8)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 120)
        }
        .buttonStyle(WaterDuolingoButtonStyle(color: color, shadowColor: shadowColor))
    }
}

struct CustomAmountsSheet: View {
    @ObservedObject var viewModel: WaterTrackerViewModel
    @Environment(\.dismiss) var dismiss
    
    let amounts: [Double] = [100, 150, 300, 750]
    
    var body: some View {
        VStack(spacing: 24) {
            Text(String(localized: "water.custom.title", defaultValue: "Andere Menge hinzufügen"))
                .font(.system(size: 20, weight: .black, design: .rounded))
                .padding(.top, 24)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(amounts, id: \.self) { amount in
                    Button(action: {
                        viewModel.addWater(ml: amount)
                        dismiss()
                    }) {
                        Text("+\(Int(amount)) ml")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(WaterDuolingoButtonStyle(color: .indigo, shadowColor: .indigo.opacity(0.6)))
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

struct EditWaterGoalSheet: View {
    @ObservedObject var goalManager: WaterGoalManager
    @Environment(\.dismiss) var dismiss
    
    @State private var customGoalText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(String(localized: "water.goal.edit_title", defaultValue: "Manuelles Tagesziel"))
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .padding(.top, 32)
                
                Text(String(localized: "water.goal.edit_desc", defaultValue: "Überschreibe die automatische Berechnung mit einem festen Ziel in ml."))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                HStack(spacing: 8) {
                    TextField(String(localized: "water.goal.edit_placeholder", defaultValue: "Z.B. 2500"), text: $customGoalText)
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
                
                Button {
                    if let val = Double(customGoalText), val > 0 {
                        goalManager.customMinGoal = val
                        goalManager.customMaxGoal = val
                        goalManager.recalculateGoal(bodyMass: HealthManager.shared.latestBodyMass, steps: HealthManager.shared.todaysSteps, enduranceMinutes: HealthManager.shared.todaysRunning, strengthMinutes: HealthManager.shared.todaysStrengthTraining)
                        dismiss()
                    }
                } label: {
                    Text(String(localized: "common.save", defaultValue: "Speichern"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(customGoalText.isEmpty ? Color.gray : Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(customGoalText.isEmpty)
                .padding(.horizontal, 40)
                
                Button {
                    goalManager.customMinGoal = 0
                    goalManager.customMaxGoal = 0
                    goalManager.recalculateGoal(bodyMass: HealthManager.shared.latestBodyMass, steps: HealthManager.shared.todaysSteps, enduranceMinutes: HealthManager.shared.todaysRunning, strengthMinutes: HealthManager.shared.todaysStrengthTraining)
                    dismiss()
                } label: {
                    Text(String(localized: "water.goal.edit_reset", defaultValue: "Auf automatisch zurücksetzen"))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.red)
                }
                .padding(.top, 12)
                
                Spacer()
            }
            .onAppear {
                if goalManager.customMinGoal > 0 {
                    customGoalText = String(Int(goalManager.customMinGoal))
                }
            }
        }
        .presentationDetents([.height(450)])
    }
}
