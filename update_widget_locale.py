import os

files = [
    'GartenWidget/GroovyNewWidgetViews.swift',
    'GartenWidget/GartenWidget.swift',
    'GartenWidget/GroovyWidgetIntent.swift'
]

old_var = """private var widgetLocale: Locale {
    Locale(identifier: SharedUserDefaults.suite.string(forKey: "appLanguage") ?? "de")
}"""

new_var = """private var widgetLocale: Locale {
    let supported = ["pt", "nl", "zh-Hans", "ko", "ja", "tr", "es", "fr", "en", "ru", "pl", "it", "hi", "zh-Hant", "pt-BR", "de"]
    
    for lang in Locale.preferredLanguages {
        let identifier = Locale(identifier: lang).language.languageCode?.identifier ?? lang
        if supported.contains(identifier) || supported.contains(lang) {
            return Locale(identifier: lang)
        }
    }
    
    return Locale(identifier: "en")
}"""

for filepath in files:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    content = content.replace(old_var, new_var)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
        
    print(f"Updated {filepath}")
