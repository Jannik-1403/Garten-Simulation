import json

path = 'Garten_Simulation/Localizable.xcstrings'
with open(path, 'r') as f:
    data = json.load(f)

key = "settings.manage_subscription"
if key in data["strings"]:
    translations = {
        "de": "Abo verwalten",
        "en": "Manage Subscription",
        "es": "Administrar suscripción",
        "fr": "Gérer l'abonnement",
        "it": "Gestisci abbonamento",
        "ja": "サブスクリプションの管理",
        "ko": "구독 관리",
        "pl": "Zarządzaj subskrypcją",
        "pt": "Gerenciar assinatura",
        "tr": "Aboneliği yönet",
        "zh-Hans": "管理订阅",
        "zh-Hant": "管理訂閱"
    }
    
    for lang, val in translations.items():
        if lang not in data["strings"][key]["localizations"]:
            data["strings"][key]["localizations"][lang] = {"stringUnit": {"state": "translated", "value": ""}}
        data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = val
        data["strings"][key]["localizations"][lang]["stringUnit"]["state"] = "translated"

with open(path, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
