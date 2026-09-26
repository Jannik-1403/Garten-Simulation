import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r") as f:
    data = json.load(f)

key = "focus.giveup.walkofshame.sentence"

translations = {
    "de": "Du hast dir diese App heruntergeladen, um besser zu werden, für dich selbst. Wenn du jetzt diesen Text eingibst, heißt es, dass du keine Willenskraft hast, nicht stark genug bist, und deine Ziele wahrscheinlich nicht erreichen wirst.",
    "en": "You downloaded this app to become better, for yourself. If you type this text now, it means that you have no willpower, are not strong enough, and will probably not achieve your goals.",
    "es": "Descargaste esta aplicación para mejorar, por ti mismo. Si escribes este texto ahora, significa que no tienes fuerza de voluntad, no eres lo suficientemente fuerte y probablemente no alcanzarás tus objetivos.",
    "fr": "Tu as téléchargé cette application pour t'améliorer, pour toi-même. Si tu tapes ce texte maintenant, cela signifie que tu n'as aucune volonté, que tu n'es pas assez fort et que tu n'atteindras probablement pas tes objectifs.",
    "it": "Hai scaricato quest'app per migliorare, per te stesso. Se scrivi questo testo ora, significa che non hai forza di volontà, non sei abbastanza forte e probabilmente non raggiungerai i tuoi obiettivi.",
    "nl": "Je hebt deze app gedownload om beter te worden, voor jezelf. Als je deze tekst nu typt, betekent dit dat je geen wilskracht hebt, niet sterk genoeg bent en je doelen waarschijnlijk niet zult bereiken.",
    "pt-BR": "Você baixou este aplicativo para melhorar, por si mesmo. Se você digitar este texto agora, significa que você não tem força de vontade, não é forte o suficiente e provavelmente não alcançará seus objetivos.",
    "pt-PT": "Transferiste esta aplicação para melhorar, por ti mesmo. Se digitares este texto agora, significa que não tens força de vontade, não és forte o suficiente e provavelmente não alcançarás os teus objetivos.",
    "ru": "Ты скачал это приложение, чтобы стать лучше, для себя. Если ты сейчас введешь этот текст, это значит, что у тебя нет силы воли, ты недостаточно силен и, вероятно, не достигнешь своих целей.",
    "zh-Hans": "你下载这个应用程序是为了让自己变得更好。如果你现在输入这段文字，就意味着你没有意志力，不够坚强，很可能无法实现你的目标。",
    "zh-Hant": "你下載這個應用程式是為了讓自己變得更好。如果你現在輸入這段文字，就意味著你沒有意志力，不夠堅強，很可能無法實現你的目標。",
    "ja": "あなたはこのアプリを、自分自身を良くするためにダウンロードしました。もし今このテキストを入力するなら、それはあなたに意志力がなく、十分に強くなく、おそらく目標を達成できないことを意味します。",
    "ko": "당신은 자신을 위해 더 나아지려고 이 앱을 다운로드했습니다. 지금 이 텍스트를 입력한다면, 그것은 당신이 의지력이 없고, 충분히 강하지 않으며, 아마도 목표를 달성하지 못할 것임을 의미합니다.",
    "ar": "لقد قمت بتنزيل هذا التطبيق لتصبح أفضل، من أجل نفسك. إذا قمت بكتابة هذا النص الآن، فهذا يعني أنه ليس لديك قوة إرادة، ولست قوياً بما يكفي، وربما لن تحقق أهدافك.",
    "hi": "आपने खुद को बेहतर बनाने के लिए यह ऐप डाउनलोड किया है। यदि आप अभी यह टेक्स्ट टाइप करते हैं, तो इसका मतलब है कि आपके पास इच्छाशक्ति नहीं है, आप पर्याप्त मजबूत नहीं हैं, और शायद अपने लक्ष्यों को प्राप्त नहीं कर पाएंगे।",
    "tr": "Bu uygulamayı kendin için, daha iyi olmak için indirdin. Eğer şimdi bu metni yazarsan, bu senin iradenin olmadığını, yeterince güçlü olmadığını ve muhtemelen hedeflerine ulaşamayacağını gösterir.",
    "pl": "Pobrałeś tę aplikację, aby stać się lepszym, dla siebie. Jeśli wpiszesz teraz ten tekst, oznacza to, że nie masz siły woli, nie jesteś wystarczająco silny i prawdopodobnie nie osiągniesz swoich celów."
}

# Convert all to uppercase
translations = {k: v.upper() for k, v in translations.items()}

if key not in data["strings"]:
    data["strings"][key] = {
        "extractionState": "manual",
        "localizations": {}
    }

if "localizations" not in data["strings"][key]:
    data["strings"][key]["localizations"] = {}

project_langs = set()
for k, v in data["strings"].items():
    if "localizations" in v:
        for lang in v["localizations"].keys():
            project_langs.add(lang)

for lang in project_langs:
    trans = translations.get(lang)
    if not trans:
        if lang == "pt": trans = translations["pt-BR"]
        elif lang == "zh-HK": trans = translations["zh-Hant"]
        else: trans = translations["en"]
    
    data["strings"][key]["localizations"][lang] = {
        "stringUnit": {
            "state": "translated",
            "value": trans
        }
    }

data["strings"][key]["extractionState"] = "manual"

with open(path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
