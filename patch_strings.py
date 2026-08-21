import json

translations = {
    '%@ %@': {
        'ko': '%1$@ %2$@', 'ru': '%1$@ %2$@', 'nl': '%1$@ %2$@', 'pl': '%1$@ %2$@', 'es': '%1$@ %2$@', 
        'pt': '%1$@ %2$@', 'it': '%1$@ %2$@', 'tr': '%1$@ %2$@', 'zh-Hant': '%1$@ %2$@', 'fr': '%1$@ %2$@', 
        'hi': '%1$@ %2$@', 'zh-Hans': '%1$@ %2$@', 'ja': '%1$@ %2$@', 'de': '%1$@ %2$@', 'en': '%1$@ %2$@'
    },
    'common.sort': {
        'ko': '정렬', 'ru': 'Сортировка', 'nl': 'Sorteren', 'pl': 'Sortuj', 'es': 'Ordenar',
        'pt': 'Ordenar', 'it': 'Ordina', 'tr': 'Sırala', 'zh-Hant': '排序', 'fr': 'Trier',
        'hi': 'क्रमबद्ध करें', 'zh-Hans': '排序', 'ja': '並べ替え', 'de': 'Sortieren', 'en': 'Sort'
    },
    'plant.detail.description.placeholder': {
        'ko': '짧은 설명 추가...', 'ru': 'Добавить краткое описание...', 'nl': 'Korte beschrijving toevoegen...', 'pl': 'Dodaj krótki opis...', 'es': 'Añadir una breve descripción...',
        'pt': 'Adicionar uma breve descrição...', 'it': 'Aggiungi una breve descrizione...', 'tr': 'Kısa bir açıklama ekle...', 'zh-Hant': '新增簡短描述...', 'fr': 'Ajouter une courte description...',
        'hi': 'एक संक्षिप्त विवरण जोड़ें...', 'zh-Hans': '添加简短描述...', 'ja': '簡単な説明を追加...', 'de': 'Kurze Beschreibung hinzufügen...', 'en': 'Add a short description...'
    },
    'plant.detail.description.title': {
        'ko': '사용자 지정 설명', 'ru': 'Собственное описание', 'nl': 'Aangepaste beschrijving', 'pl': 'Własny opis', 'es': 'Descripción personalizada',
        'pt': 'Descrição personalizada', 'it': 'Descrizione personalizzata', 'tr': 'Özel Açıklama', 'zh-Hant': '自訂描述', 'fr': 'Description personnalisée',
        'hi': 'कस्टम विवरण', 'zh-Hans': '自定义描述', 'ja': 'カスタム説明', 'de': 'Eigene Beschreibung', 'en': 'Custom Description'
    },
    'habit.custom.todo': {
        'ko': '사용자 지정 할 일', 'ru': 'Собственная задача', 'nl': 'Aangepaste taak', 'pl': 'Własne zadanie', 'es': 'Tarea personalizada',
        'pt': 'Tarefa personalizada', 'it': 'Cosa da fare personalizzata', 'tr': 'Özel Görev', 'zh-Hant': '自訂待辦事項', 'fr': 'Tâche personnalisée',
        'hi': 'कस्टम टू-डू', 'zh-Hans': '自定义待办事项', 'ja': 'カスタムToDo', 'de': 'Eigenes To-Do', 'en': 'Custom Todo'
    },
    'routine.default_name': {
        'ko': '루틴', 'ru': 'Рутина', 'nl': 'Routine', 'pl': 'Rutyna', 'es': 'Rutina',
        'pt': 'Rotina', 'it': 'Routine', 'tr': 'Rutin', 'zh-Hant': '日常', 'fr': 'Routine',
        'hi': 'दिनचर्या', 'zh-Hans': '日常', 'ja': 'ルーティン', 'de': 'Routine', 'en': 'Routine'
    },
    'routine.todo.edit': {
        'ko': '할 일 이름 바꾸기', 'ru': 'Переименовать задачу', 'nl': 'Taak hernoemen', 'pl': 'Zmień nazwę zadania', 'es': 'Renombrar tarea',
        'pt': 'Renomear tarefa', 'it': 'Rinomina cosa da fare', 'tr': 'Görevi Yeniden Adlandır', 'zh-Hant': '重新命名待辦事項', 'fr': 'Renommer la tâche',
        'hi': 'टू-डू का नाम बदलें', 'zh-Hans': '重命名待办事项', 'ja': 'ToDoの名前を変更', 'de': 'To-Do umbenennen', 'en': 'Rename Todo'
    },
    'routine.todo.edit.message': {
        'ko': '이 할 일의 새 이름을 입력하세요.', 'ru': 'Введите новое имя для этой задачи.', 'nl': 'Voer een nieuwe naam in voor deze taak.', 'pl': 'Wprowadź nową nazwę dla tego zadania.', 'es': 'Introduce un nuevo nombre para esta tarea.',
        'pt': 'Introduza um novo nome para esta tarefa.', 'it': 'Inserisci un nuovo nome per questa cosa da fare.', 'tr': 'Bu görev için yeni bir isim girin.', 'zh-Hant': '輸入此待辦事項的新名稱。', 'fr': 'Entrez un nouveau nom pour cette tâche.',
        'hi': 'इस टू-डू के लिए नया नाम दर्ज करें।', 'zh-Hans': '输入此待办事项的新名称。', 'ja': 'このToDoの新しい名前を入力してください。', 'de': 'Gib einen neuen Namen für dieses To-Do ein.', 'en': 'Enter a new name for this todo.'
    }
}

file_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

strings = data.get("strings", {})

for key, lang_map in translations.items():
    if key in strings:
        localizations = strings[key].setdefault("localizations", {})
        for lang, val in lang_map.items():
            if lang not in localizations:
                localizations[lang] = {}
            localizations[lang]["stringUnit"] = {
                "state": "translated",
                "value": val
            }

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
