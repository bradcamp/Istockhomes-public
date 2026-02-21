import Foundation

// ✅ This file stays as your ONLY source of truth for models!
// Make sure you do NOT have another "DashboardListing" declared elsewhere.

// MARK: - One listing item
struct DashboardListing: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String? // Optional
    let price: Double
    let category: String?
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let image_path: String?
    let owner_email: String?
    let franchisee_email: String?
    let franchise_id: String?
    let show_location: Bool?
    let aircraft_tail: String?
    let aircraft_make: String?
    let aircraft_model: String?
    let aircraft_year: String?
    let aircraft_engine: String?
    let aircraft_hours: String?
    let aircraft_track: Bool?
    let marine_make: String?
    let marine_model: String?
    let marine_year: String?
    let marine_engine: String?
    let marine_length: String?
    let marine_mmsi: String?
    let marine_track: Bool?
    let owner_paypal: String?
    let franchisee_paypal: String?
    let charter_available: Bool?
}

// MARK: - Full dashboard response
struct DashboardResponse: Codable {
    let success: Bool
    let franchise_id: String?
    let available_franchises: [String]?
    let profile: ProfileInfo
    let stats: DashboardStats
    let categories: [String: [DashboardListing]]
}

// MARK: - Profile verification info
struct ProfileInfo: Codable {
    let email_verified: Bool
    let phone_verified: Bool
    let face_verified: Bool
}

// MARK: - Dashboard summary stats
struct DashboardStats: Codable {
    let total_listings: Int
    let total_price: Double
    let average_price: Double
    let estimated_value: Double
}

// MARK: - Franchise config model
struct FranchiseConfig: Codable {
    let franchiseID: String
    let logoPath: String
    let contactName: String
    let contactEmail: String
    let contactPhone: String
    let accentColor: String?

    enum CodingKeys: String, CodingKey {
        case franchiseID = "franchise_id"
        case logoPath = "logo_path"
        case contactName = "contact_name"
        case contactEmail = "contact_email"
        case contactPhone = "contact_phone"
        case accentColor
    }
}
// MARK: - API response for all listings
struct ListingsResponse: Codable {
    let listings: [DashboardListing]
}
