# -*- coding: utf-8 -*-
import json

file_path = 'Garten_Simulation/Localizable.xcstrings'
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

translations = {
    "weekly_report.card.focus_time.value": {
        "en": "%lld Minutes", "de": "%lld Minuten", "es": "%lld Minutos", "fr": "%lld Minutes", "it": "%lld Minuti", "pt": "%lld Minutos", "nl": "%lld Minuten", "pl": "%lld Minut", "ru": "%lld Минут", "tr": "%lld Dakika", "ja": "%lld 分", "ko": "%lld 분", "zh-Hans": "%lld 分钟", "zh-Hant": "%lld 分鐘", "hi": "%lld मिनट"
    },
    "weekly_report.chart.focus_time.value": {
        "en": "%lld Minutes", "de": "%lld Minuten", "es": "%lld Minutos", "fr": "%lld Minutes", "it": "%lld Minuti", "pt": "%lld Minutos", "nl": "%lld Minuten", "pl": "%lld Minut", "ru": "%lld Минут", "tr": "%lld Dakika", "ja": "%lld 分", "ko": "%lld 분", "zh-Hans": "%lld 分钟", "zh-Hant": "%lld 分鐘", "hi": "%lld मिनट"
    },
    "smart.weekly.title.tip": {
        "en": "Tip", "de": "Tipp", "es": "Consejo", "fr": "Astuce", "it": "Suggerimento", "pt": "Dica", "nl": "Tip", "pl": "Wskazówka", "ru": "Совет", "tr": "İpucu", "ja": "ヒント", "ko": "팁", "zh-Hans": "提示", "zh-Hant": "提示", "hi": "सुझाव"
    },
    "export.pdf.default_filename": {
        "en": "Garden Report", "de": "Garten Bericht", "es": "Informe de Jardín", "fr": "Rapport de Jardin", "it": "Rapporto Giardino", "pt": "Relatório de Jardim", "nl": "Tuinrapport", "pl": "Raport ogrodowy", "ru": "Отчет по саду", "tr": "Bahçe Raporu", "ja": "ガーデンレポート", "ko": "가든 리포트", "zh-Hans": "花园报告", "zh-Hant": "花園報告", "hi": "गार्डन रिपोर्ट"
    },
    "weekly_report.pdf.default_filename": {
        "en": "Grovy Weekly Report", "de": "Grovy Wochenbericht", "es": "Informe Semanal Grovy", "fr": "Rapport Hebdo Grovy", "it": "Rapporto Settimanale Grovy", "pt": "Relatório Semanal Grovy", "nl": "Grovy Weekrapport", "pl": "Raport tygodniowy", "ru": "Еженедельный отчет", "tr": "Haftalık Rapor", "ja": "週次レポート", "ko": "주간 리포트", "zh-Hans": "Grovy 每周报告", "zh-Hant": "Grovy 每週報告", "hi": "साप्ताहिक रिपोर्ट"
    },
    "backup.auto.view_backups": {
        "en": "Auto Backups", "de": "Automatische Backups", "es": "Copias automáticas", "fr": "Sauvegardes auto", "it": "Backup automatici", "pt": "Backups automáticos", "nl": "Auto-back-ups", "pl": "Kopie automatyczne", "ru": "Автобэкапы", "tr": "Oto Yedeklemeler", "ja": "自動バックアップ", "ko": "자동 백업", "zh-Hans": "自动备份", "zh-Hant": "自動備份", "hi": "ऑटो बैकअप"
    },
    "backup.auto.no_backups": {
        "en": "No automatic backups found.", "de": "Keine automatischen Backups gefunden.", "es": "No se encontraron copias automáticas.", "fr": "Aucune sauvegarde automatique.", "it": "Nessun backup automatico trovato.", "pt": "Nenhum backup automático.", "nl": "Geen automatische back-ups gevonden.", "pl": "Brak kopii zapasowych.", "ru": "Бэкапы не найдены.", "tr": "Otomatik yedek bulunamadı.", "ja": "自動バックアップがありません。", "ko": "자동 백업이 없습니다.", "zh-Hans": "未找到自动备份。", "zh-Hant": "未找到自動備份。", "hi": "कोई बैकअप नहीं मिला。"
    },
    "backup.auto.picker.title": {
        "en": "Select Interval", "de": "Intervall auswählen", "es": "Seleccionar intervalo", "fr": "Choisir l'intervalle", "it": "Seleziona intervallo", "pt": "Selecionar intervalo", "nl": "Selecteer interval", "pl": "Wybierz interwał", "ru": "Выберите интервал", "tr": "Aralık Seç", "ja": "間隔を選択", "ko": "간격 선택", "zh-Hans": "选择备份频率", "zh-Hant": "選擇備份頻率", "hi": "अंतराल चुनें"
    },
    "backup.auto.name_prefix": {
        "en": "Backup", "de": "Backup", "es": "Copia", "fr": "Sauvegarde", "it": "Backup", "pt": "Backup", "nl": "Back-up", "pl": "Kopia", "ru": "Бэкап", "tr": "Yedek", "ja": "バックアップ", "ko": "백업", "zh-Hans": "备份文件", "zh-Hant": "備份檔案", "hi": "बैकअप"
    },
    "export.pdf.filename_title": {
        "en": "PDF File Name", "de": "PDF Dateiname", "es": "Nombre del PDF", "fr": "Nom du fichier PDF", "it": "Nome file PDF", "pt": "Nome do ficheiro PDF", "nl": "PDF bestandsnaam", "pl": "Nazwa pliku PDF", "ru": "Имя PDF", "tr": "PDF Dosya Adı", "ja": "PDFファイル名", "ko": "PDF 파일명", "zh-Hans": "PDF 文件名称", "zh-Hant": "PDF 檔案名稱", "hi": "PDF फ़ाइल का नाम"
    },
    "export.pdf.filename_placeholder": {
        "en": "Enter name", "de": "Name eingeben", "es": "Introducir nombre", "fr": "Entrer un nom", "it": "Inserisci nome", "pt": "Introduzir nome", "nl": "Voer naam in", "pl": "Wpisz nazwę", "ru": "Введите имя", "tr": "Adı girin", "ja": "名前を入力", "ko": "이름 입력", "zh-Hans": "输入文件名称", "zh-Hant": "輸入檔案名稱", "hi": "नाम दर्ज करें"
    },
    "backup_export_hint": {
        "en": "Save your progress as a .gartensave file. You can import it on other devices.", "de": "Speichere deinen Fortschritt als .gartensave Datei. Du kannst sie auf anderen Geräten importieren.", "es": "Guarda tu progreso como archivo .gartensave.", "fr": "Enregistrez sous forme de fichier .gartensave.", "it": "Salva i progressi come file .gartensave.", "pt": "Guarde o progresso como ficheiro .gartensave.", "nl": "Sla voortgang op als .gartensave bestand.", "pl": "Zapisz jako plik .gartensave.", "ru": "Сохраните прогресс как .gartensave.", "tr": "İlerlemeni .gartensave olarak kaydet.", "ja": "進捗を .gartensave として保存します。", "ko": "진행 상황을 .gartensave로 저장하세요.", "zh-Hans": "将进度保存为 .gartensave 备份文件，以便在其他设备上导入。", "zh-Hant": "將進度儲存為 .gartensave 備份檔案，以便在其他裝置上匯入。", "hi": "अपनी प्रगति को .gartensave के रूप में सहेजें。"
    },
    "backup_import_titel": {
        "en": "Import", "de": "Importieren", "es": "Importar", "fr": "Importer", "it": "Importa", "pt": "Importar", "nl": "Importeren", "pl": "Importuj", "ru": "Импорт", "tr": "İçe Aktar", "ja": "インポート", "ko": "가져오기", "zh-Hans": "导入备份", "zh-Hant": "匯入備份", "hi": "आयात करें"
    },
    "backup_export_titel": {
        "en": "Export", "de": "Exportieren", "es": "Exportar", "fr": "Exporter", "it": "Esporta", "pt": "Exportar", "nl": "Exporteren", "pl": "Eksportuj", "ru": "Экспорт", "tr": "Dışa Aktar", "ja": "エクスポート", "ko": "내보내기", "zh-Hans": "导出备份", "zh-Hant": "匯出備份", "hi": "निर्यात करें"
    },
    "backup_title": {
        "en": "Backup & Export", "de": "Backup & Export", "es": "Copias & Exportar", "fr": "Sauvegarde & Export", "it": "Backup & Esporta", "pt": "Backup & Exportar", "nl": "Back-up & Export", "pl": "Kopie & Eksport", "ru": "Бэкап и экспорт", "tr": "Yedek & Dışa Aktar", "ja": "バックアップとエクスポート", "ko": "백업 및 내보내기", "zh-Hans": "备份与导出", "zh-Hant": "備份與匯出", "hi": "बैकअप और निर्यात"
    }
}

existing_langs = ['pt', 'nl', 'zh-Hans', 'ko', 'ja', 'tr', 'es', 'fr', 'en', 'ru', 'pl', 'it', 'hi', 'de', 'zh-Hant']

for key, lang_dict in translations.items():
    if key not in data['strings']:
        data['strings'][key] = {"extractionState": "manual", "localizations": {}}
        
    for lang in existing_langs:
        val = lang_dict.get(lang) or lang_dict.get('en')
        
        if 'localizations' not in data['strings'][key]:
            data['strings'][key]['localizations'] = {}
            
        data['strings'][key]['localizations'][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Injected accurate localizations successfully!")
