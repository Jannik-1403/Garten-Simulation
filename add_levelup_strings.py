import json

file_path = "Garten_Simulation/Localizable.xcstrings"

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

langs = ["de", "en", "es", "fr", "it", "ja", "ko", "nl", "pl", "pt", "pt-BR", "ru", "tr", "zh-Hans", "zh-Hant", "hi"]

strings = {
    "level_up.subtitle.habit": {
        "de": "Deine Gewohnheit ist jetzt",
        "en": "Your habit is now",
        "es": "Tu hábito es ahora",
        "fr": "Ton habitude est maintenant",
        "it": "La tua abitudine è ora",
        "ja": "あなたの習慣は今です",
        "ko": "당신의 습관은 지금",
        "nl": "Jouw gewoonte is nu",
        "pl": "Twój nawyk to teraz",
        "pt": "O teu hábito é agora",
        "pt-BR": "O seu hábito é agora",
        "ru": "Твоя привычка теперь",
        "tr": "Alışkanlığın artık",
        "zh-Hans": "你现在的习惯是",
        "zh-Hant": "你現在的習慣是",
        "hi": "आपकी आदत अब है"
    },
    "level_up.custom_text": {
        "de": "Du hast %@ schon lange gemeistert. Es wird immer einfacher für dich, die Gewohnheit beizubehalten!",
        "en": "You have mastered %@ for a long time. It gets easier and easier to maintain the habit!",
        "es": "Has dominado %@ durante mucho tiempo. ¡Cada vez es más fácil mantener el hábito!",
        "fr": "Tu maîtrises %@ depuis longtemps. Il est de plus en plus facile de maintenir l'habitude !",
        "it": "Hai padroneggiato %@ da molto tempo. Diventa sempre più facile mantenere l'abitudine!",
        "ja": "あなたは %@ を長い間マスターしてきました。習慣を維持するのはどんどん簡単になります！",
        "ko": "당신은 오랫동안 %@을(를) 마스터했습니다. 습관을 유지하는 것이 점점 쉬워집니다!",
        "nl": "Je hebt %@ al lang onder de knie. Het wordt steeds makkelijker om de gewoonte vol te houden!",
        "pl": "Opanowałeś %@ od dłuższego czasu. Utrzymanie nawyku staje się coraz łatwiejsze!",
        "pt": "Dominaste %@ durante muito tempo. Torna-se cada vez mais fácil manter o hábito!",
        "pt-BR": "Você domina %@ há muito tempo. Fica cada vez mais fácil manter o hábito!",
        "ru": "Вы давно освоили %@. Поддерживать эту привычку становится всё проще!",
        "tr": "%@ alışkanlığında uzun süredir ustalaştın. Bu alışkanlığı sürdürmek giderek kolaylaşıyor!",
        "zh-Hans": "你已经掌握%@很久了。保持这个习惯会变得越来越容易！",
        "zh-Hant": "你已經掌握%@很久了。保持這個習慣會變得越來越容易！",
        "hi": "आपने %@ में लंबे समय से महारत हासिल कर ली है। इस आदत को बनाए रखना और भी आसान हो जाता है!"
    }
}

for key, trans_dict in strings.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    for lang in data["strings"]["level_up.subtitle"]["localizations"].keys():
        if lang not in trans_dict:
            # Fallback to English
            trans_dict[lang] = trans_dict["en"]
        
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": trans_dict[lang]
            }
        }

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Done")
