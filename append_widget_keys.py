import json

keys = [
    "intent_water_fail", "intent_water_already_done", "intent_water_success",
    "widget_style_type", "widget_style_light", "widget_style_dark",
    "widget_period_type", "widget_period_today", "widget_period_week", "widget_period_month", "widget_period_alltime",
    "widget_intent_water_title", "widget_intent_water_desc",
    "widget_intent_streak_title", "widget_intent_history_title",
    "widget_routine_type", "widget_intent_routine_title", "widget_intent_routine_desc"
]

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

for k in keys:
    if k not in data["strings"]:
        data["strings"][k] = {"extractionState": "manual", "localizations": {}}

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Keys appended.")
