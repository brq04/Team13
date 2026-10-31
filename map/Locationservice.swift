import CoreLocation
import Observation

/// مدير موقع واحد للتطبيق كله: يطلب الإذن (نافذة أبل) ويتابع حالته
@MainActor
@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()

    private let manager = CLLocationManager()
    var status: CLAuthorizationStatus = .notDetermined

    var isAuthorized: Bool { status == .authorizedWhenInUse || status == .authorizedAlways }
    var isDenied: Bool { status == .denied || status == .restricted }

    override init() {
        super.init()
        manager.delegate = self
        status = manager.authorizationStatus
    }

    /// يطلع نافذة أبل "السماح أثناء استخدام التطبيق"
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let newStatus = manager.authorizationStatus
        Task { @MainActor in self.status = newStatus }
    }
}
