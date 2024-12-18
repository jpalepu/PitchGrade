import SwiftUI

struct PitchSummaryReviewView: View {
    @EnvironmentObject private var viewModel: PitchViewModel
    @State private var showEditAlert = false
    @State private var isGenerating = true
    @State private var typingText = ""
    @State private var currentIndex = 0
    @State private var rotation = 0.0
    @State private var scale: CGFloat = 1.0
    
    let summary: String
    let typingSpeed: Double = 0.05
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if isGenerating {
                    GeneratingView(rotation: $rotation, scale: $scale)
                } else {
                    // Summary Content
                    VStack(spacing: 8) {
                        Text("Your Pitch Summary")
                            .font(.title2.bold())
                        
                        Text("AI-generated summary of your pitch")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Summary Card with typing animation
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .font(.title2)
                                .foregroundColor(.purple)
                            
                            Text("Generated Summary")
                                .font(.headline)
                        }
                        
                        Text(typingText)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 10)
                    .padding(.horizontal)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button {
                            viewModel.moveToNextStep()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Continue")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button {
                            showEditAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                Text("Start Over")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            startGeneratingAnimation()
        }
        .alert("Start Over", isPresented: $showEditAlert) {
            Button("Go Back", role: .destructive) {
                viewModel.currentStep = .questionnaire
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Would you like to go back and edit your responses?")
        }
    }
    
    private func startGeneratingAnimation() {
        // Start rotation and scale animations
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
            scale = 1.2
        }
        
        // After a delay, show the summary with typing animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isGenerating = false
            startTypingAnimation()
        }
    }
    
    private func startTypingAnimation() {
        guard currentIndex < summary.count else { return }
        
        let index = summary.index(summary.startIndex, offsetBy: currentIndex)
        typingText += String(summary[index])
        currentIndex += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + typingSpeed) {
            startTypingAnimation()
        }
    }
}

private struct GeneratingView: View {
    @Binding var rotation: Double
    @Binding var scale: CGFloat
    
    var body: some View {
        VStack(spacing: 40) {
            // Animated icon
            ZStack {
                // Outer circle pulse
                Circle()
                    .stroke(Color.purple.opacity(0.2), lineWidth: 2)
                    .frame(width: 120, height: 120)
                    .scaleEffect(scale)
                    .opacity(2 - scale)
                
                // Rotating circles
                ForEach(0..<3) { i in
                    Circle()
                        .trim(from: 0.5, to: 0.9)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 2)
                        .frame(width: 80 + CGFloat(i * 20), height: 80 + CGFloat(i * 20))
                        .rotationEffect(.degrees(rotation + Double(i * 120)))
                }
                
                // Center icon
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 40))
                    .foregroundColor(.purple)
                    .rotationEffect(.degrees(rotation * -0.5))
            }
            
            VStack(spacing: 12) {
                Text("Generating Summary")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                
                Text("Our AI is analyzing your pitch details")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 100)
    }
} 