import re

with open("Garten_Simulation/Views/SettingsView.swift", "r") as f:
    content = f.read()

# We need to extract the parts of VStack(spacing: 32) inside ScrollView.
# It starts around:
#                         // Sections
#                         VStack(spacing: 32) {
#                             VStack(spacing: 32) {

start_marker = """                        // Sections
                        VStack(spacing: 32) {
                            VStack(spacing: 32) {
"""

# Let's find this section.
start_idx = content.find(start_marker)
if start_idx == -1:
    print("Could not find start marker")
    exit(1)

# The first inner VStack ends with:
#                             } // End of first group
#                             
#                             VStack(spacing: 32) {
mid_marker = "} // End of first group"
mid_idx = content.find(mid_marker, start_idx)

# The second inner VStack ends with:
#                             } // End of second group
#                         }
end_marker = """                            } // End of second group
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)"""

end_idx = content.find(end_marker, mid_idx)

if mid_idx == -1 or end_idx == -1:
    print("Could not find mid or end markers")
    exit(1)

# Extract first part
first_part = content[start_idx + len(start_marker):mid_idx].strip()

# Extract second part
second_start_str = "VStack(spacing: 32) {"
second_start_idx = content.find(second_start_str, mid_idx) + len(second_start_str)
second_part = content[second_start_idx:content.find("} // End of second group", second_start_idx)].strip()

# Now construct the new properties
properties = f"""
    // MARK: - Sub-Views
    @ViewBuilder
    private var primarySettingsSections: some View {{
        {first_part}
    }}
    
    @ViewBuilder
    private var secondarySettingsSections: some View {{
        {second_part}
    }}
"""

# Insert properties right after "private var aktuelleTierStufe" closing brace
insert_marker = """    private var aktuelleTierStufe: GartenTierStufe {
        GartenTierStufe.fuer(level: gardenStore.gartenStufe)
    }
"""
insert_idx = content.find(insert_marker) + len(insert_marker)
new_content = content[:insert_idx] + properties + content[insert_idx:]

# Now replace the body
body_replacement = """                        // Sections
                        VStack(spacing: 32) {
                            primarySettingsSections
                            secondarySettingsSections
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)"""

# We have to find where to replace
replace_start = new_content.find(start_marker)
replace_end = new_content.find(end_marker) + len(end_marker)

final_content = new_content[:replace_start] + body_replacement + new_content[replace_end:]

with open("Garten_Simulation/Views/SettingsView.swift", "w") as f:
    f.write(final_content)

print("SettingsView successfully updated.")
