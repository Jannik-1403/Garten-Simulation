from deep_translator import GoogleTranslator
langs = GoogleTranslator().get_supported_languages(as_dict=True)
print("ru:", langs.get('russian'))
print("hi:", langs.get('hindi'))
print("zh-CN:", langs.get('chinese (simplified)'))
print("zh-TW:", langs.get('chinese (traditional)'))
