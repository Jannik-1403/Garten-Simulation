import json

path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"
with open(path, "r") as f:
    data = json.load(f)

# Hardcoded translations for the missing keys
translations = {
    "fitness.running.detail.good": {
        "en": "Step goal reached ✓ Well done!",
        "es": "Meta de pasos alcanzada ✓ ¡Bien hecho!",
        "fr": "Objectif de pas atteint ✓ Bien joué !",
        "pt-BR": "Meta de passos alcançada ✓ Muito bem!"
    },
    "fitness.running.detail.missing.large": {
        "en": "You're still missing %lld steps. You need to be much more active today, plan a longer walk.",
        "es": "Todavía te faltan %lld pasos. Debes estar mucho más activo hoy, planea una caminata más larga.",
        "fr": "Il te manque encore %lld pas. Tu dois être beaucoup plus actif aujourd'hui, prévois une plus longue marche.",
        "pt-BR": "Faltam %lld passos. Você precisa ser muito mais ativo hoje, planeje uma caminhada mais longa."
    },
    "fitness.running.detail.missing.medium": {
        "en": "You're still missing %lld steps. Take a short walk.",
        "es": "Todavía te faltan %lld pasos. Da un breve paseo.",
        "fr": "Il te manque encore %lld pas. Fais une courte promenade.",
        "pt-BR": "Ainda faltam %lld passos. Dê uma curta caminhada."
    },
    "fitness.running.detail.missing.small": {
        "en": "You're only missing %lld steps. Just move a little bit more!",
        "es": "Solo te faltan %lld pasos. ¡Solo muévete un poco más!",
        "fr": "Il te manque seulement %lld pas. Bouge juste un peu plus !",
        "pt-BR": "Faltam apenas %lld passos. Mova-se só um pouquinho mais!"
    },
    "fitness.running.steps.short": {
        "en": "Steps",
        "es": "Pasos",
        "fr": "Pas",
        "pt-BR": "Passos"
    },
    "fitness.score.detail.title": {
        "en": "Daily Analysis",
        "es": "Análisis Diario",
        "fr": "Analyse Quotidienne",
        "pt-BR": "Análise Diária"
    },
    "fitness.sleep.detail.fallback": {
        "en": "Try to go to bed earlier today.",
        "es": "Intenta ir a dormir más temprano hoy.",
        "fr": "Essaie de te coucher plus tôt aujourd'hui.",
        "pt-BR": "Tente dormir mais cedo hoje."
    },
    "fitness.sleep.detail.timehint": {
        "en": "Tomorrow you should go to bed around %@ and wake up around %@.",
        "es": "Mañana deberías acostarte a las %@ y despertarte a las %@.",
        "fr": "Demain, tu devrais te coucher vers %@ et te réveiller vers %@.",
        "pt-BR": "Amanhã você deveria ir dormir por volta das %@ e acordar às %@."
    },
    "fitness.water.detail.progress": {
        "en": "Drank %lld of %lld ml.",
        "es": "Bebiste %lld de %lld ml.",
        "fr": "Tu as bu %lld sur %lld ml.",
        "pt-BR": "Bebeu %lld de %lld ml."
    },
    "ml": {
        "en": "ml",
        "es": "ml",
        "fr": "ml",
        "pt-BR": "ml"
    }
}

for key, trans in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    
    # mark state as translated
    data["strings"][key]["extractionState"] = "manual"
    
    for lang, text in trans.items():
        if "localizations" not in data["strings"][key]:
            data["strings"][key]["localizations"] = {}
        
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open(path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Updated translations.")
