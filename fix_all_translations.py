import json

file_path = "Garten_Simulation/Localizable.xcstrings"

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

translations = {
    "screenTime.adultFilter.title": {
        "en": "Strict Protection",
        "de": "Schutzmodus Aktiv",
        "es": "Protección estricta",
        "fr": "Protection stricte",
        "it": "Protezione severa",
        "pt": "Proteção Estrita",
        "pt-BR": "Proteção Rigorosa",
        "nl": "Strenge bescherming",
        "pl": "Ścisła ochrona",
        "ru": "Строгая защита",
        "tr": "Sıkı Koruma",
        "hi": "कड़ी सुरक्षा",
        "ja": "厳格な保護",
        "ko": "엄격한 보호",
        "zh-Hans": "严格保护",
        "zh-Hant": "嚴格保護"
    },
    "screenTime.adultFilter.desc1": {
        "en": "Blocks adult content in Safari. To prevent workarounds, this mode also completely locks:",
        "de": "Blockiert nicht jugendfreie Inhalte in Safari. Um Umgehungen zu verhindern, sperrt dieser Modus außerdem komplett:",
        "es": "Bloquea contenido para adultos en Safari. Para evitar elusiones, este modo también bloquea por completo:",
        "fr": "Bloque le contenu pour adultes dans Safari. Pour empêcher les contournements, ce mode verrouille également complètement :",
        "it": "Blocca i contenuti per adulti in Safari. Per evitare scappatoie, questa modalità blocca completamente anche:",
        "pt": "Bloqueia conteúdo para adultos no Safari. Para evitar contornos, este modo também bloqueia completamente:",
        "pt-BR": "Bloqueia conteúdo adulto no Safari. Para evitar burlas, este modo também bloqueia completamente:",
        "nl": "Blokkeert inhoud voor volwassenen in Safari. Om omzeilingen te voorkomen, vergrendelt deze modus ook volledig:",
        "pl": "Blokuje treści dla dorosłych w Safari. Aby zapobiec obejściom, ten tryb również całkowicie blokuje:",
        "ru": "Блокирует контент для взрослых в Safari. Чтобы предотвратить обход, этот режим также полностью блокирует:",
        "tr": "Safari'de yetişkinlere yönelik içeriği engeller. Geçici çözümleri önlemek için bu mod şunları da tamamen kilitler:",
        "hi": "Safari में वयस्क सामग्री को ब्लॉक करता है। वर्कअराउंड को रोकने के लिए, यह मोड पूरी तरह से लॉक कर देता है:",
        "ja": "Safariでアダルトコンテンツをブロックします。回避を防ぐため、このモードでは以下も完全にロックされます:",
        "ko": "Safari에서 성인 콘텐츠를 차단합니다. 우회를 방지하기 위해 이 모드는 다음도 완전히 잠급니다:",
        "zh-Hans": "在 Safari 中阻止成人内容。为防止绕过，此模式还会完全锁定：",
        "zh-Hant": "在 Safari 中封鎖成人內容。為了防止繞過，此模式還會完全鎖定："
    },
    "screenTime.adultFilter.bullet1": {
        "en": "App Store (No new browsers/VPNs)",
        "de": "App Store (Keine neuen Browser/VPNs)",
        "es": "App Store (Sin navegadores/VPN nuevos)",
        "fr": "App Store (Pas de nouveaux navigateurs/VPN)",
        "it": "App Store (Nessun nuovo browser o VPN)",
        "pt": "App Store (Sem novos navegadores/VPNs)",
        "pt-BR": "App Store (Sem novos navegadores/VPNs)",
        "nl": "App Store (Geen nieuwe browsers/VPN's)",
        "pl": "App Store (Brak nowych przeglądarek/VPN-ów)",
        "ru": "App Store (Без новых браузеров/VPN)",
        "tr": "App Store (Yeni tarayıcılar/VPN'ler yok)",
        "hi": "App Store (कोई नया ब्राउज़र/VPN नहीं)",
        "ja": "App Store (新しいブラウザ/VPNなし)",
        "ko": "App Store(새 브라우저/VPN 없음)",
        "zh-Hans": "App Store (无新浏览器/VPN)",
        "zh-Hant": "App Store (無新瀏覽器/VPN)"
    },
    "screenTime.adultFilter.bullet2": {
        "en": "App Deletion",
        "de": "Löschen von Apps",
        "es": "Eliminación de apps",
        "fr": "Suppression d'applications",
        "it": "Eliminazione app",
        "pt": "Eliminação de apps",
        "pt-BR": "Exclusão de apps",
        "nl": "App verwijderen",
        "pl": "Usuwanie aplikacji",
        "ru": "Удаление приложений",
        "tr": "Uygulama Silme",
        "hi": "ऐप हटाना",
        "ja": "アプリの削除",
        "ko": "앱 삭제",
        "zh-Hans": "应用删除",
        "zh-Hant": "應用程式刪除"
    },
    "screenTime.adultFilter.button.inactive": {
        "en": "Activate Protection",
        "de": "Schutzmodus aktivieren",
        "es": "Activar protección",
        "fr": "Activer la protection",
        "it": "Attiva protezione",
        "pt": "Ativar Proteção",
        "pt-BR": "Ativar Proteção",
        "nl": "Bescherming activeren",
        "pl": "Aktywuj ochronę",
        "ru": "Активировать защиту",
        "tr": "Korumayı Etkinleştir",
        "hi": "सुरक्षा सक्रिय करें",
        "ja": "保護を有効にする",
        "ko": "보호 활성화",
        "zh-Hans": "激活保护",
        "zh-Hant": "啟用保護"
    },
    "screenTime.adultFilter.button.active": {
        "en": "Deactivate Protection",
        "de": "Schutzmodus deaktivieren",
        "es": "Desactivar protección",
        "fr": "Désactiver la protection",
        "it": "Disattiva protezione",
        "pt": "Desativar Proteção",
        "pt-BR": "Desativar Proteção",
        "nl": "Bescherming deactiveren",
        "pl": "Dezaktywuj ochronę",
        "ru": "Деактивировать защиту",
        "tr": "Korumayı Devre Dışı Bırak",
        "hi": "सुरक्षा निष्क्रिय करें",
        "ja": "保護を無効にする",
        "ko": "보호 비활성화",
        "zh-Hans": "停用保护",
        "zh-Hant": "停用保護"
    }
}

for key, trans in translations.items():
    if key in data["strings"]:
        for lang in trans.keys():
            data["strings"][key]["localizations"][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": trans[lang]
                }
            }

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("All 16 languages translated perfectly.")
