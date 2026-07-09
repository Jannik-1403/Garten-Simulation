import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

new_strings = [
    {
        "key": "screentime.preprompt.title",
        "translations": {
            "de": "Schütze deinen Fokus",
            "en": "Protect your focus",
            "nl": "Bescherm je focus",
            "fr": "Protégez votre concentration",
            "it": "Proteggi la tua concentrazione",
            "ja": "集中力を守る",
            "ko": "집중력 보호",
            "pl": "Chroń swoje skupienie",
            "pt": "Proteja o seu foco",
            "es": "Protege tu concentración",
            "tr": "Odaklanmanı koru"
        }
    },
    {
        "key": "screentime.preprompt.desc",
        "translations": {
            "de": "Damit dein Garten wachsen kann und das Unkraut keine Chance hat, müssen wir deine Ablenkungen aussperren. Bitte erlaube den Screen-Time-Zugriff im nächsten Fenster, damit Grovy dich schützen kann.",
            "en": "To let your garden grow and give weeds no chance, we need to lock out your distractions. Please allow Screen Time access in the next window so Grovy can protect you.",
            "nl": "Om je tuin te laten groeien en onkruid geen kans te geven, moeten we je afleidingen buitensluiten. Sta schermtoegang toe in het volgende venster, zodat Grovy je kan beschermen.",
            "fr": "Pour laisser votre jardin pousser et ne donner aucune chance aux mauvaises herbes, nous devons bloquer vos distractions. Veuillez autoriser l'accès au temps d'écran dans la fenêtre suivante afin que Grovy puisse vous protéger.",
            "it": "Per far crescere il tuo giardino e non dare scampo alle erbacce, dobbiamo bloccare le tue distrazioni. Consenti l'accesso al tempo di utilizzo nella finestra successiva in modo che Grovy possa proteggerti.",
            "ja": "庭を育て、雑草にチャンスを与えないために、気晴らしをブロックする必要があります。Grovyがあなたを守れるように、次のウィンドウでスクリーンタイムへのアクセスを許可してください。",
            "ko": "정원이 자라게 하고 잡초가 자라지 못하게 하려면 주의가 산만해지는 것을 막아야 합니다. Grovy가 사용자를 보호할 수 있도록 다음 창에서 화면 시간 액세스를 허용하세요.",
            "pl": "Aby Twój ogród mógł rosnąć i nie dać szans chwastom, musimy zablokować Twoje czynniki rozpraszające. Zezwól na dostęp do czasu przed ekranem w następnym oknie, aby Grovy mógł Cię chronić.",
            "pt": "Para deixar o seu jardim crescer e não dar hipótese às ervas daninhas, precisamos de bloquear as suas distrações. Por favor, permita o acesso ao Tempo de Ecrã na janela seguinte para que o Grovy possa protegê-lo.",
            "es": "Para que tu jardín crezca y las malas hierbas no tengan oportunidad, debemos bloquear tus distracciones. Permita el acceso al tiempo de pantalla en la siguiente ventana para que Grovy pueda protegerlo.",
            "tr": "Bahçenizin büyümesini sağlamak ve yabani otlara şans tanımamak için dikkatinizi dağıtan şeyleri dışarıda bırakmalıyız. Grovy'nin sizi koruyabilmesi için lütfen sonraki pencerede Ekran Süresi erişimine izin verin."
        }
    },
    {
        "key": "screentime.preprompt.button",
        "translations": {
            "de": "Verstanden",
            "en": "Understood",
            "nl": "Begrepen",
            "fr": "Compris",
            "it": "Capito",
            "ja": "了解しました",
            "ko": "이해했습니다",
            "pl": "Zrozumiałem",
            "pt": "Entendi",
            "es": "Entendido",
            "tr": "Anladım"
        }
    }
]

for item in new_strings:
    key = item["key"]
    translations = item["translations"]
    
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}

    for lang, text in translations.items():
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
