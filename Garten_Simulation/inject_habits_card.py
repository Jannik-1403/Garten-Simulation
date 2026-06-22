import re
import glob

files = [
    'Views/Profile/GrowthAssessmentViews.swift',
    'Views/Profile/LifestyleAssessmentViews.swift',
    'Views/Profile/MentalAssessmentViews.swift',
    'Views/Profile/HealthAssessmentViews.swift',
    'Views/Profile/FitnessAssessmentViews.swift'
]

for filepath in files:
    with open(filepath, 'r') as f:
        content = f.read()
    
    # We look for `// Score Bars`
    replacement = r'''                    // Habits
                    ResultHabitsCard(buildHabitsKey: profile.buildHabitsKey, breakHabitsKey: profile.breakHabitsKey)
                        .padding(.bottom, 6)

                    // Score Bars'''
    
    content = re.sub(r'(\s+)// Score Bars', r'\1' + replacement.replace('\n', r'\n\1').lstrip(), content, count=1)
    
    with open(filepath, 'w') as f:
        f.write(content)
        
print("Injected ResultHabitsCard in all views!")
