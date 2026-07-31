import json
import time
from deep_translator import GoogleTranslator

def main():
    path = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings'
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    langs_to_delete = ['sv', 'pt-PT']
    # Removed zh-Hant and zh-Hans from standard handling as we need to map them
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
                print(f"Failed to init translator for {lang}: {e}")

    strings = data.get('strings', {})
    total_translated = 0

    for key, value in strings.items():
        if 'localizations' not in value:
            value['localizations'] = {}
        
        locs = value['localizations']
        
        # Delete unwanted languages
        for d_lang in langs_to_delete:
            if d_lang in locs:
                del locs[d_lang]
                
        # Find base value
        base_value = key
        if 'de' in locs and 'stringUnit' in locs['de'] and 'value' in locs['de']['stringUnit']:
            base_value = locs['de']['stringUnit']['value']
            
        # Translate missing languages
        for lang in xcode_target_langs:
            if lang not in locs:
                translated_val = base_value
                if lang != 'de' and any(c.isalpha() for c in base_value) and '%' not in base_value: 
                    # basic safety: only translate if there's text and no format specifiers to avoid mangling
                    try:
                        translated_val = translators[lang].translate(base_value)
                        total_translated += 1
                        if total_translated % 50 == 0:
                            print(f"Translated {total_translated} strings so far...")
                        time.sleep(0.05) # Prevent rate limiting
                    except Exception as e:
                        print(f"Error translating '{base_value}' to {lang}: {e}")
                elif lang != 'de':
                    # For strings with format specifiers or just symbols, copy as is
                    pass 

                locs[lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": translated_val
                    }
                }
                
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        
    print(f"Finished translation. Total translated API calls: {total_translated}")

if __name__ == '__main__':
    main()
