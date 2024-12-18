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
            print("DEBUG: AnalysisReportView - Appeared")
            // Add a small delay to show loading state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
            // Score circle
            ScoreCircle(score: analysis.overallScore)
            
            Text("Pitch Analysis")
                .font(.title2.bold())
            
            // Analysis sections
            LazyVStack(spacing: 16) {
                AnalysisSection(
                    title: "Clarity & Structure",
                    content: analysis.clarity,
                    icon: "text.alignleft"
                )
                
                AnalysisSection(
                    title: "Value Proposition",
                    content: analysis.valueProposition,
                    icon: "star"
                )
                
                AnalysisSection(
                    title: "Market Understanding",
                    content: analysis.marketUnderstanding,
                    icon: "chart.pie"
                )
                
                AnalysisSection(
                    title: "Business Model",
                    content: analysis.businessModel,
                    icon: "building.2"
                )
                
                AnalysisSection(
                    title: "Areas for Improvement",
                    content: analysis.improvements,
                    icon: "arrow.up.circle",
                    isImprovement: true
                )
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