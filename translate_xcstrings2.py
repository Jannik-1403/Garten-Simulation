import json
import sys

def main():
    file_path = 'Garten_Simulation/Localizable.xcstrings'
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    strings = data.get('strings', {})
    
    new_keys = {
        "paywall.feature.health.bullet1.new": {
            "en": "Automatic background tracking.",
            "de": "Automatisches Tracking im Hintergrund.",
            "es": "Seguimiento automático en segundo plano.",
            "fr": "Suivi automatique en arrière-plan.",
            "it": "Tracciamento automatico in background.",
            "pt": "Rastreamento automático em segundo plano.",
            "pt-BR": "Rastreamento automático em segundo plano.",
            "nl": "Automatische tracking op de achtergrond.",
            "pl": "Automatyczne śledzenie w tle.",
            "ru": "Автоматическое отслеживание в фоновом режиме.",
            "tr": "Arka planda otomatik izleme.",
            "ja": "バックグラウンドでの自動トラッキング。",
            "ko": "백그라운드 자동 추적.",
            "zh-Hans": "后台自动追踪。",
            "zh-Hant": "後台自動追蹤。",
            "hi": "पृष्ठभूमि में स्वचालित ट्रैकिंग।"
        },
        "paywall.feature.health.bullet2.new": {
            "en": "Faster tracking of your activities.",
            "de": "Schnelleres Tracking deiner Aktivitäten.",
            "es": "Seguimiento más rápido de tus actividades.",
            "fr": "Suivi plus rapide de vos activités.",
            "it": "Tracciamento più veloce delle tue attività.",
            "pt": "Rastreamento mais rápido de suas atividades.",
            "pt-BR": "Rastreamento mais rápido de suas atividades.",
            "nl": "Snellere tracking van je activiteiten.",
            "pl": "Szybsze śledzenie twoich aktywności.",
            "ru": "Более быстрое отслеживание ваших действий.",
            "tr": "Etkinliklerinizin daha hızlı izlenmesi.",
            "ja": "アクティビティのより迅速なトラッキング。",
            "ko": "활동의 더 빠른 추적.",
            "zh-Hans": "更快的活动追踪。",
            "zh-Hant": "更快的活動追蹤。",
            "hi": "आपकी गतिविधियों की तेज ट्रैकिंग।"
        },
        "paywall.feature.health.bullet3.new": {
            "en": "Close Apple Health rings effortlessly.",
            "de": "Schließe Apple Health Ringe mühelos.",
            "es": "Cierra los anillos de Apple Health sin esfuerzo.",
            "fr": "Fermez les anneaux Apple Health sans effort.",
            "it": "Chiudi gli anelli di Apple Health senza sforzo.",
            "pt": "Feche os anéis do Apple Health sem esforço.",
            "pt-BR": "Feche os anéis do Apple Health sem esforço.",
            "nl": "Sluit Apple Health-ringen moeiteloos.",
            "pl": "Zamykaj pierścienie Apple Health bez wysiłku.",
            "ru": "Закрывайте кольца Apple Health без усилий.",
            "tr": "Apple Health halkalarını zahmetsizce kapatın.",
            "ja": "Apple Healthリングを簡単に閉じる。",
            "ko": "Apple Health 링을 쉽게 닫으세요.",
            "zh-Hans": "轻松闭合Apple Health圆环。",
            "zh-Hant": "輕鬆閉合Apple Health圓環。",
            "hi": "Apple Health रिंग आसानी से बंद करें।"
        },
        "paywall.feature.calendar.bullet1.new": {
            "en": "Fast event creation from the app.",
            "de": "Schnelle Termin-Erstellung aus der App.",
            "es": "Creación rápida de eventos desde la aplicación.",
            "fr": "Création rapide d'événements depuis l'application.",
            "it": "Creazione rapida di eventi dall'app.",
            "pt": "Criação rápida de eventos a partir do aplicativo.",
            "pt-BR": "Criação rápida de eventos a partir do aplicativo.",
            "nl": "Snelle aanmaak van evenementen vanuit de app.",
            "pl": "Szybkie tworzenie wydarzeń z poziomu aplikacji.",
            "ru": "Быстрое создание событий из приложения.",
            "tr": "Uygulamadan hızlı etkinlik oluşturma.",
            "ja": "アプリからの迅速なイベント作成。",
            "ko": "앱에서 빠른 이벤트 생성.",
            "zh-Hans": "从应用快速创建日程。",
            "zh-Hant": "從應用快速創建日程。",
            "hi": "ऐप से तेजी से इवेंट निर्माण।"
        },
        "paywall.feature.calendar.bullet2.new": {
            "en": "Real-time synchronization with the calendar.",
            "de": "Echtzeit-Synchronisation mit dem Kalender.",
            "es": "Sincronización en tiempo real con el calendario.",
            "fr": "Synchronisation en temps réel avec le calendrier.",
            "it": "Sincronizzazione in tempo reale con il calendario.",
            "pt": "Sincronização em tempo real com o calendário.",
            "pt-BR": "Sincronização em tempo real com o calendário.",
            "nl": "Realtime synchronisatie met de kalender.",
            "pl": "Synchronizacja w czasie rzeczywistym z kalendarzem.",
            "ru": "Синхронизация с календарем в реальном времени.",
            "tr": "Takvimle gerçek zamanlı senkronizasyon.",
            "ja": "カレンダーとのリアルタイム同期。",
            "ko": "캘린더와의 실시간 동기화.",
            "zh-Hans": "与日历实时同步。",
            "zh-Hant": "與日曆實時同步。",
            "hi": "कैलेंडर के साथ रीयल-टाइम सिंक्रोनाइज़ेशन।"
        },
        "paywall.feature.calendar.bullet3.new": {
            "en": "Automatic notifications for events.",
            "de": "Automatische Benachrichtigungen für Events.",
            "es": "Notificaciones automáticas para eventos.",
            "fr": "Notifications automatiques pour les événements.",
            "it": "Notifiche automatiche per gli eventi.",
            "pt": "Notificações automáticas para eventos.",
            "pt-BR": "Notificações automáticas para eventos.",
            "nl": "Automatische meldingen voor evenementen.",
            "pl": "Automatyczne powiadomienia o wydarzeniach.",
            "ru": "Автоматические уведомления о событиях.",
            "tr": "Etkinlikler için otomatik bildirimler.",
            "ja": "イベントの自動通知。",
            "ko": "이벤트에 대한 자동 알림.",
            "zh-Hans": "日程自动通知。",
            "zh-Hant": "日程自動通知。",
            "hi": "इवेंट के लिए स्वचालित सूचनाएं।"
        }
    }
    
    existing_langs = {'hi', 'zh-Hans', 'ja', 'ko', 'pl', 'pt', 'ru', 'tr', 'de', 'es', 'en', 'it', 'pt-BR', 'zh-Hant', 'nl', 'fr'}
    
    for key, translations in new_keys.items():
        if key not in strings:
            strings[key] = {
                "extractionState": "manual",
                "localizations": {}
            }
        elif 'localizations' not in strings[key]:
            strings[key]['localizations'] = {}
            
        for lang in existing_langs:
            if lang in translations:
                text = translations[lang]
            else:
                text = translations['en'] # fallback
            
            strings[key]['localizations'][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": text
                }
            }
            
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        
    print("Done updating translations properly.")

if __name__ == '__main__':
    main()
