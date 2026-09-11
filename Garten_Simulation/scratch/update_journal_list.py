import re

filepath = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Views/PflanzeDetailSheet.swift'

with open(filepath, 'r') as f:
    content = f.read()

# 1. Add State variable
content = re.sub(r'(@State private var zeigeGratitudeJournal = false\n)', 
                 r'\1    @State private var selectedJournalEntry: GratitudeJournalEntry? = nil\n', 
                 content)

# 2. Replace the rendering of the list entry
old_list_item = """                                        HStack {
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
                                                ForEach(0..<entry.mood, id: \\.self) { _ in
                                                    Image("Powerup")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 14, height: 14)
                                                }
                                            }
                                        }
                                        .padding()
                                        .background(Color(UIColor.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.05), lineWidth: 1))"""

new_list_item = """                                        Button {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            selectedJournalEntry = entry
                                        } label: {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                                        .foregroundColor(.secondary)
                                                    Text(entry.thankfulFor)
                                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                                        .foregroundColor(.primary)
                                                        .lineLimit(2)
                                                        .multilineTextAlignment(.leading)
                                                }
                                                Spacer()
                                                HStack(spacing: 2) {
                                                    ForEach(0..<entry.mood, id: \\.self) { _ in
                                                        Image("Powerup")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 14, height: 14)
                                                    }
                                                }
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                                        }
                                        .buttonStyle(.plain)"""

content = content.replace(old_list_item, new_list_item)

# 3. Add fullScreenCover for selectedJournalEntry right after the fullScreenCover for zeigeGratitudeJournal
old_full_screen = """                        .fullScreenCover(isPresented: $zeigeGratitudeJournal) {
                            GratitudeJournalView(habit: pflanze)
                                .environmentObject(settings)
                                .environmentObject(gardenStore)
                        }"""

new_full_screen = """                        .fullScreenCover(isPresented: $zeigeGratitudeJournal) {
                            GratitudeJournalView(habit: pflanze)
                                .environmentObject(settings)
                                .environmentObject(gardenStore)
                        }
                        .fullScreenCover(item: $selectedJournalEntry) { entry in
                            GratitudeJournalDetailView(entry: entry)
                        }"""

content = content.replace(old_full_screen, new_full_screen)

with open(filepath, 'w') as f:
    f.write(content)

print("List items replaced.")
