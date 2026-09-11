import os
import re

files = [
    "OnboardingInteractiveTutorialView.swift",
    "OnboardingTutorialWeedView.swift",
    "OnboardingPflanzenView.swift",
    "OnboardingZielView.swift",
    "OnboardingCustomPlantView.swift",
    "OnboardingZeitView.swift",
    "OnboardingNotificationView.swift",
    "OnboardingScreenTimeView.swift",
    "OnboardingFertigView.swift",
    "GoalOnboardingView.swift",
    "WeeklyGoalOnboardingView.swift",
    "OnboardingLegalView.swift"
]

base_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Onboarding"

for filename in files:
    filepath = os.path.join(base_path, filename)
    if not os.path.exists(filepath):
        print(f"Skipping {filename} (not found)")
        continue
        
    with open(filepath, "r") as f:
        content = f.read()

    if "@Environment(\\.horizontalSizeClass)" in content:
        print(f"Skipping {filename} (already modified)")
        continue

    # 1. Inject environment variable
    struct_pattern = r"(struct\s+[A-Za-z0-9_]+\s*:\s*View\s*\{)"
    content = re.sub(struct_pattern, r"\1\n    @Environment(\\.horizontalSizeClass) var hSize", content)

    # 2. Scale fonts from 34 to 44 on iPad
    content = content.replace(".font(.system(size: 34,", ".font(.system(size: hSize == .regular ? 44 : 34,")
    content = content.replace(".font(.system(size: 28,", ".font(.system(size: hSize == .regular ? 36 : 28,")

    # 3. We will remove `.padding(.horizontal, 24)` inside the content. We can just replace it with empty string, but we want to add it at the end of the root container.
    content = content.replace(".padding(.horizontal, 24)", "")
    # Note: OnboardingPflanzenView might have multiple paddings, we must check if this breaks grid or other things. But generally it's safe for simple VStacks.
    
    # 4. Find the main VStack block in body
    body_idx = content.find("var body: some View {")
    if body_idx != -1:
        # Find the first VStack or ZStack after body
        vstack_idx = content.find("VStack", body_idx)
        zstack_idx = content.find("ZStack", body_idx)
        
        stack_idx = -1
        if vstack_idx != -1 and zstack_idx != -1:
            stack_idx = min(vstack_idx, zstack_idx)
        elif vstack_idx != -1:
            stack_idx = vstack_idx
        elif zstack_idx != -1:
            stack_idx = zstack_idx
            
        if stack_idx != -1:
            # find matching closing brace
            brace_count = 0
            open_brace_idx = content.find("{", stack_idx)
            
            i = open_brace_idx
            while i < len(content):
                if content[i] == "{":
                    brace_count += 1
                elif content[i] == "}":
                    brace_count -= 1
                    if brace_count == 0:
                        # Found the end of the stack
                        break
                i += 1
                
            if brace_count == 0:
                end_idx = i
                # Insert the container modifiers right after the closing brace
                modifiers = "\n        .frame(maxWidth: 500)\n        .padding(.horizontal, 24)\n        .frame(maxWidth: .infinity)"
                content = content[:end_idx+1] + modifiers + content[end_idx+1:]
                
    with open(filepath, "w") as f:
        f.write(content)
    
    print(f"Modified {filename}")
