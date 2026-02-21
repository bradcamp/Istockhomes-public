import SwiftUI
import PhotosUI
import Security // for SecItemCopyMatching used to load token from keychain
import UIKit      // for ImagePicker fallback on older iOS versions

struct UpdateProfileView: View {
    @State var username: String
    @State var email: String
    @State var phone: String
    @State var description: String = ""
    @State var profileImage: UIImage? = nil
    @State private var photoItem: PhotosPickerItem?

    // Fallback for iOS versions prior to 16: present ImagePicker
    @State private var showImagePicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Update Profile")
                    .font(.largeTitle).bold()

                if let image = profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray)
                }
                // Image upload button: uses PhotosPicker on iOS 16+, otherwise falls back to a custom picker.
                if #available(iOS 16.0, *) {
                    PhotosPicker("Upload Photo", selection: $photoItem, matching: .images)
                        .buttonStyle(BlackButtonStyle())
                        .task(id: photoItem) {
                            if let newItem = photoItem {
                                if let data = try? await newItem.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    profileImage = uiImage
                                }
                            }
                        }
                } else {
                    Button("Upload Photo") {
                        showImagePicker = true
                    }
                    .buttonStyle(BlackButtonStyle())
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(image: $profileImage)
                    }
                }

                TextField("Description", text: $description)
                    .textFieldStyle(.roundedBorder)

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                TextField("Phone", text: $phone)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)

                Button("Save Changes") {
                    saveProfile()
                }
                .buttonStyle(BlackButtonStyle())

                Spacer()
            }
            .padding()
        }
        .onAppear {
            // Optional: prefill fields from secure source if needed
        }
    }

    // ✅ Save profile changes to your API
    func saveProfile() {
        guard let url = URL(string: "https://istockhomes.com/App/api/update-profile.php") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let token = loadToken() ?? ""

        let params: [String: Any] = [
            "username": username,
            "email": email,
            "phone": phone,
            "description": description
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: params)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ Save failed: \(error.localizedDescription)")
                return
            }

            print("✅ Profile updated successfully!")
        }.resume()
    }

    // ✅ Load token from Keychain
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

