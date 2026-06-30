import json

file_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"

try:
    with open(file_path, 'r') as f:
        data = json.load(f)
except Exception as e:
    print(f"Error: {e}")
    exit(1)

new_strings = {
    "focus.session.dnd_hint": {
        "de": "Schalte dein Handy jetzt auf 'Nicht stören' und lege es nach dieser Einrichtung außer Sichtweite.",
        "en": "Put your phone on 'Do Not Disturb' now and place it out of sight after this setup.",
        "es": "Pon tu teléfono en 'No Molestar' ahora y colócalo fuera de la vista después de esta configuración.",
        "fr": "Mettez votre téléphone sur 'Ne pas déranger' maintenant et placez-le hors de vue après cette configuration.",
        "it": "Metti il tuo telefono in 'Non Disturbare' ora e mettilo fuori dalla vista dopo questa configurazione.",
        "pt": "Coloque seu telefone em 'Não Perturbe' agora e coloque-o fora de vista após esta configuração.",
        "ja": "今すぐ電話を「おやすみモード」にして、設定後に見えない場所に置いてください。",
        "ko": "지금 휴대전화를 '방해 금지' 모드로 설정하고 설정 후 눈에 띄지 않는 곳에 두세요.",
        "pl": "Włącz teraz tryb 'Nie przeszkadzać' i odłóż telefon poza zasięg wzroku po tej konfiguracji.",
        "nl": "Zet je telefoon nu op 'Niet storen' en leg hem uit het zicht na deze installatie.",
        "tr": "Telefonunuzu şimdi 'Rahatsız Etmeyin' moduna alın ve bu kurulumdan sonra gözden uzak bir yere koyun."
    },
    "focus.session.goal_hint": {
        "de": "Was genau möchtest du in deiner Fokus-Zeit schaffen? Nimm dir einen Moment, um dich zu fokussieren.",
        "en": "What exactly do you want to accomplish in your focus time? Take a moment to focus.",
        "es": "¿Qué quieres lograr exactamente en tu tiempo de enfoque? Tómate un momento para enfocarte.",
        "fr": "Que voulez-vous accomplir exactement pendant votre temps de concentration ? Prenez un moment pour vous concentrer.",
        "it": "Cosa vuoi realizzare esattamente nel tuo tempo di focus? Prenditi un momento per concentrarti.",
        "pt": "O que exatamente você quer realizar no seu tempo de foco? Reserve um momento para se concentrar.",
        "ja": "フォーカス時間で正確に何を達成したいですか？ 集中するための時間を取ってください。",
        "ko": "집중 시간 동안 정확히 무엇을 성취하고 싶으신가요? 잠시 집중할 시간을 가지세요.",
        "pl": "Co dokładnie chcesz osiągnąć w swoim czasie skupienia? Poświęć chwilę na koncentrację.",
        "nl": "Wat wil je precies bereiken in je focustijd? Neem even de tijd om je te concentreren.",
        "tr": "Odaklanma zamanınızda tam olarak ne başarmak istiyorsunuz? Odaklanmak için bir an ayırın."
    },
    "inventory.item.desc.growth_boost": {
        "de": "Beschleunigt das Wachstum deiner Pflanzen um 50% für die nächsten 24 Stunden.",
        "en": "Accelerates the growth of your plants by 50% for the next 24 hours.",
        "es": "Acelera el crecimiento de tus plantas en un 50% durante las próximas 24 horas.",
        "fr": "Accélère la croissance de vos plantes de 50% pendant les prochaines 24 heures.",
        "it": "Accelera la crescita delle tue piante del 50% per le prossime 24 ore.",
        "pt": "Acelera o crescimento de suas plantas em 50% pelas próximas 24 horas.",
        "ja": "次の24時間、植物の成長を50%加速させます。",
        "ko": "다음 24시간 동안 식물의 성장을 50% 가속화합니다.",
        "pl": "Przyspiesza wzrost twoich roślin o 50% przez następne 24 godziny.",
        "nl": "Versnelt de groei van je planten met 50% voor de komende 24 uur.",
        "tr": "Önümüzdeki 24 saat boyunca bitkilerinizin büyümesini %50 hızlandırır."
    },
    "inventory.item.symbolism.growth_boost": {
        "de": "Energie und schnelles Vorankommen.",
        "en": "Energy and rapid progress.",
        "es": "Energía y progreso rápido.",
        "fr": "Énergie et progrès rapide.",
        "it": "Energia e progresso rapido.",
        "pt": "Energia e progresso rápido.",
        "ja": "エネルギーと迅速な進歩。",
        "ko": "에너지와 빠른 진전.",
        "pl": "Energia i szybki postęp.",
        "nl": "Energie en snelle vooruitgang.",
        "tr": "Enerji ve hızlı ilerleme."
    },
    "banner.start_journey": {
        "de": "Starte deine Reise",
        "en": "Start your journey",
        "es": "Comienza tu viaje",
        "fr": "Commencez votre voyage",
        "it": "Inizia il tuo viaggio",
        "pt": "Comece sua jornada",
        "ja": "あなたの旅を始めましょう",
        "ko": "여정을 시작하세요",
        "pl": "Rozpocznij swoją podróż",
        "nl": "Begin je reis",
        "tr": "Yolculuğunuza başlayın"
    },
    "settings.terms.placeholder": {
        "de": "Dies sind die Nutzungsbedingungen für die Garten-Simulation...",
        "en": "These are the terms of use for the Garden Simulation...",
        "es": "Estos son los términos de uso para la Simulación de Jardín...",
        "fr": "Ce sont les conditions d'utilisation de la Simulation de Jardin...",
        "it": "Questi sono i termini di utilizzo per la Simulazione Giardino...",
        "pt": "Estes são os termos de uso para a Simulação de Jardim...",
        "ja": "これはガーデンシミュレーションの利用規約です...",
        "ko": "정원 시뮬레이션의 이용 약관입니다...",
        "pl": "Oto warunki użytkowania Symulacji Ogrodu...",
        "nl": "Dit zijn de gebruiksvoorwaarden voor de Tuinsimulatie...",
        "tr": "Bahçe Simülasyonu kullanım şartları şunlardır..."
    },
    "developer.jump_to_day_89": {
        "de": "Zu Tag 89 springen",
        "en": "Jump to Day 89",
        "es": "Saltar al Día 89",
        "fr": "Sauter au jour 89",
        "it": "Salta al giorno 89",
        "pt": "Pular para o dia 89",
        "ja": "89日目にジャンプ",
        "ko": "89일로 점프",
        "pl": "Skocz do dnia 89",
        "nl": "Spring naar dag 89",
        "tr": "89. Güne Atla"
    },
    "developer.options.title": {
        "de": "Developer Options",
        "en": "Developer Options",
        "es": "Opciones de Desarrollador",
        "fr": "Options du développeur",
        "it": "Opzioni Sviluppatore",
        "pt": "Opções de Desenvolvedor",
        "ja": "開発者オプション",
        "ko": "개발자 옵션",
        "pl": "Opcje Programisty",
        "nl": "Ontwikkelaarsopties",
        "tr": "Geliştirici Seçenekleri"
    }
}

for key, translations in new_strings.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang, text in translations.items():
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open(file_path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Strings updated successfully!")
