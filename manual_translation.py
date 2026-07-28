import json

file_path = 'Garten_Simulation/Localizable.xcstrings'
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

translations = {
    "widget_intent_history_title": {"en": "Customize History Widget", "es": "Personalizar widget de historial", "fr": "Personnaliser le widget d'historique", "it": "Personalizza widget cronologia"},
    "widget_intent_routine_desc": {"en": "Select a routine and the background.", "es": "Selecciona una rutina y el fondo.", "fr": "Sélectionnez une routine et l'arrière-plan.", "it": "Seleziona una routine e lo sfondo."},
    "widget_intent_routine_title": {"en": "Customize Routine Widget", "es": "Personalizar widget de rutina", "fr": "Personnaliser le widget de routine", "it": "Personalizza widget routine"},
    "widget_intent_streak_title": {"en": "Customize Streak Widget", "es": "Personalizar widget de racha", "fr": "Personnaliser le widget de série", "it": "Personalizza widget serie"},
    "widget_intent_water_desc": {"en": "Select background.", "es": "Seleccionar fondo.", "fr": "Sélectionner l'arrière-plan.", "it": "Seleziona sfondo."},
    "widget_intent_water_title": {"en": "Customize Water Widget", "es": "Personalizar widget de agua", "fr": "Personnaliser le widget d'eau", "it": "Personalizza widget acqua"},
    "widget_period_alltime": {"en": "All Time", "es": "Todo el tiempo", "fr": "Toujours", "it": "Sempre"},
    "widget_period_month": {"en": "This Month", "es": "Este mes", "fr": "Ce mois-ci", "it": "Questo mese"},
    "widget_period_today": {"en": "Today", "es": "Hoy", "fr": "Aujourd'hui", "it": "Oggi"},
    "widget_period_type": {"en": "Period", "es": "Período", "fr": "Période", "it": "Periodo"},
    "widget_period_week": {"en": "This Week", "es": "Esta semana", "fr": "Cette semaine", "it": "Questa settimana"},
    "widget_routine_type": {"en": "Routine", "es": "Rutina", "fr": "Routine", "it": "Routine"},
    "widget_style_dark": {"en": "Dark (Black)", "es": "Oscuro (Negro)", "fr": "Sombre (Noir)", "it": "Scuro (Nero)"},
    "widget_style_light": {"en": "Light (White)", "es": "Claro (Blanco)", "fr": "Clair (Blanc)", "it": "Chiaro (Bianco)"},
    "widget_style_type": {"en": "Background Style", "es": "Estilo de fondo", "fr": "Style d'arrière-plan", "it": "Stile sfondo"}
}

langs = ['pt', 'nl', 'zh-Hans', 'ko', 'ja', 'tr', 'es', 'fr', 'en', 'ru', 'pl', 'it', 'hi', 'zh-Hant', 'pt-BR']

strings = data.get('strings', {})

for key, trans in translations.items():
    if key not in strings:
        continue
    locs = strings[key].setdefault('localizations', {})
    for lang in langs:
        val = trans.get(lang, trans['en']) # fallback to en
        locs[lang] = {"stringUnit": {"state": "translated", "value": val}}

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Manual translations applied.")
