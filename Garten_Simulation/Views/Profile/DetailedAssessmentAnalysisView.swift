import SwiftUI

// MARK: - Data Source Model
struct AssessmentDataSource: Identifiable {
    let id = UUID()
    let sectionTitle: String
    let items: [String]
}

// MARK: - Neumorphic Helpers
extension View {
    func neumorphicCard(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: Color.black.opacity(0.09), radius: 8, x: 5, y: 5)
            .shadow(color: Color.white.opacity(0.95), radius: 8, x: -5, y: -5)
    }
}

// MARK: - Analysis Row Item (Tippable)
struct AnalysisRowItem: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let dataSource: [AssessmentDataSource]

    @State private var showingSource = false

    var body: some View {
        Button(action: { showingSource = true }) {
            HStack(alignment: .top, spacing: 14) {
                // Neumorphic Icon
                ZStack {
                    Circle()
                        .fill(Color(UIColor.systemBackground))
                        .frame(width: 42, height: 42)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 3, y: 3)
                        .shadow(color: Color.white.opacity(0.9), radius: 4, x: -3, y: -3)
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(iconColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(4)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
        .neumorphicCard()
        .sheet(isPresented: $showingSource) {
            DataSourceSheet(title: title, dataSources: dataSource)
        }
    }
}

// MARK: - Data Source Sheet
struct DataSourceSheet: View {
    let title: String
    let dataSources: [AssessmentDataSource]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(String(localized: "assessment.source.intro", defaultValue: "So haben wir diese Einschätzung berechnet:"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    ForEach(dataSources) { source in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(source.sectionTitle)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                                .padding(.horizontal, 20)

                            VStack(spacing: 0) {
                                ForEach(Array(source.items.enumerated()), id: \.offset) { index, item in
                                    HStack(alignment: .top, spacing: 10) {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 5))
                                            .foregroundStyle(.secondary)
                                            .padding(.top, 7)
                                        Text(item)
                                            .font(.subheadline)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)

                                    if index < source.items.count - 1 {
                                        Divider().padding(.leading, 16)
                                    }
                                }
                            }
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "common.done", defaultValue: "Fertig")) { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Benchmark Section
struct BenchmarkCard: View {
    let percentile: Double // 0.0 = worst, 1.0 = best
    let label: String
    let labelColor: Color
    let description: String
    let dataSources: [AssessmentDataSource]

    @State private var showingSource = false

    var body: some View {
        Button(action: { showingSource = true }) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(String(localized: "assessment.analysis.benchmark_title", defaultValue: "Benchmark"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(label)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(labelColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(labelColor.opacity(0.12))
                        .clipShape(Capsule())

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }

                // Neumorphic inset track
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Track (inset look)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(UIColor.systemBackground))
                            .frame(height: 10)
                            .shadow(color: Color.black.opacity(0.08), radius: 3, x: 2, y: 2)
                            .shadow(color: Color.white.opacity(0.9), radius: 3, x: -2, y: -2)

                        // Fill
                        let fillW = max(10.0, geo.size.width * percentile)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(
                                colors: [labelColor.opacity(0.45), labelColor],
                                startPoint: .leading, endPoint: .trailing))
                            .frame(width: fillW, height: 10)
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
            .padding(16)
        }
        .buttonStyle(.plain)
        .neumorphicCard()
        .sheet(isPresented: $showingSource) {
            DataSourceSheet(
                title: String(localized: "assessment.analysis.benchmark_title", defaultValue: "Benchmark"),
                dataSources: dataSources
            )
        }
    }
}

// MARK: - Main View
struct DetailedAssessmentAnalysisView: View {
    let result: DetailedAssessmentResult
    let color: Color

    var body: some View {
        VStack(spacing: 16) {

            AnalysisRowItem(
                icon: result.strengthIcon,
                iconColor: .green,
                title: String(localized: "assessment.analysis.strength_title", defaultValue: "Deine Stärke"),
                subtitle: String(localized: String.LocalizationValue(result.topStrengthKey)),
                dataSource: result.strengthDataSources
            )

            AnalysisRowItem(
                icon: result.weaknessIcon,
                iconColor: .red,
                title: String(localized: "assessment.analysis.weakness_title", defaultValue: "Deine Schwäche"),
                subtitle: String(localized: String.LocalizationValue(result.biggestWeaknessKey)),
                dataSource: result.weaknessDataSources
            )

            AnalysisRowItem(
                icon: "exclamationmark.triangle.fill",
                iconColor: .orange,
                title: String(localized: "assessment.analysis.pitfall_title", defaultValue: "Was du vermeiden musst"),
                subtitle: String(localized: String.LocalizationValue(result.pitfallKey)),
                dataSource: result.pitfallDataSources
            )

            BenchmarkCard(
                percentile: result.benchmarkPercentile,
                label: result.benchmarkLabel,
                labelColor: color,
                description: String(localized: String.LocalizationValue(result.benchmarkKey)),
                dataSources: result.benchmarkDataSources
            )
        }
        .padding(.horizontal, 20)
    }
}
