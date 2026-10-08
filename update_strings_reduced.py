import json

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

new_keys = {
    "dopamine_story_time_title": {
        "de": "Deine Bildschirmzeit", "en": "Your Screen Time", "es": "Tu tiempo de pantalla", "fr": "Ton temps d'écran",
        "it": "Il tuo tempo di utilizzo", "pt-PT": "O teu tempo de ecrã", "nl": "Je schermtijd", "tr": "Ekran süren",
        "ru": "Ваше экранное время", "zh-Hans": "你的屏幕使用时间", "zh-Hant": "你的螢幕使用時間",
        "ja": "あなたのスクリーンタイム", "ko": "화면 시간", "ar": "وقت الشاشة الخاص بك", "hi": "आपका स्क्रीन समय"
    },
    "dopamine_story_time_life": {
        "de": "In deinem Leben", "en": "In your life", "es": "En tu vida", "fr": "Dans ta vie",
        "it": "Nella tua vita", "pt-PT": "Na tua vida", "nl": "In je leven", "tr": "Hayatın boyunca",
        "ru": "В вашей жизни", "zh-Hans": "你的一生", "zh-Hant": "你的一生",
        "ja": "あなたの一生で", "ko": "일생 동안", "ar": "في حياتك", "hi": "आपके जीवन में"
    },
    "dopamine_story_time_10y": {
        "de": "10 Jahre", "en": "10 years", "es": "10 años", "fr": "10 ans",
        "it": "10 anni", "pt-PT": "10 anos", "nl": "10 jaar", "tr": "10 yıl",
        "ru": "10 лет", "zh-Hans": "10年", "zh-Hant": "10年",
        "ja": "10年", "ko": "10년", "ar": "10 سنوات", "hi": "10 वर्ष"
    },
    "dopamine_story_time_year": {
        "de": "Im Jahr", "en": "Per year", "es": "Por año", "fr": "Par an",
        "it": "All'anno", "pt-PT": "Por ano", "nl": "Per jaar", "tr": "Yılda",
        "ru": "В год", "zh-Hans": "每年", "zh-Hant": "每年",
        "ja": "1年で", "ko": "연간", "ar": "في السنة", "hi": "प्रति वर्ष"
    },
    "dopamine_story_time_46d": {
        "de": "46 Tage", "en": "46 days", "es": "46 días", "fr": "46 jours",
        "it": "46 giorni", "pt-PT": "46 dias", "nl": "46 dagen", "tr": "46 gün",
        "ru": "46 дней", "zh-Hans": "46天", "zh-Hant": "46天",
        "ja": "46日", "ko": "46일", "ar": "46 يوماً", "hi": "46 दिन"
    },
    "dopamine_story_time_day": {
        "de": "Am Tag", "en": "Per day", "es": "Por día", "fr": "Par jour",
        "it": "Al giorno", "pt-PT": "Por dia", "nl": "Per dag", "tr": "Günde",
        "ru": "В день", "zh-Hans": "每天", "zh-Hant": "每天",
        "ja": "1日で", "ko": "하루에", "ar": "في اليوم", "hi": "प्रति दिन"
    },
    "dopamine_story_time_3h": {
        "de": "3+ Stunden", "en": "3+ hours", "es": "Más de 3 horas", "fr": "Plus de 3 heures",
        "it": "Più di 3 ore", "pt-PT": "Mais de 3 horas", "nl": "3+ uur", "tr": "3+ saat",
        "ru": "Более 3 часов", "zh-Hans": "3小时以上", "zh-Hant": "3小時以上",
        "ja": "3時間以上", "ko": "3시간 이상", "ar": "أكثر من 3 ساعات", "hi": "3+ घंटे"
    },
    "dopamine_story_prob_title": {
        "de": "Der Dopamin-Kick", "en": "The dopamine hit", "es": "El chute de dopamina", "fr": "Le pic de dopamine",
        "it": "Il picco di dopamina", "pt-PT": "O pico de dopamina", "nl": "De dopamine-kick", "tr": "Dopamin patlaması",
        "ru": "Всплеск дофамина", "zh-Hans": "多巴胺冲击", "zh-Hant": "多巴胺衝擊",
        "ja": "ドーパミンの急上昇", "ko": "도파민 분비", "ar": "اندفاع الدوبامين", "hi": "डोपामाइन का असर"
    },
    "dopamine_story_prob_sub": {
        "de": "Social Media liefert schnelle, unerwartete Belohnungen. Das Gehirn will immer mehr, der echte Fokus sinkt.", "en": "Social media delivers quick, unexpected rewards. The brain wants more, and true focus drops.", "es": "Las redes sociales dan recompensas rápidas. El cerebro quiere más y el enfoque cae.", "fr": "Les réseaux sociaux offrent des récompenses rapides. Le cerveau en veut toujours plus, et la concentration baisse.",
        "it": "I social media offrono ricompense rapide. Il cervello ne vuole di più, e la concentrazione cala.", "pt-PT": "As redes sociais dão recompensas rápidas. O cérebro quer mais, e o foco diminui.", "nl": "Social media geeft snelle beloningen. Je brein wil meer, en je focus daalt.", "tr": "Sosyal medya hızlı ödüller sunar. Beyin daha fazlasını ister ve odaklanma düşer.",
        "ru": "Соцсети дают быстрые награды. Мозг хочет больше, и концентрация падает.", "zh-Hans": "社交媒体提供快速奖励。大脑想要更多，而真正的专注力下降。", "zh-Hant": "社交媒體提供快速獎勵。大腦想要更多，而真正的專注力下降。",
        "ja": "SNSは手軽な報酬を与えます。脳はもっと欲しがり、集中力は低下します。", "ko": "소셜 미디어는 빠르고 예기치 않은 보상을 제공합니다. 뇌는 더 원하고 집중력은 떨어집니다.", "ar": "تقدم وسائل التواصل الاجتماعي مكافآت سريعة. الدماغ يريد المزيد، والتركيز يقل.", "hi": "सोशल मीडिया त्वरित इनाम देता है। दिमाग और अधिक चाहता है, और असली ध्यान कम हो जाता है।"
    },
    "dopamine_story_sol_title": {
        "de": "Nachhaltige Routinen", "en": "Sustainable routines", "es": "Rutinas sostenibles", "fr": "Routines durables",
        "it": "Routine sostenibili", "pt-PT": "Rotinas sustentáveis", "nl": "Duurzame routines", "tr": "Sürdürülebilir rutinler",
        "ru": "Устойчивые привычки", "zh-Hans": "可持续的日常习惯", "zh-Hant": "可持續的日常習慣",
        "ja": "持続可能なルーティン", "ko": "지속 가능한 습관", "ar": "روتين مستدام", "hi": "टिकाऊ दिनचर्या"
    },
    "dopamine_story_sol_sub": {
        "de": "Statt schnellen Kicks baust du echte Gewohnheiten auf. Im Schnitt dauert es 66 Tage, bis sie automatisch ablaufen.", "en": "Instead of quick hits, you build real habits. It takes an average of 66 days for them to become automatic.", "es": "En lugar de picos rápidos, construyes hábitos reales. Tardan una media de 66 días en volverse automáticos.", "fr": "Au lieu de pics rapides, tu construis de vraies habitudes. Il faut en moyenne 66 jours pour qu'elles deviennent automatiques.",
        "it": "Invece di picchi veloci, costruisci vere abitudini. Ci vogliono in media 66 giorni perché diventino automatiche.", "pt-PT": "Em vez de picos rápidos, constróis hábitos reais. Demora em média 66 dias para se tornarem automáticos.", "nl": "In plaats van snelle kicks bouw je echte gewoontes op. Gemiddeld duurt het 66 dagen voordat ze automatisch gaan.", "tr": "Hızlı ödüller yerine gerçek alışkanlıklar edinirsiniz. Bunların otomatik hale gelmesi ortalama 66 gün sürer.",
        "ru": "Вместо быстрых наград вы строите настоящие привычки. В среднем требуется 66 дней, чтобы они стали автоматическими.", "zh-Hans": "不再追求快速刺激，而是养成真正的习惯。平均需要66天，习惯才会自然形成。", "zh-Hant": "不再追求快速刺激，而是養成真正的習慣。平均需要66天，習慣才會自然形成。",
        "ja": "手軽な刺激の代わりに、本物の習慣を築きます。自動的にできるようになるまで平均66日かかります。", "ko": "빠른 쾌감 대신 진정한 습관을 만듭니다. 습관이 자동으로 자리 잡는 데 평균 66일이 걸립니다.", "ar": "بدلاً من المكافآت السريعة، تبني عادات حقيقية. يستغرق الأمر 66 يوماً في المتوسط لتصبح العادات تلقائية.", "hi": "तेज़ किक के बजाय, आप असली आदतें बनाते हैं। इन्हें स्वचालित होने में औसतन 66 दिन लगते हैं।"
    },
    "dopamine_story_fin_title": {
        "de": "Dein Garten wartet", "en": "Your garden awaits", "es": "Tu jardín te espera", "fr": "Ton jardin t'attend",
        "it": "Il tuo giardino ti aspetta", "pt-PT": "O teu jardim espera-te", "nl": "Je tuin wacht op je", "tr": "Bahçen seni bekliyor",
        "ru": "Ваш сад ждёт вас", "zh-Hans": "你的花园在等你", "zh-Hant": "你的花園在等你",
        "ja": "あなたの庭が待っています", "ko": "당신의 정원이 기다립니다", "ar": "حديقتك في انتظارك", "hi": "आपका बगीचा इंतजार कर रहा है"
    },
    "dopamine_story_fin_sub": {
        "de": "Tausche endlose Feeds gegen echte Erfolge.", "en": "Trade endless feeds for real accomplishments.", "es": "Cambia los feeds interminables por logros reales.", "fr": "Échange les fils d'actualité infinis contre de vraies réussites.",
        "it": "Scambia i feed infiniti con veri successi.", "pt-PT": "Troca feeds intermináveis por sucessos reais.", "nl": "Verruil eindeloze feeds voor echte successen.", "tr": "Sonsuz akışları gerçek başarılarla değiştir.",
        "ru": "Променяйте бесконечные ленты на настоящие достижения.", "zh-Hans": "用无尽的信息流换取真实的成就。", "zh-Hant": "用無盡的資訊流換取真實的成就。",
        "ja": "終わりのないフィードを本物の達成感に変えましょう。", "ko": "끝없는 피드 대신 진정한 성취를 얻으세요.", "ar": "استبدل التمرير المستمر بإنجازات حقيقية.", "hi": "अंतहीन फ़ीड्स को असली सफलताओं से बदलें।"
    }
}

langs = ["de", "en", "es", "fr", "it", "pt-PT", "nl", "tr", "ru", "zh-Hans", "zh-Hant", "ja", "ko", "ar", "hi"]

for key, translations in new_keys.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    
    for lang in langs:
        if lang not in data["strings"][key]["localizations"]:
            data["strings"][key]["localizations"][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": translations.get(lang, translations["en"])
                }
            }

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Keys added successfully!")
