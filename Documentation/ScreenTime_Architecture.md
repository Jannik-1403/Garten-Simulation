# Screen Time Architektur & Anti-Cheat System (Garten Simulation)

## 1. Wann wird die Bildschirmzeit abgefragt und eingerichtet?
**Die initiale Abfrage:**
* Die App muss zwingend beim ersten Start (oder im Onboarding) die Systemberechtigung anfordern. Im Code passiert das über `AuthorizationCenter.shared.requestAuthorization(for: .individual)`.
* In diesem Moment ploppt beim Nutzer ein natives iOS-Fenster auf: *"Garten Simulation möchte auf die Bildschirmzeit zugreifen"*. Stimmt der Nutzer zu, wird der Status auf `.approved` gesetzt. Ab jetzt darf die App Schilde über andere Apps legen.

**Die Einrichtung in der App:**
* Die Nutzer konfigurieren ihre Limits über den `FamilyActivityPicker` (das native iOS-UI, in dem man Apps wie TikTok oder Instagram mit Häkchen versieht).
* Die App speichert diese Auswahlen in drei verschiedenen Bereichen:
  1. **Dauerhafte Sperren** (`permanentBlockSelection`): Apps, die grundsätzlich geblockt sind.
  2. **Zeitlimits** (`dailyLimitSelection` & `limitSelections`): Apps, die nach einer bestimmten Zeit gesperrt werden.
  3. **Fokus-Listen** (`focusFullBlockSelection` / `focusPartialBlockSelection`): Apps, die *nur* während eines laufenden Pflanzen-Timers geblockt werden.

## 2. Der Unterschied: Fokus Timer vs. Normale Einstellungen
Um zu verhindern, dass sich Sperren gegenseitig überschreiben, nutzen wir im `ScreenTimeManager` **zwei getrennte Schild-Stores** (`ManagedSettingsStore`):

* **Normale Einstellungen (`permanentStore`)**: Hier liegen die dauerhaften Sperren. Dieser Store ist immer aktiv, egal was der Nutzer gerade in der App macht. Wenn eine App hier drin ist, bleibt sie zu.
* **Fokus Timer (`scheduledStore`)**: Das ist unser dynamischer Schild. Wenn der Nutzer den Fokus Timer ("Handy weglegen" oder "Lernen") startet, schießt die App die Fokus-Listen in den `scheduledStore`. 
  * *Die Magie:* Apple legt die Schilde beider Stores automatisch übereinander. Wenn der Timer abläuft, leeren wir einfach den `scheduledStore` (`unblockApps()`), und die Timer-Sperren fallen weg – aber die permanenten Sperren aus dem `permanentStore` bleiben intakt!

## 3. Wo findet man das auf dem iPhone (iOS-Einstellungen)?
Der Nutzer (oder das System) verwaltet diese tiefe Integration an zwei Orten im iPhone:
1. **Der Hauptschalter:** `Einstellungen` -> `Bildschirmzeit` -> `App- & Website-Aktivitäten`. Hier ist der Haupt-Datenstamm für Apples Screen Time API.
2. **Die App-Berechtigung:** `Einstellungen` -> `Garten Simulation`. Dort gibt es (sofern einmal abgefragt) einen Schalter für "Bildschirmzeit".

## 4. Wann ist sie deaktiviert und wie kann der Nutzer sie killen?
Hier wird es kritisch. Du kannst den Nutzer systemseitig **nicht** zwingen, die Bildschirmzeit an zu lassen. Apple gibt dem Nutzer immer die oberste Kontrolle. 

**So kann der Nutzer das System brechen:**
1. Er geht in `Einstellungen` -> `Bildschirmzeit` -> `App- & Website-Aktivitäten` und schaltet die Funktion komplett aus.
2. Er geht in `Einstellungen` -> `Garten Simulation` und entzieht der App dort den Schalter für die Bildschirmzeit.
3. *Ergebnis:* iOS löscht sofort alle deine Schilde (`permanentStore` und `scheduledStore` verpuffen) und deine App-Tokens (die IDs der blockierten Apps) werden ungültig. Die Sperren sind offen.

## 5. Das aktuelle Anti-Cheat-System
Da wir diesen Verrat nicht technisch blockieren können, reagieren wir auf App-Ebene.
* Sobald der Nutzer den Schalter in iOS umlegt, ändert sich im `ScreenTimeManager` der `AuthorizationStatus` sofort von `.approved` auf `.denied`.
* Beim nächsten Öffnen der App (oder wenn sie aus dem Hintergrund zurückkehrt) feuert das `CheatPunishmentOverlay`.
* **Das Resultat:** Die App ist durch das rote "🚨 SYSTEMZUGRIFF BLOCKIERT" Overlay komplett gesperrt. Der Nutzer kann seine Pflanze nicht mehr pflegen, er kann nichts mehr klicken. Zusätzlich greift `punishForCheating()` und zieht der Pflanze unerbittlich das Leben ab.
* **Der Ausweg:** Der einzige Button auf diesem Bildschirm führt ihn zurück in die iOS-Einstellungen. Erst wenn er die Bildschirmzeit dort wieder brav aktiviert (Status springt auf `.approved`), verschwindet das Overlay und er kann seinen Garten wieder retten.

## 6. Offene Schwachstelle: Der Ghost-Mode Exploit
**Das Problem:** Die aktuelle Logik feuert nur, wenn die App mit dem Status `.denied` aus dem Hintergrund zurückkehrt oder neu startet. Beendet der Nutzer die App komplett (Force Quit), deaktiviert die Bildschirmzeit, verweilt stundenlang in blockierten Apps, reaktiviert die Bildschirmzeit und startet die App erst *danach* wieder, so verläuft der Start mit Status `.approved`. Die Manipulation im Hintergrund bleibt unbemerkt.

**Die Lösung (Geplant nach der Testphase):** Tiefe Integration in die `DeviceActivityMonitor` Extension, um Hintergrund-Callbacks (Schild-Manipulationen und Thresholds) abzufangen und den Regelverstoß via SharedUserDefaults (`AppGroup`) oder Hintergrund-Datenbank auch bei geschlossener App verlässlich in die Main-App zu übertragen.
