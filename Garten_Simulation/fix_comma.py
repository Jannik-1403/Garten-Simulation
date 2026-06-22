with open('Localization/AppStrings.swift', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace(']        "assessment.habits.build.title":', '],\n        "assessment.habits.build.title":')

with open('Localization/AppStrings.swift', 'w', encoding='utf-8') as f:
    f.write(content)

print("Comma fixed!")
