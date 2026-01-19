import CoreLocation
import Foundation
import SatelliteKit

final class ISSOrbitService {
    private let tleEndpoint = URL(string: "https://celestrak.org/NORAD/elements/gp.php?CATNR=25544&FORMAT=TLE")!
    private let session: URLSession
    private let cacheTTL: TimeInterval = 6 * 60 * 60
    private var cachedTLE: (String, String, String)?
    private var cachedAt: Date?

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchPosition() async throws -> ISSPosition {
        let tle = try await fetchTLE()
        let elements = try Elements(tle.0, tle.1, tle.2)
        let satellite = Satellite(elements: elements)

        let now = Date()
        let julianDays = now.julianDate
        let positionVector = try satellite.position(julianDays: julianDays)
        let velocityVector = try satellite.velocity(julianDays: julianDays)

        let geo = eci2geo(julianDays: julianDays, celestial: positionVector)
        let speedKmh = magnitude(velocityVector) * 3600.0

        return ISSPosition(
            coordinate: CLLocationCoordinate2D(latitude: geo.lat, longitude: geo.lon),
            latitude: geo.lat,
            longitude: geo.lon,
            altitudeKm: geo.alt,
            velocityKmh: speedKmh,
            timestamp: now
        )
    }

    private func fetchTLE() async throws -> (String, String, String) {
        if let cachedTLE, let cachedAt, Date().timeIntervalSince(cachedAt) < cacheTTL {
            return cachedTLE
        }

        let (data, response) = try await session.data(from: tleEndpoint)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let text = String(decoding: data, as: UTF8.self)
        let records = preProcessTLEs(text)
        guard let tle = records.first else {
            throw URLError(.cannotParseResponse)
        }

        cachedTLE = tle
        cachedAt = Date()
        return tle
    }
}
