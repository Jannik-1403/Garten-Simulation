import json
import sys

file_path = 'Garten_Simulation/Localizable.xcstrings'

with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

tour_inventory_title = {
    "de": "Deine Samen",
    "en": "Your Seeds",
    "es": "Tus Semillas",
    "fr": "Vos Graines",
    "hi": "आपके बीज",
    "it": "I Tuoi Semi",
    "ja": "あなたの種",
    "ko": "당신의 씨앗",
    "nl": "Jouw Zaden",
    "pl": "Twoje Nasiona",
    "pt": "Suas Sementes",
    "pt-BR": "Suas Sementes",
    "ru": "Твои семена",
    "tr": "Tohumlarınız",
    "zh-Hans": "你的种子",
    "zh-Hant": "你的種子"
}

tour_inventory_desc = {
    "de": "Hier findest du all deine Samen. Außerdem kannst du hier deine ganz eigenen Pflanzen erstellen!",
    "en": "Here you will find all your seeds. You can also create your very own plants here!",
    "es": "Aquí encontrarás todas tus semillas. ¡También puedes crear tus propias plantas aquí!",
    "fr": "Vous trouverez ici toutes vos graines. Vous pouvez également créer vos propres plantes ici !",
    "hi": "यहाँ आपको अपने सभी बीज मिलेंगे। आप यहाँ अपने खुद के पौधे भी बना सकते हैं!",
    "it": "Qui troverai tutti i tuoi semi. Puoi anche creare le tue piante qui!",
    "ja": "ここにはすべての種があります。また、ここで独自の植物を作成することもできます！",
    "ko": "여기에 모든 씨앗이 있습니다. 여기서 나만의 식물을 만들 수도 있습니다!",
    "nl": "Hier vind je al je zaden. Je kunt hier ook je eigen planten creëren!",
    "pl": "Tutaj znajdziesz wszystkie swoje nasiona. Możesz tutaj również tworzyć własne rośliny!",
    "pt": "Aqui você encontrará todas as suas sementes. Você também pode criar suas próprias plantas aqui!",
    "pt-BR": "Aqui você encontrará todas as suas sementes. Você também pode criar suas próprias plantas aqui!",
    "ru": "Здесь вы найдете все свои семена. Вы также можете создавать свои собственные растения здесь!",
    "tr": "Burada tüm tohumlarınızı bulacaksınız. Ayrıca burada kendi bitkilerinizi de oluşturabilirsiniz!",
    "zh-Hans": "在这里你会找到所有的种子。你也可以在这里创建自己的植物！",
    "zh-Hant": "在這裡你會找到所有的種子。你也可以在這裡創建自己的植物！"
}

profile_inventory = {
    "de": "Samen",
    "en": "Seeds",
    "es": "Semillas",
    "fr": "Graines",
    "hi": "बीज",
    "it": "Semi",
    "ja": "種",
    "ko": "씨앗",
    "nl": "Zaden",
    "pl": "Nasiona",
    "pt": "Sementes",
    "pt-BR": "Sementes",
    "ru": "Семена",
    "tr": "Tohumlar",
    "zh-Hans": "种子",
    "zh-Hant": "種子"
}

inventory_empty = {
    "de": "Du hast keine Samen",
    "en": "You have no seeds",
    "es": "No tienes semillas",
    "fr": "Tu n'as pas de graines",
    "hi": "आपके पास कोई बीज नहीं है",
    "it": "Non hai semi",
    "ja": "種がありません",
    "ko": "씨앗이 없습니다",
    "nl": "Je hebt geen zaden",
    "pl": "Nie masz nasion",
    "pt": "Não tens sementes",
    "pt-BR": "Não tem sementes",
    "ru": "У вас нет семян",
    "tr": "Tohumun yok",
    "zh-Hans": "你没有种子",
    "zh-Hant": "你沒有種子"
}

def update_key(key, new_values):
    if key in data['strings']:
        for lang, value in new_values.items():
            if lang in data['strings'][key].get('localizations', {}):
                data['strings'][key]['localizations'][lang]['stringUnit']['value'] = value
                data['strings'][key]['localizations'][lang]['stringUnit']['state'] = 'translated'

update_key("tour_inventory_title", tour_inventory_title)
update_key("tour_inventory_desc", tour_inventory_desc)
update_key("profile.inventory", profile_inventory)
update_key("inventory.empty", inventory_empty)

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Updated Localizable.xcstrings directly.")
