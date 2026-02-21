import SwiftUI

struct ListingDetailView: View {
    let listing: DashboardListing

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(listing.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                // ✅ Safely unwrap optional description
                if let desc = listing.description {
                    Text(desc)
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Price:")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text(String(format: "$%.2f", listing.price))
                        .font(.title3)
                        .foregroundColor(.blue)
                }

                // ✅ Optional address
                if let address = listing.address {
                    Text("Address: \(address)")
                        .font(.body)
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ListingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ListingDetailView(listing: DashboardListing(
            id: 1,
            title: "Luxury Yacht",
            description: "A beautiful yacht for private charters. Fully crewed, all inclusive, and ready to sail.",
            price: 2_500_000,
            category: "Marine",
            address: "Marina Bay",
            latitude: nil,
            longitude: nil,
            image_path: nil,
            owner_email: nil,
            franchisee_email: nil,
            franchise_id: nil,
            show_location: nil,
            aircraft_tail: nil,
            aircraft_make: nil,
            aircraft_model: nil,
            aircraft_year: nil,
            aircraft_engine: nil,
            aircraft_hours: nil,
            aircraft_track: nil,
            marine_make: nil,
            marine_model: nil,
            marine_year: nil,
            marine_engine: nil,
            marine_length: nil,
            marine_mmsi: nil,
            marine_track: nil,
            owner_paypal: nil,
            franchisee_paypal: nil,
            charter_available: nil
        ))
    }
}

