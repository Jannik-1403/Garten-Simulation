with open('Garten_Simulation/Views/Profile/AssessmentView.swift', 'r') as f:
    content = f.read()

content = content.replace(
    "private let available: Set<HabitCategory> = [.finance, .mental, .growth, .health]",
    "private let available: Set<HabitCategory> = [.finance, .mental, .growth, .health, .fitness]"
)

content = content.replace(
    "case .health:  return assessmentStore.healthResult  != nil\n        default:       return false",
    "case .health:  return assessmentStore.healthResult  != nil\n        case .fitness: return assessmentStore.fitnessResult != nil\n        default:       return false"
)

content = content.replace(
    """                case .health:
                    HealthAssessmentQuizView()
                        .environmentObject(assessmentStore)
                        .environmentObject(settings)
                default:
                    EmptyView()""",
    """                case .health:
                    HealthAssessmentQuizView()
                        .environmentObject(assessmentStore)
                        .environmentObject(settings)
                case .fitness:
                    FitnessAssessmentQuizView()
                        .environmentObject(assessmentStore)
                        .environmentObject(settings)
                default:
                    EmptyView()"""
)

with open('Garten_Simulation/Views/Profile/AssessmentView.swift', 'w') as f:
    f.write(content)
