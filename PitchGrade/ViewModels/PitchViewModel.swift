import Foundation
import SwiftUI

@MainActor
class PitchViewModel: ObservableObject {
    @Published var currentStep: PitchStep = .selectMode
    @Published var selectedMode: PitchMode?
    @Published var pitchIdea: PitchIdea
    @Published var selectedDuration: PitchDuration?
    @Published var selectedStyle: PitchStyle?
    @Published var pitchAnalysis: PitchAnalysis?
    @Published var hasSeenOnboarding: Bool = false
    @Published var savedPitches: [SavedPitch] = []
    @Published var generatedSummary: String?
    
    private let storageService = PitchStorageService()
    
    init() {
        self.hasSeenOnboarding = false
        self.currentStep = .selectMode
        self.pitchIdea = PitchIdea(
            businessName: "",
            industry: "",
            problemStatement: "",
            solution: "",
            targetMarket: "",
            businessModel: ""
        )
        self.savedPitches = storageService.loadPitches()
    }
    
    func completeOnboarding() {
        hasSeenOnboarding = true
        currentStep = .selectMode
    }
    
    enum PitchStep {
        case selectMode
        case questionnaire
        case confirmIdea
        case summaryReview
        case selectDuration
        case selectStyle
        case capture
        case analysis
    }
    
    func moveToNextStep() {
        print("DEBUG: PitchViewModel - Moving from step: \(currentStep)")
        
        switch currentStep {
        case .selectMode:
            if selectedMode != nil {
                currentStep = .questionnaire
            }
        case .questionnaire:
            currentStep = .confirmIdea
        case .confirmIdea:
            currentStep = .summaryReview
            Task {
                await generateSummary()
            }
        case .summaryReview:
            currentStep = .selectDuration
        case .selectDuration:
            if selectedDuration != nil {
                currentStep = .selectStyle
            }
        case .selectStyle:
            if selectedStyle != nil {
                currentStep = .capture
            }
        case .capture:
            print("DEBUG: PitchViewModel - Moving to analysis with pitchText: \(pitchIdea.pitchText)")
            currentStep = .analysis
            
            // Start analysis immediately
            Task {
                await analyzePitch()
            }
        case .analysis:
            savePitch()
            break
        }
    }
    
    private func savePitch() {
        let newPitch = SavedPitch(
            id: UUID(),
            businessName: pitchIdea.businessName,
            date: Date(),
            mode: selectedMode ?? .camera,
            summary: generatedSummary ?? "",
            score: pitchAnalysis?.overallScore ?? 0
        )
        savedPitches.append(newPitch)
        storageService.savePitches(savedPitches)
    }
    
    func reset() {
        currentStep = .selectMode
        selectedMode = nil
        pitchIdea = PitchIdea(businessName: "", industry: "", problemStatement: "", solution: "", targetMarket: "", businessModel: "")
        selectedDuration = nil
        selectedStyle = nil
        pitchAnalysis = nil
    }
    
    private func generateSummary() async {
        do {
            let summary = try await OpenAIService().generatePitchSummary(pitchIdea: pitchIdea)
            self.generatedSummary = summary
        } catch {
            print("ERROR: Failed to generate summary - \(error.localizedDescription)")
            self.generatedSummary = "Failed to generate summary. Please try again."
        }
    }
    
    @MainActor
    private func analyzePitch() async {
        print("DEBUG: PitchViewModel - Starting pitch analysis")
        do {
            guard !pitchIdea.pitchText.isEmpty else {
                print("DEBUG: PitchViewModel - Error: Empty pitch text")
                return
            }
            
            print("DEBUG: PitchViewModel - Sending to OpenAI: \(pitchIdea.pitchText)")
            let analysis = try await OpenAIService().analyzePitchText(pitchIdea.pitchText)
            print("DEBUG: PitchViewModel - Received analysis: \(analysis)")
            
            await MainActor.run {
                print("DEBUG: PitchViewModel - Setting analysis in view model")
                self.pitchAnalysis = analysis
                print("DEBUG: PitchViewModel - Analysis set: \(self.pitchAnalysis != nil)")
            }
        } catch {
            print("DEBUG: PitchViewModel - Analysis error: \(error.localizedDescription)")
        }
    }
} 
