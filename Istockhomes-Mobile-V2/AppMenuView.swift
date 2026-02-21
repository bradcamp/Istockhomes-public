import SwiftUI

struct AppMenuView: View {
    @Binding var isShowing: Bool
    var profileUsername: String
    @ObservedObject var franchiseManager: FranchiseManager
    var onLogout: () -> Void // ✅ Accept logout callback

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("👋 Hello, \(profileUsername)")
                .font(.headline)

            // ✅ Dashboard
            if let franchiseID = franchiseManager.config?.franchiseID {
                NavigationLink(destination: DashboardView(
                    username: profileUsername,
                    franchiseID: franchiseID,
                    franchiseManager: franchiseManager,
                    onLogout: onLogout
                )) {
                    Label("Dashboard", systemImage: "rectangle.grid.2x2")
                }
                .buttonStyle(BlackButtonStyle())
            }

            // ✅ Add Listing (clean route, no prefill BS)
            NavigationLink(destination: UploadImageView()) {
                Label("Add Listing", systemImage: "plus.circle")
            }
            .buttonStyle(BlackButtonStyle())

            // ✅ View Listings
            NavigationLink(destination: ViewListings(franchiseManager: franchiseManager)) {
                Label("View Listings", systemImage: "list.bullet")
            }
            .buttonStyle(BlackButtonStyle())

            // ✅ Update Profile
            NavigationLink(destination: UpdateProfileView(username: "", email: "", phone: "")) {
                Label("Update Profile", systemImage: "person.crop.circle")
            }
            .buttonStyle(BlackButtonStyle())

            // ✅ Branding Settings
            NavigationLink(destination: BrandingView()) {
                Label("Branding", systemImage: "paintpalette")
            }
            .buttonStyle(BlackButtonStyle())

            // ✅ Logout (calls passed in handler)
            Button {
                withAnimation { isShowing = false }
                onLogout() // ✅ Logout logic invoked
            } label: {
                Label("Logout", systemImage: "arrow.backward.square")
            }
            .buttonStyle(BlackButtonStyle())

            Spacer()

            // ✅ Close menu
            Button {
                withAnimation { isShowing = false }
            } label: {
                Label("Close Menu", systemImage: "xmark")
            }
            .buttonStyle(BlackButtonStyle())
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

