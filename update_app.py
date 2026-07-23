import re

file_path = 'Garten_Simulation/Garten_SimulationApp.swift'
with open(file_path, 'r') as f:
    content = f.read()

new_onchange = """            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    container.gardenStore.reloadData()
                    container.streakStore.checkForMissedDays()
                    container.gardenStore.checkScreenTimeExceeded()
                } else if newPhase == .background {
                    AutoBackupManager.shared.checkAndPerformBackup(
                        interval: container.settingsStore.autoBackupInterval,
                        gardenStore: container.gardenStore,
                        shopStore: container.shopStore,
                        achievementStore: container.achievementStore,
                        settingsStore: container.settingsStore,
                        streakStore: container.streakStore,
                        assessmentStore: container.assessmentStore
                    )
                }
            }"""

content = re.sub(r'\.onChange\(of: scenePhase\) \{ oldPhase, newPhase in.*?\}', new_onchange, content, flags=re.DOTALL)

with open(file_path, 'w') as f:
    f.write(content)
