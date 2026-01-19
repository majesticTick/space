import Foundation
import MapKit
import SwiftUI

@MainActor
final class ISSViewModel: ObservableObject {
    struct AnnotationItem: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }

    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 60)
    )
    @Published var annotations: [AnnotationItem] = []
    @Published private(set) var lastPosition: ISSPosition?
    @Published private(set) var statusText = "Waiting for update"

    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    private let service = ISSOrbitService()
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()

    func refresh() async {
        do {
            let position = try await service.fetchPosition()
            lastPosition = position
            statusText = "Updated \(formatter.string(from: Date())) - Celestrak TLE"
            region = MKCoordinateRegion(
                center: position.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30)
            )
            annotations = [AnnotationItem(coordinate: position.coordinate)]
        } catch {
            statusText = "Update failed: \(error.localizedDescription)"
        }
    }

    var formattedLatitude: String {
        guard let position = lastPosition else { return "--" }
        return String(format: "%.4f°", position.latitude)
    }

    var formattedLongitude: String {
        guard let position = lastPosition else { return "--" }
        return String(format: "%.4f°", position.longitude)
    }

    var formattedAltitude: String {
        guard let position = lastPosition else { return "--" }
        return String(format: "%.1f km", position.altitudeKm)
    }

    var formattedVelocity: String {
        guard let position = lastPosition else { return "--" }
        return String(format: "%.1f km/h", position.velocityKmh)
    }

    var formattedTimestamp: String {
        guard let position = lastPosition else { return "--" }
        return formatter.string(from: position.timestamp)
    }
}
