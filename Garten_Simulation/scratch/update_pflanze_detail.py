import re

filepath = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Views/PflanzeDetailSheet.swift'

with open(filepath, 'r') as f:
    content = f.read()

# Replace the whole Gratitude Journal block in PflanzeDetailSheet
old_block = """                    // Dankbarkeitsjournal
                    if pflanze.habitName == "habit.dankbarkeit" {
                        Button {
                            zeigeGratitudeJournal = true
                        } label: {
                            HStack {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.purple)
                                Text(String(localized: "habit.gratitude.open_journal", defaultValue: "Journal öffnen"))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                        .buttonStyle(.plain)
                        .sheet(isPresented: $zeigeGratitudeJournal) {
                            GratitudeJournalView(habit: pflanze)
                                .environmentObject(settings)
                                .environmentObject(gardenStore)
                        }
                    }"""

new_block = """                    // Dankbarkeitsjournal (Accordion wie Notizen)
                    if pflanze.habitName == "habit.dankbarkeit" {
                        DisclosureGroup(isExpanded: .constant(true)) {
                            VStack(spacing: 8) {
                                if pflanze.journalEntries.isEmpty {
                                    Text(String(localized: "habit.gratitude.empty", defaultValue: "Noch keine Einträge"))
                                        .font(.system(size: 14))
                                        .foregroundStyle(.secondary)
                                        .padding(.top, 8)
                                } else {
                                    let sortedEntries = pflanze.journalEntries.sorted(by: { $0.date > $1.date })
                                    ForEach(sortedEntries) { entry in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                                    .foregroundColor(.secondary)
                                                Text(entry.thankfulFor)
                                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                                    .foregroundColor(.primary)
                                                    .lineLimit(2)
                                            }
                                            Spacer()
                                            HStack(spacing: 2) {
                                                ForEach(0..<entry.mood, id: \.self) { _ in
                                                    Image("Powerup")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 14, height: 14)
                                                }
                                            }
                                        }
                                        .padding()
                                        .background(Color(UIColor.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.05), lineWidth: 1))
                                    }
                                }
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                        } label: {
                            HStack {
                                Text(String(localized: "habit.gratitude.title", defaultValue: "Journal"))
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                Spacer()
                                Item3DButton(
                                    farbe: .blauPrimary,
                                    sekundaerFarbe: .blauPrimary.darker(),
                                    groesse: 36,
                                    isRectangular: false,
                                    aktion: {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        zeigeGratitudeJournal = true
                                    }
                                ) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                        .tint(.primary)
                        .fullScreenCover(isPresented: $zeigeGratitudeJournal) {
                            GratitudeJournalView(habit: pflanze)
                                .environmentObject(settings)
                                .environmentObject(gardenStore)
                        }
                    }"""

content = content.replace(old_block, new_block)

with open(filepath, 'w') as f:
    f.write(content)

print("PflanzeDetailSheet updated.")
