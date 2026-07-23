import json

file_path = "Garten_Simulation/Localizable.xcstrings"

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

new_strings = {
    "screenTime.strictMode.title": {
        "en": "Strict Protection",
        "de": "Schutzmodus",
        "fr": "Protection stricte",
        "es": "Protección estricta",
        "it": "Protezione severa",
        "pt-PT": "Proteção Estrita"
    },
    "screenTime.strictMode.desc": {
        "en": "Locks the App Store (to prevent VPN downloads), app deletion, and account changes. Remains active until emergency unlock is used.",
        "de": "Sperrt den App Store (um VPN-Downloads zu verhindern), das Löschen von Apps und Account-Änderungen. Gilt dauerhaft, bis der Notfall-Unlock genutzt wird.",
        "fr": "Verrouille l'App Store (pour empêcher le téléchargement de VPN), la suppression d'applications et les modifications de compte. Reste actif jusqu'au déverrouillage d'urgence.",
        "es": "Bloquea la App Store (para evitar descargas de VPN), la eliminación de aplicaciones y los cambios de cuenta. Permanece activo hasta que se use el desbloqueo de emergencia.",
        "it": "Blocca l'App Store (per impedire i download di VPN), l'eliminazione di app e le modifiche all'account. Rimane attivo fino allo sblocco di emergenza.",
        "pt-PT": "Bloqueia a App Store (para evitar downloads de VPN), a exclusão de aplicativos e as alterações na conta. Permanece ativo até o uso do desbloqueio de emergência."
    },
    "screenTime.strictMode.active": {
        "en": "Enable Strict Protection",
        "de": "Schutzmodus aktivieren",
        "fr": "Activer la protection stricte",
        "es": "Activar protección estricta",
        "it": "Attiva protezione severa",
        "pt-PT": "Ativar Proteção Estrita"
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
        text = trans.get(lang, trans["en"]) # Fallback to en
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Translations added.")
