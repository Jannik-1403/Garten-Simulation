from deep_translator import GoogleTranslator

try:
    translated = GoogleTranslator(source='de', target='en').translate("Gewohnheit")
    print(f"Translation worked: {translated}")
except Exception as e:
    print(f"Error: {e}")
