import SwiftUI
import LocalAuthentication
import Security // for SecItemAdd, SecItemCopyMatching, SecItemDelete
import UIKit

struct LoginView: View {
    // Unified auth uses email + 6-digit code for first login.
    // After that, FaceID unlocks the refresh token stored in Keychain.
    @State private var email = ""
    @State private var code = ""
    @State private var loginMessage = ""
    @State private var isLoading = false

    @State private var username = ""
    @State private var franchiseID = ""
    @State private var showDashboard = false

    @AppStorage("isLoggedIn") private var isLoggedIn = false

    @StateObject private var franchiseManager = FranchiseManager()

    private let authURL = URL(string: "https://istockhomes.com/App/api/auth.php")!
    private let accessTokenAccount = "userToken"     // keep existing key name so other views keep working
    private let refreshTokenAccount = "refreshToken" // new: biometric protected
    @AppStorage("deviceID") private var deviceID: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // ✅ Istockhomes Logo (replaces HeaderView)
                AsyncImage(url: URL(string: "https://istockhomes.com/App/images/Istockhomes_logo-2020-Clear.jpg")) { image in
                    image.resizable()
                         .scaledToFit()
                         .frame(height: 100)
                         .padding(.top, 8)
                } placeholder: {
                    ProgressView()
                        .frame(height: 100)
                }

