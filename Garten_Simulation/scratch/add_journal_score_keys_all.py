import json

file_path = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings'

with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

new_keys = {
    "fitness.gratitude.summary.good": {
        "de": "Journal ✓", "en": "Journal ✓", "es": "Diario ✓", "fr": "Journal ✓", "it": "Diario ✓",
        "pt": "Diário ✓", "pt-BR": "Diário ✓", "nl": "Dagboek ✓", "ru": "Журнал ✓", "zh-Hans": "日记 ✓", "zh-Hant": "日記 ✓",
        "ja": "日記 ✓", "ko": "일기 ✓", "pl": "Dziennik ✓", "tr": "Günlük ✓", "hi": "जर्नल ✓"
    },
    "fitness.gratitude.summary.missing": {
        "de": "Journal fehlt", "en": "Journal missing", "es": "Falta el diario", "fr": "Journal manquant", "it": "Diario mancante",
        "pt": "Diário em falta", "pt-BR": "Diário faltando", "nl": "Dagboek ontbreekt", "ru": "Журнал отсутствует", "zh-Hans": "缺少日记", "zh-Hant": "缺少日記",
        "ja": "日記がありません", "ko": "일기 없음", "pl": "Brak dziennika", "tr": "Günlük eksik", "hi": "जर्नल गायब है"
    },
    "fitness.gratitude.detail.good": {
        "de": "Klasse, du hast dir heute schon Zeit für dein Journal genommen!", 
        "en": "Great, you have already taken time for your journal today!",
        "es": "¡Genial, ya te has tomado tiempo para tu diario hoy!",
        "fr": "Super, tu as déjà pris du temps pour ton journal aujourd'hui !",
        "it": "Fantastico, hai già dedicato del tempo al tuo diario oggi!",
        "pt": "Ótimo, já tiraste tempo para o teu diário hoje!",
        "pt-BR": "Ótimo, você já tirou um tempo para o seu diário hoje!",
        "nl": "Geweldig, je hebt vandaag al tijd genomen voor je dagboek!",
        "ru": "Отлично, сегодня вы уже уделили время своему журналу!",
        "zh-Hans": "太棒了，你今天已经花时间写日记了！",
        "zh-Hant": "太棒了，你今天已經花時間寫日記了！",
        "ja": "素晴らしい、今日すでに日記の時間を作りましたね！",
        "ko": "잘하셨어요, 오늘 이미 일기 쓸 시간을 내셨군요!",
        "pl": "Świetnie, że znalazłeś dzisiaj czas na swój dziennik!",
        "tr": "Harika, bugün günlüğün için zaten zaman ayırdın!",
        "hi": "बहुत बढ़िया, आपने आज पहले ही अपनी जर्नल के लिए समय निकाल लिया है!"
    },
    "fitness.gratitude.detail.yesterday.improve": {
        "de": "Heute wolltest du laut gestern das hier besser machen: %@",
        "en": "Yesterday you said you wanted to do this better today: %@",
        "es": "Ayer dijiste que querías hacer esto mejor hoy: %@",
        "fr": "Hier, tu as dit que tu voulais mieux faire cela aujourd'hui : %@",
        "it": "Ieri hai detto che volevi fare meglio questo oggi: %@",
        "pt": "Ontem disseste que querias fazer isto melhor hoje: %@",
        "pt-BR": "Ontem você disse que queria fazer isso melhor hoje: %@",
        "nl": "Gisteren zei je dat je dit vandaag beter wilde doen: %@",
        "ru": "Вчера вы сказали, что хотите сделать это лучше сегодня: %@",
        "zh-Hans": "昨天你说今天想把这做得更好：%@",
        "zh-Hant": "昨天你說今天想把這做得更好：%@",
        "ja": "昨日、今日はこれをより良くしたいと言っていましたね: %@",
        "ko": "어제 당신은 오늘 이것을 더 잘하고 싶다고 말했습니다: %@",
        "pl": "Wczoraj powiedziałeś, że chcesz zrobić to lepiej dzisiaj: %@",
        "tr": "Dün bugün bunu daha iyi yapmak istediğini söyledin: %@",
        "hi": "कल आपने कहा था कि आप आज इसे बेहतर करना चाहते हैं: %@"
    },
    "fitness.gratitude.detail.yesterday.low": {
        "de": "Gestern hast du dich nicht so gut gefühlt. Probier heute dich besser zu fühlen oder gestalte deinen Tag so, dass du dich besser fühlst.",
        "en": "Yesterday you didn't feel so good. Try to feel better today or shape your day so you feel better.",
        "es": "Ayer no te sentiste muy bien. Intenta sentirte mejor hoy o diseña tu día para sentirte mejor.",
        "fr": "Hier, tu ne te sentais pas très bien. Essaie de te sentir mieux aujourd'hui ou organise ta journée pour te sentir mieux.",
        "it": "Ieri non ti sei sentito molto bene. Prova a sentirti meglio oggi o organizza la tua giornata per sentirti meglio.",
        "pt": "Ontem não te sentiste muito bem. Tenta sentir-te melhor hoje ou organiza o teu dia para te sentires melhor.",
        "pt-BR": "Ontem você não se sentiu muito bem. Tente se sentir melhor hoje ou organize seu dia para se sentir melhor.",
        "nl": "Gisteren voelde je je niet zo goed. Probeer je vandaag beter te voelen of deel je dag zo in dat je je beter voelt.",
        "ru": "Вчера вы чувствовали себя не очень хорошо. Постарайтесь сегодня почувствовать себя лучше или спланируйте свой день так, чтобы почувствовать себя лучше.",
        "zh-Hans": "昨天你感觉不太好。今天试着感觉好点，或者安排你的一天让自己感觉更好。",
        "zh-Hant": "昨天你感覺不太好。今天試著感覺好點，或者安排你的一天讓自己感覺更好。",
        "ja": "昨日はあまり気分が良くありませんでしたね。今日はもっと気分を良くするか、気分が良くなるように一日を計画してみてください。",
        "ko": "어제는 기분이 별로 좋지 않았네요. 오늘은 기분이 좋아지도록 노력하거나 기분이 좋아지도록 하루를 계획해 보세요.",
        "pl": "Wczoraj nie czułeś się najlepiej. Spróbuj dzisiaj poczuć się lepiej lub zaplanuj swój dzień tak, aby poczuć się lepiej.",
        "tr": "Dün kendini pek iyi hissetmedin. Bugün kendini daha iyi hissetmeye çalış veya gününü kendini daha iyi hissedecek şekilde planla.",
        "hi": "कल आपको अच्छा नहीं लग रहा था। आज बेहतर महसूस करने की कोशिश करें या अपने दिन की योजना ऐसे बनाएं कि आपको बेहतर महसूस हो।"
    },
    "fitness.gratitude.detail.yesterday.high": {
        "de": "Gestern hast du dich exzellent gefühlt, mach heute weiter so!",
        "en": "Yesterday you felt excellent, keep it up today!",
        "es": "Ayer te sentiste excelente, ¡sigue así hoy!",
        "fr": "Hier tu te sentais très bien, continue comme ça aujourd'hui !",
        "it": "Ieri ti sei sentito eccellente, continua così oggi!",
        "pt": "Ontem sentiste-te excelente, continua assim hoje!",
        "pt-BR": "Ontem você se sentiu excelente, continue assim hoje!",
        "nl": "Gisteren voelde je je uitstekend, ga zo door vandaag!",
        "ru": "Вчера вы чувствовали себя отлично, продолжайте в том же духе сегодня!",
        "zh-Hans": "昨天你感觉极好，今天继续保持！",
        "zh-Hant": "昨天你感覺極好，今天繼續保持！",
        "ja": "昨日は素晴らしい気分でしたね、今日もその調子で！",
        "ko": "어제는 기분이 최고였어요, 오늘도 이대로 쭉 가요!",
        "pl": "Wczoraj czułeś się wyśmienicie, trzymaj tak dalej dzisiaj!",
        "tr": "Dün kendini harika hissettin, bugün de aynen devam!",
        "hi": "कल आपने बहुत अच्छा महसूस किया था, आज भी इसे जारी रखें!"
    },
    "fitness.gratitude.detail.yesterday.medium": {
        "de": "Nutze dein Journal, um deinen Tag zu reflektieren.",
        "en": "Use your journal to reflect on your day.",
        "es": "Usa tu diario para reflexionar sobre tu día.",
        "fr": "Utilise ton journal pour réfléchir à ta journée.",
        "it": "Usa il tuo diario per riflettere sulla tua giornata.",
        "pt": "Usa o teu diário para refletir sobre o teu dia.",
        "pt-BR": "Use seu diário para refletir sobre o seu dia.",
        "nl": "Gebruik je dagboek om op je dag te reflecteren.",
        "ru": "Используйте свой журнал для размышлений о прошедшем дне.",
        "zh-Hans": "用日记来反思你的一天。",
        "zh-Hant": "用日記來反思你的一天。",
        "ja": "日記を使って一日を振り返りましょう。",
        "ko": "일기를 활용해 하루를 되돌아보세요.",
        "pl": "Użyj swojego dziennika, aby zastanowić się nad swoim dniem.",
        "tr": "Günlüğünü kullanarak gününü değerlendir.",
        "hi": "अपने दिन पर विचार करने के लिए अपनी जर्नल का उपयोग करें।"
    },
    "fitness.gratitude.detail.not_done": {
        "de": "Du hast heute noch kein Journal geschrieben. Halte kurz inne und reflektiere deinen Tag.",
        "en": "You haven't written a journal today. Pause for a moment and reflect on your day.",
        "es": "Aún no has escrito un diario hoy. Haz una pausa y reflexiona sobre tu día.",
        "fr": "Tu n'as pas encore écrit dans ton journal aujourd'hui. Fais une pause et réfléchis à ta journée.",
        "it": "Non hai ancora scritto un diario oggi. Fai una pausa e rifletti sulla tua giornata.",
        "pt": "Ainda não escreveste no diário hoje. Faz uma pausa e reflete sobre o teu dia.",
        "pt-BR": "Você ainda não escreveu um diário hoje. Faça uma pausa e reflita sobre o seu dia.",
        "nl": "Je hebt vandaag nog geen dagboek geschreven. Pauzeer even en reflecteer op je dag.",
        "ru": "Сегодня вы еще не заполняли журнал. Сделайте паузу и поразмышляйте о своем дне.",
        "zh-Hans": "你今天还没有写日记。停下来反思一下你的一天。",
        "zh-Hant": "你今天還沒有寫日記。停下來反思一下你的一天。",
        "ja": "今日はまだ日記を書いていませんね。少し立ち止まって一日を振り返ってみましょう。",
        "ko": "오늘 아직 일기를 쓰지 않았네요. 잠시 멈추고 하루를 되돌아보세요.",
        "pl": "Jeszcze dzisiaj nie pisałeś w dzienniku. Zrób przerwę i pomyśl o swoim dniu.",
        "tr": "Bugün henüz günlük yazmadın. Biraz durakla ve gününü değerlendir.",
        "hi": "आपने आज अभी तक जर्नल नहीं लिखी है। थोड़ा रुकें और अपने दिन पर विचार करें।"
    },
    "fitness.category.gratitude": {
        "de": "Dankbarkeits-Check", "en": "Gratitude Check", "es": "Control de gratitud", "fr": "Bilan de gratitude", "it": "Controllo gratitudine",
        "pt": "Check de Gratidão", "pt-BR": "Checagem de Gratidão", "nl": "Dankbaarheidscheck", "ru": "Проверка благодарности", "zh-Hans": "感恩检查", "zh-Hant": "感恩檢查",
        "ja": "感謝チェック", "ko": "감사 체크", "pl": "Sprawdzenie wdzięczności", "tr": "Şükran Kontrolü", "hi": "आभार चेक"
    },
    "tagesanalyseHeaderDankbarkeit": {
        "de": "Dankbarkeits-Check", "en": "Gratitude Check", "es": "Control de gratitud", "fr": "Bilan de gratitude", "it": "Controllo gratitudine",
        "pt": "Check de Gratidão", "pt-BR": "Checagem de Gratidão", "nl": "Dankbaarheidscheck", "ru": "Проверка благодарности", "zh-Hans": "感恩检查", "zh-Hant": "感恩檢查",
        "ja": "感謝チェック", "ko": "감사 체크", "pl": "Sprawdzenie wdzięczności", "tr": "Şükran Kontrolü", "hi": "आभार चेक"
    }
}

languages_in_file = set()
for string_data in data.get("strings", {}).values():
    if "localizations" in string_data:
        languages_in_file.update(string_data["localizations"].keys())

for key, translations in new_keys.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang in languages_in_file:
        trans_text = translations.get(lang)
        if not trans_text:
            print(f"Warning: No translation for {lang} in {key}, falling back to English")
            trans_text = translations.get("en")
            
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": trans_text
            }
        }

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Added complete translations for {len(new_keys)} strings across {len(languages_in_file)} languages.")
