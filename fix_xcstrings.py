import json
import re

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

for key, item in data.get("strings", {}).items():
    if "localizations" in item:
        # Check all localizations
        for lang, loc in item.get("localizations", {}).items():
            val = loc.get("stringUnit", {}).get("value", "")
            
            # Known specific manual replacements
            if val == "%@:%lлд": val = "%@: %lld"
            if val == "%lид%@": val = "%lld %@"
            if val == "%lотбросы": val = "%lld отбросы"
            if val == "%lизд.": val = "%lld."
            if val == "%@:%lвыполнено": val = "%@: %lld выполнено"
            if val == "Общее время фокусировки:%lминут (%@по сравнению с прошлой неделей)": 
                val = "Общее время фокусировки: %lld минут (%@ по сравнению с прошлой неделей)"
            if val == "Ты был очень сосредоточен в течение%lминут. Твое растение гордится тобой!":
                val = "Ты был очень сосредоточен в течение %lld минут. Твое растение гордится тобой!"
            if val == "Ты был экстремально сосредоточен%lминут. Опыт будет распределен между всеми твоими растениями!":
                val = "Ты был экстремально сосредоточен %lld минут. Опыт будет распределен между всеми твоими растениями!"
            if val == "%ll Gün": val = "%lld Gün"
            
            # Catch any other raw %l (that is not %lld)
            # This regex replaces %l followed by non-ASCII letters with %lld and space
            val = re.sub(r'%l([а-яА-Я]+)', r'%lld \1', val)
            
            # Also fixing any %ll (that isn't %lld)
            val = re.sub(r'%ll\s', r'%lld ', val)
            
            loc["stringUnit"]["value"] = val

# Write back
with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
