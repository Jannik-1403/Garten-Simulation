import re

file_path = "Garten_Simulation/Localization/AppStrings.swift"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Keys to add
new_keys = """
        "trigger.boredom": ["de": "Langeweile", "en": "Boredom"],
        "trigger.stress": ["de": "Stress", "en": "Stress"],
        "trigger.sadness": ["de": "Traurigkeit", "en": "Sadness"],
        "trigger.loneliness": ["de": "Einsamkeit", "en": "Loneliness"],
        "trigger.fatigue": ["de": "Müdigkeit", "en": "Fatigue"],
        "trigger.reward": ["de": "Als Belohnung", "en": "As a reward"],
        "trigger.social_pressure": ["de": "Sozialer Druck", "en": "Social pressure"],
        "trigger.relapse_note": ["de": "Rückfall durch: %@", "en": "Relapse due to: %@"],
        "trigger.all_habits": ["de": "Alle Gewohnheiten", "en": "All habits"],
        "trigger.no_triggers": ["de": "Keine Auslöser in diesem Zeitraum erfasst.", "en": "No triggers recorded in this period."],
        "trigger.title": ["de": "Häufigste Auslöser", "en": "Most Frequent Triggers"],
        "trigger.selection_title": ["de": "Auslöser", "en": "Triggers"],
        "trigger.save_button": ["de": "Rückfall Speichern", "en": "Save Relapse"],
        "trigger.own_trigger": ["de": "Eigener Auslöser", "en": "Custom Trigger"],
        "trigger.own_trigger_desc": ["de": "Gib einen eigenen Grund für diesen Rückfall ein.", "en": "Enter a custom reason for this relapse."],
        "trigger.trigger_name": ["de": "Name des Auslösers", "en": "Trigger Name"],
        "trigger.add": ["de": "Hinzufügen", "en": "Add"],
        "trigger.cancel": ["de": "Abbrechen", "en": "Cancel"],
"""

# Insert before the closing brace of the `all` dictionary
if "static let all: [String: [String: String]] = [" in content:
    # Find the closing brace of `all`
    # We can just look for the last `    ]` before the end of the file or class
    # Actually, let's just insert it after the first `{` of `all`
    pattern = r'(static let all: \[String: \[String: String\]\] = \[)'
    content = re.sub(pattern, r'\1\n' + new_keys, content, count=1)
    
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Keys added to AppStrings.swift")
else:
    print("Could not find static let all dictionary.")

