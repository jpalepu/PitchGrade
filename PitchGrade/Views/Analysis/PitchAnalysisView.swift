import SwiftUI

struct PitchAnalysisView: View {
    let analysis: PitchAnalysis
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with score
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(scoreColor)
                            .frame(width: 120, height: 120)
                        
                        VStack {
                            Text("\(analysis.overallScore)")
                                .font(.system(size: 40, weight: .bold))
                            Text("Score")
                                .font(.subheadline)
                        }
                        .foregroundColor(.white)
                    }
                    
                    Text("Pitch Analysis")
                        .font(.title2.bold())
                }
                .padding(.top)
                
                // Analysis sections
                VStack(spacing: 16) {
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
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var scoreColor: Color {
        switch analysis.overallScore {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
} 