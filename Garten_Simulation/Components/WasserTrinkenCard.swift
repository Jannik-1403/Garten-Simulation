import SwiftUI
import HealthKit

struct WasserTrinkenCard: View {
    @ObservedObject var healthManager = HealthManager.shared
    @ObservedObject var goalManager = WaterGoalManager.shared
    @StateObject private var viewModel = WaterTrackerViewModel()
    
    @State private var zeigeHinzufuegenSheet = false
    @State private var manuelleMenge: String = ""
    
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
                        TextField(String(localized: "water.add.placeholder", defaultValue: "z.B. 250"), text: $manuelleMenge)
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
    }
}
