import Foundation

struct OpenAIHelper {
    static func analyzeImage(base64Image: String) async throws -> [String: String] {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw URLError(.badURL)
        }

        let imagePart: [String: Any] = [
            "type": "image_url",
            "image_url": [
                "url": "data:image/jpeg;base64,\(base64Image)"
            ]
        ]

        let systemPrompt = """
        You are Andy of Istockhomes, an AI listing assistant.
        Analyze this image and return JSON: {"title":"...", "category":"...", "price":"...", "description":"..."}.
        The category must be one of: Aircraft, Marine, Vehicles, Real Estate, Art, Business.
        """

        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [[
                "role": "user",
                "content": [
                    ["type": "text", "text": systemPrompt],
                    imagePart
                ]
            ]],
            "max_tokens": 600
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(Secrets.OPENAI_API_KEY)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        guard let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = result["choices"] as? [[String: Any]],
              let content = choices.first?["message"] as? [String: Any],
              let text = content["content"] as? String else {
            throw NSError(domain: "Invalid OpenAI response", code: 0)
        }

        // Extract JSON substring
        if let start = text.firstIndex(of: "{"), let end = text.lastIndex(of: "}") {
            let jsonStr = String(text[start...end])
            if let jsonData = jsonStr.data(using: .utf8),
               let parsed = try? JSONSerialization.jsonObject(with: jsonData) as? [String: String] {
                return parsed
            }
        }

        throw NSError(domain: "Failed to parse AI JSON", code: 0)
    }
}
