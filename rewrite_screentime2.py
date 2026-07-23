import re

with open('Garten_Simulation/Views/ScreenTimeSettingsView.swift', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add State variables
state_vars = """    @State private var pendingLimitAction: (() -> Void)? = nil
    
    @State private var showInfoAlert = false
    @State private var infoAlertTitle = ""
    @State private var infoAlertMessage = ""
"""
content = content.replace("    @State private var pendingLimitAction: (() -> Void)? = nil\n", state_vars)

# 2. Add Alert modifier
alert_mod = """        } message: {
            Text(String(localized: "screenTime.limit.confirm.message", defaultValue: "Sobald das Limit festgelegt ist, kannst du es heute nicht mehr erhöhen!"))
        }
        .alert(infoAlertTitle, isPresented: $showInfoAlert) {
            Button(String(localized: "common.ok", defaultValue: "OK"), role: .cancel) { }
        } message: {
            Text(infoAlertMessage)
        }"""
content = content.replace("""        } message: {
            Text(String(localized: "screenTime.limit.confirm.message", defaultValue: "Sobald das Limit festgelegt ist, kannst du es heute nicht mehr erhöhen!"))
        }""", alert_mod)

# 3. Update sectionHeader3D
old_header = """    private func sectionHeader3D(level: String, title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(level.uppercased())
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                
                ZStack(alignment: .topLeading) {
                    Text(title)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Color.blauPrimary.opacity(0.35))
                        .offset(y: 3)
                    
                    Text(title)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(Color.blauPrimary)
                }
            }
            
            Text(description)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }"""
new_header = """    private func sectionHeader3D(level: String, title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(level.uppercased())
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                
                Button {
                    infoAlertTitle = title
                    infoAlertMessage = description
                    showInfoAlert = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            
            ZStack(alignment: .topLeading) {
                Text(title)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(Color.primary.opacity(0.15))
                    .offset(y: 3)
                
                Text(title)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(Color.primary)
            }
        }
        .padding(.horizontal)
    }"""
content = content.replace(old_header, new_header)

# 4. Remove infoSection from scroll view
content = content.replace("                ebene4Section\n                infoSection\n", "                ebene4Section\n")

# 5. Remove infoSection definition
content = re.sub(r'    // MARK: - Info Section\s*private var infoSection: some View \{.*?\}\s*\.padding\(\.horizontal, 8\)\s*\}', '', content, flags=re.DOTALL)

with open('Garten_Simulation/Views/ScreenTimeSettingsView.swift', 'w', encoding='utf-8') as f:
    f.write(content)

