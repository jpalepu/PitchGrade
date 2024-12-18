import SwiftUI

struct AnalysisReportView: View {
    @EnvironmentObject private var viewModel: PitchViewModel
    @State private var isLoading = true
    @State private var showingExportSheet = false
    @State private var pdfData: Data?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if isLoading {
                    LoadingView()
                } else if let analysis = viewModel.pitchAnalysis {
                    AnalysisContent(analysis: analysis)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button {
                            exportToPDF(analysis: analysis)
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Report")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button {
                            withAnimation {
                                viewModel.currentStep = .selectMode
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Try Again")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemBackground))
                            .foregroundColor(.blue)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100) // Space for tab bar
                } else {
                    ErrorView()
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingExportSheet) {
            if let pdfData = pdfData {
                ShareSheet(activityItems: [pdfData])
            }
        }
        .onAppear {
            // Start with loading state
            isLoading = true
            
            // Simulate API call delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        }
    }
    
    private func exportToPDF(analysis: PitchAnalysis) {
        // Create PDF document
        let pdfMetaData = [
            kCGPDFContextCreator: "PitchGrade",
            kCGPDFContextAuthor: "PitchGrade Analysis"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Render content
            let titleAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)
            ]
            
            let title = "PitchGrade Analysis Report"
            title.draw(at: CGPoint(x: 50, y: 50), withAttributes: titleAttributes)
            
            // Score
            let scoreAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 36)
            ]
            let score = "Overall Score: \(analysis.overallScore)"
            score.draw(at: CGPoint(x: 50, y: 100), withAttributes: scoreAttributes)
            
            // Feedback
            let feedbackAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)
            ]
            let feedback = analysis.overallFeedback
            feedback.draw(at: CGPoint(x: 50, y: 150), withAttributes: feedbackAttributes)
            
            // Add more content as needed...
        }
        
        self.pdfData = data
        showingExportSheet = true
    }
}

// PDF Content View
struct PDFContent: View {
    let analysis: PitchAnalysis
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            Text("PitchGrade Analysis Report")
                .font(.title.bold())
            
            // Score Section
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
            
            // Sections Analysis
            ForEach(analysis.sections, id: \.title) { section in
                SectionAnalysisView(section: section)
            }
            
            // Improvements
            if !analysis.improvements.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Key Areas for Improvement")
                        .font(.headline)
                    
                    ForEach(analysis.improvements, id: \.self) { improvement in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.orange)
                            
                            Text(improvement)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
        .padding()
    }
    
    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }
}

// Share Sheet for exporting
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private struct LoadingView: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1
    @State private var dots = ""
    
    var body: some View {
        VStack(spacing: 40) {
            // Animated brain icon
            ZStack {
                // Outer circle pulse
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 2)
                    .frame(width: 120, height: 120)
                    .scaleEffect(scale)
                    .opacity(2 - scale)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: scale)
                
                // Rotating circles
                ForEach(0..<3) { i in
                    Circle()
                        .trim(from: 0.5, to: 0.9)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                        .frame(width: 80 + CGFloat(i * 20), height: 80 + CGFloat(i * 20))
                        .rotationEffect(.degrees(rotation + Double(i * 120)))
                }
                
                // Brain icon
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                    .rotationEffect(.degrees(rotation * -0.5))
            }
            .onAppear {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    scale = 1.2
                }
            }
            
            VStack(spacing: 12) {
                Text("Analyzing Your Pitch")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                
                Text("Our AI is evaluating your presentation skills")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(dots)
                    .font(.title2.bold())
                    .foregroundColor(.blue)
                    .onAppear {
                        animateDots()
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 100)
    }
    
    private func animateDots() {
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            count += 1
            dots = String(repeating: ".", count: (count % 4))
        }
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
                ForEach(analysis.sections) { section in
                    AnalysisDetailSection(
                        title: section.title,
                        analysis: section,
                        icon: getIcon(for: section.title)
                    )
                }
                
                if !analysis.improvements.isEmpty {
                    ImprovementsSection(improvements: analysis.improvements)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func getIcon(for title: String) -> String {
        switch title.lowercased() {
        case let t where t.contains("clarity"): return "text.alignleft"
        case let t where t.contains("delivery"): return "person.fill.viewfinder"
        case let t where t.contains("content"): return "doc.text"
        case let t where t.contains("engagement"): return "person.2.fill"
        default: return "checkmark.circle"
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
    let analysis: PitchAnalysis.Section
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

// Update SectionAnalysisView
struct SectionAnalysisView: View {
    let section: PitchAnalysis.Section
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
            
            if !section.recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommendations")
                        .font(.subheadline.bold())
                    
                    ForEach(section.recommendations, id: \.self) { recommendation in
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
