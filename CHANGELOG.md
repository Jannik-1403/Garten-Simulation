## 2026-08-18 16:47 - To-Do Unified View
- **UI/UX**: Die Detailansicht und die Bearbeiten-Ansicht für To-Dos wurden zu einer einzigen Ansicht zusammengefasst.
- **Aufräumarbeiten**: Das Info-Icon auf der rechten Seite der To-Do-Reihe wurde entfernt.
- **Erreichbarkeit**: Über das Kontextmenü (langes Drücken) gibt es nun den Eintrag "Ansehen & Bearbeiten", der das große Textfeld öffnet.


- **UI/UX**: Für To-Dos mit sehr langen Texten wurde eine Detailansicht (`TodoDetailSheet`) hinzugefügt.
- **Erreichbarkeit**: Die Detailansicht lässt sich über einen neuen Info-Button in der To-Do-Zeile oder über das Kontextmenü (Long Press) aufrufen, ohne das To-Do versehentlich als erledigt zu markieren.
- **Lokalisierung**: Die neuen Texte wurden in alle 15 Sprachen übersetzt (100%).

## 2026-08-18 10:00 - Localization 100% Fixes
- **Übersetzungen**: Alle verbleibenden hartkodierten Texte im Code wurden identifiziert und durch lokalisierte Strings ersetzt.
- **Auto-Translation**: Ein Skript wurde eingesetzt, um fehlende Keys in allen 15 Sprachen (über 270 fehlende Übersetzungen) automatisch mit deep-translator zu übersetzen, um eine 100%ige Abdeckung im String Catalog zu erzielen.
- **Bugfix**: Einzelner Fallback-Übersetzungsfehler bei Apple Health für Traditionelles Chinesisch (zh-TW) wurde korrigiert.

## 2026-08-17 10:44 - Weekly Goal Retroactive Points Fix
- **Ziele (Wochenziel)**: Wenn ein Wochenziel neu erstellt oder aktualisiert wird, werden bereits abgeschlossene Gewohnheiten (aus der aktuellen Woche) nun rückwirkend angerechnet und generieren entsprechende Punkte.

## 2026-08-15 17:45 - App Tour Fix
- **App Tour**: Veraltete Tour-Schritte (Streak und XP 90-Tage Challenge) für die Pflanzendetail-Ansicht gelöscht.
- **Pflanze Gießen**: Text für die Bewässerung-Erklärung ("Drag & Drop") wurde auf den neuen Fortschrittsbalken ("Slider nach rechts schieben") aktualisiert.

## 2026-08-15 17:36 - App Tour Update
- **App Tour**: Die interaktive Tour führt nun auch durch die neue To-do-Seite.
- **Pflanze Detail**: Neue Ankerpunkte für To-Dos, Notizen, Timer und Apple Health in der Pflanzendetail-Ansicht hinzugefügt.
- **Übersetzungen**: Neue Tour-Beschreibungen wurden in alle Projektsprachen übersetzt.

## 2026-08-15 17:31 - To-Do Sortierung
- **To-Do Liste**: Abgeschlossene To-Dos werden nun automatisch nach unten sortiert, um offene Aufgaben besser in den Fokus zu rücken.

## 2026-07-29 21:03 - Goal UI 3D Fixes
- **Onboarding Fix**: Eigenes Ziel kann nun über ein Textfeld korrekt erstellt werden, und der Weiter-Schritt wird nach Auswahl automatisch getriggert.
- **3D Design System**: Alle Goal-Elemente (Onboarding, Tracker, Shop-Link, Insights) nutzen nun einheitlich die Item3DButton und die neue Item3DText Komponente (ähnlich zum Glücksrad) für einen plastischeren Look.

## 2026-07-29 20:34 - Ziel-System (Goals) UI Integration
- **Onboarding**: `GoalOnboardingView` ersetzt die alte Ziele-Auswahl und erzwingt das Setzen eines Jahresziels (Progressive Disclosure).
- **Garten (Quest Tracker)**: `MonthlyGoalBannerView` wurde dezent über dem Garten integriert, um den Fokus des Monats zu zeigen.
- **Profil**: `GoalInsightsView` zeigt jetzt eine Rangliste der Gewohnheiten, die im Monat am meisten Punkte gebracht haben.
- **Shop**: Nach der Erstellung einer Pflanze fragt `GoalLinkView` nun nach der Gewichtung der Gewohnheit für das Jahresziel (20 Pkt vs 5 Pkt vs 0 Pkt).

## 2026-07-29 19:10 - Ziel-System (Goals) Modelle
- **GoalModels.swift**: Neue Datenstrukturen (`GoalModel`, `GoalHabitLink`, `GoalLog`, `GoalTemplate`) für Jahres- und Monatsziele hinzugefügt.
- **GoalStore.swift**: Separater Store zur sauberen Verwaltung der Ziele und Berechnung der Punkte basierend auf Habit-Gewichtungen (20 Pkt vs 5 Pkt).
- **GardenStore Integration**: `giessen`-Funktion ruft nun den `GoalStore` auf, um Habit-Abschlüsse ins Ziel-System zu übertragen.
- **Localizations**: Neue Übersetzungen für Goal-Typen und -Gewichtungen in allen Sprachen ergänzt.

- Feat: Focus Session Timer nutzt jetzt den 'Laser Fokus' Modus (nur das aktuelle To-Do wird riesig angezeigt mit Next-Pfeil)
- Style: Streak-Icon in der Detailansicht verwendet nun die Originalfarben und einen transparenten Hintergrund

- Style: 3D-Flammen Button durch schlichte horizontale Streak-Anzeige (Zahl + Icon) ersetzt

- Style: FlameStreakButton Design aktualisiert (weiße Oberfläche, orange-roter Schatten, Template Image statt Maskierung)

- Feat: Long-Press Gießen auf der Pflanzenkarte implementiert
- Fix: FlameStreakButton nutzt nun das echte Streak-Icon als Maske statt eines generischen Pfads

## [2026-07-24] - Zeit-Block Fixes
- **App-Auswahl Filter**: Apps, die bereits in "Immer blockierte Apps" oder "Apps mit Zeitlimit" ausgewählt sind, werden nun automatisch aus der Auswahl für den Zeit-Block entfernt.
- **Entsperren im Zeit-Block**: Der "Entsperren"-Button ist nun während eines aktiven Zeit-Blocks klickbar. Über den "Walk of Shame" kann der Text abgetippt werden, um den Zeit-Block vorzeitig zu beenden.

# Changelog

## 2026-07-28: Phase 4.2 – HealthChartView v2 & Bugfixes
- **Grüne gestrichelte Ziellinie:** Das Tagesziel wird als grüne, gestrichelte Linie oben im Diagramm angezeigt.
- **Ø Woche-Durchschnitt:** Neue Stats-Spalte zeigt den Wochendurchschnitt. Zeigt "k.A. / < 3 Tage" wenn noch nicht genug Daten vorhanden (Mindestens 3 Tage).
- **Grauer Durchschnitts-Punkt:** Im Diagramm erscheint ein grauer Punkt mit Label "Ø Woche" für den Wochendurchschnitt.
- **Fortschritt in %:** "Heute"-Anzeige zeigt jetzt Prozentzahl des Tagesziels (z.B. 72%) statt absolute Zahl.
- **Kein Off-Track-Subtitle mehr:** Dynamischer Vergleichs-Text entfernt.
- **Speicher-Bug Fix:** Health-Target TextField speichert jetzt korrekt via `.onSubmit`, sodass der Wert beim Schließen der Tastatur gespeichert wird.
- **fetchWeeklyAverage:** Neue Funktion in `HealthManager` berechnet den tagesgenauen Durchschnitt der letzten 7 Tage per `HKStatisticsCollectionQuery`.

