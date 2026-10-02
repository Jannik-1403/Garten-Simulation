import re

file_path = "Garten_Simulation/Views/WaterTracker/DailyFeedbackView.swift"
with open(file_path, "r") as f:
    content = f.read()

# Replace PillButtonStyle with Liquid Glass style
old_style = """                .clipped()
            }
            .buttonStyle(PillButtonStyle(
                farbe: .white,
                sekundaerFarbe: Color(white: 0.85),
                cornerRadius: 16,
                shadowDepth: 6
            ))"""
new_style = """                .clipped()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            }
            .buttonStyle(.plain)"""
content = content.replace(old_style, new_style)

with open(file_path, "w") as f:
    f.write(content)
