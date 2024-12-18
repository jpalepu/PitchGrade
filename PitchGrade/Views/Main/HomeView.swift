import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: PitchViewModel
    @State private var selectedMode: PitchMode?
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // White background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Text("Choose Your Method")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                    
                    Text("Select how you want to analyze your pitch")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                }
                .padding(.top, 40)
                
                // Mode Selection Cards
                VStack(spacing: 24) {
                    // Document Analysis Card
                    AnalysisCard(
                        title: "Document Analysis",
                        description: "Upload a document or image of your pitch",
                        icon: "doc.text.viewfinder",
                        gradient: [Color.blue, Color.cyan],
                        isSelected: selectedMode == .camera,
                        delay: 0.2
                    ) {
                        withAnimation(.spring()) {
                            selectedMode = .camera
                            viewModel.selectedMode = .camera
                            viewModel.moveToNextStep()
                        }
                    }
                    
                    // Voice Recording Card
                    AnalysisCard(
                        title: "Voice Recording",
                        description: "Record your pitch presentation",
                        icon: "waveform",
                        gradient: [Color.purple, Color.pink],
                        isSelected: selectedMode == .voice,
                        delay: 0.4
                    ) {
                        withAnimation(.spring()) {
                            selectedMode = .voice
                            viewModel.selectedMode = .voice
                            viewModel.moveToNextStep()
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
}

struct AnalysisCard: View {
    let title: String
    let description: String
    let icon: String
    let gradient: [Color]
    let isSelected: Bool
    let delay: Double
    let action: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                // Icon and Title
                HStack(spacing: 16) {
                    Circle()
                        .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: icon)
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                        
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                // Arrow indicator
                HStack {
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(gradient[0])
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: isSelected ? gradient[0].opacity(0.3) : Color.black.opacity(0.1),
                        radius: isSelected ? 12 : 8,
                        y: 4
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: isSelected ? gradient : [.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 50)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(PitchViewModel())
} 
