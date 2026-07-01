import json

path = "Garten_Simulation/Localizable.xcstrings"

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

translations = {
    "custom.tracker.title": {
        "de": "Eigener Tracker", "en": "Custom Tracker", "ko": "맞춤형 트래커", "ja": "カスタムトラッカー",
        "es": "Rastreador personalizado", "fr": "Traqueur personnalisé", "it": "Tracker personalizzato",
        "pt": "Rastreador personalizado", "pl": "Własny tracker", "nl": "Aangepaste tracker", "tr": "Özel İzleyici"
    },
    "custom.tracker.create.button": {
        "de": "Tracker erstellen", "en": "Create Tracker", "ko": "트래커 만들기", "ja": "トラッカーを作成",
        "es": "Crear rastreador", "fr": "Créer un traqueur", "it": "Crea tracker",
        "pt": "Criar rastreador", "pl": "Utwórz tracker", "nl": "Tracker maken", "tr": "İzleyici Oluştur"
    },
    "custom.tracker.create.title": {
        "de": "Neuen Tracker erstellen", "en": "Create New Tracker", "ko": "새 트래커 만들기", "ja": "新しいトラッカーを作成",
        "es": "Crear nuevo rastreador", "fr": "Créer un nouveau traqueur", "it": "Crea nuovo tracker",
        "pt": "Criar novo rastreador", "pl": "Utwórz nowy tracker", "nl": "Nieuwe tracker maken", "tr": "Yeni İzleyici Oluştur"
    },
    "custom.tracker.create.message": {
        "de": "Gib einen Namen für deinen eigenen Fortschritts-Tracker ein.", "en": "Enter a name for your custom progress tracker.",
        "ko": "사용자 지정 진행률 트래커의 이름을 입력하세요.", "ja": "カスタム進捗トラッカーの名前を入力してください。",
        "es": "Ingrese un nombre para su rastreador de progreso personalizado.", "fr": "Entrez un nom pour votre traqueur de progression personnalisé.",
        "it": "Inserisci un nome per il tuo tracker di progressi personalizzato.", "pt": "Insira um nome para o seu rastreador de progresso personalizado.",
        "pl": "Wpisz nazwę dla swojego niestandardowego trackera postępów.", "nl": "Voer een naam in voor uw aangepaste voortgangstracker.",
        "tr": "Özel ilerleme izleyiciniz için bir ad girin."
    },
    "custom.tracker.name.placeholder": {
        "de": "z.B. Seiten gelesen", "en": "e.g. Pages read", "ko": "예: 읽은 페이지 수", "ja": "例：読んだページ",
        "es": "p. ej. Páginas leídas", "fr": "ex. Pages lues", "it": "es. Pagine lette",
        "pt": "ex. Páginas lidas", "pl": "np. Przeczytane strony", "nl": "bijv. Pagina's gelezen", "tr": "örn. Okunan sayfalar"
    },
    "custom.tracker.delete.title": {
        "de": "Tracker löschen?", "en": "Delete Tracker?", "ko": "트래커 삭제?", "ja": "トラッカーを削除しますか？",
        "es": "¿Eliminar rastreador?", "fr": "Supprimer le traqueur ?", "it": "Elimina tracker?",
        "pt": "Excluir rastreador?", "pl": "Usunąć tracker?", "nl": "Tracker verwijderen?", "tr": "İzleyici Silinsin mi?"
    },
    "custom.tracker.delete.message": {
        "de": "Bist du sicher, dass du deinen Tracker löschen möchtest? Dein Fortschritt geht dabei verloren.", "en": "Are you sure you want to delete your tracker? Your progress will be lost.",
        "ko": "트래커를 삭제하시겠습니까? 진행 상황이 손실됩니다.", "ja": "トラッカーを削除してもよろしいですか？進捗は失われます。",
        "es": "¿Estás seguro de que quieres eliminar tu rastreador? Tu progreso se perderá.", "fr": "Êtes-vous sûr de vouloir supprimer votre traqueur ? Votre progression sera perdue.",
        "it": "Sei sicuro di voler eliminare il tuo tracker? I tuoi progressi andranno persi.", "pt": "Tem certeza de que deseja excluir seu rastreador? Seu progresso será perdido.",
        "pl": "Czy na pewno chcesz usunąć swój tracker? Twój postęp zostanie utracony.", "nl": "Weet je zeker dat je je tracker wilt verwijderen? Je voortgang gaat verloren.",
        "tr": "İzleyicinizi silmek istediğinizden emin misiniz? İlerlemeniz kaybolacak."
    },
    "custom.tracker.target": {
        "de": "Ziel", "en": "Target", "ko": "목표", "ja": "目標", "es": "Objetivo", "fr": "Cible",
        "it": "Obiettivo", "pt": "Alvo", "pl": "Cel", "nl": "Doel", "tr": "Hedef"
    },
    "custom.tracker.progress.today": {
        "de": "Fortschritt heute", "en": "Today's Progress", "ko": "오늘의 진행 상황", "ja": "今日の進捗",
        "es": "Progreso de hoy", "fr": "Progression du jour", "it": "Progressi di oggi",
        "pt": "Progresso de hoje", "pl": "Dzisiejszy postęp", "nl": "Voortgang van vandaag", "tr": "Bugünün İlerlemesi"
    }
}

for key, lang_dict in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    for lang, val in lang_dict.items():
        if lang not in data["strings"][key]["localizations"]:
            data["strings"][key]["localizations"][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": val
                }
            }
        else:
            data["strings"][key]["localizations"][lang]["stringUnit"]["state"] = "translated"
            data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = val

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
