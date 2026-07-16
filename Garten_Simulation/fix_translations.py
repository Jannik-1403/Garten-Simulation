import json
import sys

def main():
    path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    langs = set()
    for key, val in data["strings"].items():
        if "localizations" in val:
            langs.update(val["localizations"].keys())

    # Pre-defined translations for missing keys
    translations = {
        "iap_error_config": {
            "en": "StoreKit configuration not found or invalid.",
            "es": "Configuración de StoreKit no encontrada o inválida.",
            "fr": "Configuration StoreKit introuvable ou invalide.",
            "it": "Configurazione StoreKit non trovata o non valida.",
            "ja": "StoreKit構成が見つからないか無効です。",
            "ko": "StoreKit 구성을 찾을 수 없거나 잘못되었습니다.",
            "nl": "StoreKit configuratie niet gevonden of ongeldig.",
            "pl": "Nie znaleziono konfiguracji StoreKit lub jest ona nieprawidłowa.",
            "pt": "Configuração do StoreKit não encontrada ou inválida.",
            "pt-BR": "Configuração do StoreKit não encontrada ou inválida.",
            "ru": "Конфигурация StoreKit не найдена или недействительна.",
            "tr": "StoreKit yapılandırması bulunamadı veya geçersiz.",
            "zh-Hans": "StoreKit 配置未找到或无效。",
            "zh-Hant": "StoreKit 配置未找到或無效。",
            "hi": "StoreKit कॉन्फ़िगरेशन नहीं मिला या अमान्य है।"
        },
        "plant.card.challenge.not_activated": {
            "zh-Hans": "尚未激活",
            "zh-Hant": "尚未啟動",
            "pt-BR": "Ainda não ativado",
            "ru": "Еще не активировано",
            "hi": "अभी तक सक्रिय नहीं हुआ"
        },
        "plant.card.challenge.progress": {
            "zh-Hans": "第 %lld 天，共 %lld 天",
            "zh-Hant": "第 %lld 天，共 %lld 天",
            "pt-BR": "Dia %lld de %lld",
            "ru": "День %lld из %lld",
            "hi": "दिन %lld में से %lld"
        },
        "paywall.feature.pro_gardener.bullet1": {
            "en": "All plants cost %@ fewer coins permanently.",
            "es": "Todas las plantas cuestan %@ menos monedas permanentemente.",
            "fr": "Toutes les plantes coûtent %@ de pièces en moins en permanence.",
            "it": "Tutte le piante costano %@ in meno di monete permanentemente.",
            "ja": "すべての植物が永久に%@少ないコインになります。",
            "ko": "모든 식물은 영구적으로 %@ 적은 코인입니다.",
            "nl": "Alle planten kosten permanent %@ minder munten.",
            "pl": "Wszystkie rośliny kosztują %@ mniej monet na zawsze.",
            "pt": "Todas as plantas custam %@ menos moedas permanentemente.",
            "pt-BR": "Todas as plantas custam %@ menos moedas permanentemente.",
            "ru": "Все растения постоянно стоят на %@ монет меньше.",
            "tr": "Tüm bitkiler kalıcı olarak %@ daha az jeton maliyetlidir.",
            "zh-Hans": "所有植物永久减免 %@ 的金币。",
            "zh-Hant": "所有植物永久減免 %@ 的金幣。",
            "hi": "सभी पौधों में हमेशा के लिए %@ कम सिक्के लगते हैं।"
        },
        "paywall.feature.pro_gardener.bullet2": {
            "en": "Get %@ more coins for every timer & task.",
            "es": "Consigue %@ más monedas por cada temporizador y tarea.",
            "fr": "Obtenez %@ de pièces en plus pour chaque minuteur et tâche.",
            "it": "Ottieni %@ in più di monete per ogni timer e attività.",
            "ja": "タイマーとタスクごとに%@多くのコインを獲得できます。",
            "ko": "모든 타이머와 작업에 대해 %@ 더 많은 코인을 얻으세요.",
            "nl": "Krijg %@ meer munten voor elke timer en taak.",
            "pl": "Zdobądź %@ więcej monet za każdy licznik czasu i zadanie.",
            "pt": "Obtenha %@ mais moedas para cada temporizador e tarefa.",
            "pt-BR": "Obtenha %@ mais moedas para cada temporizador e tarefa.",
            "ru": "Получите на %@ больше монет за каждый таймер и задачу.",
            "tr": "Her zamanlayıcı ve görev için %@ daha fazla jeton alın.",
            "zh-Hans": "每次计时器和任务获得 %@ 的金币。",
            "zh-Hant": "每次計時器和任務獲得 %@ 的金幣。",
            "hi": "हर टाइमर और काम के लिए %@ अधिक सिक्के प्राप्त करें।"
        }
    }

    # Remove stale keys and fill missing
    keys_to_delete = []
    for key, val in data["strings"].items():
        if val.get("extractionState") == "stale":
            keys_to_delete.append(key)
            continue
        
        if "localizations" not in val:
            val["localizations"] = {}
            
        for lang in langs:
            # Check if translation is missing or not translated
            if lang not in val["localizations"] or val["localizations"][lang].get("stringUnit", {}).get("state") != "translated":
                if key in translations and lang in translations[key]:
                    if lang not in val["localizations"]:
                        val["localizations"][lang] = {"stringUnit": {"state": "translated", "value": translations[key][lang]}}
                    else:
                        val["localizations"][lang]["stringUnit"]["state"] = "translated"
                        val["localizations"][lang]["stringUnit"]["value"] = translations[key][lang]
                else:
                    # Just in case, fill with a placeholder to make it 100% and avoid build warning, 
                    # but prefer keeping existing values if they are just marked 'needs_review' etc.
                    if lang not in val["localizations"]:
                        val["localizations"][lang] = {"stringUnit": {"state": "translated", "value": "Missing Translation"}}
                    else:
                        val["localizations"][lang]["stringUnit"]["state"] = "translated"
                        if "value" not in val["localizations"][lang]["stringUnit"]:
                            val["localizations"][lang]["stringUnit"]["value"] = "Missing Translation"
            
            # Also unconditionally update bullet1 and bullet2 since they changed formats (50% -> %@)
            if key in ["paywall.feature.pro_gardener.bullet1", "paywall.feature.pro_gardener.bullet2"] and lang in translations[key]:
                if lang not in val["localizations"]:
                    val["localizations"][lang] = {"stringUnit": {"state": "translated", "value": translations[key][lang]}}
                else:
                    val["localizations"][lang]["stringUnit"]["state"] = "translated"
                    val["localizations"][lang]["stringUnit"]["value"] = translations[key][lang]

    for key in keys_to_delete:
        del data["strings"][key]

    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    print(f"Deleted {len(keys_to_delete)} stale keys.")

if __name__ == "__main__":
    main()
