import Foundation

class APIService {
    static let shared = APIService()

    private init() {}

    func fetchListings(completion: @escaping (Result<[Listing], Error>) -> Void) {
        let urlString = "https://istockhomes.com/App/api/Listings.php"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(ListingsResponse.self, from: data)
                completion(.success(decoded.listings))
            } catch {
                completion(.failure(error))
            }

        }.resume()
    }
}
