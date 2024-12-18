import SwiftUI
import AVFoundation
import Speech

struct VoiceRecordingView: View {
    @EnvironmentObject private var viewModel: PitchViewModel
    @StateObject private var audioManager = AudioManager()
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isProcessing = false
    @State private var recordedTranscription: String?
    
    var body: some View {
        VStack(spacing: 32) {
            
     
            // Header
            Text(headerText)
                .font(.title2.bold())
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.top)
            
            // Timer (only show when recording)
            if audioManager.isRecording {
                if let remaining = audioManager.remainingTime {
                    Text(timeString(from: remaining))
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(remaining < 10 ? .red : .blue)
                }
            }
            
            // Only show record button when not reviewing
            if recordedTranscription == nil {
                // Record Button
                ZStack {
                    // Pulse animation when recording
                    if audioManager.isRecording {
                        Circle()
                            .stroke(Color.red.opacity(0.3), lineWidth: 2)
                            .frame(width: 100, height: 100)
                            .scaleEffect(audioManager.isRecording ? 1.5 : 1.0)
                            .opacity(audioManager.isRecording ? 0 : 1)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), 
                                     value: audioManager.isRecording)
                    }
                    
                    Button(action: handleRecordingTap) {
                        Circle()
                            .fill(audioManager.isRecording ? Color.red : Color.blue)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: audioManager.isRecording ? "stop.fill" : "mic.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            )
                    }
                }
                
                // Status Text
                Text(statusText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Review Section
            if let recorded = recordedTranscription {
                ReviewSection(
                    transcription: recorded,
                    onConfirm: {
                        print("DEBUG: VoiceRecordingView - Confirm button pressed with transcription: \(recorded)")
                        viewModel.pitchIdea.pitchText = recorded
                        viewModel.moveToNextStep()
                    },
                    onEdit: {
                        recordedTranscription = nil
                        audioManager.reset()
                    }
                )
            } else if audioManager.isRecording {
                // Live transcription
                LiveTranscriptionView(transcription: audioManager.liveTranscription)
            }
            
            if isProcessing {
                ProgressView("Processing recording...")
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        .onAppear { checkPermissions() }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var headerText: String {
        if recordedTranscription != nil {
            return "Review Your Idea Details"
        } else if audioManager.isRecording {
            return "Recording Your Pitch"
        } else {
            return "Record Your Pitch\n(\(viewModel.selectedDuration?.rawValue ?? ""))"
        }
    }
    
    private var statusText: String {
        if recordedTranscription != nil {
            return "Please review your recorded speech"
        } else if audioManager.isRecording {
            return "Recording in progress..."
        } else {
            return "Tap the button to start recording"
        }
    }
    
    private func handleRecordingTap() {
        if audioManager.isRecording {
            audioManager.stopRecording()
            processRecording()
        } else {
            recordedTranscription = nil
            guard let duration = getDurationInSeconds() else {
                errorMessage = "Please select a valid duration"
                showError = true
                return
            }
            
            audioManager.startRecording(withDuration: duration) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func processRecording() {
        Task {
            do {
                let transcription = try await audioManager.transcribeAudio()
                print("DEBUG: VoiceRecordingView - Received transcription: \(transcription)")
                
                await MainActor.run {
                    recordedTranscription = transcription
                    print("DEBUG: VoiceRecordingView - Updated recordedTranscription state")
                }
            } catch {
                print("DEBUG: VoiceRecordingView - Error processing recording: \(error.localizedDescription)")
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func getDurationInSeconds() -> TimeInterval? {
        switch viewModel.selectedDuration {
        case .elevator: return 30
        case .oneMinute: return 60
        case .twoMinutes: return 120
        case .fiveMinutes: return 300
        case .sevenMinutes: return 420
        case .none: return nil
        }
    }
    
    private func timeString(from duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func checkPermissions() {
        audioManager.requestPermissions { granted in
            if !granted {
                errorMessage = "Microphone and Speech Recognition access is required"
                showError = true
            }
        }
    }
}

// MARK: - Supporting Views
private struct ReviewSection: View {
    let transcription: String
    let onConfirm: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Review Your Idea Details")
                .font(.headline)
            
            ScrollView {
                Text(transcription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            .frame(maxHeight: 200)
            
            VStack(spacing: 12) {
                Button(action: onConfirm) {
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
                
                Button(action: onEdit) {
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
        }
    }
}

private struct LiveTranscriptionView: View {
    let transcription: String
    
    var body: some View {
        ScrollView {
            Text(transcription)
                .font(.body)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
        .frame(maxHeight: 200)
    }
} 
