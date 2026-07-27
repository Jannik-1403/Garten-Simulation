# -*- coding: utf-8 -*-
import json

file_path = 'Garten_Simulation/Localizable.xcstrings'
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

translations = {
    "backup.interval.never": {
        "en": "Never", "de": "Nie", "es": "Nunca", "fr": "Jamais", "it": "Mai", "pt": "Nunca", "nl": "Nooit", "pl": "Nigdy", "ru": "Никогда", "tr": "Asla", "ja": "なし", "ko": "안 함", "zh-Hans": "从不", "zh-Hant": "從不", "hi": "कभी नहीं"
    },
    "backup.interval.onSave": {
        "en": "On Save", "de": "Bei jeder Speicherung", "es": "Al guardar", "fr": "À chaque sauvegarde", "it": "Al salvataggio", "pt": "Ao guardar", "nl": "Bij opslaan", "pl": "Przy zapisie", "ru": "При сохранении", "tr": "Kaydederken", "ja": "保存時", "ko": "저장할 때", "zh-Hans": "保存时", "zh-Hant": "儲存時", "hi": "सहेजने पर"
    },
    "backup.interval.daily": {
        "en": "Daily", "de": "Täglich", "es": "Diariamente", "fr": "Quotidiennement", "it": "Giornalmente", "pt": "Diariamente", "nl": "Dagelijks", "pl": "Codziennie", "ru": "Ежедневно", "tr": "Günlük", "ja": "毎日", "ko": "매일", "zh-Hans": "每天", "zh-Hant": "每天", "hi": "रोजाना"
    },
    "backup.interval.weekly": {
        "en": "Weekly", "de": "Wöchentlich", "es": "Semanalmente", "fr": "Hebdomadairement", "it": "Settimanalmente", "pt": "Semanalmente", "nl": "Wekelijks", "pl": "Co tydzień", "ru": "Еженедельно", "tr": "Haftalık", "ja": "毎週", "ko": "매주", "zh-Hans": "每周", "zh-Hant": "每週", "hi": "साप्ताहिक"
    },
    "backup.interval.monthly": {
        "en": "Monthly", "de": "Monatlich", "es": "Mensualmente", "fr": "Mensuellement", "it": "Mensilmente", "pt": "Mensalmente", "nl": "Maandelijks", "pl": "Co miesiąc", "ru": "Ежемесячно", "tr": "Aylık", "ja": "毎月", "ko": "매월", "zh-Hans": "每月", "zh-Hant": "每月", "hi": "मासिक"
    }
}

existing_langs = ['pt', 'nl', 'zh-Hans', 'ko', 'ja', 'tr', 'es', 'fr', 'en', 'ru', 'pl', 'it', 'hi', 'de', 'zh-Hant']

for key, lang_dict in translations.items():
    if key not in data['strings']:
        data['strings'][key] = {"extractionState": "manual", "localizations": {}}
        
    for lang in existing_langs:
        val = lang_dict.get(lang) or lang_dict.get('en')
        
        if 'localizations' not in data['strings'][key]:
            data['strings'][key]['localizations'] = {}
            
        data['strings'][key]['localizations'][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Injected accurate interval localizations successfully!")
