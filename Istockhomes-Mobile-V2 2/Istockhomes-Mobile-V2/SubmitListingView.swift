import SwiftUI
import CoreLocation
import UIKit // for UIApplication.shared used when opening URLs

struct SubmitListingView: View {
    let imageData: Data
    @State var aiDescription: String

    // Inputs
    @State private var title: String = ""
    @State private var category: String = ""
    @State private var price: String = ""
    @State private var description: String = ""
    @State private var address: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""

    @State private var submitMessage: String = ""

    // ✅ Your franchise ID (pass if dynamic!)
    let franchiseID: String = "FLREL"

    // ✅ NEW: LocationHelper
    @StateObject private var locationHelper = LocationHelper()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(10)
                }

                Group {
                    TextField("Title", text: $title)
                        .textFieldStyle(.roundedBorder)

                    TextField("Category", text: $category)
                        .textFieldStyle(.roundedBorder)

                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)

                    TextEditor(text: $description)
                        .frame(height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                        .onAppear {
                            if description.isEmpty {
                                description = aiDescription
                            }
                        }

                    TextField("Address", text: $address)
                        .textFieldStyle(.roundedBorder)

                    TextField("Latitude", text: $latitude)
                        .textFieldStyle(.roundedBorder)

                    TextField("Longitude", text: $longitude)
                        .textFieldStyle(.roundedBorder)
                }

                Button("📍 Auto-Fill Location") {
                    autoFillLocationIfNeeded()
                }
                .buttonStyle(BlackButtonStyle())

                Button("✅ Save Listing") {
                    submitListing()
                }
                .buttonStyle(BlackButtonStyle())

                Text(submitMessage)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .navigationTitle("Review & Submit")
    }

    // ✅ Auto-fill location and reverse geocode
    func autoFillLocationIfNeeded() {
        locationHelper.didUpdate = { loc in
            latitude = String(format: "%.8f", loc.coordinate.latitude)
            longitude = String(format: "%.8f", loc.coordinate.longitude)
            print("✅ Auto-filled lat/lng: \(latitude), \(longitude)")

            CLGeocoder().reverseGeocodeLocation(loc) { placemarks, error in
                if let place = placemarks?.first {
                    address = [
                        place.name,
                        place.locality,
                        place.administrativeArea
                    ].compactMap { $0 }.joined(separator: ", ")
                    print("✅ Auto-filled address: \(address)")
                }
            }
        }
        locationHelper.requestLocation()
    }

    // ✅ Submit listing to your PHP API
    func submitListing() {
        guard let url = URL(string: "https://istockhomes.com/App/api/SubmitListing.php") else {
            submitMessage = "❌ Invalid API URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "title": title,
            "price": price,
            "category": category,
            "description": description,
            "latitude": latitude,
            "longitude": longitude,
            "address": address,
            "image_path": "uploads/my_uploaded_image.jpg", // ✅ Replace if dynamic
            "franchise_id": franchiseID
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    submitMessage = "❌ Error: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    submitMessage = "❌ No response from server."
                    return
                }

                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let success = json["success"] as? Bool {
                    submitMessage = success ? "✅ Listing saved!" : "❌ \(json["message"] as? String ?? "Failed")"
                } else {
                    submitMessage = "❌ Invalid server response."
                }
            }
        }.resume()
    }
}

#Preview {
    SubmitListingView(
        imageData: Data(),
        aiDescription: "Sample AI description"
    )
}

