import os

views_to_update = [
    "Garten_Simulation/Views/Profile/FitnessAssessmentViews.swift",
    "Garten_Simulation/Views/Profile/GrowthAssessmentViews.swift",
    "Garten_Simulation/Views/Profile/LifestyleAssessmentViews.swift",
    "Garten_Simulation/Views/Profile/MentalAssessmentViews.swift",
    "Garten_Simulation/Views/Profile/AssessmentView.swift",
    "Garten_Simulation/Views/Profile/HealthAssessmentViews.swift",
]

for filepath in views_to_update:
    with open(filepath, "r") as f:
        content = f.read()

    # NSLocalizedString(currentQuestion.textKey, comment: "") -> PercentHelper.localizedWithPercents(currentQuestion.textKey)
    content = content.replace(
        'NSLocalizedString(currentQuestion.textKey, comment: "")',
        'PercentHelper.localizedWithPercents(currentQuestion.textKey)'
    )
    
    content = content.replace(
        'NSLocalizedString(answer.textKey, comment: "")',
        'PercentHelper.localizedWithPercents(answer.textKey)'
    )
    
    with open(filepath, "w") as f:
        f.write(content)
