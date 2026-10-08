import json

file_path = "Garten_Simulation/Localizable.xcstrings"

try:
    with open(file_path, "r") as f:
        data = json.load(f)
except Exception as e:
    print(f"Error reading {file_path}: {e}")
    exit(1)

new_keys = {
    "intent.export_summary.title": {
        "en": "Export Daily Summary",
        "de": "Tages-Zusammenfassung exportieren",
        "es": "Exportar Resumen Diario",
        "fr": "Exporter le résumé quotidien",
        "it": "Esporta Riepilogo Giornaliero",
        "ja": "日次サマリーをエクスポート",
        "ko": "일일 요약 내보내기",
        "nl": "Dagelijkse samenvatting exporteren",
        "pl": "Eksportuj codzienne podsumowanie",
        "pt": "Exportar Resumo Diário",
        "tr": "Günlük Özeti Dışa Aktar"
    },
    "intent.export_summary.description": {
        "en": "Exports a summary of today's progress for external tools like AI coaches.",
        "de": "Exportiert eine Zusammenfassung des heutigen Fortschritts für externe Tools wie KI-Coaches.",
        "es": "Exporta un resumen del progreso de hoy para herramientas externas como coaches de IA.",
        "fr": "Exporte un résumé de la progression d'aujourd'hui pour des outils externes comme les coachs IA.",
        "it": "Esporta un riepilogo dei progressi di oggi per strumenti esterni come gli AI coach.",
        "ja": "AIコーチなどの外部ツール向けに今日の進捗サマリーをエクスポートします。",
        "ko": "AI 코치와 같은 외부 도구를 위해 오늘의 진행 상황 요약을 내보냅니다.",
        "nl": "Exporteert een samenvatting van de voortgang van vandaag voor externe tools zoals AI-coaches.",
        "pl": "Eksportuje podsumowanie dzisiejszych postępów dla zewnętrznych narzędzi, takich jak trenerzy AI.",
        "pt": "Exporta um resumo do progresso de hoje para ferramentas externas como treinadores de IA.",
        "tr": "Yapay zeka koçları gibi harici araçlar için bugünkü ilerlemenin bir özetini dışa aktarır."
    },
    "developer.export.title": {
        "en": "AI & Data Export",
        "de": "KI & Daten-Export",
        "es": "Exportación de IA y Datos",
        "fr": "Exportation IA & Données",
        "it": "Esportazione IA & Dati",
        "ja": "AI & データエクスポート",
        "ko": "AI 및 데이터 내보내기",
        "nl": "AI & Data-export",
        "pl": "Eksport AI i danych",
        "pt": "Exportação de IA e Dados",
        "tr": "YZ & Veri Dışa Aktarımı"
    },
    "developer.export.copyJSON": {
        "en": "Copy Daily Summary (JSON)",
        "de": "Tageszusammenfassung kopieren (JSON)",
        "es": "Copiar Resumen Diario (JSON)",
        "fr": "Copier le résumé quotidien (JSON)",
        "it": "Copia Riepilogo Giornaliero (JSON)",
        "ja": "日次サマリーをコピー (JSON)",
        "ko": "일일 요약 복사 (JSON)",
        "nl": "Dagelijkse samenvatting kopiëren (JSON)",
        "pl": "Kopiuj codzienne podsumowanie (JSON)",
        "pt": "Copiar Resumo Diário (JSON)",
        "tr": "Günlük Özeti Kopyala (JSON)"
    }
}

for key, translations in new_keys.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    for lang, text in translations.items():
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open(file_path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Localizable.xcstrings patched successfully!")
