import SwiftUI

struct GenerateLogoView: View {
    @State private var keywords: String = ""
    @State private var isLoading: Bool = false
    @State private var newLogoURL: String = ""
    @State private var message: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("🤖 Generate AI Logo")
                    .font(.largeTitle)
                    .bold()

                TextField("Enter keywords for your logo...", text: $keywords)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .padding(.horizontal)

                Button(action: {
                    generateAILogo()
                }) {
                    Text("Generate Logo")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(isLoading || keywords.isEmpty)
                .padding(.horizontal)

                if isLoading {
                    ProgressView("Generating logo...")
                        .padding()
                }

                if !message.isEmpty {
                    Text(message)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                }

                if !newLogoURL.isEmpty {
                    Text("✅ New Logo Preview")
                        .font(.headline)

                    AsyncImage(url: URL(string: newLogoURL)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                    } placeholder: {
                        ProgressView()
                    }
                }

                Spacer()
            }
            .padding()
        }
    }

    func generateAILogo() {
        isLoading = true
        message = ""
        newLogoURL = ""

        guard let url = URL(string: "https://YOURDOMAIN.com/App/api/generate-logo.php") else {
            message = "Invalid API URL"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = ["keywords": keywords]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    message = "❌ Error: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    message = "❌ No data returned."
                    return
                }

                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let success = json["success"] as? Bool, success == true,
                       let logoPath = json["logo_path"] as? String {
                        newLogoURL = "https://YOURDOMAIN.com" + logoPath
                        message = "✅ AI logo generated and saved!"
                    } else {
                        message = "❌ Failed: \(json["error"] ?? "Unknown error")"
                    }
                } else {
                    message = "❌ Failed to parse response."
                }
            }
        }.resume()
    }
}

#Preview {
    GenerateLogoView()
}