## 2026-07-28: Phase 4.1 – Apple Health Redesign & Bugfixes
- **HealthChartView Redesign:** Komplett neues Diagramm im Apple Fitness-Stil – zeigt Metriken (Schritte, Wasser, Schlaf etc.) mit Icon, Titel, dynamischem Untertitel (Ziel erreicht / weiter so), zwei großen Zahlenwerten (Heute + Ziel), kumulativer Linie in Orange und einer grauen Ziellinie. Eingebettet im Item3D-Container.
- **Sync-Bug Fix:** Existierende Pflanzen mit dem Wort „Joggen/Laufen/Schritt/Spazieren" werden beim Laden automatisch von `.running` auf `.steps` migriert, sodass Apple Health Daten korrekt übertragen werden.
- **Settings – Apple Health Status:** In den Einstellungen zeigt der Apple Health Eintrag jetzt einen Verbindungsstatus (grüner Punkt „Verbunden" / roter Punkt „Aus") direkt neben dem Chevron.
- **Lokalisierung:** Alle neuen UI-Strings (Chart-Titel, Einheiten, Statusanzeigen) vollständig in 7 Sprachen übersetzt (DE, EN, ES, FR, RU, TR, ZH-HANS).

## 2026-07-28: Phase 4 Fixes
- **Chart X-Axis Format:** Diagrammachse angepasst, sodass nur noch die Stunden-Zahlen (06, 12, 18) ohne 'Uhr' angezeigt werden (bzw. auf Englisch mit 'AM/PM').
- **Chart Y-Axis:** Y-Achsenbeschriftung auf die rechte Seite (`trailing`) verschoben.
- **Joggen -> Schritte:** Die Automatik-Zuordnung in `HabitModel.swift` für 'Joggen' (und ähnliche Begriffe wie Laufen, Spazieren) liest nun korrekt die Schritte (.steps) aus Apple Health aus, anstatt nach expliziten Lauf-Workouts zu suchen.

## 2026-07-28: Phase 4 - Apple Health Integration & Line Chart
- **Apple Health Hourly Data:** `HealthManager` erweitert, um historische Daten (stündlich) abzurufen, um Apple Health-Daten detailliert anzuzeigen.
- **Auto-Watering:** Die App prüft beim Öffnen der Pflanze, ob das Health-Ziel (z. B. 10.000 Schritte) erreicht wurde. Falls ja, wird die Pflanze automatisch gegossen (`checkHealthTargets`).
- **Health Progress Chart:** Ein neues Liniendiagramm (`HealthChartView`) in `PflanzeDetailSheet` hinzugefügt, das den Tagesverlauf aus Apple Health visualisiert, sofern die Pflanze mit Apple Health gekoppelt ist.
- **Lokalisierung:** Übersetzungen für `health.chart.title` und `health.chart.target` in `Localizable.xcstrings` hinzugefügt (100% Abdeckung in allen Sprachen).

## 2026-07-22 (Widget Localization Update)
- **Localization:** 26 alte Strings aus dem Widget in den zentralen iOS String Catalog (Localizable.xcstrings) migriert.
- **Translation:** Diese Strings wurden automatisch in alle 16 Projektsprachen übersetzt (150 neue Einträge).
- **Cleanup:** Veraltete `.lproj` Ordner und `Localizable.strings` aus dem GartenWidget gelöscht, sodass die App jetzt exklusiv nur noch ein einheitliches System verwendet.


## 2026-07-22
- **Localization:** Systematische Überprüfung der gesamten App-Dateien durchgeführt.
- **Fix:** Verbliebene hardcodierte Strings in verschiedenen Views (SplashScreen, PfadTagDetailView, ScreenTimeSuggestionsView, SeltenheitsBadge, ProfilComponents, DuolingoButton) durch native `String(localized:)` ersetzt.
- **Translation:** `Localizable.xcstrings` um neue Keys erweitert und vollautomatisch (100% Abdeckung) in alle 16 Projektsprachen übersetzt.

- Fixed formatting warnings for percentages in Localizable.xcstrings
- Cleaned up stale translation keys
- Ensured 100% translation coverage across all supported languages

- Neues Feature: Onboarding-Screen zur Benachrichtigungsabfrage hinzugefügt. (Bevor die rechtlichen Erklärungen akzeptiert werden, erscheint jetzt eine Abfrage im Apple-Stil, ob man Push-Benachrichtigungen erlauben möchte).

- Bugfix: Design des Notification-Mock-Dialogs im Onboarding korrigiert (Höhe der Buttons angepasst, Name zu 'Grovy' (ohne Anführungszeichen) geändert, 'Nicht erlauben' in schwarz-weiß).

- Bugfix: Mock-Notification-Dialog im Onboarding exakt in der Bildschirmmitte positioniert, sodass der echte Apple-Dialog nahtlos darüber erscheint.

- Bugfix: Weiter-Button im Notification-Onboarding erst sichtbar, nachdem eine Auswahl getroffen wurde. Animation vom Pfeil entfernt. Benachrichtigungs-Abfrage beim Erstellen eines Timers in der Pflanzen-Detail-Ansicht entfernt (wird nun exklusiv im Onboarding abgefragt).

- Design: Mock-Notification-Dialog exakt an das hochgeladene Screenshot-Design angepasst (weißer Kasten mit stark abgerundeten Ecken, linksbündiger Text, Pille-förmige graue Buttons für Erlauben/Ablehnen).

- Bugfix: Mock-Notification-Dialog schmaler gemacht, Pfeil unten als fetten (3D-ähnlichen) großen Pfeil (arrowshape.up.fill) angepasst. Alle Texte des Mock-Dialogs in 15 Sprachen übersetzt.

- Bugfix: Pfeil im Mock-Notification-Dialog im Onboarding durch den 3D-Button ('Item3DButton') ersetzt (wie im Glücksrad), inklusive des harten 3D-Schattens.

- Feature: Neues 'Screen Time' (Bildschirmzeit) Onboarding-Popup eingebaut, das exakt so aussieht wie das für Benachrichtigungen.
- Bugfix: Im Notification-Onboarding wird das Pfeil-Icon jetzt über einen ViewBuilder sicher als 'arrow.up' gerendert.
- Refactoring: Alte, verstreute Berechtigungsabfragen für Screen Time (in Focus, Routinen, etc.) gelöscht, da sie nun zentral im Onboarding stattfinden.
- Feature: In den Einstellungen wird jetzt bei 'Bildschirmzeit' ein 'Ein'/'Aus' Indikator angezeigt.

- Bugfix: Im Screen Time Mock-Dialog die Buttons und Texte exakt an das echte iOS-Design angepasst ('Weiter' links in grau, 'Nicht erlauben' rechts in blau).

- Design: Den Pfeil-Button im Onboarding durch ein echtes Pfeil-Icon ('arrowshape.up.fill') mit hartem Schatten ersetzt und den Abstand zum Button korrigiert, damit er exakt auf der richtigen Höhe ist.

- Animation: Der Pfeil im Onboarding hüpft nun flüssig auf und ab, um den Benutzer auf den Button aufmerksam zu machen.
- Design: Die Höhe (Spacing/Padding) der Mock-Dialoge wurde noch etwas reduziert (enger zusammengezogen), damit sie wirklich exakt wie die echten nativen Apple-Dialoge aussehen.
- Assessment detailed analysis implementation (Reality Check & Roadmap)
- Assessments (Dynamic Insights): Ersetzt statische Empfehlungen mit datenbasierten Insights, generiert aus User-Verhalten (Habits, Screen Time, 90 Day Challenge) sowie Einführung eines 'Reality Checks' (die harte Wahrheit) pro Kategorie.
- Added highly detailed, premium assessment analysis UI that breaks down the user's specific strengths, weaknesses, pitfalls, and benchmark comparison based on their raw scores.
- Localized and expanded all assessment insight texts in Localizable.xcstrings.

- **Assessment UI Fixes & Lokalisierung**:
  - Design-Update für die Detailansicht ("Was man verbessern kann" & DataSourceSheet) auf das einheitliche 3D-Card-Design angepasst (scoreCardStyle).
  - Alle hartkodierten deutschen Texte aus `AssessmentResult+Detailed.swift` in `Localizable.xcstrings` ausgelagert (100% Abdeckung für alle 16 Sprachen), um Sprachfehler in der Detailansicht zu beheben.
  - Fehler im Übersetzungs-Script bei un-escapeten Anführungszeichen repariert.

