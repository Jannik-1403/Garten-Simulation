import json
import sys

def main():
    path = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings'
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    langs_to_delete = ['sv', 'pt-PT']
    target_langs = ['ru', 'en', 'ko', 'es', 'pl', 'zh-Hans', 'zh-Hant', 'hi', 'de', 'nl', 'pt', 'tr', 'fr', 'ja', 'it']
    
    missing_count = {lang: 0 for lang in target_langs}
    missing_strings = {}
    
    for key, value in data.get('strings', {}).items():
        localizations = value.get('localizations', {})
        for lang in target_langs:
            if lang == 'de': continue # assuming de is default or already present mostly? actually default is usually English, but let's check
            if lang not in localizations:
                missing_count[lang] += 1
                if lang not in missing_strings:
                    missing_strings[lang] = []
                missing_strings[lang].append(key)
                
    print("Missing counts:")
    for lang, count in missing_count.items():
        if count > 0:
            print(f"{lang}: {count}")
            
    print(f"Total keys: {len(data.get('strings', {}))}")

if __name__ == '__main__':
    main()
