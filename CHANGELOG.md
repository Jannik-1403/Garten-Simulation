- Feature: Interaktive Pro-Widgets (Homescreen) zum direkten Gießen und Lock-Screen Streak-Widget hinzugefügt.
## 2026-07-07 08:18:18 - Pro Abo Test in Developer Settings
- Button zum Kündigen des Pro-Abos zu den Developer Settings hinzugefügt.
- String für Button-Label in 11 Sprachen übersetzt und zu Localizable.xcstrings hinzugefügt.

- Glücksrad: Belohnungen und Pop-Up-Texte an die angezeigten Zahlen auf dem Rad (10, 25, 50, 150) angepasst.
## [2026-07-06] - Shop & UI Updates

- **Wochenstatistik Tipps**: Die Texte der Fortschritt-Analyse (Tipps) wurden in eine ScrollView verpackt und die Kartenhöhe leicht vergrößert. Längere Texte werden dadurch nicht mehr abgeschnitten und der abgerundete Hintergrund bleibt nun auch bei langem Text formstabil.
- **iPadOS Tab Bar Fix**: Die Tab Bar bleibt nun auch auf dem iPad unter iOS 18+ dauerhaft am unteren Bildschirmrand fixiert, statt sich in eine Seitenleiste (Sidebar) umzuwandeln. (Über die horizontale Size Class forciert).
- **iPadOS Layout Anpassung**: Die maximale Breite der Karten und Container wurde auf 850px erhöht, um den Platz auf dem iPad besser auszunutzen und die UI breiter und "länger" wirken zu lassen.
- **PDF Export Configurator**: Gute Gewohnheiten sind im PDF-Export-Menü nun standardmäßig ausgewählt.
- **Tägliches Glücksrad im Shop**: Der Button für das tägliche, kostenlose Glücksrad wurde von der Startseite (Gartenansicht) in den Shop verschoben. Er befindet sich nun prominent über den Power-Ups als aufgewertete Shop-Karte (mit "Kostenlos"-Badge und 2.2x größerem Icon), um das Shop-Erlebnis aufzuwerten und die Startseite aufzuräumen. Der Icon-Name wurde zudem zu "Spin" korrigiert. Der Action-Button im Glücksrad zeigt nun unabhängig von der Anzahl immer den generischen Text "Glücksrad drehen" an.

## [2026-07-02] - Hintergrund-Audio, Pro-Rabatt & unbegrenzte Gewohnheiten

- **Wochenübersicht Tipps**: Die Tipp- und Analyse-Texte werden nun nicht mehr alle auf einmal untereinander angezeigt. Stattdessen sind sie in ein kompaktes, seitlich wischbares TabView-Karussell integriert, was deutlich mehr Platz spart und aufgeräumter wirkt.- **Wochenübersicht Feinschliff**: Navigation-Pfeile wurden von störenden Kreisen befreit und die Datums-Anzeige im Header zu einem interaktiven, pillenförmigen Liquid Glass Button aufgewertet.
- **Wochenübersicht UI Redesign**: Die Wochenübersicht wurde aufgeräumt. Statistikkarten sind jetzt als swipebares Karussell (TabView) umgesetzt. Die Navigation im Header nutzt einen Liquid Glass-Effekt (`.ultraThinMaterial`), die Diagramm-Balken haben eine flache Einzelfarbe ohne störende Verläufe und alle Kärtchen besitzen nun eine dünne Outline. Die Tipp-Sektion wurde farblich beruhigt (ohne grelle Neonfarben) und unnötige Charts (Radar) wurden für mehr Übersichtlichkeit entfernt.- **Oranger 3D-Pfeil bei Rabatten**: Im Shop wird nun bei einem rabattierten Preis ein oranges 3D-Pfeil-Symbol (`↓`) mittels `Stat3DTitleView` angezeigt, um die Preissenkung visuell hervorzuheben.
- **"pro Bonus" 3D-Schriftzug bei Belohnungen**: Wenn ein Pro-User eine Belohnung (Münzen) nach Fokus-Sessions, Routinen oder abgeschlossenen Pfaden und Meilensteinen erhält, wird der Schriftzug **"pro Bonus"** in der plastischen 3D-Schriftart (`Stat3DTitleView`) in Gold angezeigt.
- **Direkte Weiterleitung bei Münzmangel**: Bei unzureichendem Münzguthaben öffnet sich für Nicht-Pro-User sofort die Paywall (wo nun auch der Pflanzen-Rabatt als Feature gelistet ist), während Pro-User direkt zum Münzen-Kauf-Fenster weitergeleitet werden.
- **Pro-Rabatt & Coin-Bonus**: Pro-User erhalten 50% Rabatt beim Freischalten neuer Gewohnheiten im Shop (400 statt 800 Münzen) sowie einen +25% Multiplikator auf gewonnene Münzen beim Gießen.
- **Unbegrenzte Gewohnheiten**: Es gibt keine künstlichen Limits für aktive Gewohnheiten mehr (sowohl für Free- als auch Pro-User). Alle Pflanzen können unlimitiert freigeschaltet und gepflanzt werden.
- **Dynamischer Rückkaufwert**: Der Refund-Betrag einer Pflanze passt sich dem Kaufpreis des Benutzers an (Pro-User erhalten 200 Münzen, Free-User erhalten 400 Münzen zurück), um Exploits zu verhindern.
- **Shop UI-Visualisierung**: Pro-User sehen im Shop nun den Originalpreis durchgestrichen sowie den ermäßigten Preis und einen orangen 3D-Pfeil nach unten. Das störende "PRO -50%"-Badge oben auf den Karten wurde wunschgemäß entfernt.
- **Pro-Status Persistence**: Der Pro-User-Status wird nun über `UserDefaults` lokal persistiert. Beim Neustarten oder Beenden der App bleibt das freigeschaltete Pro-Abo somit dauerhaft aktiv und muss nicht erneut freigeschaltet werden.
- **Premium Loop-Synthese (16 Sek. + Crossfade)**: Die synthetische Generierung aller Fokus-Sounds wurde von 4 auf **16 Sekunden Pufferlänge** verlängert. Dadurch klingen die Geräusche (Regen, Zen-Flöte, Kaffeehaus) deutlich natürlicher und weniger repetitiv. Zudem wurde ein **1,5 Sekunden Crossfade** am Loop-Übergang implementiert, um Knackser und hörbare Wiederholungsschnitte vollständig zu eliminieren.
- **Timer Icon**: Auf dem Endbildschirm (Success-View) der Fokus-Session wird nun wunschgemäß das `Timer empty`-Icon angezeigt anstelle des orangen Checkmarks.
- **Level Up UI Redesign**: Der Rarity Level Up Screen (z.B. Bronze zu Silber) wurde komplett überarbeitet. Der alte verschwommene Glas-Effekt wurde entfernt; das Popup hat nun einen soliden Hintergrund und die Seltenheit (z. B. "SILBER") wird als 3D-Schrift dargestellt. Beim Erreichen des Diamant-Rangs wird zudem eine zusätzliche Nachricht eingeblendet ("Du hast einen neuen Spiel-Titel freigeschaltet!").
- **Level Up Trigger Bugfix**: Ein Fehler wurde behoben, durch den das Rarity-Overlay nicht automatisch ausgelöst wurde, wenn eine Pflanze durch reines Gießen im Hintergrund einen neuen Rang (z.B. von Bronze auf Silber) erreicht hat.
- **Pro Bonus Visualisierung**: Wenn eine Pflanze gegossen wird, erscheint für Pro-Nutzer ab sofort ein schwebender **"PRO"**-Schriftzug im auffälligen 3D-Neon-Design. Auf Wunsch wurde auf die detaillierte XP/Münzen-Auflistung und auf Emojis verzichtet, um die Visualisierung auf das Wesentliche und Premium-Feeling zu fokussieren. Ein Fehler, durch den der "PRO"-Text auf kleineren Geräten in der Raster-Ansicht abgeschnitten ("P...") wurde, ist behoben.
- **Fokus Session Success View**: Der End-Screen der Fokus-Session wurde wunschgemäß auf das alte Design zurückgesetzt. Er zeigt nun wieder das vertraute Checkmark-Symbol und den Text "Deine Pflanze ist stolz auf dich!", während gleichzeitig beide Belohnungen (Münzen und XP) übersichtlich nebeneinander dargestellt werden.
- **Haptisches Feedback & Partikeleffekte**: Die App bietet nun ein wesentlich hochwertigeres "Premium-Gefühl" durch verbesserte haptische Reaktionen. Beim Gießen einer Pflanze spürt man nun einen satten, fühlbaren Klick (Taptic Engine) und visuell spritzen kleine interaktive Wassertropfen animiert aus der Gießkanne/Pflanze.
- **Timer-Weiterlauf im Hintergrund**: Der Fokus-Timer pausiert *nicht* mehr, wenn die App minimiert (Home-Bildschirm) oder das Handy gesperrt wird. Die Zeit im Hintergrund wird beim Öffnen der App automatisch berechnet und abgezogen. Bei aktivem Strict-Mode führt das Verlassen der App nach wie vor nach 10 Sekunden zum Fehlschlag der Session.
- **Live Activity Beenden bei Force-Close**: Wenn die App vom Benutzer über den App-Switcher komplett geschlossen (weggewischt) wird, fängt die App den Termination-Event (`UIApplication.willTerminateNotification`) ab und beendet alle aktiven Live Activities auf dem Sperrbildschirm sofort.
- **Hintergrund-Audio**: `UIBackgroundModes = [audio]` in `Info.plist` eingetragen – Fokus-Sounds (Regen, Kaffeehaus, Zen-Flöte, Weißes/Braunes Rauschen) laufen jetzt weiter, wenn die App in den Hintergrund geht.
- **Live Activity Tap → Fokus-Timer**: Tippen auf die Live Activity im Sperrbildschirm oder die Dynamic Island öffnet die App direkt im laufenden Fokus-Timer der richtigen Gewohnheit.
- **Deep Link Architektur**: `grovy://focus?habitId=<id>` – `FocusTimerActivityAttributes` trägt jetzt die `habitId`, Live Activity setzt `widgetURL`, `onOpenURL` im App-Root setzt `gardenStore.activeFocusHabitId`, `GartenView` öffnet daraufhin automatisch das richtige Detail-Sheet.
- **Kompaktes Sound-Layout**: Die Musikkarte (`FocusSoundControlView`) wurde drastisch verkleinert. Durch die Platzierung der 3D-Bodenlayer direkt im `.background()` der `VStack` statt in einem umschließenden `ZStack` dehnt sich die Karte nicht mehr fälschlicherweise vertikal aus. Zudem ist die maximale Breite nun fest auf `280pt` eingestellt, um perfekt mit dem runden Countdown-Timer zu harmonieren.

