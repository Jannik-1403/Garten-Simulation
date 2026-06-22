import re

# 1. AssessmentView.swift: Fix Category localization
path = 'Views/Profile/AssessmentView.swift'
with open(path, 'r') as f:
    content = f.read()

# Add settings to Category3DCard
# struct Category3DCard: View {
#    let category: HabitCategory
#    let isAvailable: Bool
#    let hasResult: Bool
#    let action: () -> Void
#    @EnvironmentObject var settings: SettingsStore

content = content.replace(
    'let action: () -> Void',
    'let action: () -> Void\n    @EnvironmentObject var settings: SettingsStore'
)

# Text(NSLocalizedString(category.localizationKey, comment: "")) -> Text(settings.localizedString(for: category.localizationKey))
content = content.replace(
    'Text(NSLocalizedString(category.localizationKey, comment: ""))',
    'Text(settings.localizedString(for: category.localizationKey))'
)

# Fix Category3DCard call:
content = content.replace(
    'hasResult: resultExists(for: category)',
    'hasResult: resultExists(for: category)\n                                ) {\n                                    if available.contains(category) {\n                                        selectedCategory = category\n                                    }\n                                }\n                                .environmentObject(settings)'
)
# Wait, the block was:
#                                 Category3DCard(
#                                     category: category,
#                                     isAvailable: available.contains(category),
#                                     hasResult: resultExists(for: category)
#                                 ) {
#                                     if available.contains(category) {
#                                         selectedCategory = category
#                                     }
#                                 }

# I should use regex to insert .environmentObject(settings) safely.
content = re.sub(
    r'(Category3DCard\([^)]+\)\s*\{\s*if available\.contains\(category\) \{\s*selectedCategory = category\s*\}\s*\})',
    r'\1\n                                .environmentObject(settings)',
    content
)

with open(path, 'w') as f:
    f.write(content)
print("Updated AssessmentView.swift")
