import CoreLocation
import Foundation

struct ISSPosition {
    let coordinate: CLLocationCoordinate2D
    let latitude: Double
    let longitude: Double
    let altitudeKm: Double
    let velocityKmh: Double
    let timestamp: Date
}