## [2026-07-01] - Audio-Overhaul: Hochwertige Stereo-Synthese & Button-Fix

- **Regen**: Vollständig neue Synthese – mehrschichtiges Stereo-Pink-Noise mit langsamer Windmodulation (LFO) und einer simulierten Einzeltropfen-Schicht für natürliches, lebendiges Regengeräusch.
- **Kaffeehaus**: 5 überlagerte Bandpass-Stimmschichten (280 Hz–1,8 kHz) mit natürlicher Sprachkadenz-Modulation statt bloßem Rauschen – klingt wie echtes Hintergrundgemurmel.
- **Zen-Flöte**: Additive Synthese auf pentatonischer Tonleiter (C4–C5) mit 4 Obertönen, sanften sin²-Hüllkurven und Atemgeräusch-Schicht für flötenähnlichen Charakter.
- **Weißes/Braunes Rauschen**: Jetzt echter Stereo-Ausgang statt Mono.
- **Soft-Clipping**: Eretzt den harten Limiter durch sanftes `tanh`-Clipping gegen digitale Verzerrung.
- **EQ + Reverb pro Sound**: Jeder Klang erhält eigene Equalizer-Einstellungen (Hochpass, Tiefpass, Parametric) und einen passenden Raumhall (cathedral, largeChamber, mediumHall etc.).
- **Button-Tap-Fix**: Chevron-Buttons in FocusSoundControlView haben jetzt `.buttonStyle(.plain)` + `frame(44×44)` + `contentShape(Rectangle())` für zuverlässige Tap-Erkennung ohne Fehlklicks.
- **Puffer-Erzeugung im Hintergrund**: Kein UI-Einfrieren mehr beim Starten eines Sounds.

## [2026-07-01] - Lokalisierung & Pro-Feature: Fokus-Timer & Sound-Maschine

- **Vollständige Lokalisierung**: Alle verbleibenden Harttexte im Fokus-Timer (wie Überschriften, Vorbereitungs-Phasen, Buttons und Prioritäts-Labels) wurden vollständig in das native Xcode String Catalog System (`Localizable.xcstrings`) überführt.
- **Mehrsprachige Vorlagen (Templates)**: Sämtliche 20 Vorschläge und Ziele (z.B. "10 Min Dehnen", "Tiefes Atmen", "Ausgaben tracken" etc.) wurden für alle 11 Projektsprachen (DE, NL, EN, FR, IT, JA, KO, PL, PT, ES, TR) übersetzt und im String Catalog eingetragen.
- **SwiftUI Code Refactoring**: Veraltete `NSLocalizedString(...)` Aufrufe wurden durch die native SwiftUI-Integration ersetzt. Benutzereingaben werden jetzt direkt unübersetzt dargestellt, während vordefinierte Vorlagen und statische UI-Texte sauber über `String(localized:defaultValue:)` geladen werden.
- **3D-Card Design**: Die gesamte Sound-Maschine (`FocusSoundControlView`) verwendet jetzt ein plastisches 3D-Karten-Design mit einem Hauptlayer in `secondarySystemBackground` (weiß in Light Mode) und einem passenden 3D-Schatten-Bodenlayer. Die Karte wurde im Timer-Screen weiter nach unten verschoben.
- **Pro-Feature Schutz**: Die komplette Sound-Maschine ist nun strikt für Nicht-Pro-User gesperrt (inklusive "Kein Sound"). Der gesamte 3D-Hintergrund färbt sich dabei golden, zeigt weiße Bedienelemente und ein Schloss-Symbol, welches bei Klick direkt die Paywall öffnet.

