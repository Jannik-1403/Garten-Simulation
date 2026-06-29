import json

with open('./Localizable.xcstrings', 'r') as f:
    data = json.load(f)

strings = data.setdefault('strings', {})

new_translations = {
    "focus.session.cancelled.app_left": {
        "de": "Du hast die App zu lange verlassen. Dein Fokus-Timer wurde abgebrochen.",
        "en": "You left the app for too long. Your focus timer was cancelled.",
        "es": "Dejaste la app demasiado tiempo. Tu temporizador de enfoque fue cancelado.",
        "fr": "Vous avez quitté l'application trop longtemps. Votre minuteur de concentration a été annulé.",
        "it": "Hai lasciato l'app troppo a lungo. Il tuo timer di concentrazione è stato annullato.",
        "pt": "Ficaste fora da app durante tempo demais. O teu temporizador de foco foi cancelado.",
        "ja": "アプリを長時間離れていました。フォーカスタイマーがキャンセルされました。",
        "ko": "앱을 너무 오래 벗어났습니다. 포커스 타이머가 취소되었습니다.",
        "pl": "Byłeś poza aplikacją zbyt długo. Twój timer skupienia został anulowany.",
        "nl": "Je verliet de app te lang. Je focustimer is geannuleerd.",
        "tr": "Uygulamayı çok uzun süre terk ettiniz. Odak zamanlayıcınız iptal edildi."
    },
    "focus.session.completed.xp_shared": {
        "de": "Du warst %lld Minuten lang extrem fokussiert. Die XP werden auf alle deine Pflanzen aufgeteilt!",
        "en": "You were extremely focused for %lld minutes. The XP will be distributed to all your plants!",
        "es": "Estuviste extremadamente enfocado durante %lld minutos. ¡Los XP se distribuirán entre todas tus plantas!",
        "fr": "Vous avez été extrêmement concentré pendant %lld minutes. Les XP seront distribués à toutes vos plantes !",
        "it": "Sei stato estremamente concentrato per %lld minuti. I punti XP verranno distribuiti a tutte le tue piante!",
        "pt": "Estiveste extremamente focado durante %lld minutos. Os XP serão distribuídos por todas as tuas plantas!",
        "ja": "%lld分間、非常に集中していました。XPはすべての植物に分配されます！",
        "ko": "%lld분 동안 매우 집중했습니다. XP가 모든 식물에 분배됩니다!",
        "pl": "Byłeś niezwykle skupiony przez %lld minut. XP zostaną podzielone na wszystkie twoje rośliny!",
        "nl": "Je was %lld minuten lang extreem gefocust. De XP wordt verdeeld over al je planten!",
        "tr": "%lld dakika boyunca son derece odaklandınız. XP tüm bitkilerinize dağıtılacak!"
    },
    "focus.session.start": {
        "de": "Fokus-Session starten",
        "en": "Start Focus Session",
        "es": "Iniciar sesión de enfoque",
        "fr": "Démarrer la session de concentration",
        "it": "Avvia sessione di concentrazione",
        "pt": "Iniciar sessão de foco",
        "ja": "フォーカスセッションを開始",
        "ko": "포커스 세션 시작",
        "pl": "Rozpocznij sesję skupienia",
        "nl": "Start focussessie",
        "tr": "Odak Oturumunu Başlat"
    },
    "notification.routine.start": {
        "de": "Starte jetzt deine Routine und verdiene Fokus-Punkte!",
        "en": "Start your routine now and earn focus points!",
        "es": "¡Inicia tu rutina ahora y gana puntos de enfoque!",
        "fr": "Commencez votre routine maintenant et gagnez des points de concentration !",
        "it": "Inizia la tua routine ora e guadagna punti concentrazione!",
        "pt": "Começa a tua rotina agora e ganha pontos de foco!",
        "ja": "今すぐルーチンを開始して、フォーカスポイントを獲得しましょう！",
        "ko": "지금 루틴을 시작하고 포커스 포인트를 획득하세요!",
        "pl": "Rozpocznij swoją rutynę teraz i zdobywaj punkty skupienia!",
        "nl": "Start nu je routine en verdien focuspunten!",
        "tr": "Şimdi rutininize başlayın ve odak puanları kazanın!"
    },
    "shop.mystic.confirmation.title": {
        "de": "Ultimatives Luxus-Item!",
        "en": "Ultimate Luxury Item!",
        "es": "¡Artículo de lujo supremo!",
        "fr": "Article de luxe ultime !",
        "it": "Articolo di lusso definitivo!",
        "pt": "Item de luxo supremo!",
        "ja": "究極の高級アイテム！",
        "ko": "궁극의 럭셔리 아이템!",
        "pl": "Ostateczny luksusowy przedmiot!",
        "nl": "Ultiem luxe item!",
        "tr": "En Üst Düzey Lüks Eşya!"
    },
    "focus.session.subgoal.add": {
        "de": "Unterziel hinzufügen...",
        "en": "Add sub-goal...",
        "es": "Agregar subobjetivo...",
        "fr": "Ajouter un sous-objectif...",
        "it": "Aggiungi sotto-obiettivo...",
        "pt": "Adicionar subobjetivo...",
        "ja": "サブ目標を追加...",
        "ko": "하위 목표 추가...",
        "pl": "Dodaj podcel...",
        "nl": "Subdoel toevoegen...",
        "tr": "Alt hedef ekle..."
    }
}

for key, translations in new_translations.items():
    if key not in strings:
        strings[key] = {"extractionState": "manual", "localizations": {}}
    
    locs = strings[key]["localizations"]
    for lang, text in translations.items():
        locs[lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open('./Localizable.xcstrings', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Added new translations to Localizable.xcstrings")
