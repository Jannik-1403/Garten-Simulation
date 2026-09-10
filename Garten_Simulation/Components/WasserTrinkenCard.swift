import SwiftUI
import HealthKit

struct WasserTrinkenCard: View {
    @ObservedObject var healthManager = HealthManager.shared
    @ObservedObject var goalManager = WaterGoalManager.shared
    @StateObject private var viewModel = WaterTrackerViewModel()
    
    @State private var zeigeHinzufuegenSheet = false
    @State private var manuelleMenge: String = "250"
    
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
                    
                    // Add Button
                    Button(action: {
                        zeigeHinzufuegenSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text(String(localized: "water.add.button", defaultValue: "Wasser hinzufügen"))
                        }
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 24)
                    }
                    .buttonStyle(DuolingoButtonStyle(size: .medium, fillWidth: true, backgroundColor: .cyan, shadowColor: .cyan.opacity(0.8), foregroundColor: .white))
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
                    HStack(spacing: 8) {
                        TextField("250", text: $manuelleMenge)
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
                    .padding(.top, 40)
                    
                    Button(action: {
                        if let amount = Double(manuelleMenge), amount > 0 {
                            // Optimistic UI update
                            healthManager.todaysWater += amount
                            viewModel.addWater(ml: amount)
                            manuelleMenge = "250"
                            zeigeHinzufuegenSheet = false
                        }
                    }) {
                        Text(String(localized: "common.save", defaultValue: "Speichern"))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .frame(height: 24)
                    }
                    .buttonStyle(DuolingoButtonStyle(size: .medium, fillWidth: true, backgroundColor: .cyan, shadowColor: .cyan.opacity(0.8), foregroundColor: .white))
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
