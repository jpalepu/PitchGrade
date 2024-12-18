import SwiftUI

struct IdeaConfirmationView: View {
    @EnvironmentObject private var viewModel: PitchViewModel
    @State private var isProcessing = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Check Your Idea Details")
                .font(.title2.bold())
                .padding(.top)
            
            ScrollView {
                VStack(spacing: 20) {
                    DetailRow(title: "Business Name", text: viewModel.pitchIdea.businessName)
                    DetailRow(title: "Industry", text: viewModel.pitchIdea.industry)
                    DetailRow(title: "Problem Statement", text: viewModel.pitchIdea.problemStatement)
                    DetailRow(title: "Solution", text: viewModel.pitchIdea.solution)
                    DetailRow(title: "Target Market", text: viewModel.pitchIdea.targetMarket)
                    DetailRow(title: "Business Model", text: viewModel.pitchIdea.businessModel)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 12) {
                Button {
                    viewModel.moveToNextStep()
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Confirm Details")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button {
                    viewModel.currentStep = .questionnaire
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Edit Details")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

private struct DetailRow: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(text)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
} 