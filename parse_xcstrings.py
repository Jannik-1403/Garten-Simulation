import json
import sys

def main():
    try:
        with open('Garten_Simulation/Localizable.xcstrings', 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print("Error reading file:", e)
        return

    strings = data.get('strings', {})
    missing_info = {}
    
    target_langs = ["de", "nl", "en", "fr", "it", "ja", "ko", "pl", "pt", "es", "tr"]

    for key, value in strings.items():
        localizations = value.get('localizations', {})
        for lang in target_langs:
            if lang not in localizations or localizations[lang].get('stringUnit', {}).get('state') != 'translated':
                if key not in missing_info:
                    missing_info[key] = []
                missing_info[key].append(lang)

    print("Missing translations for:")
    for k, langs in missing_info.items():
        print(f"Key: '{k}' missing in: {langs}")

if __name__ == '__main__':
    main()
