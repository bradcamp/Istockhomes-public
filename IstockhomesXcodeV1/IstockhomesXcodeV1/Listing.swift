import Foundation

struct Listing: Codable, Identifiable {
    let id: Int
    let title: String?
    let description: String?
    let price: String?
    let category: String?
    let image_path: String?

    var safeTitle: String {
        let t = (title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? "Untitled" : t
    }

    var imageURL: URL? {
        guard let p = image_path, !p.isEmpty else { return nil }
        if p.lowercased().hasPrefix("http") { return URL(string: p) }
        return URL(string: "https://istockhomes.com/App/\(p)")
    }
}
