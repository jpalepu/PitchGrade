import Foundation

class OpenAIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init() {
        self.apiKey = APIConfig.getOpenAIKey()
    }
    
    func analyzePitchText(_ text: String) async throws -> PitchAnalysis {
        print("DEBUG: Starting pitch analysis")
        
        let messages: [[String: String]] = [
            ["role": "system", "content": """
                You are an expert pitch analyst. Analyze the pitch and provide detailed feedback in these categories:
                1. Clarity & Structure
                2. Delivery Style
                3. Content Quality
                4. Engagement & Impact
                
                For each category, provide:
                - A score (0-100)
                - Detailed feedback
                - Specific examples from the pitch
                - Actionable recommendations
                """
            ],
            ["role": "user", "content": text]
        ]
        
        let response = try await sendRequest(messages: messages)
        return try parseAnalysisResponse(response)
    }
    
    func generatePitchSummary(pitchIdea: PitchIdea) async throws -> String {
        print("DEBUG: Starting summary generation")
        
        let prompt = """
        Generate a concise summary of the following business pitch:
        
        Business Name: \(pitchIdea.businessName)
        Industry: \(pitchIdea.industry)
        Problem: \(pitchIdea.problemStatement)
        Solution: \(pitchIdea.solution)
        Target Market: \(pitchIdea.targetMarket)
        Business Model: \(pitchIdea.businessModel)
        Additional Details: \(pitchIdea.pitchText)
        
        Please provide a professional and engaging summary that highlights the key aspects of this business idea.
        """
        
        let messages: [[String: String]] = [
            ["role": "system", "content": "You are an expert business analyst who creates clear and compelling pitch summaries."],
            ["role": "user", "content": prompt]
        ]
        
        return try await sendRequest(messages: messages)
    }
    
    private func sendRequest(messages: [[String: String]]) async throws -> String {
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 1000
        ]
        
        guard let url = URL(string: baseURL) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API Error: \(httpResponse.statusCode)"])
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }
        
        return content
    }
    
    private func parseAnalysisResponse(_ content: String) throws -> PitchAnalysis {
        let categories = [
            ("Clarity & Structure", "clarity"),
            ("Delivery Style", "delivery"),
            ("Content Quality", "content"),
            ("Engagement & Impact", "engagement")
        ]
        
        var sections: [PitchAnalysis.Section] = []
        
        for (title, key) in categories {
            sections.append(PitchAnalysis.Section(
                title: title,
                score: extractScore(from: content, for: key),
                feedback: extractFeedback(from: content, for: key),
                examples: extractExamples(from: content, for: key),
                recommendations: extractRecommendations(from: content, for: key)
            ))
        }
        
        let overallScore = sections.reduce(0) { $0 + $1.score } / sections.count
        
        return PitchAnalysis(
            overallScore: overallScore,
            overallFeedback: extractOverallFeedback(from: content),
            sections: sections,
            improvements: extractImprovements(from: content)
        )
    }
    
    private func extractScore(from content: String, for category: String) -> Int {
        if let range = content.range(of: "\(category.capitalized).*?Score: (\\d+)", options: .regularExpression),
           let scoreStr = content[range].firstMatch(of: /\d+/)?.output {
            return Int(scoreStr) ?? 75
        }
        return 75 // Default score
    }
    
    private func extractFeedback(from content: String, for category: String) -> String {
        if let range = content.range(of: "\(category.capitalized).*?Feedback: (.*?)(?=\\n|$)", options: .regularExpression),
           let feedback = content[range].firstMatch(of: /Feedback: (.+)/)?.output.1 {
            return String(feedback)
        }
        return "Analysis feedback for \(category)"
    }
    
    private func extractExamples(from content: String, for category: String) -> [String] {
        if let range = content.range(of: "\(category.capitalized).*?Examples:(.*?)(?=Recommendations|$)", options: .regularExpression) {
            let examples = content[range].components(separatedBy: "\n")
                .filter { $0.contains("- ") }
                .map { $0.replacingOccurrences(of: "- ", with: "") }
            return examples.isEmpty ? ["Example point for \(category)"] : examples
        }
        return ["Example point for \(category)"]
    }
    
    private func extractRecommendations(from content: String, for category: String) -> [String] {
        if let range = content.range(of: "\(category.capitalized).*?Recommendations:(.*?)(?=\\n\\n|$)", options: .regularExpression) {
            let recommendations = content[range].components(separatedBy: "\n")
                .filter { $0.contains("- ") }
                .map { $0.replacingOccurrences(of: "- ", with: "") }
            return recommendations.isEmpty ? ["Recommendation for \(category)"] : recommendations
        }
        return ["Recommendation for \(category)"]
    }
    
    private func extractOverallFeedback(from content: String) -> String {
        if let range = content.range(of: "Overall Feedback:(.*?)(?=\\n\\n|$)", options: .regularExpression),
           let feedback = content[range].firstMatch(of: /Overall Feedback:(.+)/)?.output.1 {
            return String(feedback)
        }
        return "Overall analysis of the pitch presentation"
    }
    
    private func extractImprovements(from content: String) -> [String] {
        if let range = content.range(of: "Key Improvements:(.*?)(?=\\n\\n|$)", options: .regularExpression) {
            let improvements = content[range].components(separatedBy: "\n")
                .filter { $0.contains("- ") }
                .map { $0.replacingOccurrences(of: "- ", with: "") }
            return improvements.isEmpty ? ["Key improvement point"] : improvements
        }
        return ["Key improvement point"]
    }
}
