import SwiftUI

struct HeaderView: View {
    let config: FranchiseConfig

    var body: some View {
        VStack(spacing: 8) {
            // ✅ Logo
            if let url = URL(string: config.logoPath) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 100)
                        .padding(.top, 8)
                } placeholder: {
                    ProgressView()
                        .frame(height: 100)
                }
            }

            // ✅ Contact Info
            if !(config.contactName.isEmpty && config.contactEmail.isEmpty && config.contactPhone.isEmpty) {
                VStack(spacing: 4) {
                    if !config.contactName.isEmpty {
                        Text(config.contactName)
                            .font(.headline)
                    }
                    if !config.contactEmail.isEmpty {
                        Text(config.contactEmail)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    if !config.contactPhone.isEmpty {
                        Text(config.contactPhone)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

#Preview {
    HeaderView(config: FranchiseConfig(
        franchiseID: "demo",
        logoPath: "https://istockhomes.com/App/images/Istockhomes%20Andy%20Logo%20clear.png",
        contactName: "Brad Camp Realty",
        contactEmail: "brad@example.com",
        contactPhone: "1-555-555-5555",
        accentColor: "#000000"
    ))
}

