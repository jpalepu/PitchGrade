import Foundation

class OpenAIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init() {
        self.apiKey = APIConfig.getOpenAIKey()
        print("DEBUG: API Key length: \(apiKey.count)")
    }
    
    func analyzePitchText(_ text: String) async throws -> PitchAnalysis {
        print("DEBUG: Starting pitch analysis for text: \(text)")
        
        let systemPrompt = """
        You are an expert pitch coach who evaluates pitch delivery and presentation. Focus on HOW the pitch is delivered, not the business idea itself.
        
        Consider these aspects in your evaluation:
        1. Voice and Delivery:
           - Clarity of speech
           - Pace and rhythm
           - Voice modulation
           - Confidence in delivery
        
        2. Structure and Flow:
           - Opening hook
           - Logical progression
           - Transitions between points
           - Strong conclusion
        
        3. Engagement:
           - Energy level
           - Use of pauses
           - Emphasis on key points
           - Audience connection
        
        4. Time Management:
           - Efficient use of time
           - Balanced coverage of points
           - Appropriate pacing
           - Natural flow
        
        Provide constructive feedback in this JSON format:
        {
            "clarity": {
                "score": <0-100>,
                "feedback": "<specific feedback on voice clarity and articulation>",
                "examples": ["<specific moment from the pitch>", "<another specific moment>"],
                "recommendations": ["<actionable improvement tip>", "<another specific tip>"]
            },
            "deliveryStyle": {
                "score": <0-100>,
                "feedback": "<feedback on energy, confidence, and engagement>",
                "examples": ["<specific positive or negative example>", "<another example>"],
                "recommendations": ["<specific technique to improve>", "<another technique>"]
            },
            "communicationEffectiveness": {
                "score": <0-100>,
                "feedback": "<feedback on message clarity and impact>",
                "examples": ["<specific effective/ineffective moment>", "<another moment>"],
                "recommendations": ["<specific communication tip>", "<another tip>"]
            },
            "timeManagement": {
                "score": <0-100>,
                "feedback": "<feedback on pacing and time usage>",
                "examples": ["<specific timing observation>", "<another observation>"],
                "recommendations": ["<specific timing improvement>", "<another improvement>"]
            },
            "improvements": ["<key delivery improvement>", "<another key improvement>"],
            "overallScore": <0-100>,
            "overallFeedback": "<comprehensive evaluation of delivery style and specific ways to improve>"
        }
        
        Focus on delivery techniques, speaking skills, and presentation effectiveness rather than content.
        """
        
        let userPrompt = """
        Analyze this pitch presentation and provide feedback in the specified JSON format:
        
        \(text)
        """
        
        let messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": userPrompt]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": messages,
            "temperature": 0.7
        ]
        
        print("DEBUG: Request body: \(requestBody)")
        
        guard let url = URL(string: baseURL) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            print("DEBUG: Request headers: \(request.allHTTPHeaderFields ?? [:])")
        } catch {
            print("DEBUG: JSON serialization error: \(error)")
            throw error
        }
        
        print("DEBUG: Sending request to OpenAI")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("DEBUG: Response status code: \(httpResponse.statusCode)")
            print("DEBUG: Response headers: \(httpResponse.allHeaderFields)")
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? "none"
        print("DEBUG: Raw response: \(responseString)")
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = json["error"] as? [String: Any],
               let message = error["message"] as? String {
                print("DEBUG: OpenAI error message: \(message)")
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: message])
            }
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get response from OpenAI"])
        }
        
        print("DEBUG: Received response from OpenAI")
        print("DEBUG: Raw response content: \(String(data: data, encoding: .utf8) ?? "none")")
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            
            print("DEBUG: Parsing GPT response content")
            guard let jsonData = content.data(using: .utf8) else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert content to data"])
            }
            
            do {
                let analysisData = try JSONDecoder().decode(GPTAnalysisResponse.self, from: jsonData)
                print("DEBUG: Successfully parsed analysis data")
                
                return PitchAnalysis(
                    clarity: PitchAnalysis.SectionAnalysis(
                        score: analysisData.clarity.score,
                        feedback: analysisData.clarity.feedback,
                        examples: analysisData.clarity.examples,
                        recommendations: analysisData.clarity.recommendations
                    ),
                    deliveryStyle: PitchAnalysis.SectionAnalysis(
                        score: analysisData.deliveryStyle.score,
                        feedback: analysisData.deliveryStyle.feedback,
                        examples: analysisData.deliveryStyle.examples,
                        recommendations: analysisData.deliveryStyle.recommendations
                    ),
                    communicationEffectiveness: PitchAnalysis.SectionAnalysis(
                        score: analysisData.communicationEffectiveness.score,
                        feedback: analysisData.communicationEffectiveness.feedback,
                        examples: analysisData.communicationEffectiveness.examples,
                        recommendations: analysisData.communicationEffectiveness.recommendations
                    ),
                    timeManagement: PitchAnalysis.SectionAnalysis(
                        score: analysisData.timeManagement.score,
                        feedback: analysisData.timeManagement.feedback,
                        examples: analysisData.timeManagement.examples,
                        recommendations: analysisData.timeManagement.recommendations
                    ),
                    improvements: analysisData.improvements,
                    overallScore: analysisData.overallScore,
                    overallFeedback: analysisData.overallFeedback
                )
            } catch {
                print("DEBUG: JSON parsing error: \(error)")
                throw error
            }
        }
        
        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse OpenAI response"])
    }
    
    private func extractSection(_ content: String, _ section: String) -> String {
        // Add logic to extract and format specific sections from the GPT response
        // This should return detailed feedback with examples
        return ""  // Implement proper extraction
    }
    
    private func calculateOverallScore(from content: String) -> Int {
        // Add logic to calculate overall score based on individual scores
        // This should weight different aspects appropriately
        return 0  // Implement proper calculation
    }
    
    func generatePitchSummary(pitchIdea: PitchIdea) async throws -> String {
        print("DEBUG: Starting summary generation with API key: \(apiKey.prefix(8))...")
        
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
        
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 500
        ]
        
        guard let url = URL(string: baseURL) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("DEBUG: Sending summary request to OpenAI")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, 
                userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
        }
        
        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            print("DEBUG: Authentication failed. API Key invalid or missing")
            throw NSError(domain: "", code: 401, 
                userInfo: [NSLocalizedDescriptionKey: "Invalid API key. Please check your OpenAI API key"])
        case 429:
            throw NSError(domain: "", code: 429, 
                userInfo: [NSLocalizedDescriptionKey: "Rate limit exceeded. Please try again later"])
        default:
            print("DEBUG: API Error - Status Code: \(httpResponse.statusCode)")
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("DEBUG: Error response: \(errorData)")
            }
            throw NSError(domain: "", code: httpResponse.statusCode, 
                userInfo: [NSLocalizedDescriptionKey: "OpenAI API error: \(httpResponse.statusCode)"])
        }
        
        // Parse the response
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            print("DEBUG: Successfully generated summary")
            return content
        }
        
        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse OpenAI response"])
    }
}

// Helper structure to parse GPT response
private struct GPTAnalysisResponse: Codable {
    struct Section: Codable {
        let score: Int
        let feedback: String
        let examples: [String]
        let recommendations: [String]
    }
    
    let clarity: Section
    let deliveryStyle: Section
    let communicationEffectiveness: Section
    let timeManagement: Section
    let improvements: [String]
    let overallScore: Int
    let overallFeedback: String
} 
