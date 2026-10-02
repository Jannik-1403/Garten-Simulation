import re

file_path = "Garten_Simulation/Views/WaterTracker/DailyFeedbackView.swift"
with open(file_path, "r") as f:
    content = f.read()

# 1. Remove the Date Header HStack from DailyFeedbackView
old_header = """            // Date Header
            HStack {
                Button {
                    showCalendarSheet = true
                } label: {
                    dateLabel(for: vm.targetDate)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                }
                Spacer()
            }

            // MARK: Kopfzeile (Score)"""

new_header = """            // MARK: Kopfzeile (Score)"""
content = content.replace(old_header, new_header)

# 2. Wir können die Methode dateLabel in DailyFeedbackView drinnen lassen, aber sie wird nicht mehr im Body aufgerufen.
# Besser ist, wir nehmen die Funktionalität für dateLabel drüben in GartenView. 

with open(file_path, "w") as f:
    f.write(content)
