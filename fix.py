with open("Garten_Simulation/ProfilView.swift", "r") as f:
    lines = f.readlines()

# Find the end of ProfilView struct
# The struct ends around line 316
# Let's remove the extraneous `}` by looking near line 250 where I added it
with open("Garten_Simulation/ProfilView.swift", "w") as f:
    for line in lines:
        if line.strip() == "}" and lines.index(line) == 249: # the extra one I added was here
            continue
        f.write(line)
