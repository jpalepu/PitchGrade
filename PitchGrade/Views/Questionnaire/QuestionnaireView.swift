import SwiftUI

struct Question {
    let field: String
    let title: String
    let description: String
    let icon: String
}

struct QuestionnaireView: View {
    @EnvironmentObject private var viewModel: PitchViewModel
    @State private var currentQuestion = 0
    @State private var answers: [String: String] = [:]
    
    let questions = [
        Question(field: "businessName", title: "Business Name", description: "What's your startup or business called?", icon: "building.2"),
        Question(field: "industry", title: "Industry", description: "What industry are you in?", icon: "globe"),
        Question(field: "problemStatement", title: "Problem", description: "What problem are you solving?", icon: "exclamationmark.bubble"),
        Question(field: "solution", title: "Solution", description: "How does your solution work?", icon: "lightbulb"),
        Question(field: "targetMarket", title: "Target Market", description: "Who are your target customers?", icon: "person.2"),
        Question(field: "businessModel", title: "Business Model", description: "How will you make money?", icon: "chart.line.uptrend.xyaxis")
    ]
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar
                ProgressView(value: Double(currentQuestion + 1), total: Double(questions.count))
                    .tint(.blue)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                // Main content
                ScrollView {
                    VStack(spacing: 24) {
                        // Question header
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: questions[currentQuestion].icon)
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                Text(questions[currentQuestion].title)
                                    .font(.title2.bold())
                            }
                            
                            Text(questions[currentQuestion].description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                        
                        // Text input
                        QuestionCard(
                            text: Binding(
                                get: { answers[questions[currentQuestion].field] ?? "" },
                                set: { answers[questions[currentQuestion].field] = $0 }
                            ),
                            placeholder: "Enter your answer here..."
                        )
                    }
                    .padding()
                }
                
                // Fixed navigation buttons at the bottom with proper spacing
                VStack(spacing: 0) {
                    // Navigation buttons
                    HStack(spacing: 20) {
                        if currentQuestion > 0 {
                            NavigationButton(
                                title: "Previous",
                                icon: "chevron.left"
                            ) {
                                currentQuestion -= 1
                            }
                        }
                        
                        NavigationButton(
                            title: currentQuestion == questions.count - 1 ? "Review" : "Next",
                            icon: "chevron.right",
                            isEnabled: !(answers[questions[currentQuestion].field]?.isEmpty ?? true)
                        ) {
                            if currentQuestion == questions.count - 1 {
                                saveAnswers()
                                viewModel.moveToNextStep()
                            } else {
                                currentQuestion += 1
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(
                        Rectangle()
                            .fill(.ultraThinMaterial)
                    )
                    
                    // Spacer for tab bar
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 80) // Height for tab bar space
                }
            }
        }
    }
    
    private func saveAnswers() {
        viewModel.pitchIdea = PitchIdea(
            businessName: answers["businessName"] ?? "",
            industry: answers["industry"] ?? "",
            problemStatement: answers["problemStatement"] ?? "",
            solution: answers["solution"] ?? "",
            targetMarket: answers["targetMarket"] ?? "",
            businessModel: answers["businessModel"] ?? ""
        )
    }
}

struct QuestionCard: View {
    @Binding var text: String
    let placeholder: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            TextEditor(text: $text)
                .frame(minHeight: 120)
                .focused($isFocused)
                .scrollContentBackground(.hidden)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .overlay(
                    Group {
                        if text.isEmpty {
                            Text(placeholder)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)
                        }
                    }
                )
        }
    }
}

struct NavigationButton: View {
    let title: String
    let icon: String
    var isEnabled: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if icon == "chevron.left" {
                    Image(systemName: icon)
                }
                
                Text(title)
                    .fontWeight(.medium)
                
                if icon == "chevron.right" {
                    Image(systemName: icon)
                }
            }
            .foregroundColor(.white)
            .frame(height: 45)
            .frame(maxWidth: .infinity)
            .background(isEnabled ? Color.blue : Color.gray)
            .cornerRadius(10)
        }
        .disabled(!isEnabled)
    }
} 
