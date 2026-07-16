---
name: app-builder-autopilot
description: Generiert Code für Garten_Simulation und führt danach IMMER vollautomatisch Lokalisierung, Tests, Fehlerbehebung und Screenshots aus.
---

# Arbeitsanweisung (Wird nach JEDER Code-Änderung automatisch ausgeführt)

Sobald du Code generierst oder änderst, durchlaufe diese Schritte komplett autonom:

## Schritt 1: Lokalisierung in den String Catalog
1. Scanne den neu geschriebenen SwiftUI-Code auf hartkodierte Strings.
2. Trage neue Texte direkt in die `Garten_Simulation/Garten_Simulation/Localizable.xcstrings` ein.
3. Übersetze die Texte automatisch für ALLE aktiven Sprachen im Projekt. Schau in die `Localizable.xcstrings`, um herauszufinden, welche Sprachen aktiv sind.
4. Ersetze den harten Text im Code durch die lokalisierte Variable (`String(localized: "dein_key")`).

## Schritt 2: Build- & Reparaturschleife im Simulator (mit Branch-Isolierung!)
**WICHTIG für parallele Agenten:** Damit zwei Agenten nicht denselben Simulator blockieren, erstelle und nutze für deinen aktuellen Branch IMMER einen eigenen Simulator!
1. Starte das Terminal und führe exakt dieses Script aus, um den branch-spezifischen Simulator zu nutzen und zu testen:
   ```bash
   BRANCH=$(git rev-parse --abbrev-ref HEAD)
   SIM_NAME="iPhone 15 - $BRANCH"
   if ! xcrun simctl list devices | grep -q "$SIM_NAME"; then
      xcrun simctl create "$SIM_NAME" "com.apple.CoreSimulator.SimDeviceType.iPhone-15"
   fi
   xcodebuild test -project Garten_Simulation.xcodeproj -scheme Garten_Simulation -destination "platform=iOS Simulator,name=$SIM_NAME"
   ```
2. **Wenn Fehler auftreten (Build-Error oder Test-Absturz):**
   - Analysiere das Terminal-Log.
   - Behebe den Fehler direkt im Quellcode der betroffenen `.swift`-Datei.
   - Starte den Test-Befehl neu.
   - Wiederhole dies (Loop), bis der Test fehlerfrei durchläuft.

## Schritt 3: Screenshots für den Nutzer posten
1. Wenn die App fehlerfrei startet, erstelle über das Terminal einen Screenshot aus dem gebooteten branch-spezifischen Simulator:
   ```bash
   BRANCH=$(git rev-parse --abbrev-ref HEAD)
   SIM_NAME="iPhone 15 - $BRANCH"
   SIM_ID=$(xcrun simctl list devices | grep "$SIM_NAME" | grep "Booted" | awk -F'[{}]' '{print $2}')
   xcrun simctl io "$SIM_ID" screenshot screenshot_de.png
   ```
2. Starte die App testweise auf Englisch neu, um die Übersetzung zu prüfen:
   ```bash
   BRANCH=$(git rev-parse --abbrev-ref HEAD)
   SIM_NAME="iPhone 15 - $BRANCH"
   xcodebuild test -project Garten_Simulation.xcodeproj -scheme Garten_Simulation -destination "platform=iOS Simulator,name=$SIM_NAME" -ArgumentsPassedOnLaunch "-AppleLanguages (en) -AppleLocale en_US"
   ```
3. Mache den zweiten Screenshot auf Englisch:
   ```bash
   BRANCH=$(git rev-parse --abbrev-ref HEAD)
   SIM_NAME="iPhone 15 - $BRANCH"
   SIM_ID=$(xcrun simctl list devices | grep "$SIM_NAME" | grep "Booted" | awk -F'[{}]' '{print $2}')
   xcrun simctl io "$SIM_ID" screenshot screenshot_en.png
   ```
4. Poste beide Screenshots (`screenshot_de.png` und `screenshot_en.png`) unaufgefordert direkt hier in den Chat, damit ich das visuelle Ergebnis sehen kann.
