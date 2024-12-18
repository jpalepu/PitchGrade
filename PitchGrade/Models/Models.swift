import Foundation

// MARK: - Core Models
struct PitchIdea: Codable {
    var businessName: String
    var industry: String
    var problemStatement: String
    var solution: String
    var targetMarket: String
    var businessModel: String
    var pitchText: String = ""
}

struct PitchAnalysis: Codable, Equatable {
    struct SectionAnalysis: Codable, Equatable {
        let score: Int
        let feedback: String
        let examples: [String]
        let recommendations: [String]
    }
    
    let clarity: SectionAnalysis
    let deliveryStyle: SectionAnalysis
    let communicationEffectiveness: SectionAnalysis
    let timeManagement: SectionAnalysis
    let improvements: [String]
    let overallScore: Int
    let overallFeedback: String
}

struct SavedPitch: Identifiable, Codable {
    let id: UUID
    let businessName: String
    let date: Date
    let mode: PitchMode
    let summary: String
    let score: Int
}

// MARK: - Enums
enum PitchMode: String, Codable {
    case camera
    case voice
}

enum PitchStyle: String, Codable, CaseIterable {
    case peterThiel = "Peter Thiel Style"
    case steveJobs = "Steve Jobs Style"
    case elonMusk = "Elon Musk Style"
    case traditional = "Traditional"
    case storytelling = "Storytelling"
}

enum PitchDuration: String, Codable, CaseIterable {
    case elevator = "30 Seconds"
    case oneMinute = "1 Minute"
    case twoMinutes = "2 Minutes"
    case fiveMinutes = "5 Minutes"
    case sevenMinutes = "7 Minutes"
} 
