import json
import os

path = 'Garten_Simulation/Localizable.xcstrings'
with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)

keys = {
    "cheat_punishment.title": {
        "de": "🚨 SYSTEMZUGRIFF BLOCKIERT",
        "en": "🚨 SYSTEM ACCESS BLOCKED",
        "es": "🚨 ACCESO AL SISTEMA BLOQUEADO",
        "fr": "🚨 ACCÈS AU SYSTÈME BLOQUÉ",
        "hi": "🚨 सिस्टम पहुँच अवरुद्ध",
        "it": "🚨 ACCESSO AL SISTEMA BLOCCATO",
        "ja": "🚨 システムアクセスがブロックされました",
        "ko": "🚨 시스템 액세스 차단됨",
        "nl": "🚨 SYSTEEMTOEGANG GEBLOKKEERD",
        "pl": "🚨 DOSTĘP DO SYSTEMU ZABLOKOWANY",
        "pt": "🚨 ACESSO AO SISTEMA BLOQUEADO",
        "ru": "🚨 ДОСТУП К СИСТЕМЕ ЗАБЛОКИРОВАН",
        "tr": "🚨 SİSTEM ERİŞİMİ ENGELLENDİ"
    },
    "cheat_punishment.message": {
        "de": "Du hast die App- & Website-Aktivitäten in den iOS-Einstellungen deaktiviert. Damit hast du das Fundament deines Gartens zerstört.",
        "en": "You have disabled App & Website Activities in the iOS settings. With this, you have destroyed the foundation of your garden.",
        "es": "Has desactivado las Actividades de Apps y Sitios Web en los ajustes de iOS. Con esto, has destruido los cimientos de tu jardín.",
        "fr": "Vous avez désactivé les Activités des apps et des sites web dans les réglages d'iOS. Avec cela, vous avez détruit les fondations de votre jardin.",
        "hi": "आपने iOS सेटिंग्स में ऐप और वेबसाइट गतिविधियों को अक्षम कर दिया है। इसके साथ, आपने अपने बगीचे की नींव नष्ट कर दी है।",
        "it": "Hai disabilitato le Attività di app e siti web nelle impostazioni di iOS. Con questo, hai distrutto le fondamenta del tuo giardino.",
        "ja": "iOSの設定でアプリとウェブサイトのアクティビティを無効にしました。これにより、あなたは庭の基盤を破壊しました。",
        "ko": "iOS 설정에서 앱 및 웹사이트 활동을 비활성화했습니다. 이로써 정원의 기반이 파괴되었습니다.",
        "nl": "Je hebt App- en website-activiteiten uitgeschakeld in de iOS-instellingen. Hiermee heb je de fundering van je tuin vernietigd.",
        "pl": "Wyłączyłeś Aktywność aplikacji i witryn w ustawieniach iOS. Tym samym zniszczyłeś fundamenty swojego ogrodu.",
        "pt": "Você desativou as Atividades de Apps e Sites nos ajustes do iOS. Com isso, você destruiu os alicerces do seu jardim.",
        "ru": "Вы отключили активность приложений и веб-сайтов в настройках iOS. Тем самым вы разрушили фундамент своего сада.",
        "tr": "iOS ayarlarında Uygulama ve Web Sitesi Etkinliklerini devre dışı bıraktınız. Bununla bahçenizin temelini yok ettiniz."
    },
    "cheat_punishment.warning": {
        "de": "Dein Garten verliert aktuell jede Stunde 1 Leben. Schalte die Bildschirmzeit in den Einstellungen wieder ein, um das Sterben zu stoppen.",
        "en": "Your garden is currently losing 1 life every hour. Turn Screen Time back on in the settings to stop the dying.",
        "es": "Tu jardín está perdiendo actualmente 1 vida cada hora. Vuelve a activar el Tiempo de uso en los ajustes para detener la muerte.",
        "fr": "Votre jardin perd actuellement 1 vie toutes les heures. Réactivez le Temps d'écran dans les réglages pour arrêter la mort.",
        "hi": "आपका बगीचा वर्तमान में हर घंटे 1 जीवन खो रहा है। मरने से रोकने के लिए सेटिंग्स में स्क्रीन टाइम वापस चालू करें।",
        "it": "Il tuo giardino sta attualmente perdendo 1 vita ogni ora. Riattiva il Tempo di utilizzo nelle impostazioni per fermare la morte.",
        "ja": "現在、あなたの庭は1時間ごとに1つのライフを失っています。死を止めるには、設定でスクリーンタイムを再びオンにしてください。",
        "ko": "현재 정원은 매시간 1개의 생명을 잃고 있습니다. 죽음을 막으려면 설정에서 스크린 타임을 다시 켜세요.",
        "nl": "Je tuin verliest momenteel 1 leven per uur. Schakel Schermtijd weer in de instellingen in om het sterven te stoppen.",
        "pl": "Twój ogród traci obecnie 1 życie co godzinę. Włącz ponownie Czas przed ekranem w ustawieniach, aby zatrzymać umieranie.",
        "pt": "Seu jardim está perdendo 1 vida a cada hora. Ative o Tempo de Uso novamente nos ajustes para parar a morte.",
        "ru": "В настоящее время ваш сад теряет 1 жизнь каждый час. Снова включите Экранное время в настройках, чтобы остановить смерть.",
        "tr": "Bahçeniz şu anda her saat 1 can kaybediyor. Ölümü durdurmak için ayarlardan Ekran Süresini tekrar açın."
    },
    "cheat_punishment.button.settings": {
        "de": "Zu den Einstellungen",
        "en": "To Settings",
        "es": "A los Ajustes",
        "fr": "Vers les Réglages",
        "hi": "सेटिंग्स पर जाएं",
        "it": "Vai alle Impostazioni",
        "ja": "設定へ",
        "ko": "설정으로 이동",
        "nl": "Naar instellingen",
        "pl": "Do ustawień",
        "pt": "Para os Ajustes",
        "ru": "В настройки",
        "tr": "Ayarlara Git"
    }
}

for key, translations in keys.items():
    if key not in data['strings']:
        data['strings'][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang, text in translations.items():
        data['strings'][key]['localizations'][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Updated Localizable.xcstrings successfully!")
