import re

file_path = "Garten_Simulation/Views/WaterTracker/DailyFeedbackView.swift"
with open(file_path, "r") as f:
    content = f.read()

# Add wrapper view at the top
wrapper = """
struct DailyHealthScoreCardWrapper: View {
    let date: Date
    @EnvironmentObject var gardenStore: GardenStore
    @StateObject private var vm = DailyFeedbackViewModel()
    
    var body: some View {
        DailyHealthScoreCard(vm: vm)
            .onAppear {
                vm.activeHabits = gardenStore.sichtbarePflanzen
                vm.targetDate = date
                vm.reevaluate()
            }
            .onChange(of: gardenStore.sichtbarePflanzen.count) { _ in
                vm.activeHabits = gardenStore.sichtbarePflanzen
                vm.reevaluate()
            }
    }
}
"""

if "DailyHealthScoreCardWrapper" not in content:
    content = content.replace("struct DailyHealthScoreCard: View {", wrapper + "\nstruct DailyHealthScoreCard: View {")
    with open(file_path, "w") as f:
        f.write(content)
