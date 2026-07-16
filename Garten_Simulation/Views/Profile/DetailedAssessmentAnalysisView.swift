import SwiftUI

// MARK: - Data Source Model
struct AssessmentDataSource: Identifiable {
    let id = UUID()
    let sectionTitle: String
    let items: [String]
}

// MARK: - Shared card background (matches ScoreBreakdownCard exactly)
struct ScoreCardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.18), radius: 0, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
    }
}

extension View {
    func scoreCardStyle() -> some View {
        modifier(ScoreCardBackground())
    }
}


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

// MARK: - Main View
struct DetailedAssessmentAnalysisView: View {
    let result: DetailedAssessmentResult
    let color: Color

    var body: some View {
        VStack(spacing: 12) {

            AnalysisRowItem(
                icon: result.strengthIcon,
                iconColor: .green,
                title: String(localized: "assessment.analysis.strength_title", defaultValue: "Deine Stärke"),
                subtitle: String(localized: String.LocalizationValue(result.topStrengthKey)))

            AnalysisRowItem(
                icon: result.weaknessIcon,
                iconColor: .red,
                title: String(localized: "assessment.analysis.weakness_title", defaultValue: "Deine Schwäche"),
                subtitle: String(localized: String.LocalizationValue(result.biggestWeaknessKey)))

            AnalysisRowItem(
                icon: "exclamationmark.triangle.fill",
                iconColor: .orange,
                title: String(localized: "assessment.analysis.pitfall_title", defaultValue: "Was du vermeiden musst"),
                subtitle: String(localized: String.LocalizationValue(result.pitfallKey)))

            BenchmarkCard(
                percentile: result.benchmarkPercentile,
                label: result.benchmarkLabel,
                labelColor: color,
                description: String(localized: String.LocalizationValue(result.benchmarkKey)))
        }
        .padding(.horizontal, 20)
    }
}
