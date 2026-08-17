import json
import sys

file_path = 'Garten_Simulation/Localizable.xcstrings'

translations = {
    'de': 'Verbinde Apple Health, um deine Schritte und deinen Schlaf zu synchronisieren und so den Fortschritt in deinem Garten voranzutreiben.',
    'en': 'Connect Apple Health to synchronize your steps and sleep, driving the progress in your garden.',
    'es': 'Conecta Apple Health para sincronizar tus pasos y sueño, impulsando el progreso en tu jardín.',
    'fr': 'Connectez Apple Health pour synchroniser vos pas et votre sommeil, favorisant ainsi la progression de votre jardin.',
    'it': 'Connetti Apple Health per sincronizzare i tuoi passi e il sonno, favorendo i progressi nel tuo giardino.',
    'ja': 'Apple Healthを連携して歩数と睡眠を同期し、庭の成長を促進しましょう。',
    'ko': 'Apple Health를 연결하여 걸음 수와 수면을 동기화하고 정원의 성장을 촉진하세요.',
    'nl': 'Verbind Apple Health om je stappen en slaap te synchroniseren en zo de voortgang in je tuin te stimuleren.',
    'pl': 'Połącz Apple Health, aby zsynchronizować swoje kroki i sen, co przyspieszy postępy w Twoim ogrodzie.',
    'pt': 'Conecte o Apple Health para sincronizar seus passos e sono, impulsionando o progresso do seu jardim.',
    'ru': 'Подключите Apple Health, чтобы синхронизировать шаги и сон, ускоряя прогресс в вашем саду.',
    'tr': 'Adımlarınızı ve uykunuzu senkronize ederek bahçenizdeki gelişimi desteklemek için Apple Health\'i bağlayın.',
    'hi': 'अपने कदम और नींद को सिंक करने और अपने बगीचे में प्रगति को बढ़ावा देने के लिए Apple Health को कनेक्ट करें।',
    'zh-Hans': '连接 Apple Health 同步您的步数和睡眠，从而推动花园的进度。',
    'zh-Hant': '連接 Apple Health 同步您的步數和睡眠，從而推動花園的進度。'
}

with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

key = 'settings.health.description'
if key not in data['strings']:
    data['strings'][key] = {
        "extractionState": "manual",
        "localizations": {}
    }

for lang, text in translations.items():
    data['strings'][key]['localizations'][lang] = {
        "stringUnit": {
            "state": "translated",
            "value": text
        }
    }

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
