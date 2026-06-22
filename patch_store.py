import re

with open('Garten_Simulation/Stores/AssessmentStore.swift', 'r') as f:
    content = f.read()

# Add to Published State
content = content.replace(
    "@Published var healthResult: HealthAssessmentResult? {\n        didSet { persistHealth() }\n    }",
    "@Published var healthResult: HealthAssessmentResult? {\n        didSet { persistHealth() }\n    }\n\n    @Published var fitnessResult: FitnessAssessmentResult? {\n        didSet { persistFitness() }\n    }"
)

# Add to persist()
content = content.replace(
    "persistHealth()\n    }",
    "persistHealth()\n        persistFitness()\n    }"
)

# Add to load()
content = content.replace(
    "loadHealth()\n    }",
    "loadHealth()\n        loadFitness()\n    }"
)

fitness_extension = """

// MARK: - Fitness Assessment Extension

extension AssessmentStore {

    // MARK: Public API — Fitness

    func submitFitnessQuiz(answers: [Int: FitnessAnswer]) {
        var score = FitnessRawScore()

        for (_, answer) in answers {
            score.konsistenz += answer.delta.konsistenz
            score.intensitaet += answer.delta.intensitaet
            score.verantwortung += answer.delta.verantwortung
        }

        let profile = FitnessScoringEngine.computeProfile(from: score)

        fitnessResult = FitnessAssessmentResult(
            profile: profile,
            rawKonsistenz: score.konsistenz,
            rawIntensitaet: score.intensitaet,
            rawVerantwortung: score.verantwortung,
            date: Date()
        )
    }

    func resetFitnessResult() {
        fitnessResult = nil
    }

    // MARK: Persistence — Fitness

    private var fitnessResultKey: String { "assessmentStore.fitnessResult" }

    func persistFitness() {
        if let result = fitnessResult,
           let encoded = try? JSONEncoder().encode(result) {
            UserDefaults.standard.set(encoded, forKey: fitnessResultKey)
        } else {
            UserDefaults.standard.removeObject(forKey: fitnessResultKey)
        }
    }

    func loadFitness() {
        if let data = UserDefaults.standard.data(forKey: fitnessResultKey),
           let decoded = try? JSONDecoder().decode(FitnessAssessmentResult.self, from: data) {
            self.fitnessResult = decoded
        }
    }
}
"""

with open('Garten_Simulation/Stores/AssessmentStore.swift', 'w') as f:
    f.write(content + fitness_extension)