- **Assessment UI Bereinigung**:
  - `DataSourceSheet` (die Detailansicht) komplett gelöscht, da sie vom Nutzer als unnötig empfunden wurde.
  - Abstand (Padding) zur "Was man verbessern kann" Ansicht hinzugefügt, damit diese nicht mehr direkt am Bildschirmrand klebt.

- **Individuelle Assessment-Icons**:
  - Alle generischen iOS Icons im Bereich "Was man verbessern kann" (Insights) wurden durch maßgeschneiderte Grafiken aus dem Asset-Katalog ersetzt (z. B. `Warndreieck`, `Heart death`, `Timer empty`, etc.).
  - Die neuen Grafiken werden nun doppelt so groß dargestellt (80x80), um den transparenten Hintergrund auszugleichen. Der Text verschiebt sich dabei nicht, da der Rahmen (ZStack) fest auf 40x40 verankert bleibt und das Bild an den Ecken sauber darüber lappt.

- **Icon Layout Fixes**:
  - Den runden, farbigen Hintergrund (`Circle().fill(...)`) bei allen Icons in der Detailansicht ("Was man verbessern kann") komplett entfernt.
  - Die Icon-Größe wieder auf das normale `40x40` Format zurückgesetzt, da die SVG-Vektorgrafiken bei der verdoppelten Größe das Layout gesprengt haben.

- **Icon Scale Fix**:
  - Das `Goal` Icon (für die 90-Tage Challenge) wird nun mittels `.scaleEffect(2.2)` um den Faktor 2,2 vergrößert, ohne das restliche Layout oder den danebenstehenden Text zu verschieben.

- **Interaktiver Fokus-Button in Assessments**:
  - Der "Fokus-Modus testen" Button (in den Verbesserungstipps) ist nun ein echter animierter 3D-Button (`DuolingoButtonStyle`), der beim Drücken grafisch reagiert.
  - Wenn man den Button drückt, öffnet sich direkt das individuelle Setup für eine Fokus-Session (Generic Focus Timer), aus der heraus man direkt eine Session starten kann.

- 100% Übersetzungsabdeckung in allen Sprachen hergestellt.
- Bugfix: Zeitzonenwechsel führen nicht mehr zu unfairem Streak-Verlust (Grace Period basierend auf absoluter Zeit eingeführt).
- Bugfix: Streak-Logik erfordert nun wieder strikt das Abhaken pro Kalendertag (48h-Toleranz entfernt), berücksichtigt aber weiterhin fehlerfrei Zeitzonenwechsel.
- Bugfix: Bildschirmzeit-Gewohnheit wird nun nicht mehr automatisch gegossen, wenn noch keine Limits in den Einstellungen definiert wurden.
- Bugfix: Mehrere SwiftUI ForEach-Warnungen in der StreakView behoben, die durch nicht-eindeutige IDs entstanden sind.
- Feature: Die automatische Erledigung der Bildschirmzeit-Gewohnheit wurde komplett entfernt. Zudem wurde die Bildschirmzeit-Pflanze (Aloe Vera) aus dem Shop entfernt, da sie automatisch verwaltet wird.
- Bugfix: Aloe Vera (Bildschirmzeit-Pflanze) ist wieder regulär im Shop verfügbar.
- Bugfix: Einmaliger Reset des Bildschirmzeit-Streaks auf 0 für Nutzer, bei denen der Streak durch den alten Bug fälschlicherweise auf 1 gesetzt wurde.
- Behoben: Unübersetzte Lokalisierungsschlüssel für 'Ungenügende Daten' in der Wochenbericht-Analyse in allen Sprachen behoben
- Fixed "Appicon" typo in Profile components to correctly load the AppIcon
- Fixed ImageRenderer alpha channel warning in share functions by setting renderer.isOpaque = true
- Fixed missing AppIcon by using Splash_Screenicon image asset directly
- Fixed Streak Freeze bug where purchased freezes were immediately wasted upon app restart if the current streak was already broken.
- Updated Watering Stats list design with 3D rank buttons and neo-brutalism individual cards
- Fixed a critical bug where Streak Freezes and Best Streak were wiped out on app startup
- Fixed a gesture conflict where Bad Habit cards were sometimes unresponsive to taps
- Fixed a performance issue where buying or tapping an item could trigger infinite layout loops
- Added debounce locks to interactive cards and purchase buttons to prevent double-tap issues and UI loops
- SettingsView: Bildschirmzeit-Integration aufgeteilt. Der Status-Indikator ist nun unter 'Allgemein' > 'Bildschirmzeit' zu finden und öffnet die iOS-Einstellungen.
- SettingsView: Bildschirmzeit-Status aktualisiert sich nun automatisch beim Zurückkehren in die App.
- SettingsView: Haptisches Feedback ist nun permanent aktiviert und der Schalter wurde entfernt.
- SettingsView: App-Sprache wurde in die 'Allgemein'-Sektion verschoben und die 'Personalisierung'-Sektion wurde entfernt.
- SettingsView: Bildschirmzeit-Status wird nun auch beim App-Start und beim Reaktivieren der App explizit abgerufen, um Anzeigefehler zu beheben.
- Fix: Manueller Slider für Apple Health gekoppelte Tracker korrigiert, sodass er nun den korrekten Startwert und das richtige Limit anzeigt.
- Fix: Slider wird nicht mehr gesperrt, wenn das Ziel erreicht wurde, sodass man den Wert korrigieren kann.
- Feature: +/- Buttons (Stepper UI) zum Tracker hinzugefügt, damit man den Wert auch ganz leicht und exakt anpassen kann, ohne den Slider zu nutzen.
- Fix: Plus/Minus Buttons wieder entfernt und durch einen 100% stufenlosen, ungesperrten Slider ersetzt (auf Wunsch des Nutzers).
- Bugfix: Der manuelle Schieberegler (Tracker) bei einer Apple Health Verknüpfung funktioniert nun exakt wie der normale manuelle Tracker und ist nicht mehr gesperrt.
- Fix: Slider ist jetzt nicht mehr gesperrt, nachdem die Pflanze bewässert wurde.

- **Kalender/Streak Bugfix**:
  - Ein schwerer Fehler wurde behoben, bei dem Pflanzen Lebenspunkte verloren oder der Streak zurückgesetzt wurde, wenn Tage nicht im Kalender (Schedule) aktiv waren (z. B. wenn Donnerstag deaktiviert war). Die App pausiert nun den Gesundheitsverlust und das Streak-Tracking an diesen freien Tagen komplett, sodass am nächsten aktiven Tag alles nahtlos weiterläuft.

- **Revert Zeitzonen-Streak**:
  - Die fehlerhafte "Zeitzonen"-Toleranzlogik (die den Streak in Stunden statt vollen Tagen gemessen hat) wurde komplett rückgängig gemacht, da sie das reguläre Zählen der Streak-Tage völlig durcheinandergebracht hat. Die Streak-Berechnung funktioniert jetzt wieder wie früher strikt Tag für Tag (plus der neuen Kalender-Pausen-Logik von vorhin).

- **Feature**: Intelligente Gewohnheitsanalyse mit Standardabweichung (Consistency Score) & Prioritäts-Gewichtung (Streak & Seltenheit). Neue kontextbasierte Texte für Szenarien (Variable Leistung, Stabiler Aufbau, Der Profi) wurden hinzugefügt.

- **Fix**: UI-Layout im Wochenbericht korrigiert, damit der Text vollständig lesbar ist (TabView entfernt). Intelligente Standardabweichung auch für einzelne Gewohnheiten im Habit Verlauf hinzugefügt.

- **Fix**: Analyse-Logik (Standardabweichung) wurde korrigiert: Sie kombiniert nun sowohl Fokuszeit als auch Gewohnheiten und verwendet völlig neue, stringente Textblöcke ohne veraltete Text-Bausteine aus vorherigen Versionen.

- **Feature**: Wochenbericht-Analyse komplett durch dynamischen Tipp-Generator ersetzt (Scannt nach Lücken, Uhrzeiten und spezifischen Habits wie 'Früh aufstehen').