                // ✅ Email + Code (first login)
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)

                Button(action: sendCode) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Send 6-digit code")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(BlackButtonStyle())
                .disabled(isLoading)

                TextField("6-digit code", text: $code)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)

                Button(action: verifyCode) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Verify & Continue")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(BlackButtonStyle())
                .disabled(isLoading)

                Button("Login with Face ID / Touch ID", action: authenticateBiometrically)
                    .font(.footnote)

                Text(loginMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)

                NavigationLink(destination: SignupView(prefillEmail: $email)) {
                    Text("Don't have an account? Sign Up")
                        .font(.footnote)
                }

                Spacer()

                // ✅ Footer
                FooterView()
            }
            .padding()
            .navigationDestination(isPresented: $showDashboard) {
                DashboardView(username: username, franchiseID: franchiseID, franchiseManager: franchiseManager, onLogout: handleLogout)
            }
            .onAppear {
                let fallbackFranchiseID = franchiseID.isEmpty ? "IstockhomesDefault" : franchiseID
                franchiseManager.loadFranchiseConfig(franchiseID: fallbackFranchiseID)

                // Ensure we have a stable device id for refresh tokens
                if deviceID.isEmpty {
                    deviceID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
                }

                // If we have a biometric refresh token, go straight to FaceID login
                if hasRefreshToken() {
                    authenticateBiometrically()
                } else if loadAccessTokenFromKeychain() != nil {
                    // Fallback: if an access token exists (may be expired), still allow UI
                    showDashboard = true
                }
            }
        }
    }

    // MARK: - Unified Auth (send_code)
    func sendCode() {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard cleanEmail.contains("@") else {
            loginMessage = "Enter a valid email address"
            return
        }

        isLoading = true
        loginMessage = ""

        var request = URLRequest(url: authURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload: [String: Any] = [
            "action": "send_code",
            "email": cleanEmail
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    loginMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let data = data,
                      let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                else {
                    loginMessage = "Invalid server response"
                    return
                }

                if (json["ok"] as? Bool) == true {
                    loginMessage = "✅ Code sent. Check your email (and spam)."
                } else {
                    loginMessage = (json["error"] as? String) ?? "Could not send code"
                }
            }
        }.resume()
    }

    // MARK: - Unified Auth (verify_code)
    func verifyCode() {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanEmail.contains("@") else {
            loginMessage = "Enter a valid email address"
            return
        }
        guard cleanCode.count == 6 else {
            loginMessage = "Enter the 6-digit code"
            return
        }

        if deviceID.isEmpty {
            deviceID = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        }

        isLoading = true
        loginMessage = ""

        var request = URLRequest(url: authURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload: [String: Any] = [
            "action": "verify_code",
            "email": cleanEmail,
            "code": cleanCode,
            "device_id": deviceID,
            "device_name": UIDevice.current.name,
            "platform": "iOS"
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    loginMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let data = data,
                      let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                else {
                    loginMessage = "Invalid server response"
                    return
                }

                guard (json["ok"] as? Bool) == true else {
                    loginMessage = (json["error"] as? String) ?? "Verification failed"
                    return
                }

                // Read user
                if let user = json["user"] as? [String: Any] {
                    username = user["username"] as? String ?? "User"
                    franchiseID = user["franchise_id"] as? String ?? "IstockhomesDefault"
                }

                // Read tokens
                if let tokens = json["tokens"] as? [String: Any],
                   let accessToken = tokens["access_token"] as? String,
                   let refreshToken = tokens["refresh_token"] as? String {

                    saveAccessTokenToKeychain(accessToken)
                    saveRefreshTokenBiometric(refreshToken)

                    franchiseManager.loadFranchiseConfig(franchiseID: franchiseID)
                    isLoggedIn = true
                    showDashboard = true
                } else {
                    loginMessage = "Missing tokens in response"
                }
            }
        }.resume()
    }

    func authenticateBiometrically() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock Istockhomes") { success, authError in
                DispatchQueue.main.async {
                    guard success else {
                        loginMessage = "Biometric auth failed"
                        return
                    }

                    // Use biometric-protected refresh token to mint a new access token
                    self.refreshWithBiometricToken()
                }
            }
        } else {
            loginMessage = "Biometric auth not available"
        }
    }

    // MARK: - Token Storage (Access token: normal)
    func saveAccessTokenToKeychain(_ token: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: accessTokenAccount,
            kSecValueData as String: token.data(using: .utf8) ?? Data()
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func loadAccessTokenFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: accessTokenAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        if SecItemCopyMatching(query as CFDictionary, &result) == noErr,
           let data = result as? Data,
           let token = String(data: data, encoding: .utf8) {
            return token
        }
        return nil
    }

    // MARK: - Token Storage (Refresh token: biometric protected)
    func hasRefreshToken() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: refreshTokenAccount,
            kSecReturnData as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        return SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess
    }

    func saveRefreshTokenBiometric(_ token: String) {
        // Protect refresh token with FaceID/TouchID
        let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryCurrentSet,
            nil
        )

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: refreshTokenAccount,
            kSecValueData as String: token.data(using: .utf8) ?? Data(),
            kSecAttrAccessControl as String: access as Any
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func loadRefreshTokenBiometric(prompt: String) -> String? {
        let context = LAContext()
        context.localizedReason = prompt

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: refreshTokenAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseAuthenticationContext as String: context
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        return token
    }

    // MARK: - Refresh flow
    func refreshWithBiometricToken() {
        guard !deviceID.isEmpty else {
            loginMessage = "Missing device id"
            return
        }
        guard let refreshToken = loadRefreshTokenBiometric(prompt: "Unlock to sign in") else {
            loginMessage = "No FaceID login set up yet. Use email code once."
            return
        }

        isLoading = true
        loginMessage = ""

        var request = URLRequest(url: authURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload: [String: Any] = [
            "action": "refresh",
            "device_id": deviceID,
            "refresh_token": refreshToken
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    loginMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let data = data,
                      let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                else {
                    loginMessage = "Invalid server response"
                    return
                }

                guard (json["ok"] as? Bool) == true else {
                    loginMessage = (json["error"] as? String) ?? "Refresh failed"
                    return
                }

                if let user = json["user"] as? [String: Any] {
                    username = user["username"] as? String ?? "User"
                    franchiseID = user["franchise_id"] as? String ?? "IstockhomesDefault"
                }

                if let tokens = json["tokens"] as? [String: Any],
                   let accessToken = tokens["access_token"] as? String {
                    saveAccessTokenToKeychain(accessToken)
                    franchiseManager.loadFranchiseConfig(franchiseID: franchiseID)
                    isLoggedIn = true
                    showDashboard = true
                } else {
                    loginMessage = "Missing access token"
                }
            }
        }.resume()
    }

    func handleLogout() {
        saveAccessTokenToKeychain("")
        isLoggedIn = false
        showDashboard = false
    }
}

#Preview {
    LoginView()
        .environmentObject(FranchiseManager())
}

