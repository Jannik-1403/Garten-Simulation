import json
import time
from deep_translator import GoogleTranslator

path = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings'
with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)

new_strings = {
    "tour_plant_todos_title": "To-Dos",
    "tour_plant_todos_desc": "Füge kleine Aufgaben für deine Gewohnheit hinzu.",
    "tour_plant_notes_title": "Notizen",
    "tour_plant_notes_desc": "Halte wichtige Gedanken oder Fortschritte fest.",
    "tour_plant_timer_title": "Daily Reminder",
    "tour_plant_timer_desc": "Stelle Erinnerungen ein, damit du diese Gewohnheit nicht vergisst.",
    "tour_plant_health_title": "Apple Health",
    "tour_plant_health_desc": "Verbinde Apple Health, um den Fortschritt automatisch zu tracken.",
    "tour_todo_prompt_desc": "Hier findest du alle deine Aufgaben.",
    "tour_todo_intro_title": "To-Dos",
    "tour_todo_intro_desc": "Erstelle tägliche To-Dos und hake sie ab, um XP zu sammeln!"
}

xcode_target_langs = ['ru', 'en', 'ko', 'es', 'pl', 'zh-Hans', 'zh-Hant', 'hi', 'de', 'nl', 'pt', 'tr', 'fr', 'ja', 'it']

def get_google_lang(xcode_lang):
    if xcode_lang == 'zh-Hans': return 'zh-CN'
    if xcode_lang == 'zh-Hant': return 'zh-TW'
    return xcode_lang

translators = {}
for lang in xcode_target_langs:
    if lang != 'de':
        try:
            translators[lang] = GoogleTranslator(source='de', target=get_google_lang(lang))
        except Exception as e:
            pass

strings = data.setdefault('strings', {})

for key, de_val in new_strings.items():
    if key not in strings:
        strings[key] = {"localizations": {}}
        
    locs = strings[key]["localizations"]
    
    # Always set DE first
    locs['de'] = {
        "stringUnit": {
            "state": "translated",
            "value": de_val
        }
    }
    
    for lang in xcode_target_langs:
        if lang != 'de' and lang not in locs:
            try:
                translated_val = translators[lang].translate(de_val)
                locs[lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": translated_val
                    }
                }
                time.sleep(0.05)
            except Exception as e:
                print(f"Failed {lang} for {key}")
                locs[lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": de_val
                    }
                }

with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    
print("New strings added and translated.")
