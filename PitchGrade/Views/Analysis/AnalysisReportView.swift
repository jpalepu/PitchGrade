import SwiftUI

struct AnalysisReportView: View {
    @EnvironmentObject private var viewModel: PitchViewModel
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if isLoading {
                    LoadingView()
                } else if let analysis = viewModel.pitchAnalysis {
                    AnalysisContent(analysis: analysis)
                } else {
                    ErrorView()
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            // Start with loading state
            isLoading = true
            
            // Add a small delay to ensure analysis is processed
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isLoading = viewModel.pitchAnalysis == nil
            }
        }
        .onChange(of: viewModel.pitchAnalysis) { newValue in
            if newValue != nil {
                // Analysis is available, stop loading
                isLoading = false
            }
        }
    }
}

private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Analyzing your pitch...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 100)
    }
}

private struct ErrorView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text("Unable to analyze pitch")
                .font(.headline)
            
            Text("Please try again later")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 100)
    }
}

private struct AnalysisContent: View {
    let analysis: PitchAnalysis
    
    var body: some View {
        VStack(spacing: 24) {
            ScoreCircle(score: analysis.overallScore)
            
            Text("Pitch Analysis")
                .font(.title2.bold())
            
            Text(analysis.overallFeedback)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            LazyVStack(spacing: 16) {
                AnalysisDetailSection(
                    title: "Clarity & Structure",
                    analysis: analysis.clarity,
                    icon: "text.alignleft"
                )
                
                AnalysisDetailSection(
                    title: "Delivery Style",
                    analysis: analysis.deliveryStyle,
                    icon: "person.fill.viewfinder"
                )
                
                // ... other sections ...
                
                ImprovementsSection(improvements: analysis.improvements)
            }
            .padding(.horizontal)
        }
    }
}

private struct ScoreCircle: View {
    let score: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(scoreColor)
                .frame(width: 120, height: 120)
            
            VStack {
                Text("\(score)")
                    .font(.system(size: 40, weight: .bold))
                Text("Score")
                    .font(.subheadline)
            }
            .foregroundColor(.white)
        }
    }
    
    private var scoreColor: Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
}

private struct AnalysisDetailSection: View {
    let title: String
    let analysis: PitchAnalysis.SectionAnalysis
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
                
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                ScoreTag(score: analysis.score)
            }
            
            Text(analysis.feedback)
                .font(.body)
                .foregroundColor(.secondary)
            
            if !analysis.examples.isEmpty {
                ExamplesView(examples: analysis.examples)
            }
            
            if !analysis.recommendations.isEmpty {
                RecommendationsView(recommendations: analysis.recommendations)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
}

private struct ScoreTag: View {
    let score: Int
    
    var body: some View {
        Text("\(score)")
            .font(.system(.caption, design: .rounded).bold())
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(scoreColor)
            .cornerRadius(8)
    }
    
    private var scoreColor: Color {
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
                .foregroundColor(.primary)
            
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
                .foregroundColor(.primary)
            
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

private struct ImprovementsSection: View {
    let improvements: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 20))
                
                Text("Key Areas for Improvement")
                    .font(.headline)
            }
            
            ForEach(improvements, id: \.self) { improvement in
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
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
} 
