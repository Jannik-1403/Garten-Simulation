import json
from deep_translator import GoogleTranslator

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

langs_to_fix = ["es", "fr", "hi", "it", "ja", "ko", "pt-BR", "ru", "zh-Hans"]

def map_lang(lang_code):
    lc = lang_code.lower()
    if 'zh-hans' in lc: return 'zh-CN'
    if 'zh-hant' in lc: return 'zh-TW'
    if 'pt' in lc: return 'pt'
    if 'es' in lc: return 'es'
    return lc.split('-')[0]

key = "nutrient.status.low"
source_text = "Niedrig"

for lang in langs_to_fix:
    target = map_lang(lang)
    translated = GoogleTranslator(source='de', target=target).translate(source_text)
    print(f"{lang}: {translated}")
    
    if key in data["strings"] and lang in data["strings"][key].get("localizations", {}):
        data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = translated

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