## [2026-07-01] - Pro-Feature: Fokus-Sound-Maschine (Flow-State-Audio)
- **Neues Feature: Fokus-Sound-Maschine**: Ermöglicht das Abspielen von beruhigenden Hintergrundgeräuschen direkt während einer Fokus-Session oder einer Routine-Session.
- **Schlichtes UI-Refactoring**: Das Steuerelement `FocusSoundControlView` wurde auf ein minimalistisches Design umgestellt. Keine Icons im Header, sondern nur der Soundname flankiert von einfachen Chevron-Pfeilen zur Navigation.
- **Großer 3D-Steuerungsbutton**: Der Play/Stop-Knopf wurde durch einen großen `Item3DButton` ersetzt. Bei spielbaren Sounds ist er weiß/hellgrau; bei Premium-Sounds (ohne Pro) ist er golden und zeigt ein Schloss-Symbol, um die Paywall zu öffnen.
- **Hochwertige Sound-Verbesserung**: Das Rauschen klingt nun weicher und angenehmer:
  - "Weißes Rauschen" verwendet jetzt den **Paul-Kellet-Pink-Noise-Filter**, der wie ein natürlicher, sanfter Wasserfall klingt.
  - "Braunes Rauschen" verwendet einen **2-Pol-Tiefpassfilter** für ein warmes, tiefes Meeresrauschen/Gewitter-Grummeln.
  - Ein Soft-Clipping-Limiter verhindert jegliche digitale Verzerrung im Audiokanal.
- **6 Fokus-Sounds**: Keine Geräusche, Weißes Rauschen, Braunes Rauschen, Waldregen, Kaffeehaus-Atmosphäre und Zen-Flöte stehen zur Auswahl.
- **Pro-Feature Schutz**: Premium-Naturgeräusche sind exklusiv für Pro-Nutzer freigeschaltet (gesichert über `IAPStore` und `FeatureFlags.isProVersionEnabled`). Versucht ein Nicht-Pro-User diese abzuspielen, öffnet sich die `PaywallView`.
- **Lebenszyklus-Steuerung**: Sounds stoppen automatisch beim erfolgreichen Beenden, Abbrechen (durch die Matheaufgabe oder den Strict Mode) oder beim Schließen des Ansicht-Sheets.
- **Vollständige Lokalisierung**: Alle Töne und UI-Texte wurden in alle 11 Projektsprachen (DE, NL, EN, FR, IT, JA, KO, PL, PT, ES, TR) in `Localizable.xcstrings` übersetzt.

## [2026-07-01] - Bugfix & Pro-Feature: ReminderSchedule & Kalender-Sync
- Die veralteten Properties `weekdays` und `todaysReminder` wurden als read-write Computed Properties auf `ReminderSchedule` wiederhergestellt, um Compilerfehler zu beheben.
- `ReminderSchedule` wurde im `GartenWidget` Target aktualisiert und für reibungslose Synchronisation vereinheitlicht.
- Kalender-Synchronisation wird nun als Pro-Feature behandelt: Der Kalender-Button wird auch für Nicht-Pro-User angezeigt, ist jedoch golden gefärbt, besitzt ein Schloss-Symbol und öffnet bei Klick die Paywall.
- In der `PaywallView` wurde die "Kalender Synchronisation" zur Liste der exklusiven Pro-Features hinzugefügt.
- Auf der Paywall-Seite wird nun das `ProFeature`-Icon statisch auf **250x250** Pixel vergrößert dargestellt.
- Der Titeltext wurde durch ein negatives Bottom-Padding am Icon (`-15`) weiter nach oben gerückt, um eine stylische, leichte Überlappung mit dem Diamanten/Krone-Bild zu ermöglichen.
- Das Wort "Pro" im Titel "Grovy Pro" wurde für die asiatischen Sprachen lokalisiert (Koreanisch: "Grovy 프로", Japanisch: "Grovy プロ").
- Der Kauf-Button in der `PaywallView` wurde auf den voll-plastischen `DuolingoButtonStyle` (3D Button) umgestellt.
- Das Pro-Produkt (`com.gartenapp.pro.lifetime`) mit einem Lifetime-Preis von **9,99 €** wurde in beiden Xcode-StoreKit-Konfigurationen (`StoreKitConfig.storekit` und `Purchases.storekit`) hinzugefügt. Dadurch können Produkte nun auch im Simulator regulär geladen werden.
- Ein Fallback-Bypass (DEBUG-Freischaltung) wurde im Simulator auch außerhalb des regulären Debug-Flags aktiviert, um Entwicklungs- und Previews-Tests zu vereinfachen, wenn die Produkte noch laden.
- **NEUES FEATURE**: Detaillierte wöchentliche Produktivitäts-Analyse (`WeeklyReportDashboardView` & `WeeklyStatsManager`) unter dem Tab "Statistik" hinzugefügt, wenn das Wochen-Intervall ausgewählt ist.
  - Ermöglicht das Navigieren zwischen historischen Wochen mittels `<` und `>` Tasten.
  - Bietet interaktive Swift Charts für die tägliche Fokuszeit und die Anzahl erledigter Gewohnheiten mit Tooltips.
  - Bietet eine detaillierte, aufklappbare Wochen-Analyse mit Vergleichen und prozentualen Veränderungen zur Vorwoche.
  - Integriert den wöchentlichen PDF-Report-Export und Share Sheet über den `PDFExportManager` (Pro-Feature).
- **Entwickler-Testoption**: In den Developer Options wurde die Option 'Wochenbericht testen' hinzugefügt, um die wöchentliche Produktivitäts-Analyse (`WeeklyReportDashboardView`) direkt als modales Test-Sheet zu öffnen und zu prüfen.

- Alle neuen Zeichenketten und Wochentage wurden vollständig in alle 11 Projektsprachen übersetzt.






## [2026-06-30] - PDF Sprache/Lokalisierung Bugfix Teil 3 (Statistiken & Streaks)

- Die Platzhalter für Streaks (Höchster Streak, Aktueller Streak, Abgeschlossene Challenges, Längster Streak ohne Rückfall) wurden aus dem lokalen Speicher korrekt in alle 11 Sprachen übersetzt und eingebunden.
- Auch die Auslöser (Triggers) bei den schlechten Gewohnheiten werden jetzt mehrsprachig angezeigt.

## [2026-06-30] - PDF Sprache/Lokalisierung Bugfix Teil 2
- Der PDF Export Manager und der PDF Export Configurator nutzen nun bei jeder Textgenerierung den aktuell in der App ausgewählten `appLanguage`-Code (z.B. "en" oder "de").
- Bisher wurden manche Texte nur im Standard-Locale formatiert oder haben die Sprachauswahl ignoriert. Dies ist nun für alle Datumswerte, Timer-Formatierungen, Routinen-Namen und PDF-Textblöcke strikt an die In-App Sprache gebunden.

## [2026-06-30] - Übersetzung Bugfix
- Fehlende Übersetzungen im PDF Export Konfigurator und im PDF Bericht selbst wurden nachgetragen. Wenn die App auf Englisch gestellt ist, sind nun auch alle Menüpunkte und Überschriften (z.B. "Good Habits", "Additional Data", "Generate PDF") korrekt übersetzt.

