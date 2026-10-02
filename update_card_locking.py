import re

file_path = "Garten_Simulation/Components/PflanzenCard.swift"
with open(file_path, "r") as f:
    content = f.read()

# 1. Sperre DragGesture für targetDate < today
drag_changed_old = """                .onChanged { value in
                    guard healthProgress == nil, !pflanze.wasCompleted(on: targetDate), !pflanze.isDead else { return }"""
drag_changed_new = """                .onChanged { value in
                    guard Calendar.current.isDateInToday(targetDate) else { return }
                    guard healthProgress == nil, !pflanze.wasCompleted(on: targetDate), !pflanze.isDead else { return }"""
content = content.replace(drag_changed_old, drag_changed_new)

# 2. Sperre onTap (LongPress und regulärer Tap)
# Der onTap-Aufruf geschieht hier:
on_tap_old = """                    } else {
                        onTap()
                    }"""
on_tap_new = """                    } else {
                        if Calendar.current.isDateInToday(targetDate) {
                            onTap()
                        }
                    }"""
content = content.replace(on_tap_old, on_tap_new)

# 3. MinimumDistance auf 15 erhöhen (5 war zu krass)
content = content.replace("DragGesture(minimumDistance: 5)", "DragGesture(minimumDistance: 15)")

with open(file_path, "w") as f:
    f.write(content)
