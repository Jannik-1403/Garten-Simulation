import json

file_path = "Garten_Simulation/Localizable.xcstrings"

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

translations = {
    "screenTime.safariFilter.title": {
        "en": "Safari Adult Filter",
        "de": "Safari Erwachsenen-Filter",
        "es": "Filtro de adultos (Safari)",
        "fr": "Filtre adulte Safari",
        "it": "Filtro adulti Safari",
        "pt": "Filtro Adulto Safari",
        "pt-BR": "Filtro Adulto Safari",
        "nl": "Safari filter voor volwassenen",
        "pl": "Filtr dla dorosłych Safari",
        "ru": "Фильтр для взрослых Safari",
        "tr": "Safari Yetişkin Filtresi",
        "hi": "सफ़ारी वयस्क फ़िल्टर",
        "ja": "Safari アダルトフィルター",
        "ko": "Safari 성인 필터",
        "zh-Hans": "Safari 成人过滤器",
        "zh-Hant": "Safari 成人過濾器"
    },
    "screenTime.safariFilter.desc": {
        "en": "Blocks adult content in Safari. (Note: Does not affect other browsers like Chrome or Edge).",
        "de": "Blockiert nicht jugendfreie Inhalte in Safari. (Hinweis: Gilt nicht für andere Browser wie Chrome oder Edge).",
        "es": "Bloquea contenido para adultos en Safari. (Nota: No afecta a otros navegadores como Chrome o Edge).",
        "fr": "Bloque le contenu pour adultes dans Safari. (Remarque : N'affecte pas les autres navigateurs comme Chrome ou Edge).",
        "it": "Blocca i contenuti per adulti in Safari. (Nota: Non ha effetto su altri browser come Chrome o Edge).",
        "pt": "Bloqueia conteúdo para adultos no Safari. (Nota: Não afeta outros navegadores como Chrome ou Edge).",
        "pt-BR": "Bloqueia conteúdo adulto no Safari. (Nota: Não afeta outros navegadores como Chrome ou Edge).",
        "nl": "Blokkeert inhoud voor volwassenen in Safari. (Opmerking: Heeft geen invloed op andere browsers zoals Chrome of Edge).",
        "pl": "Blokuje treści dla dorosłych w Safari. (Uwaga: Nie dotyczy innych przeglądarek, takich jak Chrome lub Edge).",
        "ru": "Блокирует контент для взрослых в Safari. (Примечание: не влияет на другие браузеры, такие как Chrome или Edge).",
        "tr": "Safari'de yetişkinlere yönelik içeriği engeller. (Not: Chrome veya Edge gibi diğer tarayıcıları etkilemez).",
        "hi": "Safari में वयस्क सामग्री को ब्लॉक करता है। (नोट: Chrome या Edge जैसे अन्य ब्राउज़रों को प्रभावित नहीं करता है)।",
        "ja": "Safariでアダルトコンテンツをブロックします。（注：ChromeやEdgeなどの他のブラウザには影響しません）。",
        "ko": "Safari에서 성인 콘텐츠를 차단합니다. (참고: Chrome이나 Edge와 같은 다른 브라우저에는 영향을 미치지 않습니다).",
        "zh-Hans": "在 Safari 中阻止成人内容。（注意：不影响 Chrome 或 Edge 等其他浏览器）。",
        "zh-Hant": "在 Safari 中封鎖成人內容。（注意：不影響 Chrome 或 Edge 等其他瀏覽器）。"
    },
    "screenTime.safariFilter.button.inactive": {
        "en": "Activate Safari Filter",
        "de": "Safari Filter aktivieren",
        "es": "Activar filtro Safari",
        "fr": "Activer le filtre Safari",
        "it": "Attiva filtro Safari",
        "pt": "Ativar Filtro Safari",
        "pt-BR": "Ativar Filtro Safari",
        "nl": "Safari filter activeren",
        "pl": "Aktywuj filtr Safari",
        "ru": "Активировать фильтр Safari",
        "tr": "Safari Filtresini Etkinleştir",
        "hi": "Safari फ़िल्टर सक्रिय करें",
        "ja": "Safariフィルターを有効にする",
        "ko": "Safari 필터 활성화",
        "zh-Hans": "激活 Safari 过滤器",
        "zh-Hant": "啟用 Safari 過濾器"
    },
    "screenTime.safariFilter.button.active": {
        "en": "Filter Active (Deactivate)",
        "de": "Filter Aktiv (Deaktivieren)",
        "es": "Filtro activo (Desactivar)",
        "fr": "Filtre actif (Désactiver)",
        "it": "Filtro attivo (Disattiva)",
        "pt": "Filtro Ativo (Desativar)",
        "pt-BR": "Filtro Ativo (Desativar)",
        "nl": "Filter Actief (Deactiveren)",
        "pl": "Filtr aktywny (Dezaktywuj)",
        "ru": "Фильтр активен (Деактивировать)",
        "tr": "Filtre Aktif (Devre Dışı Bırak)",
        "hi": "फ़िल्टर सक्रिय (निष्क्रिय करें)",
        "ja": "フィルター有効（無効にする）",
        "ko": "필터 활성 (비활성화)",
        "zh-Hans": "过滤器有效（停用）",
        "zh-Hant": "過濾器有效（停用）"
    }
}

for key, trans in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    for lang in trans.keys():
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": trans[lang]
            }
        }

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Safari filter translations updated.")
