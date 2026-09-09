import json

languages = ['en', 'ja', 'ru', 'fr', 'pt-BR', 'zh-Hant', 'zh-Hans', 'nl', 'de', 'pt', 'it', 'tr', 'hi', 'ko', 'pl', 'es']

# Translations
translations = {
    "notification.title.generic": {
        "de": "Erinnerung",
        "en": "Reminder",
        "es": "Recordatorio",
        "fr": "Rappel",
        "it": "Promemoria",
        "pt": "Lembrete",
        "pt-BR": "Lembrete",
        "nl": "Herinnering",
        "pl": "Przypomnienie",
        "tr": "Hatırlatma",
        "ru": "Напоминание",
        "ja": "リマインダー",
        "ko": "알림",
        "zh-Hans": "提醒",
        "zh-Hant": "提醒",
        "hi": "अनुस्मारक"
    },
    "notification.body.generic": {
        "de": "Vergiss nicht: %@ wartet auf dich!",
        "en": "Don't forget: %@ is waiting for you!",
        "es": "No olvides: ¡%@ te espera!",
        "fr": "N'oubliez pas : %@ vous attend !",
        "it": "Non dimenticare: %@ ti sta aspettando!",
        "pt": "Não esqueças: %@ está à tua espera!",
        "pt-BR": "Não esqueça: %@ está esperando por você!",
        "nl": "Vergeet niet: %@ wacht op je!",
        "pl": "Nie zapomnij: %@ czeka na Ciebie!",
        "tr": "Unutma: %@ seni bekliyor!",
        "ru": "Не забудьте: %@ ждет вас!",
        "ja": "忘れないでください：%@があなたを待っています！",
        "ko": "잊지 마세요: %@이(가) 당신을 기다리고 있습니다!",
        "zh-Hans": "别忘了：%@在等你！",
        "zh-Hant": "別忘了：%@在等你！",
        "hi": "याद रखें: %@ आपका इंतजार कर रहा है!"
    },
    "notification.body.habit.obst_gemuese": {
        "de": "Du musst heute noch zum Beispiel Obst und Gemüse zu dir nehmen.",
        "en": "You still need to eat your fruits and vegetables today.",
        "es": "Aún necesitas comer tus frutas y verduras hoy.",
        "fr": "Vous devez encore manger vos fruits et légumes aujourd'hui.",
        "it": "Oggi devi ancora mangiare frutta e verdura.",
        "pt": "Ainda precisas de comer as tuas frutas e vegetais hoje.",
        "pt-BR": "Você ainda precisa comer suas frutas e legumes hoje.",
        "nl": "Je moet vandaag nog je fruit en groenten eten.",
        "pl": "Musisz dzisiaj zjeść jeszcze owoce i warzywa.",
        "tr": "Bugün hala meyve ve sebzelerini yemen gerekiyor.",
        "ru": "Вам сегодня еще нужно съесть фрукты и овощи.",
        "ja": "今日はまだ果物と野菜を食べる必要があります。",
        "ko": "오늘 아직 과일과 채소를 먹어야 합니다.",
        "zh-Hans": "你今天还需要吃点水果和蔬菜。",
        "zh-Hant": "你今天還需要吃點水果和蔬菜。",
        "hi": "आपको आज भी अपने फल और सब्जियां खानी हैं।"
    },
    "notification.body.habit.gesund_kochen": {
        "de": "Heute hast du noch nicht gesund gekocht.",
        "en": "You haven't cooked a healthy meal today.",
        "es": "Hoy no has cocinado una comida saludable.",
        "fr": "Tu n'as pas cuisiné sainement aujourd'hui.",
        "it": "Oggi non hai cucinato un pasto sano.",
        "pt": "Hoje não cozinhaste uma refeição saudável.",
        "pt-BR": "Hoje você não cozinhou uma refeição saudável.",
        "nl": "Je hebt vandaag nog niet gezond gekookt.",
        "pl": "Dzisiaj nie ugotowałeś jeszcze zdrowego posiłku.",
        "tr": "Bugün henüz sağlıklı bir yemek pişirmedin.",
        "ru": "Сегодня вы еще не приготовили здоровую еду.",
        "ja": "今日はまだ健康的な食事を作っていません。",
        "ko": "오늘은 아직 건강한 식사를 요리하지 않았습니다.",
        "zh-Hans": "你今天还没做一顿健康的饭菜。",
        "zh-Hant": "你今天還沒做一頓健康的飯菜。",
        "hi": "आज आपने स्वस्थ भोजन नहीं पकाया है।"
    },
    "notification.body.habit.wasser_trinken": {
        "de": "Heute musst du noch mehr Wasser trinken.",
        "en": "You still need to drink more water today.",
        "es": "Aún necesitas beber más agua hoy.",
        "fr": "Tu dois encore boire plus d'eau aujourd'hui.",
        "it": "Oggi devi ancora bere più acqua.",
        "pt": "Ainda precisas de beber mais água hoje.",
        "pt-BR": "Você ainda precisa beber mais água hoje.",
        "nl": "Je moet vandaag nog meer water drinken.",
        "pl": "Musisz dzisiaj wypić więcej wody.",
        "tr": "Bugün daha fazla su içmelisin.",
        "ru": "Сегодня вам нужно выпить больше воды.",
        "ja": "今日はもっと水を飲む必要があります。",
        "ko": "오늘 물을 더 마셔야 합니다.",
        "zh-Hans": "你今天还需要喝更多的水。",
        "zh-Hant": "你今天還需要喝更多的水。",
        "hi": "आज आपको और पानी पीने की जरूरत है।"
    }
}

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, 'r') as f:
    data = json.load(f)

for key, lang_dict in translations.items():
    if key not in data['strings']:
        data['strings'][key] = {"extractionState": "manual", "localizations": {}}
    for lang in languages:
        data['strings'][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": lang_dict.get(lang, lang_dict["en"])
            }
        }

with open(path, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Injected localized strings.")
