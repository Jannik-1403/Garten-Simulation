import json

file_path = "Garten_Simulation/Localizable.xcstrings"

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

translations = {
    "settings.display.mode.desc": {
        "de": "Wähle, ob der Name der Pflanze ohne die verknüpfte Gewohnheit im Garten angezeigt werden soll.",
        "en": "Choose whether the name of the plant should be displayed in the garden without the linked habit.",
        "es": "Elige si quieres que el nombre de la planta se muestre en el jardín sin el hábito vinculado.",
        "fr": "Choisissez si le nom de la plante doit être affiché dans le jardin sans l'habitude liée.",
        "hi": "चुनें कि क्या पौधे का नाम बगीचे में बिना जुड़ी आदत के प्रदर्शित किया जाना चाहिए।",
        "it": "Scegli se il nome della pianta debba essere visualizzato nel giardino senza l'abitudine associata.",
        "ja": "関連する習慣なしで植物の名前を庭に表示するかどうかを選択します。",
        "ko": "연결된 습관 없이 식물의 이름을 정원에 표시할지 여부를 선택하세요.",
        "nl": "Kies of de naam van de plant in de tuin moet worden weergegeven zonder de gekoppelde gewoonte.",
        "pl": "Wybierz, czy nazwa rośliny ma być wyświetlana w ogrodzie bez powiązanego nawyku.",
        "pt": "Escolha se o nome da planta deve ser exibido no jardim sem o hábito vinculado.",
        "ru": "Выберите, должно ли имя растения отображаться в саду без связанной привычки.",
        "tr": "Bağlı alışkanlık olmadan bitkinin adının bahçede gösterilip gösterilmeyeceğini seçin.",
        "zh-Hans": "选择是否在没有关联习惯的情况下在花园中显示植物的名称。",
        "zh-Hant": "選擇是否在沒有關聯習慣的情況下在花園中顯示植物的名稱。"
    }
}

for key, langs in translations.items():
    if key in data["strings"]:
        for lang, value in langs.items():
            if "localizations" not in data["strings"][key]:
                data["strings"][key]["localizations"] = {}
            if lang not in data["strings"][key]["localizations"]:
                data["strings"][key]["localizations"][lang] = {"stringUnit": {"state": "translated"}}
            
            data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = value
            data["strings"][key]["localizations"][lang]["stringUnit"]["state"] = "translated"

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Updated Localizable.xcstrings successfully!")