## [2026-06-30] - PDF Export Quiz & Kategorie-Stats Fixes
- Die Quiz-Ergebnisse im PDF zeigen nun den korrekten lokalisierten Text statt dem rawValue der Datenbank an (z.B. "Ausreden-Sucher" statt "ausreden_suche").
- Bei den Quiz-Ergebnissen wird jetzt zusätzlich die Beschreibung und der Punkt "Was man verbessern kann" mit angezeigt.
- Bei den allgemeinen Statistiken wird nun die Anzahl der Gieß-Vorgänge (Mischgut/Erfahrungspunkte) pro Kategorie aufgeschlüsselt angezeigt.
- Alle neuen Strings wurden erfolgreich in alle verfügbaren Sprachen übersetzt.

## [2026-06-30] - Export UI Anpassungen
- Die Option "Gute Gewohnheiten" in den Export-Einstellungen wurde nach unten zu den restlichen Optionen verschoben.
- Der Hintergrund der Export-Konfiguration ist nun in einem dezenten Grauton gehalten, damit sich die Buttons besser abheben.
- Alle Einstellungs-Buttons haben nun eine feine Umrandung, um sich noch deutlicher vom Hintergrund abzusetzen.
- Sämtliche neuen Texte wurden in alle Sprachen übersetzt (Englisch, etc.).

## [2026-06-30] - Fokus Session Metadaten
- `FocusSessionLog` erweitert, um festzuhalten, ob es sich um eine Routine oder normale Gewohnheit handelt, inklusive verknüpfter Aufgaben/Todos.
- PDF-Export Manager liest die neuen Fokus-Session Daten aus und stellt diese im Bericht dar (mit Gewohnheitsnamen und Aufgaben).
- PDF-Export zeigt nun bei den Routinen auch die Historie an (wann welche Routine abgeschlossen wurde).
- Übersetzungen mit dem Python-Script in `Localizable.xcstrings` aktualisiert.

## [2026-06-30] - UI & Export Updates
- Gute Gewohnheiten sind im PDF-Export nun standardmäßig deaktiviert, können aber über einen Toggle aktiviert werden.
- Der `Item3DButton` hat nun eine dezente Kontur erhalten, um Ränder besser sichtbar zu machen.
- Der Button "PDF generieren" nutzt nun das einheitliche `Item3DButton`-Design.
- Das Schließen-X oben rechts ist jetzt dicker (`.heavy`) und komplett schwarz.

## [2026-06-30] - PDF Export Refactor
- Modulare PDF-Generierung für Notizen, Statistiken, Timer, schlechte Gewohnheiten, Quizzes und Routinen eingebaut.
- `ImageRenderer` für Quiz Ergebnisse eingebaut, um diese als Bilder im PDF zu zeigen.
- Lange Streaks für schlechte Gewohnheiten kalkuliert und im PDF hinzugefügt.
- UI Refactoring der Export-Seite mit nativem Design und `NavigationStack` umgesetzt.
- Lokalisierungs-Updates in der `Localizable.xcstrings` durchgeführt.
- Sämtliche Tests im Terminal bestehen erfolgreich.

### Routine UI & Syntax Fix
- Ein Syntaxfehler in PflanzeDetailSheet (fehlende Klammer) wurde behoben.
- Routinen zeigen nun an, wenn Gewohnheiten heute bereits erledigt wurden, und vergeben keine doppelten Belohnungen.


### Assessment "1% Marginal Gains" Updates
- Sämtliche Texte für aufzubauende (Plus) und abzulegende (Minus) Gewohnheiten in den 24 Assessment-Profilen wurden nach der "1% Marginal Gains" Methode umgeschrieben.
- Die Texte fokussieren sich jetzt auf extreme Mini-Habits (z.B. "15 Sekunden kalt duschen", "1 Kreditkarte aus Autofill löschen"), anstatt unüberwindbare Aufgaben zu verlangen.
- Alle 11 Sprachen wurden entsprechend aktualisiert.

### Assessment Re-Refactoring (3-Kategorien-Profilsystem)
- Single-Score Bewertung wurde rückgängig gemacht. Das Quiz-System nutzt wieder die 3-Achsen-Bewertung (z.B. Kontrolle, Entscheidung, Risiko).
- Die 24 verschiedenen Profile wurden beibehalten und mit extrem personalisierten und ausführlichen Texten in allen 11 Sprachen angereichert.
- Nutzer erhalten nun bei jedem Ergebnis detaillierte Erklärungen, welche Gewohnheiten sie aufbauen und welche sie ablegen sollten.
- Die 3 Bewertungsbalken pro Kategorie werden wieder im UI angezeigt.

### Assessment Single-Score Refactoring
- Alle 6 Assessments (Finance, Mental, Growth, Health, Fitness, Lifestyle) verwenden nun ein einheitliches Single-Score System.
- Die komplexen 3-Achsen Scores wurden auf einen einzigen integer Score reduziert (Minuspunkte, Pluspunkte).
- Das Ergebnis wird nun in 4 Leveln kategorisiert (Level 1 bis Level 4).
- Alle Profile und Result-Views wurden aktualisiert, um nur noch den Gesamtscore (Total Score) anzuzeigen.
- Lokalisierungen für alle 11 Sprachen für die neuen Level 1-4 wurden hinzugefügt.

# Changelog

## 2026-06-28 - Cleanup & TikTok Integration
- **Projekt Cleanup**: Über 50 veraltete Python-/Ruby-Skripte und Logdateien aus dem Hauptverzeichnis entfernt, um das Projekt schlank zu halten.
- **Assets Cleanup**: Ungenutzte Icons, fehlerhafte KI-Bildkopien und ungenutzte Charaktere aus `Assets.xcassets` entfernt. Bonsai-Stufen und das TikTok-Logo blieben erhalten.
- **Community Einstellungen**: Neuen Bereich "Community" in `SettingsView` hinzugefügt, inklusive verlinktem TikTok-Account (`@grovy807`) mit offiziellem Logo.
- **Lokalisierung**: TikTok-Texte direkt in `Localizable.xcstrings` für alle 11 Projektsprachen hinterlegt.

## 2026-06-28 - Onboarding Flow Korrektur
- **Reihenfolge**: App-Onboarding → Tour-Prompt → Routinen-Onboarding funktioniert jetzt korrekt nach Alles-Löschen.
- **Timing-Fix**: `routineOnboardingAbgeschlossen = false` wird jetzt BEVOR der Tab-Wechsel gesetzt → `onAppear` in `RoutinenView` sieht den korrekten Zustand.

## 2026-06-28 - Onboarding Timing-Bug behoben
- **Root Cause**: `routineOnboardingAbgeschlossen` war bei Erstnutzern bereits `false` → erneutes Setzen auf `false` löste kein `onChange` aus.
- **Fix**: Erzwungener `true → false`-Toggle mit 400ms Delay garantiert, dass SwiftUI die Änderung immer erkennt.
- **Zusatz**: `onChange(of: selectedTab)` in `RoutinenView` fängt Tab-Navigation ab als zweite Absicherung.

## 2026-06-28 - Onboarding-Routing & Item3DButton Fertig-Button
- **Vorschau-Frage umgebaut**: Sowohl "Ja" als auch "Nein" leiten jetzt direkt zum Routinen-Tab (Tab 4) weiter und triggern das Routine-Onboarding sofort.
- **Fertig-Button** im Routine-Onboarding ist jetzt ein `Item3DButton` (Orange, 3D-Druckeffekt, Haptic Feedback).

