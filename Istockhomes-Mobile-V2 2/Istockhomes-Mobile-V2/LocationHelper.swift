import Foundation
import CoreLocation

class LocationHelper: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let manager = CLLocationManager()
    
    // Publishes live location updates if you want SwiftUI bindings
    @Published var currentLocation: CLLocation?
    
    // Closure to handle callback directly
    var didUpdate: ((CLLocation) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    // ✅ Delegate callback
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.first {
            DispatchQueue.main.async {
                self.currentLocation = loc
                self.didUpdate?(loc)
                print("✅ Got location: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
    }
}

