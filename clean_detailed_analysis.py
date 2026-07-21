import re

with open("Garten_Simulation/Views/Profile/DetailedAssessmentAnalysisView.swift", "r") as f:
    content = f.read()

# Replace AnalysisRowItem completely
new_analysis_row = """
// MARK: - Analysis Row
struct AnalysisRowItem: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .scoreCardStyle()
    }
}
"""

content = re.sub(r'// MARK: - Analysis Row \(Tippable\).*?// MARK: - Data Source Sheet', new_analysis_row + '\n// MARK: - Data Source Sheet', content, flags=re.DOTALL)

# Delete DataSourceSheet and AssessmentDataSource completely
content = re.sub(r'// MARK: - Data Source Model.*?// MARK: - Shared card background', '// MARK: - Shared card background', content, flags=re.DOTALL)
content = re.sub(r'// MARK: - Data Source Sheet.*?// MARK: - Benchmark Card', '// MARK: - Benchmark Card', content, flags=re.DOTALL)

# Replace BenchmarkCard completely
new_benchmark_card = """
// MARK: - Benchmark Card
struct BenchmarkCard: View {
    let percentile: Double
    let label: String
    let labelColor: Color
    let description: String

    @State private var animated = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(String(localized: "assessment.analysis.benchmark_title", defaultValue: "Dein Score im Vergleich"))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)
                Spacer()
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(labelColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(labelColor.opacity(0.12))
                    .clipShape(Capsule())
            }

            // Progress bar – exactly like ScoreBar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(UIColor.systemFill))
                        .frame(height: 10)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [labelColor.opacity(0.6), labelColor],
                            startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(10, geo.size.width * (animated ? percentile : 0)), height: 10)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1), value: animated)
                }
            }
            .frame(height: 10)

            HStack {
                Text(String(localized: "benchmark.label.bottom", defaultValue: "Einsteiger"))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Text(String(localized: "benchmark.label.top", defaultValue: "Elite"))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .scoreCardStyle()
        .onAppear { animated = true }
    }
}
"""
content = re.sub(r'// MARK: - Benchmark Card.*// MARK: - Main View', new_benchmark_card + '\n// MARK: - Main View', content, flags=re.DOTALL)

with open("Garten_Simulation/Views/Profile/DetailedAssessmentAnalysisView.swift", "w") as f:
    f.write(content)
