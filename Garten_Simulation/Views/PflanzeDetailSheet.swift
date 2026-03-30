import SwiftUI

struct PflanzeDetailSheet: View {
    let pflanze: HabitModel
    @EnvironmentObject var settings: SettingsStore
    var onLoeschen: (() -> Void)? = nil

    @State private var zeigeLoeschenDialog = false
    @State private var pulsieren = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    pflanze.color.opacity(0.15),
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
                            Text(settings.localizedString(for: pflanze.name))
                                .font(.system(size: 32, weight: .black, design: .rounded))
                            HStack {
                                Text(settings.localizedString(for: pflanze.habitCategory.rawValue))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(pflanze.color)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(pflanze.color.opacity(0.1)))
                                
                                Text(pflanze.seltenheit.lokalisiertTitel)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(pflanze.seltenheit.farbe)
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 20)

                    // Hero Visual
                    ZStack {
                        Circle()
                            .fill(pflanze.color.opacity(0.15))
                            .frame(width: 220, height: 220)
                            .scaleEffect(pulsieren ? 1.05 : 1.0)
                        
                        Circle()
                            .stroke(pflanze.color.opacity(0.2), lineWidth: 10)
                            .frame(width: 200, height: 200)

                        Circle()
                            .trim(from: 0, to: pflanze.ringFortschritt)
                            .stroke(
                                pflanze.seltenheit.farbe,
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))

                        Group {
                            if UIImage(named: pflanze.symbolName) != nil {
                                Image(pflanze.symbolName)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Image(systemName: pflanze.symbolName)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(pflanze.color)
                            }
                        }
                        .frame(width: 120, height: 120)
                        .shadow(color: pflanze.color.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.vertical, 20)
                    
                    // Symbolism Section
                    if !pflanze.symbolism.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(settings.localizedString(for: "garden.plant.symbolism.title"))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.secondary)
                                .kerning(1.2)
                            Text(settings.localizedString(for: pflanze.symbolism))
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(.primary.opacity(0.8))
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.5)))
                    }

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
                            Text(settings.localizedString(for: "button.delete"))
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
            Text(settings.localizedString(for: "garden.plant.delete.title")),
            isPresented: $zeigeLoeschenDialog,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                onLoeschen?()
            } label: {
                Text(settings.localizedString(for: "button.delete"))
            }
            
            Button(role: .cancel) {
                // No action
            } label: {
                Text(settings.localizedString(for: "button.cancel"))
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
            Text(settings.localizedString(for: title))
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
