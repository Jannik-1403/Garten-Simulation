import SwiftUI

struct DetailedAssessmentAnalysisView: View {
    let result: DetailedAssessmentResult
    let color: Color
    
    var body: some View {
        VStack(spacing: 24) {
            
            // 1. TOP STRENGTH
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "star.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                    Text(String(localized: "assessment.analysis.strength_title", defaultValue: "Deine größte Stärke"))
                        .font(.headline)
                        .foregroundStyle(.green)
                    Spacer()
                }
                
                Text(String(localized: String.LocalizationValue(result.topStrengthKey)))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(LinearGradient(colors: [.green.opacity(0.6), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
            )
            .shadow(color: .green.opacity(0.1), radius: 10, x: 0, y: 5)
            
            // 2. BIGGEST WEAKNESS (REALITY CHECK)
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                    Text(String(localized: "assessment.analysis.weakness_title", defaultValue: "Die harte Wahrheit"))
                        .font(.headline)
                        .foregroundStyle(.red)
                    Spacer()
                }
                
                Text(String(localized: String.LocalizationValue(result.biggestWeaknessKey)))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(LinearGradient(colors: [.red.opacity(0.6), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
            )
            .shadow(color: .red.opacity(0.1), radius: 10, x: 0, y: 5)
            
            // 3. PITFALL TO AVOID
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "xmark.octagon.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)
                    Text(String(localized: "assessment.analysis.pitfall_title", defaultValue: "Gefahrenzone: Was du vermeiden musst"))
                        .font(.headline)
                        .foregroundStyle(.orange)
                    Spacer()
                }
                
                Text(String(localized: String.LocalizationValue(result.pitfallKey)))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(LinearGradient(colors: [.orange.opacity(0.6), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
            )
            .shadow(color: .orange.opacity(0.1), radius: 10, x: 0, y: 5)
            
            // 4. BENCHMARK
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.title2)
                        .foregroundStyle(color)
                    Text(String(localized: "assessment.analysis.benchmark_title", defaultValue: "Dein Benchmark-Score"))
                        .font(.headline)
                        .foregroundStyle(color)
                    Spacer()
                }
                
                Text(String(localized: String.LocalizationValue(result.benchmarkKey)))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Visual progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                        
                        Capsule()
                            .fill(LinearGradient(colors: [color.opacity(0.6), color], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * result.benchmarkPercentile, height: 12)
                        
                        // Marker
                        Circle()
                            .fill(Color.white)
                            .frame(width: 16, height: 16)
                            .shadow(radius: 2)
                            .offset(x: (geo.size.width * result.benchmarkPercentile) - 8)
                    }
                }
                .frame(height: 16)
                
                HStack {
                    Text(String(localized: "benchmark.bottom", defaultValue: "Anfänger"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(localized: "benchmark.top", defaultValue: "Top 1%"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(LinearGradient(colors: [color.opacity(0.6), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
            )
            .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
            
        }
        .padding(.horizontal, 20)
    }
}
