with open("Garten_Simulation/Views/Profile/DynamicAssessmentInsightsView.swift", "r") as f:
    content = f.read()

content = content.replace(
    'String(localized: String.LocalizationValue(insight.titleKey))',
    'PercentHelper.localizedWithPercents(insight.titleKey)'
)
content = content.replace(
    'String(localized: String.LocalizationValue(insight.descriptionKey))',
    'PercentHelper.localizedWithPercents(insight.descriptionKey)'
)

with open("Garten_Simulation/Views/Profile/DynamicAssessmentInsightsView.swift", "w") as f:
    f.write(content)
