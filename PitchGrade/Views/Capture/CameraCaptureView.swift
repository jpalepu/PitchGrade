import SwiftUI
import VisionKit
import Vision
import AVFoundation

struct CameraCaptureView: View {
    @EnvironmentObject private var viewModel: PitchViewModel
    @StateObject private var cameraManager = CameraManager()
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Upload Your Pitch")
                    .font(.title2.bold())
                
                Text("Choose how you want to capture your pitch document")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top)
            
            // Option buttons
            VStack(spacing: 16) {
                Button {
                    requestCameraAccess()
                } label: {
                    OptionCard(
                        title: "Take Photo",
                        description: "Use camera to capture your pitch document",
                        icon: "camera.fill"
                    )
                }
                
                Button {
                    showImagePicker = true
                } label: {
                    OptionCard(
                        title: "Upload Photo",
                        description: "Choose a photo from your gallery",
                        icon: "photo.fill"
                    )
                }
            }
            .padding(.horizontal)
            
            if isProcessing {
                ProgressView("Processing document...")
                    .padding()
            }
            
            Spacer()
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { image in
                processImage(image)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: .photoLibrary) { image in
                processImage(image)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func requestCameraAccess() {
        if cameraManager.isAuthorized {
            showCamera = true
        } else {
            cameraManager.checkPermissions()
            if !cameraManager.isAuthorized {
                errorMessage = "Camera access is required to take photos"
                showError = true
            }
        }
    }
    
    private func processImage(_ image: UIImage) {
        isProcessing = true
        
        // Perform OCR
        guard let cgImage = image.cgImage else {
            handleError("Failed to process image")
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                handleError(error.localizedDescription)
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                handleError("No text found in image")
                return
            }
            
            let text = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            if text.isEmpty {
                handleError("Could not extract text from image. Please try again with a clearer image.")
                return
            }
            
            // Send text to OpenAI for analysis
            analyzeText(text)
        }
        
        do {
            try requestHandler.perform([request])
        } catch {
            handleError(error.localizedDescription)
        }
    }
    
    private func analyzeText(_ text: String) {
        Task {
            do {
                let analysis = try await OpenAIService().analyzePitchText(text)
                await MainActor.run {
                    viewModel.pitchAnalysis = analysis
                    viewModel.moveToNextStep()
                    isProcessing = false
                }
            } catch {
                handleError(error.localizedDescription)
            }
        }
    }
    
    private func handleError(_ message: String) {
        DispatchQueue.main.async {
            errorMessage = message
            showError = true
            isProcessing = false
        }
    }
}

struct OptionCard: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 50, height: 50)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
} 
