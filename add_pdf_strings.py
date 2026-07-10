import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

new_strings = [
    {
        "key": "export.pdf.filename_title",
        "translations": {
            "de": "PDF Dateiname",
            "en": "PDF Filename",
            "nl": "PDF Bestandsnaam",
            "fr": "Nom du fichier PDF",
            "it": "Nome file PDF",
            "ja": "PDFファイル名",
            "ko": "PDF 파일 이름",
            "pl": "Nazwa pliku PDF",
            "pt": "Nome do ficheiro PDF",
            "es": "Nombre de archivo PDF",
            "tr": "PDF Dosya Adı"
        }
    },
    {
        "key": "export.pdf.filename_placeholder",
        "translations": {
            "de": "Name eingeben",
            "en": "Enter name",
            "nl": "Voer naam in",
            "fr": "Entrez le nom",
            "it": "Inserisci nome",
            "ja": "名前を入力",
            "ko": "이름 입력",
            "pl": "Wpisz nazwę",
            "pt": "Introduzir nome",
            "es": "Introducir nombre",
            "tr": "Adı girin"
        }
    }
]

for item in new_strings:
    key = item["key"]
    translations = item["translations"]
    
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}

    for lang, text in translations.items():
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Strings added to Localizable.xcstrings successfully!")
