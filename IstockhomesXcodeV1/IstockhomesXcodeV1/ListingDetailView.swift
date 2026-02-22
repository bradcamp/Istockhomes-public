import SwiftUI

struct ListingDetailView: View {
    let listing: Listing

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text(listing.safeTitle)
                    .font(.largeTitle)
                    .bold()

                if let description = listing.description {
                    Text(description)
                        .foregroundColor(.secondary)
                }

                if let price = listing.price {
                    Text(price)
                        .font(.title3)
                        .foregroundColor(.blue)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
