from deep_translator import GoogleTranslator
translator = GoogleTranslator(source='de', target='en')
res = translator.translate_batch(["Hallo", "Welt"])
print(res)
