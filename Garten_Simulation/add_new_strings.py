import json
import time
from deep_translator import GoogleTranslator

path = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings'
with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)

new_strings = {
    "onboarding.goal.5year.title": "Was ist dein wichtigstes 5-Jahresziel?",
    "goal.custom.5year.message": "Gib einen kurzen Namen für dein 5-Jahresziel ein.",
    "goal.custom.5year.placeholder": "Mein 5-Jahresziel",
    "onboarding.goal.week.title": "Was ist ein Ziel für diese Woche?",
    "goal.custom.week.message": "Gib einen kurzen Namen für dein Wochenziel ein.",
    "goal.custom.week.placeholder": "Mein Wochenziel",
    "goal.template.career": "Berufliche Erfüllung",
    "goal.template.finance": "Finanzielle Freiheit",
    "goal.template.health": "Gesundheit & Fitness",
    "goal.template.week.workout": "3x Sport machen",
    "goal.template.week.reading": "Täglich lesen",
    "goal.template.week.screentime": "Bildschirmzeit reduzieren",
    "button.continue": "Weiter"
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
