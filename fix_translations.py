import json

file_path = 'Garten_Simulation/Localizable.xcstrings'
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Correct translations for health.metric.calories
correct_calories = {
    "en": "Calories",
    "fr": "Calories",
    "ru": "Калории",
    "hi": "कैलोरी",
    "tr": "Kalori",
    "pt-BR": "Calorias",
    "pt": "Calorias",
    "es": "Calorías",
    "it": "Calorie",
    "ja": "カロリー",
    "ko": "칼로리",
    "nl": "Calorieën",
    "pl": "Kalorie",
    "zh-Hans": "卡路里",
    "zh-Hant": "卡路里",
    "de": "Kalorien"
}

# Apply to health.metric.calories
if "health.metric.calories" in data["strings"]:
    localizations = data["strings"]["health.metric.calories"].get("localizations", {})
    for lang, trans in correct_calories.items():
        if lang not in localizations:
            localizations[lang] = {"stringUnit": {"state": "translated"}}
        localizations[lang]["stringUnit"]["value"] = trans
        localizations[lang]["stringUnit"]["state"] = "translated"
    data["strings"]["health.metric.calories"]["localizations"] = localizations

# There might also be a key "calorie.calc.title" or similar with wrong translations?
# Let's just fix health.metric.calories for now.

# Also, the prompt mentioned Japanese "ToDo". Let's check type.todo.
# Japanese was "やるべきこと" (Yarubekikoto). But the user said "ToDo" was used instead of "タスク" (Task).
# Let's change type.todo in ja to "タスク"
if "type.todo" in data["strings"]:
    if "ja" in data["strings"]["type.todo"].get("localizations", {}):
        data["strings"]["type.todo"]["localizations"]["ja"]["stringUnit"]["value"] = "タスク"

# Write back
with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
