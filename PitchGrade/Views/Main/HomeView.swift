import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: PitchViewModel
    @State private var selectedMode: PitchMode?
    
    var body: some View {
        ZStack {
            // Background with subtle gradient
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Decorative circles
            Circle()
                .fill(Color.blue.opacity(0.05))
                .frame(width: 300)
                .blur(radius: 40)
                .offset(x: -150, y: -100)
            
            Circle()
                .fill(Color.purple.opacity(0.05))
                .frame(width: 250)
                .blur(radius: 40)
                .offset(x: 150, y: 300)
            
            VStack(spacing: 35) {
                // Header
                VStack(spacing: 12) {
                    Text("Choose Your Method")
                        .font(.title.bold())
                        .padding(.top, 40)
                    
                    Text("Select how you want to analyze your pitch")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                // Mode cards
                VStack(spacing: 24) {
                    ModeCard(
                        mode: .camera,
                        title: "Document Analysis",
                        description: "Upload or capture your written pitch",
                        icon: "doc.text.viewfinder",
                        isSelected: selectedMode == .camera,
                        action: { selectedMode = .camera }
                    )
                    
                    ModeCard(
                        mode: .voice,
                        title: "Voice Analysis",
                        description: "Record your pitch presentation",
                        icon: "mic.fill",
                        isSelected: selectedMode == .voice,
                        action: { selectedMode = .voice }
                    )
                }
                .padding(.horizontal)
                
                if selectedMode != nil {
                    Button {
                        if let mode = selectedMode {
                            viewModel.selectedMode = mode
                            viewModel.moveToNextStep()
                        }
                    } label: {
                        HStack {
                            Text("Continue")
                                .font(.headline)
                            
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
            }
        }
    }
}

struct ModeCard: View {
    let mode: PitchMode
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isSelected ? 
                                    [.blue, .blue.opacity(0.8)] :
                                    [.blue.opacity(0.1), .blue.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : .blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Selection indicator with animation
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 26, height: 26)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 18, height: 18)
                            .transition(.scale)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: isSelected ? .blue.opacity(0.15) : .black.opacity(0.05),
                        radius: isSelected ? 12 : 8,
                        x: 0,
                        y: 4
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    HomeView()
        .environmentObject(PitchViewModel())
} 
