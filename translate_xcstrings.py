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
            "fr": "Suivi automatique en arrière-plan."
        },
        "paywall.feature.health.bullet2.new": {
            "en": "Faster tracking of your activities.",
            "de": "Schnelleres Tracking deiner Aktivitäten.",
            "es": "Seguimiento más rápido de tus actividades.",
            "fr": "Suivi plus rapide de vos activités."
        },
        "paywall.feature.health.bullet3.new": {
            "en": "Close Apple Health rings effortlessly.",
            "de": "Schließe Apple Health Ringe mühelos.",
            "es": "Cierra los anillos de Apple Health sin esfuerzo.",
            "fr": "Fermez les anneaux Apple Health sans effort."
        },
        "paywall.feature.calendar.bullet1.new": {
            "en": "Fast event creation from the app.",
            "de": "Schnelle Termin-Erstellung aus der App.",
            "es": "Creación rápida de eventos desde la aplicación.",
            "fr": "Création rapide d'événements depuis l'application."
        },
        "paywall.feature.calendar.bullet2.new": {
            "en": "Real-time synchronization with the calendar.",
            "de": "Echtzeit-Synchronisation mit dem Kalender.",
            "es": "Sincronización en tiempo real con el calendario.",
            "fr": "Synchronisation en temps réel avec le calendrier."
        },
        "paywall.feature.calendar.bullet3.new": {
            "en": "Automatic notifications for events.",
            "de": "Automatische Benachrichtigungen für Events.",
            "es": "Notificaciones automáticas para eventos.",
            "fr": "Notifications automatiques pour les événements."
        }
    }
    
    # Check what languages exist in the source language string
    # E.g. we might have de, en, es, fr, maybe others? Let's check what languages are used in general
    existing_langs = set()
    for key, val in strings.items():
        if 'localizations' in val:
            for lang in val['localizations']:
                existing_langs.add(lang)
    
    print(f"Existing languages found: {existing_langs}")
    
    # We will populate these keys
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
        
    print("Done updating translations.")

if __name__ == '__main__':
    main()
