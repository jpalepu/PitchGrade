import SwiftUI

struct PitchSummaryReviewView: View {
    @EnvironmentObject private var viewModel: PitchViewModel
    @State private var showEditAlert = false
    let summary: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Review Your Pitch Summary")
                        .font(.title2.bold())
                    
                    Text("We've analyzed your pitch and created a summary. Please review it below.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Summary Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .font(.title2)
                            .foregroundColor(.purple)
                        
                        Text("Generated Summary")
                            .font(.headline)
                    }
                    
                    Text(summary)
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
                
                // Description
                Text("If this summary accurately represents your pitch, click 'Continue with Pitch'. If you'd like to try again, click 'Try Again'.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Buttons
                VStack(spacing: 16) {
                    Button {
                        viewModel.moveToNextStep()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("Continue with Pitch")
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
                            Text("Try Again")
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
            .padding(.vertical)
        }
        .alert("Try Again", isPresented: $showEditAlert) {
            Button("Go Back", role: .destructive) {
                viewModel.currentStep = .questionnaire
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Would you like to go back and edit your responses?")
        }
    }
} 