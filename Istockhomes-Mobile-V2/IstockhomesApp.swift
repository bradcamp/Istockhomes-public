import SwiftUI

@main
struct IstockhomesApp: App {
    var body: some Scene {
        WindowGroup {
            // Start the app at the login screen. From there users can log in, sign up, or navigate to other views.
            LoginView()
        }
    }
}
