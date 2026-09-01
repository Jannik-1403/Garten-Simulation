import json
with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

fake_translations = []

for key, value in data["strings"].items():
    de_text = ""
    en_text = ""
    if "localizations" in value:
        if "de" in value["localizations"]:
            de_text = value["localizations"]["de"].get("stringUnit", {}).get("value", "")
        if "en" in value["localizations"]:
            en_text = value["localizations"]["en"].get("stringUnit", {}).get("value", "")
            
    source_text = de_text if de_text else (en_text if en_text else key)
    
    zh = value.get("localizations", {}).get("zh-Hans", {}).get("stringUnit", {}).get("value", "")
    
    if zh == source_text and any(c.isalpha() for c in source_text):
        if source_text not in [ "XP", "x%@" ]:
            fake_translations.append(source_text)
            
print(json.dumps(fake_translations[:30], ensure_ascii=False, indent=2))
print(f"Total fake translations: {len(fake_translations)}")