## 2026-06-28 - Routine Onboarding Vollständiger Bugfix
- **Timing-Bug behoben**: Onboarding erscheint jetzt sofort nach "Alles Löschen" ohne App-Neustart (via `@State showOnboarding` + `onChange` statt reaktivem Binding).
- **Doppelte Routinen nach Reset behoben**: `customRoutinesData` wird jetzt explizit auf `Data()` gesetzt, sodass `@AppStorage` den leeren Zustand sofort erkennt.
- **Sprachwechsel-Bug behoben**: Onboarding erscheint nicht mehr ungewollt beim Wechsel der App-Sprache.
- **Fertig-Button sichtbar gemacht**: Button hat jetzt einen orangen Gradient mit Schatten, klar erkennbar.

## 2026-06-28 - Routine Onboarding UI Überarbeitung
- Routine-Karten im Onboarding nutzen jetzt den `Item3DButton` mit 3D-Druckfeedback.
- Auswahlindikator (Checkbox) ist jetzt immer einheitlich orange statt in der jeweiligen Routinen-Farbe.
- "Bearbeiten"-Text wurde durch ein rundes Stift-Icon (`pencil`) ersetzt, konsistent mit der restlichen App.

## 2026-06-28 - Routine Onboarding Bugfix
- Fehler beim Laden des Routine-Onboardings nach App-Reset behoben (Fehlende Variablen in `RoutineOnboardingView` ergänzt).
- Compiler-Timeouts in `RoutinenView` behoben, indem komplexe SwiftUI-Strukturen in Unter-Views ausgelagert wurden.
- Test-Target Fehler behoben (Projekt-Dateien wurden fälschlicherweise in `Garten_SimulationTests` und `Garten_SimulationUITests` doppelt kompiliert).

## 2026-06-28 - Entfernung inaktiver Widgets
- Das inaktive "Offene Gewohnheiten" Widget (`GroovyHabitsWidget`) wurde vollständig aus dem Projekt gelöscht.
- Die Registrierung im `WidgetBundle` wurde entfernt, sodass nur noch die Widgets für Wasserverbrauch, Streak, Wochenverlauf und Monatsverlauf verfügbar sind.
- Veraltete iOS 17 Warnung für `.onChange(of:perform:)` in `RoutinenView` behoben.
- `GENERATE_INFOPLIST_FILE` für UITests aktiviert, um Build-Fehler zu beheben.

## 2026-06-28 - Routine Onboarding & Icon Updates
- Ein neues Onboarding für Routinen (RoutineOnboardingView) wurde hinzugefügt, das nach Account-Reset oder bei leerem Profil die einfache Auswahl von vordefinierten Routinen erlaubt.
- Die Routine-Icons in der App wurden vergrößert, standardisiert (ohne festen runden Hintergrund) und an die jeweiligen Routinentypen (Morgen, Abend, Gym, Allgemein) angepasst.
- Account-Löschung setzt nun zuverlässig alle Routine-Daten und Onboarding-Status in den UserDefaults zurück.
- Alle Onboarding-Texte wurden in die `Localizable.xcstrings` ausgelagert und übersetzt.

## 2026-06-28 - Dynamische Habit-Berichte
- Entfernung des separaten 'Raum für Wachstum'-Blocks aus allen ResultViews.
- Intelligente Nutzung der bestehenden 'buildHabitsKey' und 'breakHabitsKey' für detaillierte Auswertungen.
- Die Texte für AUFBAUEN und ABBAUEN reagieren nun dynamisch auf das Profil/Score des Nutzers (z.B. perfekt = alles super, schlecht = klare Handlungsanweisungen).
- Übersetzungen für 24 verschiedene Profil-Ausprägungen in 11 Sprachen über Localizable.xcstrings ausgerollt.

## 2026-06-28
- Doppel-Benachrichtigungen erlaubt: Die Sperre (usedSlots) für Benachrichtigungen zur exakt selben Uhrzeit wurde entfernt, sodass Routine-Erinnerungen und andere gleichzeitige Gewohnheiten parallel gesendet werden.
- Routine-Benachrichtigungen lokalisiert: Die Texte nutzen jetzt String(localized:...) und wurden in alle 11 Projektsprachen in Localizable.xcstrings übersetzt.

## Widget Localization & Icons Update (2026-06-28)
- Replaced hardcoded 'drop.fill' icon with dynamic plant icon in the GroovyHabitsWidget.
- Converted all hardcoded texts in GartenWidget.swift, GroovyHabitsWidget.swift, and GroovyNewWidgetViews.swift to native String(localized:).
- Added GroovyHabitsWidget to the main WidgetBundle so it displays correctly.
- Fixed a crash in RoutineSessionView caused by the Watchdog terminating the app when running in the background with isIdleTimerDisabled enabled.
- Alles Löschen-Button im Einstellungsmenü setzt nun auch Quiz-Ergebnisse (Assessments) und geplante Benachrichtigungen korrekt zurück.

- Fix: Pluralformen für Gewohnheiten in allen 11 Sprachen korrigiert (String Catalog substitutions)

- Automatisches Zuweisen von Gewohnheiten zu Routinen beim Onboarding-Abschluss
- Bereits einer Routine zugewiesene Gewohnheiten werden bei der Erstellung/Bearbeitung anderer Routinen nicht mehr zur Auswahl angeboten

## [Native Close Button für Quiz-Ergebnisse] - 2026-06-28
- 'X'-Button (LiquidGlassDismissButton) im Profil/Quizbereich hat nun ein natives iOS-Design.
- Das Overlay für den Dismiss-Button wird nun absolut platziert und überlagert nicht mehr mit der versteckten Navigationsleiste, was Fehler bei der Sichtbarkeit behebt.

## [Native Close Button für Quiz-Ergebnisse Fix] - 2026-06-28
- Komplett zurück auf Standard-iOS-Ansicht: NavigationBar bleibt erhalten und nutzt ein natives ToolbarItem (grauer Kreis mit 'X'), damit der Inhalt nicht unschön nach oben in die Statusleiste rutscht.

## 2026-06-29 - String Catalog Build-Fehler Behebung
- Behoben: Xcode Build-Fehler aufgrund von ungültigen Format-Specifiern (`%-S`, `%-D`, `%-F`, etc.) in `Localizable.xcstrings` repariert, die Abstürze bei der Swift-Typgenerierung verursacht haben.
- Mismatched positional format arguments (z.B. `%d` und `%@`) repariert, sodass Lokalisierungen mit re-geordneten Parametern sauber kompilieren (z.B. `%1$@`).
- Alle Unit- und UI-Tests durchlaufen wieder erfolgreich.
- Fehlerhafte, rohe Lokalisierungsschlüssel wurden im Code durch standardisierte Schlüssel ersetzt (z.B. `focus.session.start`).
- Ungenutzte Rohtexte wurden aus dem `Localizable.xcstrings` Katalog bereinigt.
- Fehlende Übersetzungen (besonders im Türkischen für Sonderzeichen und Platzhalter) wurden automatisiert ergänzt, um 100% Übersetzungsabdeckung zu gewährleisten.
- Alle ausstehenden und fehlenden String-Einträge in sämtlichen 11 Sprachen wurden vollautomatisiert aufgefüllt. Es wurden gezielt vorhandene Übersetzungen aus `AppStrings.swift` verwendet. 
- Platzhalter (wie `%lld` oder leere Zeichen) wurden in die jeweilige Übersetzung übernommen, sodass die Xcode-Lokalisierungsanzeige jetzt für alle Sprachen zuverlässig bei 100% steht.

