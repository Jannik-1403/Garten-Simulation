import re
import os

files = [
    'Views/Profile/GrowthAssessmentViews.swift',
    'Views/Profile/MentalAssessmentViews.swift',
    'Views/Profile/HealthAssessmentViews.swift',
    'Views/Profile/FitnessAssessmentViews.swift',
    'Views/Profile/LifestyleAssessmentViews.swift',
]

for filepath in files:
    with open(filepath, 'r') as f:
        content = f.read()

    # 1. Remove the inline "Close" HStack button (the custom xmark inside ScrollView)
    content = re.sub(
        r'\s*// Close\s*\n\s*HStack \{\s*\n\s*Spacer\(\)\s*\n\s*Button \{ dismiss\(\) \} label: \{\s*\n\s*Image\(systemName: "xmark\.circle\.fill"\)\s*\n\s*\.font\([^)]+\)\s*\n\s*\.foregroundStyle\([^)]+\)\s*\n\s*\}\s*\n\s*\}\s*\n\s*\.padding\(\.horizontal, 24\)\s*\n\s*\.padding\(\.top, 20\)',
        '',
        content
    )

    # 2. Add .navigationBarHidden(false), .navigationBarBackButtonHidden(true) and toolbar close button
    #    right before the closing of the ZStack body
    # We find the `}` that closes the ZStack body of ResultView
    # Pattern: after the ScrollView closing `}` and before the last `}` of body
    # We look for the pattern `        }\n    }\n}` at end of ResultView struct

    content = content.replace(
        '        }\n    }\n}\n\n// MARK: -',
        '        }\n        .navigationBarBackButtonHidden(true)\n        .toolbar {\n            ToolbarItem(placement: .topBarTrailing) {\n                Button {\n                    dismiss()\n                } label: {\n                    Image(systemName: "xmark")\n                        .font(.system(size: 16, weight: .semibold))\n                        .foregroundStyle(.secondary)\n                        .padding(8)\n                        .background(Color(UIColor.systemGray5), in: Circle())\n                }\n            }\n        }\n    }\n}\n\n// MARK: -',
        1
    )

    # 3. Fix the Retake button: add horizontal padding so it's not edge to edge
    # Change DuolingoButtonStyle size from .medium (full-ish) to .medium but with horizontal padding
    # We wrap the Button with .padding(.horizontal, 20)
    content = content.replace(
        '        .buttonStyle(DuolingoButtonStyle(\n            size: .medium,\n            backgroundColor: Color(hex: "#007AFF"),\n            shadowColor: Color(uiColor: .systemGray3),\n            foregroundColor: .white\n        ))',
        '        .buttonStyle(DuolingoButtonStyle(\n            size: .medium,\n            backgroundColor: Color(hex: "#007AFF"),\n            shadowColor: Color(hex: "#0055CC"),\n            foregroundColor: .white\n        ))\n        .padding(.horizontal, 20)'
    )

    with open(filepath, 'w') as f:
        f.write(content)
    print(f"Updated {filepath}")

