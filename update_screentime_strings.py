import json

path = "Garten_Simulation/Localizable.xcstrings"

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

langs = ["de", "nl", "en", "fr", "it", "ja", "ko", "pl", "pt", "es", "tr"]

translations = {
    "weekday.monday":    {"de":"Montag","en":"Monday","es":"Lunes","fr":"Lundi","it":"Lunedì","ja":"月曜日","ko":"월요일","nl":"Maandag","pl":"Poniedziałek","pt":"Segunda-feira","tr":"Pazartesi"},
    "weekday.tuesday":   {"de":"Dienstag","en":"Tuesday","es":"Martes","fr":"Mardi","it":"Martedì","ja":"火曜日","ko":"화요일","nl":"Dinsdag","pl":"Wtorek","pt":"Terça-feira","tr":"Salı"},
    "weekday.wednesday": {"de":"Mittwoch","en":"Wednesday","es":"Miércoles","fr":"Mercredi","it":"Mercoledì","ja":"水曜日","ko":"수요일","nl":"Woensdag","pl":"Środa","pt":"Quarta-feira","tr":"Çarşamba"},
    "weekday.thursday":  {"de":"Donnerstag","en":"Thursday","es":"Jueves","fr":"Jeudi","it":"Giovedì","ja":"木曜日","ko":"목요일","nl":"Donderdag","pl":"Czwartek","pt":"Quinta-feira","tr":"Perşembe"},
    "weekday.friday":    {"de":"Freitag","en":"Friday","es":"Viernes","fr":"Vendredi","it":"Venerdì","ja":"金曜日","ko":"금요일","nl":"Vrijdag","pl":"Piątek","pt":"Sexta-feira","tr":"Cuma"},
    "weekday.saturday":  {"de":"Samstag","en":"Saturday","es":"Sábado","fr":"Samedi","it":"Sabato","ja":"土曜日","ko":"토요일","nl":"Zaterdag","pl":"Sobota","pt":"Sábado","tr":"Cumartesi"},
    "weekday.sunday":    {"de":"Sonntag","en":"Sunday","es":"Domingo","fr":"Dimanche","it":"Domenica","ja":"日曜日","ko":"일요일","nl":"Zondag","pl":"Niedziela","pt":"Domingo","tr":"Pazar"},
    "screenTime.schedule.title":          {"de":"Block-Zeitplan","en":"Block Schedule","es":"Horario de bloqueo","fr":"Plage de blocage","it":"Piano di blocco","ja":"ブロックスケジュール","ko":"차단 일정","nl":"Blokkeerplan","pl":"Harmonogram blokowania","pt":"Agenda de bloqueio","tr":"Engelleme Takvimi"},
    "screenTime.schedule.applyWeekdays":  {"de":"Mo–Fr gleich","en":"Apply Mon–Fri","es":"Aplicar Lu–Vi","fr":"Appliquer Lun–Ven","it":"Applica Lun–Ven","ja":"月〜金に適用","ko":"월~금에 적용","nl":"Ma–Vr toepassen","pl":"Zastosuj Pon–Pt","pt":"Aplicar Seg–Sex","tr":"Pzt–Cum uygula"},
    "screenTime.schedule.applyWeekend":   {"de":"Sa–So gleich","en":"Apply Sat–Sun","es":"Aplicar Sáb–Dom","fr":"Appliquer Sam–Dim","it":"Applica Sab–Dom","ja":"土・日に適用","ko":"토・일에 적용","nl":"Za–Zo toepassen","pl":"Zastosuj Sob–Nd","pt":"Aplicar Sáb–Dom","tr":"Cmt–Paz uygula"},
    "screenTime.schedule.day.inactive":   {"de":"Inaktiv","en":"Inactive","es":"Inactivo","fr":"Inactif","it":"Inattivo","ja":"無効","ko":"비활성","nl":"Inactief","pl":"Nieaktywny","pt":"Inativo","tr":"Etkin değil"},
    "screenTime.suggestions.desc":        {"de":"Tippe auf eine Kategorie – der Apple-Picker öffnet sich, wo du die Apps auswählen kannst.","en":"Tap a category – the Apple Picker opens so you can select apps to block.","es":"Toca una categoría – se abre el selector de Apple para que puedas seleccionar apps.","fr":"Appuyez sur une catégorie – le sélecteur Apple s'ouvre pour choisir les apps.","it":"Tocca una categoria – si apre il selettore Apple per scegliere le app.","ja":"カテゴリをタップすると、Appleのピッカーが開きアプリを選択できます。","ko":"카테고리를 탭하면 Apple 피커가 열려 앱을 선택할 수 있습니다.","nl":"Tik op een categorie – de Apple-picker opent om apps te selecteren.","pl":"Dotknij kategorię – otworzy się Apple Picker, gdzie możesz wybrać aplikacje.","pt":"Toque numa categoria – o seletor da Apple abre para escolher apps.","tr":"Bir kategoriye dokun – Apple Seçici açılır, uygulama seçebilirsin."},
    "screenTime.suggestions.games.title": {"de":"Games","en":"Games","es":"Juegos","fr":"Jeux","it":"Giochi","ja":"ゲーム","ko":"게임","nl":"Games","pl":"Gry","pt":"Jogos","tr":"Oyunlar"},
    "screenTime.info.desc":               {"de":"Der Shield-Block zeigt einen Warn-Overlay über Apps. Die betroffenen Apps werden nicht gelöscht und können vom Nutzer weiterhin geöffnet werden (mit Bestätigung). Der Erwachsenen-Filter gilt nur in Safari.","en":"The shield block shows a warning overlay over apps. Affected apps are not deleted and can still be opened by the user (with confirmation). The adult filter only applies in Safari.","es":"El bloqueo shield muestra una superposición de advertencia sobre las apps. Las apps afectadas no se eliminan y aún pueden ser abiertas por el usuario (con confirmación). El filtro adulto solo aplica en Safari.","fr":"Le blocage shield affiche une superposition d'avertissement sur les apps. Les apps concernées ne sont pas supprimées et peuvent toujours être ouvertes par l'utilisateur (avec confirmation). Le filtre adulte ne s'applique qu'à Safari.","it":"Il blocco shield mostra una sovrapposizione di avviso sulle app. Le app interessate non vengono eliminate e possono ancora essere aperte dall'utente (con conferma). Il filtro adulti si applica solo in Safari.","ja":"シールドブロックはアプリ上に警告オーバーレイを表示します。対象アプリは削除されず、ユーザーは確認後に引き続き開くことができます。アダルトフィルターはSafariのみに適用されます。","ko":"쉴드 차단은 앱 위에 경고 오버레이를 표시합니다. 영향을 받는 앱은 삭제되지 않으며 사용자가 확인 후 계속 열 수 있습니다. 성인 필터는 Safari에만 적용됩니다.","nl":"Het shield-blok toont een waarschuwingsoverlay over apps. De getroffen apps worden niet verwijderd en kunnen nog steeds worden geopend (met bevestiging). Het volwassenenfilter geldt alleen in Safari.","pl":"Blokada shield wyświetla nakładkę ostrzegawczą nad aplikacjami. Dotknięte aplikacje nie są usuwane i nadal mogą być otwierane przez użytkownika (z potwierdzeniem). Filtr dla dorosłych działa tylko w Safari.","pt":"O bloqueio shield mostra uma sobreposição de aviso sobre os apps. Os apps afetados não são excluídos e ainda podem ser abertos pelo utilizador (com confirmação). O filtro adulto aplica-se apenas no Safari.","tr":"Kalkan bloğu, uygulamalar üzerinde bir uyarı katmanı gösterir. Etkilenen uygulamalar silinmez ve kullanıcı tarafından hâlâ açılabilir (onay ile). Yetişkin filtresi yalnızca Safari'de geçerlidir."},
}

for key, lang_dict in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    
    for lang in langs:
        val = lang_dict.get(lang, lang_dict["en"])
        if "localizations" not in data["strings"][key]:
            data["strings"][key]["localizations"] = {}
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {"state": "translated", "value": val}
        }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Done. Added/updated {len(translations)} keys.")