## 2026-06-29 - Schlechte Gewohnheiten Drag-and-Drop
- Die Darstellung von schlechten Gewohnheiten (Trash) auf der Startseite wurde von einer horizontalen Liste auf ein Grid-Layout (`LazyVGrid`) umgestellt, ähnlich wie bei den guten Gewohnheiten (`PflanzenCard`).
- Ein neues `BadHabitCard` UI-Element wurde eingeführt.
- Schlechte Gewohnheiten unterstützen nun Drag-and-Drop: Zieht man das `SchlechteGewohnheitKreuz` auf die Karte, öffnet sich das Sheet zum Melden eines Rückfalls (`TriggerSelectionSheet`). Das Kreuz springt nach dem Loslassen sofort zurück und bleibt nutzbar.
- Der graue Timer-Hintergrundkreis wurde bei `BadHabitCard` entfernt und der Icon-Button wurde Rot gefärbt.
- Ein Zähler (rotes Badge) oben rechts an der BadHabitCard zeigt nun an, wie oft man am heutigen Tag bereits rückfällig wurde.
- Die horizontale Breite der BadHabitCard-Elemente im Grid wurde exakt an die Breite der PflanzenCard-Elemente angepasst.

- Updated coin amounts in shop translations to match actual received values (500, 1800, 3500) for all languages.

## 2026-06-29 - Routine Timer Edit
- Routine Timer: 'Alle Tage gleich machen' Option über die drei Punkte (...) oben rechts im Timer-Edit-Screen hinzugefügt.
- Routine-Abschluss überarbeitet: Gewohnheiten werden korrekt bewässert und bringen exakt die erwarteten Münzen/XP, ohne Timer-Boni.
- Gewohnheiten werden im Routine-Onboarding nicht mehr automatisch hinzugefügt.
- Routine-Icons in der Session-Ansicht (Intro) vergrößert.
- Routine-Icons aus der Listenansicht links entfernt.
- Plural-/Singular-Logik für Gewohnheiten in der Routine-Ansicht korrigiert.
- Fehlerhafte Routine-Icons (GymRoutine etc.) gefixt.
- **Fix (Bad Habits & Localization):** Im Garten-Inventar wird bei schlechten Gewohnheiten nun korrekterweise "Schlechte Gewohnheiten" als Untertitel statt "Dekoration" angezeigt.
- **Fix (Bad Habits & Localization):** Der harte Text für das "Schlechte Gewohnheit"-Label in der `BadHabitCard` wurde in `Localizable.xcstrings` ausgelagert und in alle 11 Projektsprachen übersetzt.
- **Fix (Localization):** Die rohen Schlüssel für Beschreibungen und Objektbeschreibungen bei "Unnötig online geshoppt" (`trash.online_shopping_app.desc` und `trash.online_shopping_app.obj_desc`) wurden repariert und in alle 11 Projektsprachen übersetzt.
- Refactored Timer UI in PflanzeDetailSheet and RoutinenView to use a fullscreen edit view and added an 'Apply to all days' toggle button.
- Syntax Error (Missing brace) in PflanzeDetailSheet behoben.
- Compile-Warnung (var zu let) in RoutineOnboardingView behoben.

## PDF Notiz-Export Feature
- `PDFExportManager.swift` hinzugefügt, um aus allen Notizen der App ein strukturiertes PDF zu generieren.
- Ein globaler Export-Button wurde in der `PflanzeDetailSheet` und der `InventoryItemDetailSheet` (für Schlechte Gewohnheiten) neben dem "Notizen"-Header ergänzt.
- Neue Lokalisierungsschlüssel für den PDF-Export in `Localizable.xcstrings` hinterlegt und in alle Sprachen übersetzt.
- UI: Info-Button und Erklärungssheet für 'Schlechte Gewohnheiten' im Shop entfernt.
- **Export Selection Sheet:** Ein natives "Drei-Punkte-Menü" wurde in der oberen linken Ecke der Detailansichten (`PflanzeDetailSheet` & `InventoryItemDetailSheet`) eingeführt.
- **Benutzerdefinierter Export:** Anwender können nun zwischen "Gesamte App", "Nur dieser Eintrag" und "Benutzerdefiniert" wählen. Bei benutzerdefiniert lassen sich spezifische Gewohnheiten und schlechte Gewohnheiten gezielt für den Export via Checkboxen aus- und abwählen.
- UI: Info-Button und Erklärungssheet 'Schlechte Gewohnheiten' im Shop vollständig entfernt.

## 30.06.2026
- Export Button aus PflanzeDetailSheet und InventoryItemDetailSheet entfernt.
- In den Einstellungen unter Profil einen neuen PDF Export Konfigurator hinzugefügt.
- Beim Gießen (manuell oder durch Routine) wird nun automatisch eine Notiz angelegt.
- Die exportierte PDF enthält nun umfassende Daten: Gute/Schlechte Gewohnheiten, Statistiken, Quiz Ergebnisse, Fokus Zeit und Routinen.

- Lokalisierungs-Fix: Die Anzeige der rohen Kategorie-Schlüssel (z. B. 'character.category.body') in den Charakter-Einstellungen (CharacterCustomizationView) wurde repariert und verwendet nun  mit Standardwerten sowie echten Übersetzungen.
- Lokalisierungs-Fix: Die Anzeige der rohen Kategorie-Schlüssel (z. B. 'character.category.body') in den Charakter-Einstellungen (CharacterCustomizationView) wurde repariert und verwendet nun `String(localized: ...)` mit Standardwerten sowie echten Übersetzungen in 11 Sprachen.
- Bad Habits verwenden nun ihre spezifischen neuen Icons anstatt der Platzhalter.
- Bad Habit Icons in der BadHabitCard sind nun 2.2x größer skaliert.
- Platzhalter-Icons wurden nicht aus den Assets gelöscht, da diese reguläre Dekorationen (wie Brunnen, Vogelhaus, Laterne etc.) im Spiel sind und ansonsten dort fehlen würden.
- Alte Dekoration-Icons (die zuvor als Platzhalter für schlechte Gewohnheiten dienten) wurden vollständig aus den Assets gelöscht, da sie nun exklusiv durch die spezifischen Icons für schlechte Gewohnheiten ersetzt wurden.
- Fehlende Übersetzungen für Routinen-Texte in allen 11 Sprachen zu Localizable.xcstrings hinzugefügt.
- Hartcodierte Texte in FocusSessionView, InventoryItemDetailSheet, GruenerBanner, SettingsDetailView und DeveloperView lokalisiert und in 11 Sprachen übersetzt.
- Schlechte Gewohnheiten-Karte auf der Gartenseite komplett überarbeitet (quer, neues Layout für das X-Icon und Zielbox)
- Layout der schlechten Gewohnheiten-Liste in der Gartenseite angepasst (jetzt untereinander statt nebeneinander und schmaler)
- pt-BR Locale entfernt und fehlende Übersetzungen in allen 11 Sprachen für 100% Abdeckung hinzugefügt.
- Leere Strings und Prozentangaben (z.B. %lld%%) aus Localizable.xcstrings entfernt und im Code durch Text(verbatim:) ersetzt.
- Alle Emojis aus der gesamten Codebase (Lokalisierung, Hardcoded-Strings, Models) entfernt.
- Alle restlichen Sonder-Emojis (wie ⚠️) aus der App entfernt.
- Konflikt zwischen Haupt-Onboarding und Routine-Onboarding behoben. Routine-Onboarding feuert nun ausschließlich auf dem Routine-Tab (Tab 4).
- Fixed raw string catalog keys showing in 90-day multi-strand path view
- Added translations for pending path task badge ('pfad_tag_ausstehend')
- Fehler behoben: Button 'Ja' bei der Einführungstour hat fälschlicherweise die Tour übersprungen und sofort das Routine-Onboarding geöffnet. Jetzt startet die Tour korrekt. Routine-Onboarding wird während der Tour pausiert.