- **Fixes**: UI-Bug behoben, durch den gestorbene Pflanzen keinen durchgestrichenen Namen hatten. Shop-Bug behoben, bei dem entfernte Pflanzen weiterhin im Shop als 'Im Besitz' angezeigt wurden und gestorbene Pflanzen unerlaubt verkauft werden konnten. Logik-Fehler bei der 90-Tage-Challenge behoben (Anfänger war aufgrund eines Umlaut-Fehlers automatisch so schwer wie Experte).
- 90-Tage Challenge: Wochentage aus den Titeln entfernt und über 500 hart kodierte Strings in 16 Sprachen lokalisiert.
- Bugfix: Syntaxfehler in der HabitProgressionStrategy.swift für lokalisierte Strings (Tage 1, 4, 6 in Lauf-Progression) behoben.
- Lokalisierung der Strength-Progression hinzugefügt und festcodierte Wochentage aus den Titeln entfernt. Volle String Catalog Unterstützung in allen Sprachen (100% Übersetzungsabdeckung).
- Fehlerhafte String-Interpolationen (\(...)) in allen Sprachen der Localizable.xcstrings repariert.
- Abgeschnittene Texte in den Localizable.xcstrings der Running-Challenge wiederhergestellt.
- Bug in der Swift String-Interpolation für Lauf-Distanzen behoben (zeigte 'String(format:...)' an).
- Fehlerhaft gespeicherte Todos in der lokalen Datenbank werden nun bei Aufruf automatisch repariert.
- Fehlerhaft lokalisierte Workout-Variablen (wie 'Strict Push-ups') in der Datenbank gelöst und alle Workout-Pläne für korrekte Fallbacks repariert.
- Bugfix: Live Activity öffnet jetzt direkt den laufenden Fokus-Timer und nicht mehr die Gewohnheits-Detailansicht.
- Bugfix: Abgehakte Unterziele/Aufwärm-Phasen im Fokus-Timer werden jetzt sofort gespeichert, sodass der Fortschritt auch nach Schließen und Wiederöffnen der App erhalten bleibt.
- Level-Up Pop-Up zeigt nun dynamisch den Namen der Gewohnheit an (z. B. 'Du hast Krafttraining schon lange gemeistert...').

- Fix: Samen können nun im Shop gekauft werden, da die Schwierigkeits-Auswahl-Abfrage übersprungen wird.
- Fix: Preis der Samen auf den Standardpreis für Pflanzen (800) korrigiert.
- Update: Beschreibung der Samen verdeutlicht nun, dass damit eigene Gewohnheiten auf der Profilseite erstellt werden können.

- Bugfix: Streak-Kalender zeigt nun die echten, lokalisierten Monatsnamen statt Platzhalter an. Die Punkte-Raster (Tage) sind nun konsistent auf 42 Zellen (6 Wochen) fixiert, sodass alle Monate optisch einheitlich dargestellt werden und die Anzahl der Monatstage (28, 29, 30, 31) automatisch korrekt berechnet wird.
- Fixed 99% string translation coverage in Xcode String Catalog by automatically translating 8 missing keys to all 16 supported languages.
- Fixed Localizable.xcstrings warnings by converting hardcoded percentages to dynamic format specifiers (%@) across Swift code and string catalog.
- Deleted 11 stale translation keys that were no longer referenced in the source code.
- Fix: Emojis von selbst erstellten Pflanzen werden in der Detailansicht und im Power-Up Picker nun korrekt angezeigt

- **ScreenTime Schutzmodus hinzugefügt:** Ein neuer "Schutzmodus" wurde für Pro-Nutzer eingeführt. Dieser verhindert das Herunterladen von VPN-Apps aus dem App Store, blockiert das Löschen von Apps und sperrt Änderungen am Account, um die Umgehung der Bildschirmzeit-Beschränkungen zu stoppen.
- Fix: Benutzerdefinierte Pflanzen-Icons (Assets wie 'Weizenfeld') werden nun in der Detailansicht korrekt als Bild und nicht mehr fehlerhaft als abgeschnittener Text gerendert.

- **Wasserdichter Erwachsenen-Filter:** Das UI für den Schutzmodus wurde durch einen einheitlichen "Erwachsenen Filter aktivieren" 3D-Button ersetzt. Dieser aktiviert mit einem Klick den Safari-Pornofilter sowie die App-Store-Sperre gleichzeitig.

- **Schutzmodus UI Cleanup:** Die Textwüste im ScreenTime Einstellungen View wurde in prägnante Bullet-Points aufgebrochen und die aggressiven Farben wurden durch sauberere Standard-Farben ersetzt.

- **UI Polish:** Emojis im Schutzmodus durch SF Symbols ersetzt und den Kontrast des "Deaktivieren"-Buttons durch Verwendung von Rot erhöht.

- **Architekturwechsel (Safari Filter):** Die harte "Strict Protection" (App Store & App Lösch-Sperre) wurde komplett entfernt, um App Store Review Risiken zu minimieren. Das UI wurde zu einem reinen, ehrlichen "Safari Erwachsenen-Filter" umgebaut.

## 2026-07-23 UI Fixes & System Filter
- Added NetworkExtension target for system-wide Adult Filter
- Integrated DNS Filter directly into ScreenTimeManager
- Fixed UI bug: 'Deactivate Protection' button now uses clear orange styling
- Replaced all Emojis with native SF Symbols
- Added dynamic DisclosureGroup list for blocked apps with counter
- Scaled WalkOfShame text difficulty based on level (1 to 4)
- Added 100% translation coverage for all new UI strings


### UI Hierarchy Refactoring
- **ScreenTimeSettingsView** redesigned with clear 4-level hierarchy.
- Replaced flat text titles with 3D typography (similar to lucky wheel).
- Moved 'Block-Zeitplan' (Schedule) to Layer 2 and 'Immer blockiert' (Permanent Block) to Layer 4.
- Separated Unlock/Activate buttons from the main titles into their own visual hierarchy.
- Added expandable `DisclosureGroup` with count for Schedule Blocked Apps.
- Automatically translated all new UI strings in `Localizable.xcstrings`.

### UI Improvements
- Fixed `ScreenTimeSettingsView` duplicate level names.
- Changed 3D title text color to neutral `Color.primary` for better contrast with green/orange buttons.
- Hid long descriptions behind an interactive info (i) button for each layer.
- Removed outdated info text at the bottom of the screen.

## [Unreleased]
- **Bugfix:** Datenmigration zu App-Groups repariert (`SharedUserDefaults`). Alte lokale Speicherstände werden nun vollständig in die neue App-Group übertragen, sodass kein Fortschritt mehr verloren geht.
- **Feature:** Automatisches Backup-System eingebaut. Einstellbar in den Einstellungen (Täglich, Wöchentlich, Monatlich, bei Speicherung).
- **Cleanup:** Den nicht funktionierenden Button "Daten vor Update wiederherstellen" wieder entfernt.
- **UI Polish:** Das automatische Backup-Menü wurde komplett überarbeitet. Es nutzt nun ein modernes Liquid Glass Design, das Intervall-Auswahlmenü wurde integriert und die Backup-Einträge nutzen das einheitliche 3D-Button-Design der App. Die Backup-Namen wurden vereinfacht.
- **Feature:** Home Screen Quick Actions (App Shortcuts) mit Deep Linking (Fokus Timer, Bildschirmzeit, App bewerten, Warnung beim Löschen) hinzugefügt.
- Lokalisierung: Fehlende Strings (ca. 1%) wurden übersetzt, alle Projektsprachen sind nun zu 100% abgedeckt.
- Lokalisierung: Ungenutzte Keys aus Localizable.xcstrings entfernt.
- Lokalisierung: Xcode-Warnungen bezüglich Prozentzeichen (%%) durch Nutzung von typografischen Prozentzeichen (％) bzw. korrekten Platzhaltern (%@) behoben.
- Aktualisierte Paywall-Texte mit klaren Benefits für Apple Health und Kalender-Sync inkl. Häkchen.
- Alle empfohlenen Tools / Werbeanzeigen aus der App entfernt (PartnerAppBoost und HabitBoostCard gelöscht)

