import SwiftUI
import UIKit

/// A view that lets the user pick a photo using the built‑in `UIImagePickerController`,
/// sends it to OpenAI for analysis using `OpenAIHelper`, then navigates to
/// `SubmitListingView` where the listing can be reviewed and submitted.  This
/// approach works on iOS 14 and later.
struct UploadImageView: View {
    @State private var selectedImage: UIImage?
    @State private var aiDescription: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showImagePicker: Bool = false
    @State private var navigate: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Show either a placeholder or the selected image
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(10)
                } else {
                    Image(systemName: "photo.on.rectangle.angled")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray)
                }

                Button("Select Photo") {
                    showImagePicker = true
                }
                .buttonStyle(BlackButtonStyle())

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                if isLoading {
                    ProgressView("Analyzing image…")
                        .padding()
                }

                Spacer()

                // Hidden navigation link triggers when `navigate` becomes true
                NavigationLink(destination: submitView(), isActive: $navigate) {
                    EmptyView()
                }
                .hidden()
            }
            .padding()
            .navigationTitle("Add Listing")
            .sheet(isPresented: $showImagePicker, onDismiss: analyzeSelectedImage) {
                ImagePicker(image: $selectedImage)
            }
        }
    }

    /// Called after the image picker is dismissed.  If a new image was selected
    /// this kicks off the OpenAI analysis.
    private func analyzeSelectedImage() {
        guard let image = selectedImage, let data = image.jpegData(compressionQuality: 0.8) else { return }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let base64 = data.base64EncodedString()
                let result = try await OpenAIHelper.analyzeImage(base64Image: base64)
                self.aiDescription = result["description"] ?? ""
            } catch {
                self.errorMessage = "AI analysis failed: \(error.localizedDescription)"
            }
            self.isLoading = false
            // Navigate to the submit screen regardless of success; the user can
            // edit the description later.
            self.navigate = true
        }
    }

    /// Destination view for submitting the listing.  Ensures image data is passed.
    @ViewBuilder
    private func submitView() -> some View {
        if let image = selectedImage, let data = image.jpegData(compressionQuality: 0.8) {
            SubmitListingView(imageData: data, aiDescription: aiDescription)
        } else {
            Text("No image selected")
        }
    }
}

#Preview {
    UploadImageView()
}
