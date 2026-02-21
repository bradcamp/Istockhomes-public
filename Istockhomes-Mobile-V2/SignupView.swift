import SwiftUI
import Security // for SecItemAdd and SecItemDelete used in keychain

struct SignupView: View {
    @Binding var prefillEmail: String

    @State private var username = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var signupMessage = ""
    @State private var navigateToDashboard = false

    @State private var loginUsername = ""
    @State private var franchiseID = "IstockhomesDefault"
    @StateObject private var franchiseManager = FranchiseManager()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                // ✅ Top logo
                AsyncImage(url: URL(string: franchiseManager.config?.logoPath ?? "https://istockhomes.com/App/images/Istockhomes_logo-2020-Clear.jpg")) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(height: 100)
                } placeholder: {
                    ProgressView()
                }

                Text("Create Your Istockhomes Account")
                    .font(.title)
                    .multilineTextAlignment(.center)

                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)

                TextField("Phone", text: $phone)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                Button("Sign Up") {
                    signup()
                }
                .buttonStyle(BlackButtonStyle())

                Text(signupMessage)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()

                // ✅ Fix Navigation Link with valid result builder
                NavigationLink(
                    destination: DashboardView(
                        username: loginUsername,
                        franchiseID: franchiseID,
                        franchiseManager: franchiseManager,
                        onLogout: {
                            prefillEmail = ""
                            navigateToDashboard = false
                        }
                    ),
                    isActive: $navigateToDashboard
                ) {
                    EmptyView()
                }
                .hidden()

                VStack(spacing: 6) {
                    Text("✅ Verified by Istockhomes")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    Text("Contact: admin@istockhomes.com | 1-250-816-8577")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
        }
    }

    // MARK: - Sign Up API
    func signup() {
        guard let url = URL(string: "https://istockhomes.com/App/api/signup.php") else {
            signupMessage = "Invalid signup URL"
            return
        }

        let payload: [String: Any] = [
            "username": username,
            "email": email,
            "phone": phone,
            "password": password
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    signupMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    signupMessage = "No response data"
                    return
                }

                do {
                    if let response = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let success = response["success"] as? Bool {
                        signupMessage = success
                            ? "✅ Signup successful! Logging in..."
                            : (response["message"] as? String ?? "Signup failed.")

                        if success,
                           let profile = response["profile"] as? [String: Any],
                           let returnedEmail = profile["email"] as? String,
                           let returnedUsername = profile["username"] as? String,
                           let token = response["token"] as? String {

                            prefillEmail = returnedEmail
                            loginUsername = returnedUsername
                            franchiseID = response["franchise_id"] as? String ?? "IstockhomesDefault"

                            saveTokenToKeychain(token)
                            franchiseManager.loadFranchiseConfig(franchiseID: franchiseID)

                            navigateToDashboard = true
                        }
                    } else {
                        signupMessage = "Invalid server response"
                    }
                } catch {
                    signupMessage = "Parse error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    // MARK: - Token storage
    func saveTokenToKeychain(_ token: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "userToken",
            kSecValueData as String: token.data(using: .utf8) ?? Data()
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
}

#Preview {
    SignupView(prefillEmail: .constant(""))
}

