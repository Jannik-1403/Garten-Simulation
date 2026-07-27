## [2026-07-24] - Zeit-Block Fixes
- **App-Auswahl Filter**: Apps, die bereits in "Immer blockierte Apps" oder "Apps mit Zeitlimit" ausgewählt sind, werden nun automatisch aus der Auswahl für den Zeit-Block entfernt.
- **Entsperren im Zeit-Block**: Der "Entsperren"-Button ist nun während eines aktiven Zeit-Blocks klickbar. Über den "Walk of Shame" kann der Text abgetippt werden, um den Zeit-Block vorzeitig zu beenden.

# Changelog

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
