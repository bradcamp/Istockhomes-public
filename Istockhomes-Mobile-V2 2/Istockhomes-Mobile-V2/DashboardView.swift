import SwiftUI
import Security // for keychain functions such as SecItemCopyMatching

struct DashboardView: View {
    let username: String
    let franchiseID: String
    @ObservedObject var franchiseManager: FranchiseManager
    var onLogout: () -> Void // ✅ Add logout callback

    @State private var response: DashboardResponse?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showMenu = false

    var body: some View {
        AppLayout(franchiseManager: franchiseManager) {
            ZStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 20) {

                    Text("📊 Welcome, \(username)")
                        .font(.headline)

                    // ✅ Action Buttons (match AppMenuView destinations)
                    VStack(spacing: 12) {
                        NavigationLink(destination: UploadImageView()) {
                            Label("📷 Add a Listing", systemImage: "plus.circle")
                        }.buttonStyle(BlackButtonStyle())

                        NavigationLink(destination: ViewListings(franchiseManager: franchiseManager)) {
                            Label("📁 View My Listings", systemImage: "list.bullet")
                        }.buttonStyle(BlackButtonStyle())

                        NavigationLink(destination: UpdateProfileView(username: "", email: "", phone: "")) {
                            Label("👤 Update Profile", systemImage: "person.crop.circle")
                        }.buttonStyle(BlackButtonStyle())

                        NavigationLink(destination: BrandingView()) {
                            Label("🎨 Branding", systemImage: "paintpalette")
                        }.buttonStyle(BlackButtonStyle())
                    }

                    // 🔄 API loading and error handling
                    if isLoading {
                        ProgressView("Loading...")
                    } else if let errorMessage = errorMessage {
                        Text("❌ \(errorMessage)")
                            .foregroundColor(.red)
                    } else if let response = response {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("✅ Email Verified: \(response.profile.email_verified.description)")
                            Text("✅ Phone Verified: \(response.profile.phone_verified.description)")
                            Text("✅ Face Verified: \(response.profile.face_verified.description)")

                            Divider()

                            Text("📊 Stats:")
                            Text("- Total Listings: \(response.stats.total_listings)")
                            Text("- Total Price: \(String(format: "%.2f", response.stats.total_price))")
                            Text("- Avg Price: \(String(format: "%.2f", response.stats.average_price))")
                            Text("- Estimated Value: \(String(format: "%.2f", response.stats.estimated_value))")
                        }
                        .font(.subheadline)
                    }

                    Spacer()
                }
                .padding()
                .navigationTitle("Dashboard")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            withAnimation { showMenu.toggle() }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                        }
                    }
                }
                .gesture(
                    DragGesture().onEnded { value in
                        if value.translation.width > 50 {
                            withAnimation { showMenu = true }
                        }
                    }
                )
                .onAppear {
                    loadDashboard()
                }

                // 🍔 Side menu overlay
                if showMenu {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture { withAnimation { showMenu = false } }

                    AppMenuView(
                        isShowing: $showMenu,
                        profileUsername: username,
                        franchiseManager: franchiseManager,
                        onLogout: onLogout // ✅ Pass logout callback
                    )
                    .frame(width: 250)
                    .background(.white)
                    .transition(.move(edge: .leading))
                }
            }
        }
    }

    func loadDashboard() {
        guard let url = URL(string: "https://istockhomes.com/App/api/Dashboard.php?franchise_id=\(franchiseID)") else {
            errorMessage = "Invalid API URL"
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = loadToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = "Error: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    errorMessage = "No data returned"
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(DashboardResponse.self, from: data)
                    response = decoded
                } catch {
                    errorMessage = "Failed to parse: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    func loadToken() -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: "userToken",
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary

        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        if let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

#Preview {
    DashboardView(username: "Brad Camp", franchiseID: "FLREL", franchiseManager: FranchiseManager(), onLogout: {})
}

