import json
import os

langs = ["de", "en", "es", "fr", "it", "pt", "ja", "ko", "pl", "nl", "tr"]

bad_habit_label = {
    "de": "Schlechte Gewohnheit",
    "en": "Bad Habit",
    "es": "Mal Hábito",
    "fr": "Mauvaise Habitude",
    "it": "Cattiva Abitudine",
    "pt": "Mau Hábito",
    "ja": "悪い習慣",
    "ko": "나쁜 습관",
    "pl": "Zły Nawyk",
    "nl": "Slechte Gewoonte",
    "tr": "Kötü Alışkanlık"
}

online_shopping_desc = {
    "de": "Reduziere Online-Shopping, um Geld zu sparen und Impulskäufe zu vermeiden.",
    "en": "Reduce online shopping to save money and avoid impulse buys.",
    "es": "Reduce las compras en línea para ahorrar dinero y evitar compras compulsivas.",
    "fr": "Réduis les achats en ligne pour économiser et éviter les achats impulsifs.",
    "it": "Riduci lo shopping online per risparmiare ed evitare acquisti d'impulso.",
    "pt": "Reduza as compras online para poupar dinheiro e evitar compras por impulso.",
    "ja": "オンラインショッピングを減らして、お金を節約し、衝動買いを避けましょう。",
    "ko": "온라인 쇼핑을 줄여 돈을 절약하고 충동 구매를 피하세요.",
    "pl": "Ogranicz zakupy online, aby zaoszczędzić pieniądze i uniknąć impulsywnych zakupów.",
    "nl": "Verminder online winkelen om geld te besparen en impulsaankopen te voorkomen.",
    "tr": "Tasarruf etmek ve dürtüsel alışverişleri önlemek için çevrimiçi alışverişi azaltın."
}

online_shopping_obj_desc = {
    "de": "Ein beruhigender Seerosenteich.",
    "en": "A calming lily pond.",
    "es": "Un relajante estanque de lirios.",
    "fr": "Une mare aux nénuphars apaisante.",
    "it": "Un rilassante stagno di ninfee.",
    "pt": "Um lago de nenúfares relaxante.",
    "ja": "落ち着く睡蓮の池。",
    "ko": "평온한 백합 연못.",
    "pl": "Uspokajający staw z liliami wodnymi.",
    "nl": "Een rustgevende lelievijver.",
    "tr": "Dinlendirici bir zambak göleti."
}

path = "Garten_Simulation/Localizable.xcstrings"

with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)

def add_key(key_name, translations):
    if key_name not in data["strings"]:
        data["strings"][key_name] = {
            "extractionState": "manual",
            "localizations": {}
        }
    else:
        if "localizations" not in data["strings"][key_name]:
            data["strings"][key_name]["localizations"] = {}
    
    for lang, text in translations.items():
        data["strings"][key_name]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

add_key("bad_habit.label", bad_habit_label)
add_key("trash.online_shopping_app.desc", online_shopping_desc)
add_key("trash.online_shopping_app.obj_desc", online_shopping_obj_desc)

with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')

print("Success")
