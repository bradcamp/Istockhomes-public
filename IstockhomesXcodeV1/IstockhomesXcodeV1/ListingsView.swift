import SwiftUI

struct ListingsView: View {

    @State private var listings: [Listing] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading...")
                }
                else if let errorMessage = errorMessage {
                    VStack {
                        Text(errorMessage).foregroundStyle(.red)
                        Button("Retry") {
                            loadListings()
                        }
                    }
                }
                else {
                    List(listings) { listing in
                        NavigationLink {
                            ListingDetailView(listing: listing)
                        } label: {
                            HStack {
                                AsyncImage(url: listing.imageURL) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image.resizable()
                                            .scaledToFill()
                                    case .failure:
                                        Image(systemName: "photo")
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)

                                VStack(alignment: .leading) {
                                    Text(listing.safeTitle)
                                        .font(.headline)

                                    if let price = listing.price {
                                        Text(price)
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Istockhomes")
            .onAppear {
                loadListings()
            }
        }
    }

    private func loadListings() {
        isLoading = true
        errorMessage = nil

        APIService.shared.fetchListings { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case .success(let listings):
                    self.listings = listings
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
