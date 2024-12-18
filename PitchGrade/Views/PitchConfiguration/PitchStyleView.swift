import SwiftUI

struct PitchStyleView: View {
    @EnvironmentObject private var viewModel: PitchViewModel
    @State private var selectedStyle: PitchStyle?
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Choose Your Style")
                        .font(.title2.bold())
                    
                    Text("Select a presentation style that matches your vision")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Style options
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(PitchStyle.allCases, id: \.self) { style in
                            StyleCard(
                                style: style,
                                isSelected: style == selectedStyle,
                                action: {
                                    withAnimation(.spring()) {
                                        selectedStyle = style
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
                
                // Continue button
                Button {
                    viewModel.selectedStyle = selectedStyle
                    viewModel.moveToNextStep()
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            selectedStyle != nil ? Color.blue : Color.gray
                        )
                        .cornerRadius(12)
                }
                .disabled(selectedStyle == nil)
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
        }
    }
}

struct StyleCard: View {
    let style: PitchStyle
    let isSelected: Bool
    let action: () -> Void
    
    var styleInfo: (icon: String, description: String) {
        switch style {
        case .peterThiel:
            return ("chart.bar.fill", "Direct, analytical approach focusing on unique insights")
        case .steveJobs:
            return ("sparkles.tv.fill", "Storytelling with emphasis on revolutionary impact")
        case .elonMusk:
            return ("rocket.fill", "Vision-driven approach focusing on ambitious goals")
        case .traditional:
            return ("chart.pie.fill", "Structured approach with market metrics")
        case .storytelling:
            return ("book.fill", "Narrative-focused emotional connection")
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
                    
                    Image(systemName: styleInfo.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : .blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(style.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(styleInfo.description)
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