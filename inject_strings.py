import json
import sys

file_path = 'Garten_Simulation/Localizable.xcstrings'

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
except Exception as e:
    print(f"Error reading file: {e}")
    sys.exit(1)
    
keys_to_add = {
    "habit.fruit_veg.title": {
        "de": "Obst & Gemüse",
        "en": "Fruits & Veggies",
        "es": "Frutas y Verduras",
        "fr": "Fruits & Légumes",
        "it": "Frutta e Verdura",
        "pt": "Frutas e Legumes",
        "ja": "果物と野菜",
        "ko": "과일 및 채소",
        "pl": "Owoce i Warzywa",
        "nl": "Fruit & Groenten",
        "tr": "Meyve ve Sebze",
        "ru": "Фрукты и овощи",
        "zh-Hans": "水果和蔬菜",
        "zh-Hant": "水果和蔬菜",
        "hi": "फल और सब्जियां"
    },
    "health.metric.fiber": {
        "de": "Ballaststoffe",
        "en": "Fiber",
        "es": "Fibra",
        "fr": "Fibres",
        "it": "Fibre",
        "pt": "Fibra",
        "ja": "食物繊維",
        "ko": "식이섬유",
        "pl": "Błonnik",
        "nl": "Vezels",
        "tr": "Lif",
        "ru": "Клетчатка",
        "zh-Hans": "膳食纤维",
        "zh-Hant": "膳食纖維",
        "hi": "फाइबर"
    },
    "health.metric.calcium": {
        "de": "Kalzium",
        "en": "Calcium",
        "es": "Calcio",
        "fr": "Calcium",
        "it": "Calcio",
        "pt": "Cálcio",
        "ja": "カルシウム",
        "ko": "칼슘",
        "pl": "Wapń",
        "nl": "Calcium",
        "tr": "Kalsiyum",
        "ru": "Кальций",
        "zh-Hans": "钙",
        "zh-Hant": "鈣",
        "hi": "कैल्शियम"
    },
    "habit.fruit_veg.tip": {
        "de": "Tipp: Füge deiner nächsten Mahlzeit eine Handvoll Beeren, einen Apfel oder Gemüsesticks als Snack hinzu.",
        "en": "Tip: Add a handful of berries, an apple, or veggie sticks as a snack to your next meal.",
        "es": "Consejo: Añade un puñado de bayas, una manzana o palitos de verdura como aperitivo a tu próxima comida.",
        "fr": "Conseil : Ajoutez une poignée de baies, une pomme ou des bâtonnets de légumes comme collation à votre prochain repas.",
        "it": "Consiglio: Aggiungi una manciata di frutti di bosco, una mela o bastoncini di verdura come spuntino al tuo prossimo pasto.",
        "pt": "Dica: Adicione um punhado de frutas vermelhas, uma maçã ou palitos de vegetais como lanche na sua próxima refeição.",
        "ja": "ヒント：次の食事のおやつとして、ベリーを一掴み、リンゴ、または野菜スティックを追加しましょう。",
        "ko": "팁: 다음 식사에 베리 한 줌, 사과, 또는 채소 스틱을 간식으로 추가하세요.",
        "pl": "Wskazówka: Dodaj garść jagód, jabłko lub słupki warzywne jako przekąskę do następnego posiłku.",
        "nl": "Tip: Voeg een handje bessen, een appel of groentesticks toe als snack bij je volgende maaltijd.",
        "tr": "İpucu: Bir sonraki öğününüze atıştırmalık olarak bir avuç orman meyvesi, bir elma veya sebze çubukları ekleyin.",
        "ru": "Совет: Добавьте горсть ягод, яблоко или овощные палочки в качестве перекуса к следующему приему пищи.",
        "zh-Hans": "提示：在您的下一餐中加入一把浆果、一个苹果或蔬菜条作为零食。",
        "zh-Hant": "提示：在您的下一餐中加入一把漿果、一個蘋果或蔬菜條作為零食。",
        "hi": "सुझाव: अपने अगले भोजन में नाश्ते के रूप में एक मुट्ठी जामुन, एक सेब या वेजी स्टिक्स शामिल करें।"
    },
    "habit.fruit_veg.connect_title": {
        "de": "Obst & Gemüse tracken",
        "en": "Track Fruits & Veggies",
        "es": "Rastrear Frutas y Verduras",
        "fr": "Suivre les Fruits & Légumes",
        "it": "Traccia Frutta e Verdura",
        "pt": "Rastrear Frutas e Legumes",
        "ja": "果物と野菜を記録",
        "ko": "과일 및 채소 추적",
        "pl": "Śledź Owoce i Warzywa",
        "nl": "Fruit & Groenten volgen",
        "tr": "Meyve ve Sebzeleri Takip Et",
        "ru": "Отслеживать фрукты и овощи",
        "zh-Hans": "记录水果和蔬菜",
        "zh-Hant": "記錄水果和蔬菜",
        "hi": "फल और सब्जियां ट्रैक करें"
    },
    "habit.fruit_veg.connect_desc": {
        "de": "Verbinde Apple Health, um Ballaststoffe und Kalzium aus deiner Ernährung auszulesen.",
        "en": "Connect Apple Health to read fiber and calcium from your diet.",
        "es": "Conecta Apple Health para leer la fibra y el calcio de tu dieta.",
        "fr": "Connectez Apple Health pour lire les fibres et le calcium de votre alimentation.",
        "it": "Connetti Apple Health per leggere le fibre e il calcio dalla tua dieta.",
        "pt": "Conecte o Apple Health para ler as fibras e o cálcio da sua dieta.",
        "ja": "Apple Healthを接続して、食事から食物繊維とカルシウムを読み取ります。",
        "ko": "Apple Health를 연결하여 식단에서 식이섬유와 칼슘을 읽어오세요.",
        "pl": "Połącz Apple Health, aby odczytywać błonnik i wapń ze swojej diety.",
        "nl": "Koppel Apple Health om vezels en calcium uit je dieet te lezen.",
        "tr": "Diyetinizden lif ve kalsiyumu okumak için Apple Health'i bağlayın.",
        "ru": "Подключите Apple Health, чтобы считывать клетчатку и кальций из вашего рациона.",
        "zh-Hans": "连接Apple Health以读取您饮食中的膳食纤维和钙。",
        "zh-Hant": "連接Apple Health以讀取您飲食中的膳食纖維和鈣。",
        "hi": "अपने आहार से फाइबर और कैल्शियम पढ़ने के लिए Apple Health को कनेक्ट करें।"
    },
    "habit.fruit_veg.connect_btn": {
        "de": "Mit Apple Health verbinden",
        "en": "Connect to Apple Health",
        "es": "Conectar con Apple Health",
        "fr": "Connecter à Apple Health",
        "it": "Connetti ad Apple Health",
        "pt": "Conectar ao Apple Health",
        "ja": "Apple Healthに接続",
        "ko": "Apple Health에 연결",
        "pl": "Połącz z Apple Health",
        "nl": "Koppelen met Apple Health",
        "tr": "Apple Health'e Bağlan",
        "ru": "Подключить Apple Health",
        "zh-Hans": "连接到Apple Health",
        "zh-Hant": "連接到Apple Health",
        "hi": "Apple Health से कनेक्ट करें"
    }
}

languages_in_project = ["de", "en", "es", "fr", "it", "ja", "ko", "nl", "pl", "pt", "ru", "tr", "zh-Hans", "zh-Hant", "hi"]

for key, trans_dict in keys_to_add.items():
    if key not in data['strings']:
        data['strings'][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang in languages_in_project:
        # Fallback auf Englisch oder Deutsch, wenn die Übersetzung fehlt (hier haben wir aber alle abgedeckt)
        val = trans_dict.get(lang, trans_dict.get("en", trans_dict.get("de")))
        data['strings'][key]['localizations'][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Translations injected successfully!")
