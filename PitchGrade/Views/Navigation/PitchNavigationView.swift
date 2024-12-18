import SwiftUI

struct PitchNavigationView: View {
    @EnvironmentObject private var viewModel: PitchViewModel
    
    var body: some View {
        Group {
            switch viewModel.currentStep {
            case .questionnaire:
                QuestionnaireView()
            case .confirmIdea:
                IdeaConfirmationView()
            case .selectDuration:
                PitchDurationView()
            case .selectStyle:
                PitchStyleView()
            case .capture:
                if viewModel.selectedMode == .camera {
                    CameraCaptureView()
                } else {
                    VoiceRecordingView()
                }
            case .analysis:
                AnalysisReportView()
            default:
                EmptyView()
            }
        }
    }
} 