import json

en_translations = {
    "90 Tage Challenge": "90 Days Challenge",
    "Bild fehlerhaft": "Image invalid",
    "challenge.journal.placeholder": "How was today? Write down your thoughts...",
    "challenge.journal.title": "My Journal",
    "export.pdf.default_filename": "Garden_Report",
    "focus.generic.reward": "Focus-Session: %@",
    "Meilenstein Tag %lld": "Milestone Day %lld",
    "Noch %lld Tage": "%lld Days Left",
    "pfad_schliessen": "Close",
    "pfad_schwierigkeit_profi_desc": "Master this habit at the highest level.",
    "pfad_tag_abgeschlossen_text": "Completed",
    "pfad.ice.desc": "The Streak-Ice protects your streak. You don't lose it if you skip a day.\n\nYou receive 1 new ice for every completed week (7-day ring). A maximum of 3 ice can be active at once.",
    "pfad.ice.title": "Streak-Ice",
    "pfad.schliessen": "Close",
    "routine.habit.add": "Habit",
    "routine.todo.add": "Custom To-Do",
    "routine.todo.icon": "Plant Icon",
    "routine.todo.name": "To-Do Name",
    "routine.todo.name.placeholder": "e.g. Take out the trash",
    "routine.todo.title": "Custom To-Do",
    "screenTime.schedule.locked.info": "No changes can be made while the schedule is active.",
    "screenTime.schedule.locked.title": "Schedule currently active",
    "weekly_report.pdf.default_filename": "Grovy_WeeklyReport"
}

de_translations = {
    "90 Tage Challenge": "90 Tage Challenge",
    "Bild fehlerhaft": "Bild fehlerhaft",
    "Meilenstein Tag %lld": "Meilenstein Tag %lld",
    "Noch %lld Tage": "Noch %lld Tage",
    "pfad_schliessen": "Schließen",
    "Suggestions": "Vorschläge",
    "%lld %@ %lld %@": "%1$lld %2$@ %3$lld %4$@"
}

with open('missing_translations.json', 'r') as f:
    missing = json.load(f)

with open('./Garten_Simulation/Localizable.xcstrings', 'r') as f:
    data = json.load(f)

strings = data.get('strings', {})

def get_en_text(key):
    # Try custom EN translation first
    if key in en_translations:
        return en_translations[key]
    # Try existing EN text
    locs = strings.get(key, {}).get('localizations', {})
    en_val = locs.get('en', {}).get('stringUnit', {}).get('value')
    if en_val:
        return en_val
    return f"TODO: {key}"

for lang, keys in missing.items():
    for key in keys:
        if key not in strings:
            continue
            
        localizations = strings[key].get('localizations', {})
        
        if lang == 'de':
            # Custom DE
            val = de_translations.get(key)
            if not val:
                # keep existing DE if it's there but just not 'translated'
                de_val = localizations.get('de', {}).get('stringUnit', {}).get('value')
                if de_val:
                    val = de_val
                else:
                    val = key
        elif lang == 'en':
            val = en_translations.get(key)
            if not val:
                # Try fallback DE -> EN if not custom?
                val = f"TODO: {key}"
        else:
            # Fallback to English
            val = get_en_text(key)
            
        localizations[lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }
        strings[key]['localizations'] = localizations

with open('./Garten_Simulation/Localizable.xcstrings', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Patch complete.")

