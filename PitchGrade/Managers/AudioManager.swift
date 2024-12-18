import Foundation
import AVFoundation
import Speech

class AudioManager: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var remainingTime: TimeInterval?
    @Published var liveTranscription: String = ""
    @Published var recordingStatus: RecordingStatus = .ready
    
    enum RecordingStatus {
        case ready
        case recording
        case processing
        case finished
        case error(String)
    }
    
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recordingTimer: Timer?
    private var startTime: Date?
    private var durationLimit: TimeInterval?
    private var finalTranscription: String = ""
    
    override init() {
        super.init()
        setupSpeechRecognizer()
    }
    
    private func setupSpeechRecognizer() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        
        // Force server-based recognition
        if #available(iOS 13, *) {
            recognitionRequest?.requiresOnDeviceRecognition = false
        }
        speechRecognizer?.supportsOnDeviceRecognition = false
        
        // Add delegate to handle state changes
        speechRecognizer?.delegate = self
        
        if let recognizer = speechRecognizer, !recognizer.isAvailable {
            print("DEBUG: Speech recognition is not available on this device")
            recordingStatus = .error("Speech recognition is not available on this device")
        }
    }
    
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { granted in
                    DispatchQueue.main.async {
                        let isAuthorized = granted && status == .authorized
                        if !isAuthorized {
                            self?.recordingStatus = .error("Microphone and Speech Recognition permissions are required")
                        }
                        completion(isAuthorized)
                    }
                }
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    DispatchQueue.main.async {
                        let isAuthorized = granted && status == .authorized
                        if !isAuthorized {
                            self?.recordingStatus = .error("Microphone and Speech Recognition permissions are required")
                        }
                        completion(isAuthorized)
                    }
                }
            }
        }
    }
    
    func startRecording(withDuration duration: TimeInterval, completion: @escaping (Error?) -> Void) {
        guard let speechRecognizer = speechRecognizer else {
            let error = NSError(domain: "", code: -1, 
                userInfo: [NSLocalizedDescriptionKey: "Speech recognizer not initialized"])
            completion(error)
            return
        }
        
        if !speechRecognizer.isAvailable {
            let error = NSError(domain: "", code: -1, 
                userInfo: [NSLocalizedDescriptionKey: "Speech recognition is not available"])
            completion(error)
            return
        }
        
        resetState(duration: duration)
        
        do {
            try setupAudioSession()
            try setupRecognition(completion: completion)
        } catch {
            recordingStatus = .error(error.localizedDescription)
            completion(error)
        }
    }
    
    private func resetState(duration: TimeInterval) {
        durationLimit = duration
        remainingTime = duration
        startTime = Date()
        finalTranscription = ""
        liveTranscription = ""
        recordingStatus = .recording
    }
    
    private func setupAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    private func setupRecognition(completion: @escaping (Error?) -> Void) throws {
        let inputNode = audioEngine.inputNode
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])
        }
        
        setupRecognitionTask(with: recognitionRequest)
        setupAudioTap(on: inputNode, with: recognitionRequest)
        
        audioEngine.prepare()
        try audioEngine.start()
        
        isRecording = true
        startTimer()
        completion(nil)
    }
    
    private func setupRecognitionTask(with request: SFSpeechAudioBufferRecognitionRequest) {
        // Force server-based recognition
        if #available(iOS 13, *) {
            request.requiresOnDeviceRecognition = false
        }
        
        // Add task configuration
        request.shouldReportPartialResults = true
        request.taskHint = .dictation
        request.contextualStrings = ["pitch", "business", "idea", "market", "solution"]
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error as NSError? {
                DispatchQueue.main.async {
                    print("DEBUG: Recognition error: \(error.localizedDescription) (Code: \(error.code))")
                    
                    // Ignore specific error codes that don't affect functionality
                    let ignoredErrorCodes = [1101, 203, 216]
                    if !ignoredErrorCodes.contains(error.code) {
                        self.recordingStatus = .error(error.localizedDescription)
                    }
                }
                return
            }
            
            if let result = result {
                DispatchQueue.main.async {
                    let transcription = result.bestTranscription.formattedString
                    if !transcription.isEmpty {
                        self.liveTranscription = transcription
                        print("DEBUG: Live Transcription: \(transcription)")
                        
                        if result.isFinal {
                            self.finalTranscription = transcription
                            print("DEBUG: Final Transcription: \(transcription)")
                        }
                    }
                }
            }
        }
    }
    
    private func setupAudioTap(on inputNode: AVAudioNode, with request: SFSpeechAudioBufferRecognitionRequest) {
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
    }
    
    func stopRecording() {
        // Capture the final transcription before stopping
        let finalText = liveTranscription
        print("DEBUG: Stopping recording with transcription: \(finalText)")
        
        // Give more time before stopping
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.audioEngine.stop()
            self.audioEngine.inputNode.removeTap(onBus: 0)
            self.recognitionRequest?.endAudio()
            
            // Additional delay before canceling the task
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.recognitionTask?.cancel()
                self.recordingTimer?.invalidate()
                
                DispatchQueue.main.async {
                    self.isRecording = false
                    self.recordingStatus = .finished
                    if self.finalTranscription.isEmpty {
                        self.finalTranscription = finalText
                        print("DEBUG: Saved final transcription: \(finalText)")
                    }
                }
            }
        }
        
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    private func startTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self,
                  let start = self.startTime,
                  let limit = self.durationLimit else { return }
            
            let elapsed = Date().timeIntervalSince(start)
            DispatchQueue.main.async {
                self.remainingTime = max(0, limit - elapsed)
                
                if self.remainingTime == 0 {
                    self.stopRecording()
                }
            }
        }
    }
    
    func transcribeAudio() async throws -> String {
        recordingStatus = .processing
        print("DEBUG: Processing final transcription...")
        
        // Wait a bit longer for final transcription to be processed
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        let transcription = finalTranscription.isEmpty ? liveTranscription : finalTranscription
        print("DEBUG: Final transcription check - Live: \(liveTranscription), Final: \(finalTranscription)")
        
        if transcription.isEmpty {
            print("DEBUG: No transcription available")
            throw NSError(domain: "", code: -1, 
                userInfo: [NSLocalizedDescriptionKey: "No speech was detected. Please try again."])
        }
        
        await MainActor.run {
            recordingStatus = .finished
        }
        
        print("DEBUG: Final transcription to be sent to LLM: \(transcription)")
        return transcription
    }
    
    func reset() {
        stopRecording()
        liveTranscription = ""
        finalTranscription = ""
        remainingTime = nil
        recordingStatus = .ready
    }
}

// Add SFSpeechRecognizerDelegate
extension AudioManager: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available {
            recordingStatus = .error("Speech recognition became unavailable")
        }
    }
}

