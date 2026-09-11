import os

files = [
    "OnboardingWillkommenView.swift",
    "OnboardingInteractiveTutorialView.swift",
    "OnboardingTutorialWeedView.swift",
    "OnboardingPflanzenView.swift",
    "OnboardingZielView.swift",
    "OnboardingCustomPlantView.swift",
    "OnboardingZeitView.swift",
    "OnboardingNotificationView.swift",
    "OnboardingScreenTimeView.swift",
    "OnboardingFertigView.swift",
    "GoalOnboardingView.swift",
    "WeeklyGoalOnboardingView.swift",
    "OnboardingLegalView.swift"
]

base_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Onboarding"

for filename in files:
    filepath = os.path.join(base_path, filename)
    if not os.path.exists(filepath):
        continue
        
    with open(filepath, "r") as f:
        content = f.read()

    # Change container width from 500 to 650
    content = content.replace(".frame(maxWidth: 500)", ".frame(maxWidth: 650)")
    
    # Remove extra paddings that make fields too narrow
    content = content.replace(".padding(.horizontal, 32)", "")

    with open(filepath, "w") as f:
        f.write(content)
    
    print(f"Updated {filename}")