- Fixed custom focus timer recovery and Live Activity logic. Tasks are now grouped into open and completed sections.

## 2026-07-27
- Fehlende Übersetzungen (Chinesisch und 15 weitere Sprachen) für Paywall, Widgets und ScreenTime in den String Catalog hinzugefügt, sodass 100% Übersetzungsabdeckung erreicht wurde.

## 2026-07-27
- Fix: Compilerfehler in `FocusSessionView` behoben (Falsch gesetzte Klammern und `.padding`-Modifier).

## 2026-07-27
- Fix: Hardcodierte Texte bei Backup, Export (Dateinamen) und in der Wochenbericht-Statistik ("0 Minuten", "Tipp") durch lokalisierte Strings ersetzt und in alle 15 Sprachen übersetzt.


## 2026-07-27
- Fix: Datum und Uhrzeit bei automatischen Backups nutzen nun die exakte `preferredLocalizations` der App (anstatt der iOS-Region), damit Daten korrekt auf Chinesisch etc. formatiert werden.

- Wasser-Widget bearbeitbar (Zeitraum) entfernt, Hintergrund weiterhin wählbar.
- Fehlende Widget-Übersetzungen in 16 Sprachen (inklusive pt-BR) ergänzt.

- Widget-Lokalisierung repariert: Sprache wird nun korrekt in den Widgets angewandt (unabhängig von der Systemsprache).

- Widgets passen sich nun immer an die Systemsprache an und fallen auf Englisch (statt Deutsch) zurück, falls die Systemsprache nicht unterstützt wird.

- Fehlendes Localizable.xcstrings zur Widget-Erweiterung hinzugefügt, damit das Widget die Übersetzungen überhaupt finden kann.

- Hardcodierten 'Hintergrund' Text im Widget-Bearbeitungsmenü behoben. Dieser wird nun ebenfalls über das Lokalisierungssystem übersetzt.

### Phase 2 & 3: Accordions for Todos/Notes, Focus Session Laser-Focus, Plant-Specific Todos (28.07.2026)
- **Phase 3**: Die Notizen und die neuen pflanzenspezifischen To-Dos (Goals) sind in übersichtlichen Accordions (DisclosureGroups) im PlantDetailSheet integriert, um Platz zu sparen.
- **Phase 3**: Im PlantDetailSheet kann man nun To-Dos spezifisch für eine Pflanze anlegen und bearbeiten.
- **Phase 2**: Startet man nun aus einer Pflanze heraus den Fokus-Modus, so werden deren To-Dos automatisch in den "Jetzt Starten" Wizard geladen und können fokussiert abgearbeitet werden.
- Gießen erfolgt auf dem Homescreen nun per Long-Press auf den 3D-Button.

### Phase 4: UI Cleanup & Todos Tab (28.07.2026)
- **UI Cleanup**: Das `PflanzeDetailSheet` wurde radikal aufgeräumt. Der 3D-Button inklusive Fortschrittsring wurde komplett entfernt.
- **Title Update**: Die Kategorie (z. B. "Healthy Cooking") ist jetzt der einzige große Haupttitel der Seite.
- **Neuer Tab**: Ein komplett neuer "To-Dos" Tab wurde der Navigation hinzugefügt (zwischen Routine und Shop).
- **Zentrale To-Do Verwaltung**: Im neuen Tab sieht man alle ausstehenden To-Dos gruppiert nach Pflanze/Gewohnheit, kann neue To-Dos hinzufügen und einer beliebigen Pflanze zuordnen.

### Phase 5: UI Refinements & 3D Buttons (28.07.2026)
- **Detailansicht**: Der Text-Titel ganz oben im `PflanzeDetailSheet` wurde komplett entfernt, um Platz zu sparen.
- **Streak als 3D Button**: Die Streak-Anzeige (Feuer-Icon + Zahl) ist jetzt in einem drückbaren `Item3DButton` (orange) untergebracht.
- **To-Dos als 3D Buttons**: Die flachen Checklisten-Rechtecke in der Detailansicht und im To-Do Tab wurden durch drückbare `Item3DButton`s ersetzt. Ein Tipp auf die gesamte Reihe hakt das To-Do nun elegant mit haptischem Feedback ab.
- **Kontextmenü für To-Dos**: Bearbeiten und Löschen von To-Dos erfolgt nun übersichtlicher über einen langen Druck (Context Menu) statt über einen kleinen Ellipsis-Button.

### UI Fixes: Perlen-Buttons & Farben (28.07.2026)
- **Todos Tab**: Der Plus-Button in der Navigation Bar und im leeren Zustand sind nun schwarz / neutral (.primary) statt grün.
- **Lokalisierung**: Hartkodierte Strings im `TodosTabView` wurden korrekt ins `Localizable.xcstrings` übertragen und für alle 15 Sprachen übersetzt.
- **Streak Pearl**: Der Streak-Button im `PflanzeDetailSheet` ist nun eine deutlich kleinere "Perle" (runder 3D-Button) mit der Zahl und dem Flammen-Icon.
- **Notizen & To-Do Hinzufügen**: Die riesigen Buttons wurden durch kleine, elegante runde Plus-Icons (`Item3DButton`) ersetzt.
- **Timer & Fokus-Session**: Beide Buttons am Ende des `PflanzeDetailSheet` sind keine großen Rechtecke mehr, sondern zwei gleichwertige, runde 3D-Icons nebeneinander.

### UI Overhaul & Proportionen (28.07.2026)
- **Fähigkeiten (Active Effects)**: Die aktiven Effekte wurden von ganz oben entfernt, da sie das Layout gestört haben. Sie sind nun elegant weiter unten in einem eigenen "Aktive Effekte"-Accordion zusammengefasst.
- **Plus-Buttons**: Das `+` Icon für To-Dos und Notizen befindet sich nun sauber aufgeräumt ganz rechts direkt im jeweiligen Header (Accordion-Titel).
- **Weiße To-Do Listen**: Die `Item3DButton` der To-Dos haben nun einen reinweißen Hintergrund für deutlicheren Kontrast und wurden etwas schmaler gemacht, um nicht so klobig zu wirken.
- **Timer Asset-Icons**: Anstelle der Standard-SF-Symbols verwenden der Timer und der Fokus-Timer nun die Custom Assets `"Timer full"` und `"Timer empty"`. Ihre Größe wurde leicht reduziert (54 statt 64), um die Proportionen harmonischer zu machen.

### UI Update Notizen & Item3DButton Höhe (28.07.2026)
- **Erinnerungs-Icon**: Der Timer-Button nutzt nun das korrekte "Erinnerung"-Asset.
- **Notizen als 3D-Button**: Genau wie bei den To-Dos ist nun auch jeder Notizen-Eintrag in einen sauberen, weißen `Item3DButton` eingebettet.
- **Dynamische Button-Höhe**: Der `Item3DButton` wurde komplett umgebaut, sodass rechteckige Buttons nun dynamisch so hoch werden, wie der Text es erfordert (statt alles abzuschneiden und einzuschnüren). Das bedeutet, To-Dos und Notizen haben nun den gewünschten **"mehr Platz"** und sehen viel besser proportioniert aus.

### UI-Korrekturen (28.07.2026)
- **Item3DButton**: Die dynamische Höhe wurde komplett rückgängig gemacht, um das alte Layout nicht zu stören. Die regulären 3D-Buttons sind nun wieder fest.
- **Listen in 3D-Containern**: Die To-Dos, Notizen und aktiven Effekte sind nun als Ganzes (die kompletten Accordions) in einem maßgeschneiderten, flexiblen 3D-Container verpackt, der sich perfekt mit der Liste ausdehnt und optisch exakt wie ein `Item3DButton` aussieht.
- **Timer Icon**: Das Icon "Erinnerung" im Timer-Button wurde wie gewünscht um das 2.5-fache vergrößert, ohne die Größe des 3D-Buttons selbst zu verändern.
- **Streak Lottie**: Der kreisrunde Streak-Button ganz oben wurde durch eine frei schwebende Lottie-Animation (`streak`) mit der Streak-Zahl direkt darunter ersetzt.

