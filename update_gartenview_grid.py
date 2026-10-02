import re

file_path = "Garten_Simulation/Views/GartenView.swift"
with open(file_path, "r") as f:
    content = f.read()

# 1. Update pflanzenGridSection to a func
content = content.replace("private var pflanzenGridSection: some View {", "private func pflanzenGridSection(for offset: Int) -> some View {")

# 2. Update pageContent to pass the offset to pflanzenGridSection
content = content.replace("pflanzenGridSection\n", "pflanzenGridSection(for: offset)\n")

# 3. Add targetDate to PflanzenCard
# We need to find the PflanzenCard init inside the new func pflanzenGridSection(for offset: Int)
# The init looks like: PflanzenCard(\n    pflanze: pflanze,\n    onTap: ...\n)
# We need to add targetDate: Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date(),
# Let's use regex to find PflanzenCard(pflanze: pflanze, and add targetDate
content = re.sub(r'PflanzenCard\(\s*pflanze: pflanze,', r'PflanzenCard(\n                                pflanze: pflanze,\n                                targetDate: Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date(),', content)

with open(file_path, "w") as f:
    f.write(content)
