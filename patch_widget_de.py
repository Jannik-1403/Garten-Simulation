import json

file_path = 'Garten_Simulation/Localizable.xcstrings'
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

patches = {
    "widget_intent_history_title": "Verlauf-Widget anpassen",
    "widget_intent_routine_desc": "Wähle eine Routine und den Hintergrund.",
    "widget_intent_routine_title": "Routine-Widget anpassen",
    "widget_intent_streak_title": "Streak-Widget anpassen",
    "widget_intent_water_desc": "Hintergrund wählen.",
    "widget_intent_water_title": "Wasser-Widget anpassen",
    "widget_period_alltime": "Gesamt",
    "widget_period_month": "Dieser Monat",
    "widget_period_today": "Heute",
    "widget_period_type": "Zeitraum",
    "widget_period_week": "Diese Woche",
    "widget_routine_type": "Routine",
    "widget_style_dark": "Dunkel (Schwarz)",
    "widget_style_light": "Hell (Weiß)",
    "widget_style_type": "Hintergrund-Stil"
}

strings = data.get('strings', {})

for key, val in patches.items():
    if key not in strings:
        strings[key] = {"extractionState": "manual", "localizations": {}}
    if 'de' not in strings[key]['localizations']:
        strings[key]['localizations']['de'] = {"stringUnit": {"state": "translated", "value": val}}
    else:
        strings[key]['localizations']['de']['stringUnit']['value'] = val
        strings[key]['localizations']['de']['stringUnit']['state'] = "translated"

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Patched DE values!")