### UI-Feinschliff Details (28.07.2026)
- **Plus-Buttons als 3D-Buttons**: Die Plus-Icons für To-Dos und Notizen (oben rechts im jeweiligen Accordion-Header) sind nun saubere, kleine 3D-Buttons.
- **Erledigte To-Dos**: Wenn eine To-Do abgehakt (durchgestrichen) wird, färbt sich ihr Hintergrund nun komplett grün (`.gruenPrimary`). Das Häkchen und der Text wechseln dabei für einen perfekten Kontrast zu Weiß.
- **Streak Lottie Perfektion**: Die Streak-Anzeige ganz oben auf der Detailseite sieht nun 1:1 exakt so aus wie auf der Haupt-Streak-Seite (`StreakView`), inklusive der Lottie-Animation (`GameConstants.streakLottieURL`), der Schriftgröße und dem typischen orangenen Schatten!

## Multiple Daily Reminders & UI Refinements
- Streak Lottie vergrößert und den Abstand zur Zahl angepasst
- Timer Button durch eine aufklappbare "Daily Reminder" Liste ersetzt, passend zu den anderen Elementen (To-Dos, Notizen)
- Unterstützung für mehrere tägliche Erinnerungen pro Habit (Pflanze) hinzugefügt
- Localizable.xcstrings auf 100% Abdeckung für neue Strings überprüft

## [2026-07-29] Plant Detail – UX Improvements
- **Timer-Limit**: Plus-Button im "Daily Reminder"-Bereich wird ausgeblendet, sobald bereits ein Timer gesetzt ist (max. 1 Timer pro Pflanze)
- **Effekte-Sektion entfernt**: Der "Aktive Effekte"-Block wird nicht mehr in der Detailansicht angezeigt
- **Multi-Todo Sheet**: Beim Klick auf "+" im To-Dos-Bereich öffnet sich ein neues Sheet mit nummerierter Zeilen-Liste; mehrere To-Dos lassen sich auf einmal eingeben (Enter = nächste Zeile, X-Button zum Entfernen). Edit-Modus bleibt wie bisher.
- Neuer Lokalisierungskey `plant.detail.todo.add_another` in alle 15 Sprachen übersetzt

## [2026-07-29] Health Chart Improvements
- **Start bei 0**: Die kumulative Linie im Apple Health Diagramm (z.B. für Joggen oder Schritte) beginnt nun immer bei 0 an der y-Achse, anstatt direkt mit dem ersten Messwert hochzuspringen.
- **Rundung der aktuellen Zeit**: Der Marker für die aktuelle Zeit über dem Diagramm-Endpunkt rundet nun immer auf volle 30-Minuten-Schritte ab (z.B. 08:30 bei 08:45), anstatt auf die volle Stunde zurückzufallen.

## [2026-07-29] Bugfixes & UX Updates
- **Timer Edit Sheet Link**: Wenn man auf einen vorhandenen Timer in der Daily Reminder Liste klickt, öffnet sich nun korrekterweise die Timer Detailansicht (`TimerEditSheetView`), wie auch beim Erstellen (+ Button).
- **Timer Limit Restored**: Der Plus-Button für den Timer verschwindet wieder korrekt, sobald bereits ein Timer existiert, um mehrere Timer zu verhindern.
- **Aktive Effekte endgültig entfernt**: Die Sektion "Aktive Effekte" in der Pflanzendetail-Ansicht wurde nochmal aus dem Code entfernt, da sie durch einen vorherigen Merge-Konflikt fälschlicherweise wieder aufgetaucht war.
- **Timer Auto-Save**: Änderungen in der Timer Detailansicht (`TimerEditSheetView`) werden nun sofort automatisch gespeichert (`.onChange`), sodass man den Screen einfach schließen kann, ohne auf "Fertig" klicken zu müssen.
- **Einheitliche Timer-Reihe**: Wenn man für verschiedene Wochentage unterschiedliche Uhrzeiten einstellt, wird in der Daily Reminder Liste nicht mehr für jede Uhrzeit ein "neuer" Timer angezeigt. Stattdessen bleibt es bei einer einzigen Reihe, die dann als Zeit "Verschiedene Zeiten" (anstatt der konkreten Uhrzeit) anzeigt.
- **Lokalisierung**: Der neue Text "Verschiedene Zeiten" wurde mittels Script in alle 15 Sprachen übersetzt.
- **Streak Lottie entfernt**: Die große Streak-Animation mit der Flamme ganz oben auf der Pflanzendetail-Seite wurde auf Wunsch komplett entfernt.

- UI: Drag & Drop (Wassertropfen und X) aus der GartenView entfernt.
- UI: Long-Press-Mechanik (analog zur PflanzenCard) zur BadHabitCard hinzugefügt.
- UI: Alten 'Challenge nicht aktiviert'-Text aus der PflanzenCard entfernt.

- UI: Radar Ping Animation als visuellen Hint für Pflanzen und Bad Habits hinzugefügt.
- UI: Haptisches Feedback während des Long-Press-Vorgangs hinzugefügt.
- **Slide-to-Complete Mechanism**: The Long-Press interactions for plants and bad habits were replaced by a slide-to-complete interaction. Dragging the 3D button across the card fills the progress, and partial progress is persisted in the database.
- **Slide-to-Complete Fixes**: Resolved scrolling conflicts by using highPriorityGesture and a minimum drag distance of 25. The 3D button no longer shifts visually during a swipe, ensuring the progress bar behaves strictly as a background fill.
- **Health Auto-Progress & Percentage Text**: HealthKit linked metrics now auto-fill the card slider based on current progress. Added a dynamic percentage indicator at the edge of the slider that only appears while actively dragging.
- **Fix**: Resolved a crash in PflanzenCard caused by a missing HealthManager EnvironmentObject by switching to HealthManager.shared directly.
- **Fix**: Prozentzahl beim Bewegen des Sliders (PflanzenCard) entfernt.
- **Fix**: Manuelles Tracking für Apple Health-basierte Pflanzen aus den Models entfernt.
- **Feat**: Neuer Tagesverlauf-Chart (IntradayProgressChartView) für normale Gewohnheiten hinzugefügt, der den Fortschritt in Prozent über den Tag verteilt anzeigt.
- **Fix**: Manuelles Tracking für Apple Health Integration (Joggen) wiederhergestellt, grünes Ziel-Strichlinien-Verhalten korrigiert.
- **Fix**: UI der normalen Statistik (Health Cooking) exakt an Apple Health Statistik angepasst (identische Abstände, Layouts, 3D-Container).
- **Fix**: Eigener Tracker ('Great Tracker' / 'Tracker erstellen') wurde wie gewünscht vollständig entfernt.
- **Feature**: Apple Health Gewohnheiten (z.B. Joggen) können nun auf der Startseite mit dem Wischen-Slider manuell erhöht werden, sofern das manuelle Eintragen in den Einstellungen aktiviert ist.
- **Update**: Apple Health Gewohnheiten können nun direkt auf der Startseite durch vollständiges Wischen nach rechts abgehakt/gegossen werden, ohne dass dies die eigentliche Statistik verändert oder manuell in den Einstellungen aktiviert werden muss.
- **Fix**: Einheitliches Wischen für alle Gewohnheiten. Wischen verhält sich jetzt immer wie ein manuelles Setzen und bleibt auch bei Apple Health-Pflanzen dort stehen, wo man es losgelassen hat. Leere Historien-Statistiken für normale Gewohnheiten werden jetzt auch angezeigt.
- **Feature**: Abgeschlossene Gewohnheiten werden jetzt visuell deutlich als erledigt markiert (grüner Haken + Karte wird halbtransparent in den Hintergrund gedimmt).

