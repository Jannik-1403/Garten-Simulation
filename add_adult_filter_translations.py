import json

file_path = "Garten_Simulation/Localizable.xcstrings"

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

new_strings = {
    "screenTime.adultFilter.title": {
        "en": "Waterproof Adult Filter",
        "de": "Wasserdichter Erwachsenen-Filter",
        "fr": "Filtre adulte étanche",
        "es": "Filtro para adultos a prueba de agua",
        "it": "Filtro per adulti impermeabile",
        "pt-PT": "Filtro para adultos à prova de água"
    },
    "screenTime.adultFilter.desc1": {
        "en": "This filter blocks adult content (porn, illegal streaming) at the system level in Safari.",
        "de": "Dieser Filter blockiert nicht jugendfreie Inhalte (Pornos, illegales Streaming) auf Systemebene in Safari.",
        "fr": "Ce filtre bloque le contenu pour adultes au niveau du système dans Safari.",
        "es": "Este filtro bloquea el contenido para adultos a nivel del sistema en Safari.",
        "it": "Questo filtro blocca i contenuti per adulti a livello di sistema in Safari.",
        "pt-PT": "Este filtro bloqueia o conteúdo para adultos ao nível do sistema no Safari."
    },
    "screenTime.adultFilter.desc2": {
        "en": "To prevent circumvention, Strict Protection is activated simultaneously. This locks the App Store (preventing VPN & browser downloads) and blocks app deletion.",
        "de": "Damit der Filter nicht ausgetrickst werden kann, wird gleichzeitig der Schutzmodus aktiviert. Dieser sperrt den App Store (verhindert VPN- & Browser-Downloads) und blockiert das Löschen dieser App.",
        "fr": "Pour éviter tout contournement, la protection stricte est activée simultanément. Cela verrouille l'App Store (empêchant les téléchargements de VPN) et bloque la suppression.",
        "es": "Para evitar la elusión, se activa la Protección estricta simultáneamente. Esto bloquea la App Store y bloquea la eliminación.",
        "it": "Per evitare l'aggiramento, la Protezione severa viene attivata simultaneamente. Questo blocca l'App Store e l'eliminazione dell'app.",
        "pt-PT": "Para evitar contornar, a Proteção Estrita é ativada simultaneamente. Isso bloqueia a App Store e bloqueia a exclusão do aplicativo."
    },
    "screenTime.adultFilter.button.inactive": {
        "en": "Enable Adult Filter",
        "de": "Erwachsenen Filter aktivieren",
        "fr": "Activer le filtre adulte",
        "es": "Activar filtro para adultos",
        "it": "Attiva filtro per adulti",
        "pt-PT": "Ativar Filtro de Adultos"
    },
    "screenTime.adultFilter.button.active": {
        "en": "Disable Filter & Protection",
        "de": "Filter & Schutzmodus deaktivieren",
        "fr": "Désactiver le filtre et la protection",
        "es": "Desactivar filtro y protección",
        "it": "Disattiva filtro e protezione",
        "pt-PT": "Desativar Filtro e Proteção"
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

# Remove the old strictMode strings to clean up if we want, but let's just leave them in case they are used somewhere else or history.

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Translations added successfully.")
