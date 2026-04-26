import SwiftUI

struct DayPickerView: View {
    @Binding var selectedDay: Int // 0-indexed (0 = Tag 1)
    let heute: Int
    @EnvironmentObject var pfadStore: GartenPfadStore
    @Environment(\.dismiss) var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 6)

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(0..<90) { i in
                            let dayNum = i + 1
                            let isSelected = selectedDay == i
                            let isHeute = dayNum == heute
                            let isErledigt = pfadStore.istTagVollstaendigErledigt(tagNummer: dayNum)

                            let farbe: Color = isSelected ? .blauPrimary : (isErledigt ? .green : Color(uiColor: .secondarySystemGroupedBackground))
                            let sekFarbe: Color = farbe.darker(by: 0.2)

                            Item3DButton(
                                farbe: farbe,
                                sekundaerFarbe: sekFarbe,
                                groesse: 46,
                                isRectangular: false,
                                aktion: {
                                    selectedDay = i
                                    dismiss()
                                }
                            ) {
                                VStack(spacing: 0) {
                                    Text("\(dayNum)")
                                        .font(.system(size: 15, weight: .black, design: .rounded))
                                        .foregroundStyle(isSelected ? .white : (isErledigt ? .white : .black))

                                    if isHeute {
                                        Circle()
                                            .fill(isSelected ? .white : Color.blauPrimary)
                                            .frame(width: 4, height: 4)
                                    }
                                }
                            }
                            .id(i)
                        }
                    }
                    .padding(16)
                }
                .onAppear {
                    // Scroll zum ausgewählten Tag, aber nur wenn er nicht in den ersten Reihen ist
                    let targetRow = selectedDay / 6
                    if targetRow > 1 {
                        withAnimation {
                            proxy.scrollTo(selectedDay, anchor: .center)
                        }
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle(NSLocalizedString("common.select_day", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(NSLocalizedString("common.close", comment: "")) {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                }
            }
        }
    }
}
