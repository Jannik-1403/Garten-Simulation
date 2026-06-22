import re

files = {
    'Models/GrowthAssessmentModel.swift': 'GrowthProfile',
    'Models/LifestyleAssessmentModel.swift': 'LifestyleProfile',
    'Models/AssessmentModel.swift': ['MentalProfile', 'HealthProfile', 'FitnessProfile']
}

for filepath, profiles in files.items():
    with open(filepath, 'r') as f:
        content = f.read()
    
    if isinstance(profiles, str):
        profiles = [profiles]
        
    for profile in profiles:
        # Find var actionKey: String { ... }
        # and insert the new keys after it
        pattern = r'(var actionKey:\s*String\s*\{\s*"[^"]+"\s*\})'
        
        if profile == 'GrowthProfile':
            prefix = 'growth'
        elif profile == 'LifestyleProfile':
            prefix = 'lifestyle'
        elif profile == 'MentalProfile':
            prefix = 'mental'
        elif profile == 'HealthProfile':
            prefix = 'health'
        elif profile == 'FitnessProfile':
            prefix = 'fitness'
            
        replacement = r'\1\n    var buildHabitsKey: String { "assessment.' + prefix + r'.profile.\(rawValue).build" }\n    var breakHabitsKey: String { "assessment.' + prefix + r'.profile.\(rawValue).break" }'
        
        # apply only within the specific enum to avoid global replacements affecting others
        # but since we are doing it per file, AssessmentModel has 3.
        # we can just find the enum block first
        enum_pattern = r'(enum ' + profile + r': String, Codable, CaseIterable \{.*?\n\})'
        
        def repl_enum(match):
            enum_body = match.group(1)
            return re.sub(pattern, replacement, enum_body)
            
        content = re.sub(enum_pattern, repl_enum, content, flags=re.DOTALL)
        
    with open(filepath, 'w') as f:
        f.write(content)
print("Updated profiles!")
