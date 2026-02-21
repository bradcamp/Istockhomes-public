import SwiftUI

struct BrandingView: View {
    @AppStorage("franchise_id") var franchiseID: String = "IstockhomesDefault"

    @State private var headerBGColor = "#ffffff"
    @State private var accentColor = "#1E40AF"
    @State private var contactName = ""
    @State private var contactEmail = ""
    @State private var contactPhone = ""
    @State private var message = ""

    @State private var logoURL: URL? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Edit Branding")
                    .font(.largeTitle)

                if let logoURL = logoURL {
                    AsyncImage(url: logoURL) { image in
                        image.resizable().scaledToFit().frame(height: 100)
                    } placeholder: {
                        ProgressView()
                    }
                    .onTapGesture {
                        isImagePickerPresented = true
                    }
                }

                Text("Tap logo to upload new image")
                    .font(.caption)
                    .foregroundColor(.gray)

                TextField("Contact Name", text: $contactName)
                    .textFieldStyle(.roundedBorder)

                TextField("Contact Email", text: $contactEmail)
                    .textFieldStyle(.roundedBorder)

                TextField("Contact Phone", text: $contactPhone)
                    .textFieldStyle(.roundedBorder)

                TextField("Header BG Color", text: $headerBGColor)
                    .textFieldStyle(.roundedBorder)

                TextField("Accent Color", text: $accentColor)
                    .textFieldStyle(.roundedBorder)

                Button("Save Changes") {
                    updateBranding()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                Text(message)
                    .foregroundColor(.green)
            }
            .padding()
        }
        .onAppear {
            fetchBranding()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $selectedImage)
                .onDisappear {
                    if let image = selectedImage {
                        uploadLogo(image)
                    }
                }
        }
    }

    func fetchBranding() {
        guard let url = URL(string: "https://istockhomes.com/App/api/get-branding.php?franchise_id=\(franchiseID)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let config = json["config"] as? [String: Any] {
                DispatchQueue.main.async {
                    headerBGColor = config["header_bg_color"] as? String ?? "#ffffff"
                    accentColor = config["accent_color"] as? String ?? "#1E40AF"
                    contactName = config["contact_name"] as? String ?? ""
                    contactEmail = config["contact_email"] as? String ?? ""
                    contactPhone = config["contact_phone"] as? String ?? ""
                    if let logoPath = config["logo_path"] as? String {
                        logoURL = URL(string: logoPath)
                    }
                }
            }
        }.resume()
    }

    func updateBranding() {
        guard let url = URL(string: "https://istockhomes.com/App/api/update-branding.php") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: String] = [
            "franchise_id": franchiseID,
            "header_bg_color": headerBGColor,
            "accent_color": accentColor,
            "contact_name": contactName,
            "contact_email": contactEmail,
            "contact_phone": contactPhone
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                message = "✅ Branding updated!"
            }
        }.resume()
    }

    func uploadLogo(_ image: UIImage) {
        guard let url = URL(string: "https://istockhomes.com/App/api/upload-logo.php") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let imageData = image.jpegData(compressionQuality: 0.8)!

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"franchise_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(franchiseID)\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"logo\"; filename=\"logo.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.uploadTask(with: request, from: body) { data, _, _ in
            DispatchQueue.main.async {
                message = "✅ Logo uploaded!"
                fetchBranding()
            }
        }.resume()
    }
}

#Preview {
    BrandingView()
}

