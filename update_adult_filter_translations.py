import json

file_path = "Garten_Simulation/Localizable.xcstrings"

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

new_strings = {
    "screenTime.adultFilter.title": {
        "en": "Strict Protection",
        "de": "Schutzmodus Aktiv",
        "fr": "Protection stricte active",
        "es": "Protección estricta activa",
        "it": "Protezione severa attiva",
        "pt-PT": "Proteção Estrita Ativa"
    },
    "screenTime.adultFilter.desc1": {
        "en": "Blocks adult content in Safari. To prevent workarounds, this mode also completely locks:",
        "de": "Blockiert nicht jugendfreie Inhalte in Safari. Um Umgehungen zu verhindern, sperrt dieser Modus außerdem komplett:",
        "fr": "Bloque le contenu pour adultes dans Safari. Pour éviter les contournements, ce mode verrouille également complètement :",
        "es": "Bloquea el contenido para adultos en Safari. Para evitar soluciones alternativas, este modo también bloquea por completo:",
        "it": "Blocca i contenuti per adulti in Safari. Per evitare scappatoie, questa modalità blocca completamente anche:",
        "pt-PT": "Bloqueia o conteúdo para adultos no Safari. Para evitar contornar, este modo também bloqueia completamente:"
    },
    "screenTime.adultFilter.bullet1": {
        "en": "App Store (No new browsers/VPNs)",
        "de": "App Store (Keine neuen Browser/VPNs)",
        "fr": "App Store (Pas de nouveaux navigateurs/VPN)",
        "es": "App Store (Sin nuevos navegadores/VPN)",
        "it": "App Store (Nessun nuovo browser/VPN)",
        "pt-PT": "App Store (Sem novos navegadores/VPNs)"
    },
    "screenTime.adultFilter.bullet2": {
        "en": "App Deletion",
        "de": "Löschen von Apps",
        "fr": "Suppression d'applications",
        "es": "Eliminación de aplicaciones",
        "it": "Eliminazione app",
        "pt-PT": "Exclusão de aplicativos"
    },
    "screenTime.adultFilter.button.inactive": {
        "en": "Activate Protection",
        "de": "Schutzmodus aktivieren",
        "fr": "Activer la protection",
        "es": "Activar protección",
        "it": "Attiva protezione",
        "pt-PT": "Ativar Proteção"
    },
    "screenTime.adultFilter.button.active": {
        "en": "Deactivate Protection",
        "de": "Schutzmodus deaktivieren",
        "fr": "Désactiver la protection",
        "es": "Desactivar protección",
        "it": "Disattiva protezione",
        "pt-PT": "Desativar Proteção"
    }
}

languages = set()
for v in data["strings"].values():
    if "localizations" in v:
        for lang in v["localizations"].keys():
            languages.add(lang)

for key, trans in new_strings.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang in languages:
        text = trans.get(lang, trans["en"]) # Fallback
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Translations updated successfully.")
