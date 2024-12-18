import Foundation

class PitchStorageService {
    private let userDefaults = UserDefaults.standard
    private let pitchesKey = "saved_pitches"
    
    func savePitches(_ pitches: [SavedPitch]) {
        if let encoded = try? JSONEncoder().encode(pitches) {
            userDefaults.set(encoded, forKey: pitchesKey)
        }
    }
    
    func loadPitches() -> [SavedPitch] {
        guard let data = userDefaults.data(forKey: pitchesKey),
              let pitches = try? JSONDecoder().decode([SavedPitch].self, from: data) else {
            return []
        }
        return pitches
    }
} 
