import SwiftUI

struct PitchAnalysisView: View {
    let analysis: PitchAnalysis
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Overall Score
                VStack(spacing: 8) {
                    Text("Overall Score")
                        .font(.headline)
                    
                    Text("\(analysis.overallScore)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(scoreColor(analysis.overallScore))
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
                // Overall Feedback
                VStack(alignment: .leading, spacing: 8) {
                    Text("Overall Feedback")
                        .font(.headline)
                    
                    Text(analysis.overallFeedback)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
                // Sections Analysis
                ForEach(analysis.sections) { section in
                    SectionAnalysisCard(section: section)
                }
                
                // Improvements
                if !analysis.improvements.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Areas for Improvement")
                            .font(.headline)
                        
                        ForEach(analysis.improvements, id: \.self) { improvement in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 14))
                                
                                Text(improvement)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
}

struct SectionAnalysisCard: View {
    let section: PitchAnalysis.Section
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(section.title)
                    .font(.headline)
                
                Spacer()
                
                Text("\(section.score)")
                    .font(.headline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(scoreColor(section.score))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Text(section.feedback)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !section.examples.isEmpty {
                ExamplesView(examples: section.examples)
            }
            
            if !section.recommendations.isEmpty {
                RecommendationsView(recommendations: section.recommendations)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
}

private struct ExamplesView: View {
    let examples: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Examples")
                .font(.subheadline.bold())
            
            ForEach(examples, id: \.self) { example in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 14))
                    
                    Text(example)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

private struct RecommendationsView: View {
    let recommendations: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommendations")
                .font(.subheadline.bold())
            
            ForEach(recommendations, id: \.self) { recommendation in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 14))
                    
                    Text(recommendation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
} 
