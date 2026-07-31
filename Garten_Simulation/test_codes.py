from deep_translator import GoogleTranslator

codes = ['ru', 'en', 'ko', 'es', 'pl', 'zh-CN', 'zh-TW', 'hi', 'de', 'nl', 'pt', 'tr', 'fr', 'ja', 'it']
for code in codes:
    try:
        GoogleTranslator(source='de', target=code).translate("Hallo")
    except Exception as e:
        print(f"Error for {code}: {e}")
print("Done testing codes.")
