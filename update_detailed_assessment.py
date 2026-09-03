with open("Garten_Simulation/Views/Profile/DetailedAssessmentAnalysisView.swift", "r") as f:
    content = f.read()

content = content.replace(
    'String(localized: String.LocalizationValue(result.topStrengthKey))',
    'PercentHelper.localizedWithPercents(result.topStrengthKey)'
)
content = content.replace(
    'String(localized: String.LocalizationValue(result.biggestWeaknessKey))',
    'PercentHelper.localizedWithPercents(result.biggestWeaknessKey)'
)
content = content.replace(
    'String(localized: String.LocalizationValue(result.pitfallKey))',
    'PercentHelper.localizedWithPercents(result.pitfallKey)'
)
content = content.replace(
    'String(localized: String.LocalizationValue(result.benchmarkKey))',
    'PercentHelper.localizedWithPercents(result.benchmarkKey)'
)

with open("Garten_Simulation/Views/Profile/DetailedAssessmentAnalysisView.swift", "w") as f:
    f.write(content)