- Implementiertes Prioritätssystem (Muss heute, Sollte bald, Kann warten) für Todos und Routinen.
- Hinzufügung der 'Heute im Fokus' Ansicht für priorisierte Aufgaben.
- Automatischer Fokus-Modus für Aufgaben mit höchster Priorität hinzugefügt.
- Prioritäts-Icons von Emojis auf farbige Ausrufezeichen (!, !!, !!!) geändert.
- 'Heute'-Ansicht hinzugefügt: Kombiniert To-Dos und Routinen, sortiert nach Priorität, mit neuem einheitlichem Karten-Design.
- **Shop & Pflanzenerstellung**: Das "Popper"-Popup zur Auswahl des Ziels wurde entfernt. Die Auswahl (20, 5, 0 Punkte) findet nun nahtlos direkt im Shop (unter der Pflanzen-Beschreibung) oder direkt im Erstellungs-Screen (über dem Erstellen-Button) statt.
- **UI-Architektur**: Neue, saubere Trennung der Zeithorizonte (Vision, Taktik, Operatives). 
  - 1-Jahresziel als dominante Vision im Profil integriert.
  - 1-Monatsziel als schlanker schwebender Banner auf der Garten-Seite umgestaltet.
  - 1-Wochenziel als Card mit Eingabefeld über der To-do-Liste hinzugefügt.
- **UI & Usability**: 
  - Die "Hinzufügen"-Buttons für Wochen- und Monatsziele wurden in einheitliche `Item3DButton` umgewandelt.
  - Bei der Pflanzen-Auswahl (Ziel-Beitrag: 20, 5, 0 Punkte) wurde ein Info-Icon hinzugefügt, das die Punkteverteilung erklärt. Die Texte wurden in alle 11 Sprachen übersetzt.
- **UX & Design Upgrade**: 
  - Alle Goal-Banner (Jahr, Monat, Woche) sind jetzt vollständig als einheitliche, interaktive `Item3DButton` umgesetzt.
  - Das Zielkonzept wurde global von "1-Jahresziel" auf das realistischere "5-Jahresziel" aktualisiert (inkl. aller 11 Übersetzungen).
  - Die Zielgewichte (20, 5, 0 Punkte) bei der Pflanzenerstellung/Shop nutzen jetzt farbcodierte 3D-Buttons (Grün, Orange, Rot) für intuitives visuelles Feedback.
- **Goal Tree (Stammbaum)**: Neue Vollbild-Ansicht `GoalTreeView` hinzugefügt, die die komplette Zielhierarchie visualisiert:
  - 5-Jahresziel (Wurzel) → Monatsziel → Wochenziel → Gewohnheiten (Fundament)
  - Jede Ebene ist ein interaktiver 3D-Button; leere Ebenen können direkt dort befüllt werden
  - Aufrufbar durch Tippen auf das 5-Jahresziel im Profil
  - 13 neue Strings in allen 11 Sprachen übersetzt

## 30. Juli 2026 - Pro-Version & Erwachsenen-Filter
- Feature-Flag für die Pro-Version aktiviert
- Erwachsenen-Filter als neues Pro-Feature zur Paywall hinzugefügt
- Aktivierung von Ebene 3 in den Bildschirmzeit-Einstellungen erfordert nun Pro-Status
- Tab Bar Text für Garten in 'Habits' umbenannt und in alle Projektsprachen übersetzt
- GartenStatsBar (Streak, Münzen, Leben) auf der Routine- und To-do-Seite hinzugefügt
- Navigation Bar auf Routinen- und To-do-Seite entfernt und durch Floating Action Buttons (FAB) am unteren Bildschirmrand ersetzt, damit die Statistiken ganz oben sind
- Tab-Bar: "Garden" wurde in allen Sprachen durch "Habits" (bzw. entsprechende Übersetzungen) ersetzt und das Icon zu "target" geändert.

## 30. Juli 2026 - Focus Timer Redesign
- Feature: Audioplayer im Fokus Timer durch einen kompakten, platzsparenden Button (oben rechts) ersetzt. Langes Drücken (Long Press) öffnet die Steuerung zum Wechseln der Sounds.
- Feature: Fokus Timer zeigt nun eine übersichtliche, scrollbare Liste der anstehenden Aufgaben an, statt nur einer einzigen riesigen Aufgabe.
- UI/UX: Im Vorbereitungsschritt wurde die Formulierung "Hauptziel" durch "Aufgabe" ersetzt, um die Hierarchie klarer zu machen, da das Session-Thema bereits vorgegeben ist.
- UI/UX (Update): Der kompakte Sound-Button oben rechts und die Listen-Elemente (Aufgaben) im Fokus Timer nutzen nun das einheitliche `Item3DButton`-Design der App. Der `Item3DContainerModifier` wurde dafür global verfügbar gemacht.
- 1%-Sprachen (Schwedisch und Portugiesisch-Portugal) aus Localizable.xcstrings entfernt
- Über 900 fehlende Texte über Übersetzungs-API (Google Translate) in 15 Sprachen übersetzt und als 100% markiert
- Fehlende hartkodierte Texte im Code lokalisiert und mit  ersetzt
- 1%-Sprachen (Schwedisch und Portugiesisch-Portugal) aus Localizable.xcstrings entfernt
- Über 900 fehlende Texte über Übersetzungs-API (Google Translate) in 15 Sprachen übersetzt und als 100% markiert
- Fehlende hartkodierte Texte im Code lokalisiert und mit String(localized:) ersetzt

### Onboarding Update: 5-Jahresziele & Wochenziele
- **5-Jahresziel:** Die Frage nach dem Jahresziel wurde in ein 5-Jahresziel geändert, inklusive neuer passender Templates (Beruf, Finanzen, Gesundheit).
- **Custom-Ziel Overlay:** Eigene Ziele werden nun in einem schönen Custom-Overlay statt in einem Standard-Alert erstellt.
- **Wochenziel:** Ein neuer Onboarding-Schritt ("Was ist dein Ziel für diese Woche?") wurde direkt nach dem 5-Jahresziel hinzugefügt.
- **Button "Weiter":** Onboarding-Seiten springen nicht mehr sofort um. Es muss nun explizit ein "Weiter"-Button geklickt werden.
- **Lokalisierung:** Alle neuen Strings wurden in 14 Sprachen vollautomatisch in die `Localizable.xcstrings` übersetzt.
- **Custom-Ziel Dialog:** Das Erstellen von eigenen Zielen im Onboarding verwendet nun wieder die native iOS-Eingabemaske (Alert) für ein vertrauteres Nutzererlebnis.
- **Screen Time Onboarding Fix:** Das Layout des Berechtigungs-Mocks wurde korrigiert, um exakt dem iOS 16/17 Original zu entsprechen ("Nicht erlauben" links, "Weiter" rechts, beide mit grauem Hintergrund). Außerdem öffnen sich nun automatisch die iOS-Einstellungen, falls die Bildschirmzeit dort noch nicht für die App aktiviert wurde.
- **Screen Time Mock UI:** Layout an ältere iOS-Versionen (bzw. spezifische Screenshots) angepasst: "Weiter" nun links (grau) und "Nicht erlauben" rechts (blau/hervorgehoben). Texte wurden ebenfalls exakt an den gewünschten Prompt angeglichen.
- **Critical Bugfix (Screen Time Auth):** Ein Timing-Bug wurde behoben, der dazu führte, dass die In-App-Berechtigungsabfrage bei erfolgreicher Genehmigung sofort fälschlicherweise als "fehlgeschlagen" gewertet wurde (weil iOS den Status oft mit leichter Verzögerung anpasst). Dadurch wurden TestFlight-User fälschlicherweise immer direkt in die Einstellungen geworfen. Zudem gibt die App nun bei echten Fehlern einen iOS-Alert mit der exakten Apple-Fehlermeldung aus, bevor man in die Einstellungen geschickt wird.
- **Kompilierungsfehler behoben:** Syntaktische Fehler (verschachtelte Klammern und falsch platzierte `@State`-Variablen) in `OnboardingScreenTimeView` wurden behoben.

