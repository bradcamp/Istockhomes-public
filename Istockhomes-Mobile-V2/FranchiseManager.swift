import Foundation
import Combine

// ✅ Use the FranchiseConfig from Models.swift
// Make sure you have: import Foundation in Models.swift too

// Wrapper for the API response (only if needed)
struct FranchiseConfigResponse: Codable {
    let success: Bool
    let franchiseID: String
    let logoPath: String
    let contactName: String
    let contactEmail: String
    let contactPhone: String
    let accentColor: String?
}

// ✅ The manager class to handle API call & publish changes
class FranchiseManager: ObservableObject {
    @Published var config: FranchiseConfig?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    // Load franchise config from server
    func loadFranchiseConfig(franchiseID: String) {
        guard let url = URL(string: "https://istockhomes.com/App/api/get-franchise-config.php?franchise_id=\(franchiseID)") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data returned from server"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(FranchiseConfigResponse.self, from: data)
                    
                    if response.success {
                        // ✅ Map API response to your shared FranchiseConfig model
                        self.config = FranchiseConfig(
                            franchiseID: response.franchiseID,
                            logoPath: response.logoPath,
                            contactName: response.contactName,
                            contactEmail: response.contactEmail,
                            contactPhone: response.contactPhone,
                            accentColor: response.accentColor
                        )
                    } else {
                        self.errorMessage = "API error: did not succeed"
                    }
                } catch {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

