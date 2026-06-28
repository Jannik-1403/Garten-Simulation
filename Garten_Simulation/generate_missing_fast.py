import re

new_keys = """
        "routine.timer.paused": ["de": "pausiert", "en": "paused", "es": "en pausa", "fr": "en pause", "it": "in pausa", "pt": "em pausa", "ja": "一時停止", "ko": "일시중지됨", "pl": "wstrzymany", "nl": "gepauzeerd", "tr": "duraklatıldı"],
        "routine.session.next": ["de": "Als Nächstes", "en": "Next up", "es": "Siguiente", "fr": "Ensuite", "it": "Prossimo", "pt": "Próximo", "ja": "次へ", "ko": "다음", "pl": "Następny", "nl": "Volgende", "tr": "Sıradaki"],
        "routine.note.assign": ["de": "Notiz zuweisen", "en": "Assign Note", "es": "Asignar nota", "fr": "Attribuer une note", "it": "Assegna nota", "pt": "Atribuir nota", "ja": "メモを割り当てる", "ko": "메모 할당", "pl": "Przypisz notatkę", "nl": "Notitie toewijzen", "tr": "Not Ata"],
        "routine.note.assign.desc": ["de": "Weise dieser Routine eine Notiz zu.", "en": "Add a note to this routine.", "es": "Agrega una nota a esta rutina.", "fr": "Ajoutez une note à cette routine.", "it": "Aggiungi una nota a questa routine.", "pt": "Adicione uma nota a esta rotina.", "ja": "このルーチンにメモを追加します。", "ko": "이 루틴에 메모를 추가하세요.", "pl": "Dodaj notatkę do tej rutyny.", "nl": "Voeg een notitie toe aan deze routine.", "tr": "Bu rutine bir not ekleyin."],
        "routine_titel": ["de": "Routine", "en": "Routine", "es": "Rutina", "fr": "Routine", "it": "Routine", "pt": "Rotina", "ja": "ルーチン", "ko": "루틴", "pl": "Rutyna", "nl": "Routine", "tr": "Rutin"],
        "starten": ["de": "Starten", "en": "Start", "es": "Empezar", "fr": "Démarrer", "it": "Inizia", "pt": "Iniciar", "ja": "開始", "ko": "시작", "pl": "Rozpocznij", "nl": "Starten", "tr": "Başlat"],
        "Fokus-Score": ["de": "Fokus-Score", "en": "Focus Score", "es": "Puntuación de enfoque", "fr": "Score de concentration", "it": "Punteggio di concentrazione", "pt": "Pontuação de foco", "ja": "フォーカススコア", "ko": "포커스 점수", "pl": "Wynik skupienia", "nl": "Focus Score", "tr": "Odaklanma Puanı"],
        "Priorität": ["de": "Priorität", "en": "Priority", "es": "Prioridad", "fr": "Priorité", "it": "Priorità", "pt": "Prioridade", "ja": "優先度", "ko": "우선순위", "pl": "Priorytet", "nl": "Prioriteit", "tr": "Öncelik"],
        "Unterziel hinzufügen...": ["de": "Unterziel hinzufügen...", "en": "Add sub-goal...", "es": "Añadir subobjetivo...", "fr": "Ajouter un sous-objectif...", "it": "Aggiungi sotto-obiettivo...", "pt": "Adicionar subobjetivo...", "ja": "サブ目標を追加...", "ko": "하위 목표 추가...", "pl": "Dodaj podcel...", "nl": "Subdoel toevoegen...", "tr": "Alt hedef ekle..."],
        "assessment.soon": ["de": "Bald verfügbar", "en": "Coming Soon", "es": "Próximamente", "fr": "Bientôt", "it": "Prossimamente", "pt": "Em breve", "ja": "近日公開", "ko": "곧 출시됨", "pl": "Wkrótce", "nl": "Binnenkort", "tr": "Yakında"],
        "canvas.show_all": ["de": "Alle anzeigen", "en": "Show All", "es": "Mostrar todo", "fr": "Afficher tout", "it": "Mostra tutto", "pt": "Mostrar tudo", "ja": "すべて表示", "ko": "모두 보기", "pl": "Pokaż wszystko", "nl": "Toon alles", "tr": "Tümünü Göster"],
        "common.record": ["de": "Rekord", "en": "Record", "es": "Récord", "fr": "Record", "it": "Record", "pt": "Recorde", "ja": "記録", "ko": "기록", "pl": "Rekord", "nl": "Record", "tr": "Rekor"],
        "common.this_month": ["de": "Dieser Monat", "en": "This Month", "es": "Este mes", "fr": "Ce mois-ci", "it": "Questo mese", "pt": "Este mês", "ja": "今月", "ko": "이번 달", "pl": "Ten miesiąc", "nl": "Deze maand", "tr": "Bu Ay"],
        "habit.stats.streak": ["de": "Aktuelle Serie", "en": "Current Streak", "es": "Racha actual", "fr": "Série actuelle", "it": "Striscia attuale", "pt": "Sequência atual", "ja": "現在のストリーク", "ko": "현재 연속 기록", "pl": "Obecna seria", "nl": "Huidige streak", "tr": "Mevcut Seri"],
        "habit.stats.total": ["de": "Gesamte Ausführungen", "en": "Total Executions", "es": "Ejecuciones totales", "fr": "Exécutions totales", "it": "Esecuzioni totali", "pt": "Execuções totais", "ja": "合計実行回数", "ko": "총 실행 횟수", "pl": "Całkowita liczba wykonani", "nl": "Totale uitvoeringen", "tr": "Toplam Yürütmeler"],
        "path.no_task": ["de": "Keine Aufgabe für heute.", "en": "No task for today.", "es": "No hay tareas para hoy.", "fr": "Aucune tâche pour aujourd'hui.", "it": "Nessuna attività per oggi.", "pt": "Sem tarefa para hoje.", "ja": "今日のタスクはありません。", "ko": "오늘 할 일이 없습니다.", "pl": "Brak zadań na dziś.", "nl": "Geen taak voor vandaag.", "tr": "Bugün için görev yok."],
        "pfad_abgeschlossen_belohnung": ["de": "Pfad abgeschlossen Belohnung", "en": "Path Completed Reward", "es": "Recompensa de ruta completada", "fr": "Récompense de chemin terminé", "it": "Ricompensa percorso completato", "pt": "Recompensa de caminho concluído", "ja": "パス完了報酬", "ko": "경로 완료 보상", "pl": "Nagroda za ukończenie ścieżki", "nl": "Pad Voltooid Beloning", "tr": "Yol Tamamlama Ödülü"],
        "pfad_belohnung_meilenstein": ["de": "Meilenstein Belohnung", "en": "Milestone Reward", "es": "Recompensa de hito", "fr": "Récompense d'étape", "it": "Ricompensa traguardo", "pt": "Recompensa de marco", "ja": "マイルストーン報酬", "ko": "마일스톤 보상", "pl": "Nagroda za kamień milowy", "nl": "Mijlpaal Beloning", "tr": "Dönüm Noktası Ödülü"],
        "pfad_einstellungen_titel": ["de": "Pfad Einstellungen", "en": "Path Settings", "es": "Configuración de ruta", "fr": "Paramètres du chemin", "it": "Impostazioni percorso", "pt": "Configurações de caminho", "ja": "パス設定", "ko": "경로 설정", "pl": "Ustawienia ścieżki", "nl": "Pad Instellingen", "tr": "Yol Ayarları"],
        "pfad_tag_erledigt_belohnung": ["de": "Tagesabschluss Belohnung", "en": "Day Completed Reward", "es": "Recompensa del día", "fr": "Récompense du jour", "it": "Ricompensa giornaliera", "pt": "Recompensa diária", "ja": "デイリー報酬", "ko": "일일 보상", "pl": "Dzienna nagroda", "nl": "Dagelijkse Beloning", "tr": "Günlük Ödül"],
        "powerup.lives.full": ["de": "Leben sind voll!", "en": "Lives are full!", "es": "¡Las vidas están llenas!", "fr": "Les vies sont pleines !", "it": "Le vite sono piene!", "pt": "Vidas cheias!", "ja": "ライフがいっぱいです！", "ko": "하트가 가득 찼습니다!", "pl": "Życia są pełne!", "nl": "Levens zijn vol!", "tr": "Canlar dolu!"],
        "rarity.common": ["de": "Gewöhnlich", "en": "Common", "es": "Común", "fr": "Commun", "it": "Comune", "pt": "Comum", "ja": "コモン", "ko": "일반", "pl": "Zwykły", "nl": "Gewoon", "tr": "Yaygın"],
        "rarity.epic": ["de": "Episch", "en": "Epic", "es": "Épico", "fr": "Épique", "it": "Epico", "pt": "Épico", "ja": "エピック", "ko": "에픽", "pl": "Epicki", "nl": "Episch", "tr": "Epik"],
        "rarity.legendary": ["de": "Legendär", "en": "Legendary", "es": "Legendario", "fr": "Légendaire", "it": "Leggendario", "pt": "Lendário", "ja": "レジェンダリー", "ko": "전설", "pl": "Legendarny", "nl": "Legendarisch", "tr": "Efsanevi"],
        "rarity.mystic": ["de": "Mystisch", "en": "Mystic", "es": "Místico", "fr": "Mystique", "it": "Mistico", "pt": "Místico", "ja": "ミスティック", "ko": "신화", "pl": "Mityczny", "nl": "Mystiek", "tr": "Mistik"],
        "rarity.rare": ["de": "Selten", "en": "Rare", "es": "Raro", "fr": "Rare", "it": "Raro", "pt": "Raro", "ja": "レア", "ko": "희귀", "pl": "Rzadki", "nl": "Zeldzaam", "tr": "Nadir"],
        "ritual_config_headline": ["de": "Routine konfigurieren", "en": "Configure Routine", "es": "Configurar rutina", "fr": "Configurer la routine", "it": "Configura routine", "pt": "Configurar rotina", "ja": "ルーチンの構成", "ko": "루틴 구성", "pl": "Skonfiguruj rutynę", "nl": "Routine Configureren", "tr": "Rutini Yapılandır"],
        "shop.cheatday.confirm": ["de": "Cheat Day aktivieren?", "en": "Activate Cheat Day?", "es": "¿Activar día de trampa?", "fr": "Activer le jour de triche ?", "it": "Attiva Cheat Day?", "pt": "Ativar Dia do Lixo?", "ja": "チートデイを有効にしますか？", "ko": "치트 데이 활성화?", "pl": "Aktywować Cheat Day?", "nl": "Cheat Day Activeren?", "tr": "Kaçamak Gününü Aktifleştir?"],
        "timeline.no_notification": ["de": "Keine Benachrichtigungen", "en": "No Notifications", "es": "Sin notificaciones", "fr": "Aucune notification", "it": "Nessuna notifica", "pt": "Sem notificações", "ja": "通知なし", "ko": "알림 없음", "pl": "Brak powiadomień", "nl": "Geen Meldingen", "tr": "Bildirim Yok"],
"""

with open("Localization/AppStrings.swift", "r") as f:
    content = f.read()

match = re.search(r'("stats\.score\.msg\.low": \[.*?\],)', content)
if match:
    new_content = content[:match.end()] + "\n" + new_keys + content[match.end():]
    with open("Localization/AppStrings.swift", "w") as f:
        f.write(new_content)
    print("Added all missing strings successfully!")
else:
    print("Could not find insertion point!")
