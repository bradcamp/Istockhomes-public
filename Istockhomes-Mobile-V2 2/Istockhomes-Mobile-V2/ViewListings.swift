import SwiftUI
import Foundation // ensure this is present if used externally
import UIKit    // needed for UIApplication.shared.open

// ✅ Using shared models — remove local declarations to prevent conflicts
// DashboardListing and ListingsResponse are already declared globally in Models.swift

struct ViewListings: View {
    @ObservedObject var franchiseManager: FranchiseManager

    @State private var listings: [DashboardListing] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedCategory: String = "All"
    let categories = ["All", "Business", "Marine", "Aircraft", "Housing", "Art", "Domains", "Automotive"]

    var filteredListings: [DashboardListing] {
        listings.filter { listing in
            selectedCategory == "All" || listing.category == selectedCategory
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // ✅ Istockhomes Logo Header
                AsyncImage(url: URL(string: "https://istockhomes.com/App/images/Paruse.png")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 80)
                } placeholder: {
                    ProgressView()
                }

                // ✅ Category Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(categories, id: \".self\") { cat in
                            Text(cat)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(cat == selectedCategory ? Color.black : Color.gray.opacity(0.2))
                                .foregroundColor(cat == selectedCategory ? .white : .black)
                                .cornerRadius(20)
                                .onTapGesture {
                                    selectedCategory = cat
                                }
                        }
                    }
                    .padding(.horizontal)
                }

                if isLoading {
                    ProgressView("Loading Listings...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text("❌ \(errorMessage)")
                        .foregroundColor(.red)
                } else if filteredListings.isEmpty {
                    Text("No listings match this category.")
                        .foregroundColor(.secondary)
                } else {
                    List(filteredListings) { listing in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(listing.title)
                                .font(.headline)

                            Text(formattedPrice(listing.price))
                                .font(.caption)
                                .foregroundColor(.green)

                            if let imagePath = listing.image_path, !imagePath.isEmpty {
                                let fullURLString = imagePath.starts(with: "http")
                                    ? imagePath
                                    : "https://istockhomes.com/App/\(imagePath)"

                                if let url = URL(string: fullURLString) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxHeight: 200)
                                            .cornerRadius(8)
                                            .onTapGesture(count: 2) {
                                                let urlString = "https://istockhomes.com/view-listing.php?id=\(listing.id)"
                                                if let link = URL(string: urlString) {
                                                    UIApplication.shared.open(link)
                                                }
                                            }
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                }

                Spacer()

                // ✅ Footer Branding — Istockhomes logo only, no link
                VStack {
                    if let logoURL = URL(string: "https://istockhomes.com/App/images/Istockhomes_logo-2020-Clear.jpg") {
                        AsyncImage(url: logoURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 30)
                                    .opacity(0.8)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 30)
                                    .opacity(0.3)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }

                    Text("Branded & Verified")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 12)
            }
            .navigationTitle("")
            .onAppear {
                loadListings()
            }
        }
    }

    func formattedPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: price)) ?? "$0.00"
    }

    func loadListings() {
        let urlString = "https://istockhomes.com/App/api/AllListings.php"

        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil

        URLSession.shared.dataTask(with: url) { data, _, error in
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
                    let decoded = try JSONDecoder().decode(ListingsResponse.self, from: data)
                    self.listings = decoded.listings
                } catch {
                    errorMessage = "JSON decode error: \(error.localizedDescription)"
                    if let raw = String(data: data, encoding: .utf8) {
                        print("RAW JSON:", raw)
                    }
                }
            }
        }.resume()
    }
}

