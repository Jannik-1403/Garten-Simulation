import json

file_path = "Garten_Simulation/Localizable.xcstrings"

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

translations = {
    "tour_3_title": {
        "de": "Shop",
        "en": "Shop",
        "es": "Tienda",
        "fr": "Boutique",
        "hi": "दुकान",
        "it": "Negozio",
        "ja": "ショップ",
        "ko": "상점",
        "nl": "Winkel",
        "pl": "Sklep",
        "pt": "Loja",
        "ru": "Магазин",
        "tr": "Dükkan",
        "zh-Hans": "商店",
        "zh-Hant": "商店"
    },
    "tour_2_desc": {
        "de": "Schlechte Gewohnheiten können sich auf deinen Körper auswirken. Achte darauf so wenig wie möglich zu machen. Sei auch immer ehrlich zu dir selber.",
        "en": "Bad habits can affect your body. Make sure to do as little as possible. Always be honest with yourself.",
        "es": "Los malos hábitos pueden afectar a tu cuerpo. Asegúrate de hacer lo menos posible. Sé siempre honesto contigo mismo.",
        "fr": "Les mauvaises habitudes peuvent affecter votre corps. Veillez à en faire le moins possible. Soyez toujours honnête avec vous-même.",
        "hi": "बुरी आदतें आपके शरीर को प्रभावित कर सकती हैं। सुनिश्चित करें कि आप जितना संभव हो उतना कम करें। हमेशा खुद के प्रति ईमानदार रहें।",
        "it": "Le cattive abitudini possono influire sul tuo corpo. Assicurati di farne il meno possibile. Sii sempre onesto con te stesso.",
        "ja": "悪い習慣は体に影響を与える可能性があります。できるだけ少なくするようにしてください。常に自分に正直になってください。",
        "ko": "나쁜 습관은 몸에 영향을 미칠 수 있습니다. 가능한 한 적게 하도록 하세요. 항상 자신에게 정직해지세요.",
        "nl": "Slechte gewoonten kunnen je lichaam beïnvloeden. Zorg ervoor dat je zo min mogelijk doet. Wees altijd eerlijk tegen jezelf.",
        "pl": "Złe nawyki mogą wpływać na twoje ciało. Upewnij się, że robisz jak najmniej. Zawsze bądź ze sobą szczery.",
        "pt": "Os maus hábitos podem afetar o seu corpo. Certifique-se de fazer o mínimo possível. Seja sempre honesto consigo mesmo.",
        "ru": "Плохие привычки могут сказаться на вашем теле. Старайтесь делать как можно меньше. Всегда будьте честны с собой.",
        "tr": "Kötü alışkanlıklar vücudunuzu etkileyebilir. Mümkün olduğunca az yapmaya dikkat edin. Kendinize karşı her zaman dürüst olun.",
        "zh-Hans": "坏习惯会影响你的身体。尽量少做。始终对自己诚实。",
        "zh-Hant": "壞習慣會影響你的身體。盡量少做。始終對自己誠實。"
    },
    "tour_3_desc": {
        "de": "Nutze deine Coins um dir neue Gewohnheiten anzueignen. Hier kannst du auch deine schlechten Gewohnheiten anfangen zu tracken und jeden Tag ein kostenloses Glücksrad drehen, um Belohnungen freizuschalten.",
        "en": "Use your coins to acquire new habits. Here you can also start tracking your bad habits and spin a free wheel of fortune every day to unlock rewards.",
        "es": "Usa tus monedas para adquirir nuevos hábitos. Aquí también puedes empezar a hacer un seguimiento de tus malos hábitos y girar una ruleta de la suerte gratis todos los días para desbloquear recompensas.",
        "fr": "Utilisez vos pièces pour acquérir de nouvelles habitudes. Ici, vous pouvez également commencer à suivre vos mauvaises habitudes et faire tourner une roue de la fortune gratuite chaque jour pour débloquer des récompenses.",
        "hi": "नई आदतें हासिल करने के लिए अपने सिक्कों का उपयोग करें। यहां आप अपनी बुरी आदतों को ट्रैक करना भी शुरू कर सकते हैं और पुरस्कार अनलॉक करने के लिए हर दिन एक मुफ्त लकी व्हील घुमा सकते हैं।",
        "it": "Usa le tue monete per acquisire nuove abitudini. Qui puoi anche iniziare a monitorare le tue cattive abitudini e girare una ruota della fortuna gratuita ogni giorno per sbloccare ricompense.",
        "ja": "コインを使って新しい習慣を身につけましょう。ここでは、悪い習慣の追跡を開始したり、毎日無料のルーレットを回して報酬をロック解除したりすることもできます。",
        "ko": "코인을 사용하여 새로운 습관을 얻으세요. 여기서 나쁜 습관을 추적하기 시작하고 매일 무료 행운의 룰렛을 돌려 보상을 잠금 해제할 수도 있습니다.",
        "nl": "Gebruik je munten om nieuwe gewoonten aan te leren. Hier kun je ook beginnen met het bijhouden van je slechte gewoonten en elke dag aan een gratis rad van fortuin draaien om beloningen te ontgrendelen.",
        "pl": "Użyj swoich monet, aby zdobyć nowe nawyki. Tutaj możesz również zacząć śledzić swoje złe nawyki i codziennie kręcić darmowym kołem fortuny, aby odblokować nagrody.",
        "pt": "Use suas moedas para adquirir novos hábitos. Aqui você também pode começar a monitorar seus maus hábitos e girar uma roda da fortuna grátis todos os dias para desbloquear recompensas.",
        "ru": "Используйте свои монеты для приобретения новых привычек. Здесь вы также можете начать отслеживать свои плохие привычки и каждый день крутить бесплатное колесо фортуны, чтобы разблокировать награды.",
        "tr": "Yeni alışkanlıklar edinmek için jetonlarınızı kullanın. Burada ayrıca kötü alışkanlıklarınızı izlemeye başlayabilir ve ödüllerin kilidini açmak için her gün ücretsiz bir şans çarkı çevirebilirsiniz.",
        "zh-Hans": "使用您的金币来养成新习惯。在这里，您还可以开始追踪自己的坏习惯，并每天免费转动幸运轮盘来解锁奖励。",
        "zh-Hant": "使用您的金幣來養成新習慣。在這裡，您還可以開始追蹤自己的壞習慣，並每天免費轉動幸運輪盤來解鎖獎勵。"
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
