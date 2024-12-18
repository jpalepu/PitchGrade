import SwiftUI

struct PitchDurationView: View {
    @EnvironmentObject private var viewModel: PitchViewModel
    @State private var selectedDuration: PitchDuration?
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Select Duration")
                        .font(.title2.bold())
                    
                    Text("How long would you like your pitch to be?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Duration options
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(PitchDuration.allCases, id: \.self) { duration in
                            DurationCard(
                                duration: duration,
                                isSelected: duration == selectedDuration,
                                action: {
                                    withAnimation(.spring()) {
                                        selectedDuration = duration
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
                
                // Continue button
                Button {
                    viewModel.selectedDuration = selectedDuration
                    viewModel.moveToNextStep()
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            selectedDuration != nil ? Color.blue : Color.gray
                        )
                        .cornerRadius(12)
                }
                .disabled(selectedDuration == nil)
                .padding(.horizontal)
                .padding(.bottom, 100) // Tab bar spacing
            }
        }
    }
}

struct DurationCard: View {
    let duration: PitchDuration
    let isSelected: Bool
    let action: () -> Void
    
    var durationInfo: (icon: String, description: String) {
        switch duration {
        case .elevator:
            return ("bolt.fill", "Perfect for quick introductions")
        case .oneMinute:
            return ("clock.fill", "Brief but comprehensive")
        case .twoMinutes:
            return ("stopwatch.fill", "Detailed presentation")
        case .fiveMinutes:
            return ("clock.badge.checkmark.fill", "Full pitch with details")
        case .sevenMinutes:
            return ("presentation.fill", "Complete investor pitch")
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color.blue.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: durationInfo.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : .blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(duration.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(durationInfo.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: isSelected ? .blue.opacity(0.2) : .black.opacity(0.05),
                           radius: isSelected ? 10 : 5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
} 