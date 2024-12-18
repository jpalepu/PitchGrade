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

struct PitchAnalysis: Codable {
    let clarity: String
    let valueProposition: String
    let marketUnderstanding: String
    let businessModel: String
    let improvements: String
    let overallScore: Int
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
