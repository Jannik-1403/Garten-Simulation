import SwiftUI

struct PflanzeDetailSheet: View {
    let pflanze: HabitModel
    var onLoeschen: (() -> Void)? = nil

    @State private var zeigeLoeschenDialog = false
    @State private var pulsieren = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    pflanze.seltenheit.farbe.opacity(0.1),
                    Color.clear,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pflanze.name)
                                .font(.system(size: 32, weight: .black, design: .rounded))
                            Text(pflanze.seltenheit.lokalisiertTitel)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(pflanze.seltenheit.farbe)
                        }
                        Spacer()
                    }
                    .padding(.top, 20)

                    // Hero Visual
                    ZStack {
                        Circle()
                            .fill(pflanze.seltenheit.farbe.opacity(0.15))
                            .frame(width: 220, height: 220)
                            .scaleEffect(pulsieren ? 1.05 : 1.0)
                        
                        Circle()
                            .stroke(pflanze.seltenheit.farbe.opacity(0.2), lineWidth: 10)
                            .frame(width: 200, height: 200)

                        Circle()
                            .trim(from: 0, to: pflanze.ringFortschritt)
                            .stroke(
                                pflanze.seltenheit.farbe,
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))

                        Image(pflanze.bildName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                    }
                    .padding(.vertical, 20)

                    // Stats Grid
                    HStack(spacing: 16) {
                        statBox(title: "profile.streak", value: "\(pflanze.streak)", icon: "flame.fill", color: .orange)
                        statBox(title: "profile.coins", value: "\(pflanze.currentXP)", icon: "star.fill", color: .yellow)
                    }

                    // Delete Button
                    Button(role: .destructive) {
                        zeigeLoeschenDialog = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("button.delete", bundle: .main)
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.top, 20)
                }
                .padding(24)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulsieren = true
            }
        }
        .confirmationDialog(
            Text("garden.plant.delete.title", bundle: .main),
            isPresented: $zeigeLoeschenDialog,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                onLoeschen?()
            } label: {
                Text("button.delete", bundle: .main)
            }
            
            Button(role: .cancel) {
                // No action
            } label: {
                Text("button.cancel", bundle: .main)
            }
        }
    }

    private func statBox(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 28, weight: .black, design: .rounded))
            Text(LocalizedStringKey(title))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
