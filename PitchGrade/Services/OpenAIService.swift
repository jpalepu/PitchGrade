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
        
        let messages: [[String: String]] = [
            ["role": "system", "content": "You are an expert pitch analyzer. Analyze the following pitch and provide detailed feedback."],
            ["role": "user", "content": text]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": messages,
            "temperature": 0.7
        ]
        
        guard let url = URL(string: baseURL) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("DEBUG: Sending request to OpenAI")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("DEBUG: API Error - Status Code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get response from OpenAI"])
        }
        
        print("DEBUG: Received response from OpenAI")
        // Process the response and create PitchAnalysis
        // Add your response parsing logic here
        
        return PitchAnalysis(
            clarity: "Good clarity",
            valueProposition: "Strong value proposition",
            marketUnderstanding: "Good market understanding",
            businessModel: "Viable business model",
            improvements: "Some suggested improvements",
            overallScore: 85
        )
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