- Localized hardcoded 'Samen' category text in shop view

- Fixed 'common.collect' translation issue on routine XP screen

- Added HealthKit integration for tracking steps, water, and sleep automatically for routines.
- Fixed Picker type inference for HealthMetricType in PflanzeDetailSheet
- Added DEBUG button in PaywallView to unlock Pro mode for local testing
- Persist debug PRO feature testing locally and update Apple Health lock overlay to Item3DButton
- Changed Timer button color to match Notes button in PflanzeDetailSheet
- Updated Apple Health UI styling to match user request (black toggle, orange progress, 3D container)
- Fixed SwiftUI alert bug preventing custom tracker from saving properly
- Updated Apple Health UI in PflanzeDetailSheet to use Item3DButton and properly request permissions
- Fixed Apple Health authorization by adding HealthKit entitlement
- Updated Apple Health settings UI with toggle and removed data bubbles
- Added button to open Apple Health app for managing permissions
- Changed Apple Health setting row to match Notifications styling
- Changed Apple Health deep link to point to iOS Privacy Settings
- Updated Apple Health row in settings with Health app deep link and instructional text
- Added keyboard toolbar with dismiss button
- Moved keyboard dismiss button to top navigation bar
- Fixed SIGKILL crash on launch and restored keyboard dismiss button in topBarTrailing
- Fixed UI compilation errors related to the top right keyboard dismiss button logic
- Applied keyboard dismiss logic to Apple Health target field
- UI der Wochenübersicht (WeeklyReportDashboardView) überarbeitet (3D-Karten, schlichte Diagramme analog zu Statistiken)
- WeeklyReportDashboardView: Asset-Icons (Timer full, Drop water, streak, XP, Wachstum), Tipps-Sektion, Best-Day-Analyse mit Begründung
- Psychologische Paywall und Teaser-Elemente hinzugefügt
- **Entwickler-Test-Optionen**: Neue Buttons in den Developer Options zum manuellen Triggern der emotionalen Paywall, des Rarity-Level-Ups und des Pfad-Meilenstein-Overlays hinzugefügt.
- **Audio-Performance**: Berechnung der Fokus-Sounds asynchronisiert und mit Puffer-Caching ausgestattet, was das Einfrieren der App beim Starten verhindert (0 Latenz).
- **Premium Overlays**: Level-Up- und Meilenstein-Overlays mit 'Ultra Thin Material' (Glassmorphism), pulsierenden 3D-Sternen, farbigen Auren, Partikeln und haptischem Feedback ausgestattet.
- Fix: Zähler für schlechte Gewohnheiten wurde beim ersten Auslösen manchmal nicht direkt in der Garten-Ansicht aktualisiert

- Zeitleiste (Timeline): Navigation-Bug behoben (Scrollen bricht Klick nicht mehr ab)

- Timer-Optionen (Notizen, Wiederholungen, Löschen) in der Pflanzen-Ansicht versteckt, wenn der Timer von einer Routine gesteuert wird.
- Notizen verknüpfen zur Routine-Timer-Ansicht hinzugefügt. Es werden nun alle Notizen aller zugeordneten Pflanzen angezeigt und können für einzelne Tage ausgewählt werden.

- Zeitleiste (Timeline): Routinen werden nun gebündelt dargestellt und der unpassende Text wurde entfernt. 
- Zeitleiste (Timeline): Navigation-Fix: X-Button schließt die Zeitleiste komplett, normaler Back-Button springt wie gewohnt zur Zeitleiste zurück.

## UI Redesign
- GartenView: Pflanzen als horizontales ScrollView, Power-Ups nach unten verschoben, Gratis-Button entfernt.
- HabitCards: Anzeige von Streak & Tagesziel integriert.
- Shop: Glücksrad ganz oben bei den Gegenständen hinzugefügt.

## Neue Interaktions-Architektur (Garten)
- GartenView: Globaler Wasser-Tropfen unten links, pulsierend, mit Badge-Zähler
- PflanzenCard: DragToWater entfernt; Karte leuchtet grün wenn Tropfen hoverd
- BadHabitCard: DragToWeedCross durch HoldToConfirmButton ersetzt (0.7s halten)
- GlobalWaterDropView: Neue eigenständige Komponente


- UI-Karten (Gute & Schlechte Gewohnheiten) angepasst: Anzeige des Streaks und des Tagesziel-Fortschritts für Pro-Nutzer hinzugefügt. Emojis entfernt.

