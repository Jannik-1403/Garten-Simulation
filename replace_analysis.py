import re
import glob

replacement = """                    }

                    // Detailed Analysis
                    DetailedAssessmentAnalysisView(
                        result: result,
                        color: AppColors.color(for: profile.color)
                    )
                    .padding(.bottom, 6)"""

files = glob.glob('Garten_Simulation/Views/Profile/*AssessmentView*.swift')

for file in files:
    with open(file, 'r') as f:
        content = f.read()
    
    # Regex to match the end of the previous block and the whole Reality Check block
    pattern = r'                    \}\s*// Reality Check Description\s*VStack\(alignment: \.leading, spacing: 12\) \{.*?\.padding\(\.horizontal, 20\)\s*\.padding\(\.bottom, 6\)'
    
    new_content = re.sub(pattern, replacement, content, flags=re.DOTALL)
    
    if new_content != content:
        with open(file, 'w') as f:
            f.write(new_content)
        print(f"Updated {file}")
    else:
        print(f"No match in {file}")