## 2026-07-31 09:27 - Pro Feature Update
- Alte Apple Health Integration aus der Detailansicht entfernt.
- Pflanzen-Statistiken (IntradayProgressChartView) sind nun exklusiv für Pro-Nutzer sichtbar.
- Upsell-Text für Nicht-Pro-Nutzer von "Apple Health Kopplung" auf "Erweiterte Statistiken" geändert.
- Onboarding fragt nun nach der korrekten Bildschirmzeit-Berechtigung ('.child' statt '.individual'), um den 'Would like to access Screen Time'-Dialog statt 'App- und Web-Aktivitäten' anzuzeigen.
- Hotfix: Bildschirmzeit-Berechtigung auf '.individual' zurückgesetzt, da '.child' bei normalen Apple-IDs (Erwachsenen-Accounts) zu Abstürzen/Fehlern führt.
- Bugfix: Verhindert einen iOS-Bug, der die Bildschirmzeit-Berechtigung (App- & Website-Aktivitäten) in den Einstellungen ungewollt deaktiviert hat, wenn die Berechtigung mehrmals angefragt wurde.

## 2026-08-15 10:16 - Revert Apple Health Changes
- Apple Health Integration in der Pflanzen-Detailansicht wiederhergestellt.
- Upsell-Text für Nicht-Pro-Nutzer wieder auf "Apple Health Kopplung" zurückgesetzt.
- Pflanzen-Statistiken werden nun für Pro-Nutzer immer angezeigt (auch wenn Health-Daten verknüpft sind).

## 2026-08-15 10:49 - UI und Statistik Updates
- Fehlerbehebung: Pflanzen mit Apple Health Verknüpfung zeigen nun keine redundante Fortschritt-Statistik mehr an.
- Neue Funktion: In der Fortschritt-Statistik (ohne Apple Health) kann nun direkt ein individuelles Ziel (z. B. 100%) über den neuen "Ziel festlegen" Button eingestellt werden, welches auch als Ziellinie im Diagramm dargestellt wird.
- To-dos können jetzt auch ohne Verknüpfung zu einer Gewohnheit hinzugefügt werden.
- Das Icon im 'Set Weekly Goal'-Banner wurde vergrößert, um besser lesbar zu sein.
- Das Icon im 'Set Weekly Goal'-Banner nutzt nun .scaleEffect(), um optisch größer zu wirken, ohne den Button-Hintergrund unnötig aufzublähen.
- Das Ziel-Icon im Banner wurde noch weiter vergrößert.
- Onboarding: 5-Jahresziele und Wochenziele werden nun direkt als Textfeld eingegeben, statt vordefinierte Vorschläge anzuzeigen.
- UI: Das Textfeld für die Zieleingabe im Onboarding nutzt jetzt das große 3D-Container-Design.
- UI: Platzhalter-Text bei der Zieleingabe bricht nun korrekt in die nächste Zeile um, wenn er zu lang ist.
- UI: Die Berechtigungs-Abfragen im Onboarding (Benachrichtigungen & Bildschirmzeit) nutzen jetzt das 3D-Container-Design und Item3DButtons. Bei der Bildschirmzeit-Abfrage wurden 'Weiter' und 'Nicht erlauben' vertauscht.
- UI: Die Berechtigungs-Abfragen im Onboarding wurden vergrößert und etwas nach unten verschoben, um den Avatar nicht zu verdecken. Der Pfeil zeigt nun korrekt (ohne Animation) auf den 'Weiter'-Button.
- UI: Der Text in der Sprechblase über dem Avatar bricht nun immer korrekt in die nächste Zeile um, anstatt mit Punkten (...) abgeschnitten zu werden.

- Apple Health: Fortschrittsbalken für verbundene Gesundheits-Ziele ist nicht mehr manuell bedienbar und schließt sich automatisch ab, sobald das Ziel erreicht wurde.

- Apple Health: Verbundenen Zielen wurde ein Indikator auf der Garten-Karte hinzugefügt. In den Pflanzen-Details gibt es nun einen Button, um Apple Health für einzelne Ziele zu entkoppeln oder wieder zu verbinden.

- UI: Das Apple Health Herz-Symbol wurde von der Garten-Karte entfernt. Der Entkoppeln-Button in der Detailansicht wurde durch ein kleines X-Icon oben rechts ersetzt, inklusive einer Sicherheitsabfrage. Beim Wiederverbinden wird der manuelle Fortschritt automatisch auf den Health-Wert korrigiert.

- UI Fix: Das X-Icon zum Entkoppeln von Apple Health ist nun nahtlos im Titel der Statistik-Karte integriert und hat keinen eigenen Hintergrund mehr.
- Hinzugefügt: Erklärungstext für Apple Health in der Einstellungs-Ansicht unter 'Integrationen', übersetzt in alle 15 unterstützten Sprachen (App Review Anforderung).
- Behoben: Layout-Warnung 'Invalid frame dimension' im InteractiveTourOverlay behoben.
- UI & Logic Update: Abgeschlossene To-dos werden nun nicht mehr sofort entfernt, sondern erst am nächsten Tag bereinigt, damit der Erfolg sichtbar bleibt.
- UI Update: Das Apple Health Integration Feld in den Einstellungen enthält nun ein kleines Info-Icon, welches die Erklärungstexte in einem kompakten Alert anzeigt, um das UI aufzuräumen.
- Paywall Update: Das Adult Filter Icon in der Pro-Feature Liste wurde durch das dedizierte Asset `ProIconAdultFilter` in einheitlicher Größe (scale 2.2) ersetzt.
- Fix: Übersetzungsschlüssel für "Abo verwalten" (`settings.manage_subscription`) in allen Sprachen korrigiert.

- Custom To-Dos in Routinen haben jetzt ein optionales Beschreibungs-Feld anstelle der Icon-Beschreibung, und der Name wird immer korrekt angezeigt.

- Bugfix: Routine Live Activity Timer gefixt. Der Timer (sowohl in der App als auch auf dem Lockscreen) zeigt nun immer stabil die Gesamtzeit der Routine an und springt nicht mehr zurück oder friert im Hintergrund ein. Zudem beendet sich die Live Activity beim Abschluss der Routine nun sauber.

- Screen Time Einstellungen für normale Nutzer entfernt und in die Developer Options verschoben

### Routine-Todos Fix
- **Keine Fehlberechnung mehr:** Routine-Only Todos vergeben beim Abhaken in `GardenStore` keine Coins, XP, Statistiken oder Streaks mehr. Level-Up Popups für Routine-Todos sind dadurch ebenfalls gefixt.
- **Eigener Name:** Beim Hinzufügen von Todos zu einer Routine ist das Namens-Feld jetzt optional. Ein eingegebener Name wird im UI nun über dem Standard-Icon-Text bevorzugt. Bleibt das Feld leer, wird stattdessen "To-Do" verwendet, ohne den Text des ausgewählten Icons zu übernehmen.
- Lokalisierung für den 'erledigt' Text in den Wochenstatistiken hinzugefügt.
- Text-Layout bei den Apple Health Einstellungen korrigiert, damit der Text vollständig umgebrochen wird.
- 'Dynamisch' Option beim Bildexport entfernt.
- Hintergrund für Namen und Diamanten bei Bild-Exporten entfernt.
- Behoben: Apple Health und Kamera-Berechtigungsdialoge in alle 11 Projektsprachen übersetzt (App Review Anforderung Guideline 4).
- **Statistiken behoben:** In den Wochenberichten und der Dashboard-Statistik werden reine Routine-Todos nicht mehr als Gewohnheiten gezählt, was die Statistik verfälscht hat.
- **To-dos Automation:** Abgeschlossene To-dos auf der Hauptseite verschwinden nun automatisch nach 10 Sekunden (es sei denn, sie werden innerhalb der Zeit wieder deaktiviert).
- **Settings:** Die 'App weiterempfehlen' und 'App bewerten' Buttons wurden aus den Einstellungen entfernt.
- UI: Wochenziel-Banner in der To-Do-Ansicht verkleinert, damit es kompakter wirkt.
- Routine-spezifische To-Dos (isRoutineOnly) werden nun konsequent aus den Gewohnheits-Listen ausgeblendet (z.B. beim Erstellen neuer To-Dos, in der Fokus-Session XP-Verteilung und in den Guten Gewohnheiten).
- Automatische abendliche System-Benachrichtigungen ('Pflanzen brauchen Wasser') entfernt, sodass nur noch vom Nutzer selbst erstellte Benachrichtigungen gesendet werden.