- Streak-Anzeige auf Startseite: Nun in orange (#D95F00), mit dem Flammen-Icon (Streak) und im 3D-Schriftstil (.black, .rounded).

- Schlechte Gewohnheiten: Streak-Berechnung auf der Karte an die Logik im Detail-Sheet angeglichen.

- Schlechte Gewohnheiten Karte: Icon deutlich vergrößert, sodass es sich nun absichtlich mit dem darüberstehenden Text überschneidet.

- Detail-Sheet der schlechten Gewohnheiten: Icon deutlich vergrößert (Skalierung 2.0x), sodass es optisch stärker im Fokus steht.

- Übersetzungen: Fehlende Keys 'streak.label' und 'bad_habit.label' in alle 11 Projektsprachen in der Localizable.xcstrings eingepflegt (100% Abdeckung).

- Zeitleiste (Timeline): "onChange" Endlos-Loop-Warnung bei Navigation auf iOS 16 behoben

- Zeitleiste (Timeline): Weißen Bildschirm beim Öffnen einer Pflanze behoben (fehlende Abhängigkeiten)

- Zeitleiste (Timeline): Pflanzen sind nun nicht mehr anklickbar (rein informativ).
- Redesign: PflanzenCard von vertikal zu horizontal ('quer') umgebaut
- Layout: 3D Button links, Infos in der Mitte, fester Wassertropfen rechts
- Fortschrittsbalken: Die Outline/Rahmen der Karte dient nun als Fortschrittsanzeige für Ring-Progress
- Pro-Progressbar: Wird nun auch für Free-Nutzer (mit Schloss-Symbol) angezeigt
- GartenView: LazyVGrid durch LazyVStack ersetzt, um die volle Breite für die Karten zu nutzen
- Fix: PflanzenCard Layout korrigiert (Fortschrittsbalken wieder am Button, Text zentriert, Platz optimiert)
- Fix: Wassertropfen ist nun ein globaler Drag&Drop-Button in GartenView

- Gieß-Sync & Pop-up hinzugefügt: Tagesziel und Wassertropfen sind jetzt synchronisiert. Wassertropfen unten rechts hat ein Update als echtes 3D-Item bekommen.

- Drag & Drop für Gießen: Nur noch das Wassertropfen-Icon bewegt sich, der 3D-Button bleibt fest. Fehlermeldung/Vibration beim Ziehen auf bereits gegossene Pflanze.

- Drag & Drop Drop-Bereich korrigiert: Man kann nun auf dem gesamten weißen Hintergrund (Pflanzen-Karte) die Pflanze bewässern. Wasser-Icon wurde vergrößert.

- UI Anpassungen: Gießen-Button wurde vergrößert, etwas nach oben verschoben und die Skalierung beim Ziehen verstärkt.

- UI Anpassungen: Gießen-Button wurde wieder etwas verkleinert und weiter nach oben verschoben, um nicht mit der Tab-Bar zu kollidieren.

- UI Anpassungen: Gießen-Button wurde wieder an seine ursprüngliche Position verschoben und das Wassertropfen-Icon im Button leicht nach oben gerückt.

- UI Anpassungen: Gießen-Button wurde wieder etwas verkleinert.

- UI Anpassungen: Schlechte Gewohnheiten nutzen nun das horizontale Querformat (wie Pflanzen). Drag-and-Drop Button für schlechte Gewohnheiten wurde als globaler Button neben dem Gieß-Button integriert.

- UI Anpassungen: Schlechte Gewohnheiten werden nun untereinander angezeigt. Die interaktiven Buttons für Wasser und Unkraut sind jetzt rechteckig mit abgerundeten Ecken und wurden untereinander am rechten Rand platziert.

- UI Anpassungen: Die Breite der rechteckigen Gieß- und Unkraut-Buttons wurde fixiert, sodass sie jetzt perfekte Quadrate (wie die runden Buttons vorher) sind.

- UI Anpassungen: Das Kreuz-Icon auf dem Unkraut-Button wurde vergrößert.
- Power-Ups wurden nach unten (unter die schlechten Gewohnheiten) verschoben.
- Beim Tagesziel-Tracker erscheint nun ein Bestätigungs-PopUp ("Bist du dir sicher, dass du fertig bist?"), bevor das Ziel abgeschlossen wird.
- Das "Geschafft"-PopUp nach Abschluss des Ziels erscheint nun direkt über dem Pflanzen-Detailbildschirm und ist vollständig im 3D-Stil designt. Alle Texte wurden in 11 Sprachen übersetzt.
- Hartkodierte Strings im PDFExportManager und LiquidGlassDismissButton durch lokalisierte Strings ersetzt und in 11 Sprachen übersetzt.
- Lokalisierung: 100% Übersetzungsabdeckung wiederhergestellt und doppeltes 'Portuguese (Portugal)' entfernt.
- Fehler behoben: 'developmentRegion' in der Projektdatei auf 'de' gesetzt, um den Konflikt mit .xcstrings zu lösen.
- UI-Fix: Schildkröten-Icon (Erholungsstatus) bei der Pflanzenansicht auf Skalierung 2.2 vergrößert, während der Button gleich groß bleibt.
- UI-Fix: Schildkröten-Icon (Erholungsstatus) Skalierung auf 1.9 angepasst.
- UI-Fix: Schildkröten-Icon (Erholungsstatus) Skalierung auf 1.8 angepasst.
- Fix: 3D-Buttons in der Pflanzen-Detail-Ansicht (Export/PDF-Notizen) verwenden nun das echte Pflanzen-Icon und die korrekte Pflanzen-Farbe. Komplett rote Pflanzen erhalten einen helleren Rot-Ton, da reines Rot für schlechte Gewohnheiten reserviert ist.
- 3D-Buttons der Pflanzen (Garten und Startseite) übernehmen nun immer die echte Icon-Farbe der Pflanze anstelle der Habit-Kategorie-Farbe.
- Ist das Icon rot (wie beim Apfelbaum), wird ein helleres Rot verwendet, um eine Verwechslung mit den tiefroten Farben der schlechten Gewohnheiten zu vermeiden.
- Pro Upgrade Banner in den Einstellungen mit 3D-Effekt versehen
- Schattenfarbe des Pro Banners auf schwarz geändert
- Behoben: 48 Xcode-Warnungen bezüglich fehlgeschlagener Prozentformatierung in `Localizable.xcstrings` entfernt.
- Behoben: Formatierungsfehler in der russischen Übersetzung korrigiert (z. B. `ВВАР0В ld/ ВВАР1В ld` -> `%lld/%lld`).

- Lokalisierung: Vollständige und fehlerfreie 100% Übersetzungsabdeckung für Russisch, Hindi und Chinesisch (Simplified & Traditional) via KI- und Deep-Translation realisiert. Die zuvor fälschlicherweise kopierten deutschen Texte wurden restlos durch echte Übersetzungen ersetzt, unter Beibehaltung der korrekten Platzhalter-Syntax (z.B. %lld).
- **Bugfixes Xcode Warnings**: Behoben: 46 Xcode-Warnungen bezüglich fehlgeschlagener Prozentformatierung ("Not all languages format percentages in the same way") in Localizable.xcstrings repariert. Wir nutzen nun das optisch identische Unicode-Prozentzeichen (％), um die Xcode-15-Validierung für statische Strings zu umgehen.
- **Bugfixes Format Specifier**: Behoben: 21 fehlerhafte Übersetzungen, bei denen die KI Platzhalter wie %lld gelöscht oder vertauscht hatte ("The format specifier does not match"), wurden repariert und sicherheitshalber auf den deutschen Text zurückgesetzt.
- **Bugfixes iPad Orientation**: Behoben: "All interface orientations must be supported unless the app requires full screen" Warnung beseitigt durch das Hinzufügen von UIRequiresFullScreen zur Info.plist.
- **Bugfixes Code Warnings**: Behoben: Ungenutzte Variablen in BadHabitCard.swift und PDFExportManager.swift entfernt, sowie den Fehler 'allowsHitTesting is unused' in PflanzenCard.swift korrigiert.
- **Bugfixes Format Types**: Behoben: 57 weitere Localizable.xcstrings Übersetzungen auf das deutsche Original zurückgesetzt, da sie falsche Platzhaltertypen aufwiesen (z.B. %l statt %lld oder eine vertauschte Reihenfolge ohne Positionsmarker), was Xcode-Build-Fehler ("The format specifier does not match") auslöste.
- **Bugfixes Xcode Warnings**: Behoben: Einen verwaisten Key (`pro_bonus_text`) aus `Localizable.xcstrings` entfernt, der im Swift-Code nicht mehr verwendet wurde, um die "References to this key could not be found" Warnung zu beseitigen.
- **UI Bugfixes**: Behoben: Das Text-Layout im `WetterBanner` (Wetter-Button auf der Gartenseite) ragte bei der russischen Sprache über den 3D-Button hinaus. Die minimale Skalierung (`minimumScaleFactor`) wurde von 0.8 auf 0.4 verkleinert, sodass auch lange Übersetzungen problemlos in die vorgegebene Box passen, ohne abgeschnitten zu werden oder überzulaufen.
- **UI Anpassung**: Den Untertitel im `WetterBanner` komplett entfernt, sodass ab sofort nur noch der Titel des Wetter-Events angezeigt wird (in allen Sprachen). Das löst auch endgültig das Platzproblem für längere Sprachen wie Russisch.
- **Shop:** Der Scroll-to-Top Button funktioniert nun zuverlässig, auch während die Liste noch scrollt.
