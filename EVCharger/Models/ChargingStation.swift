//
//  ChargingStation.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-03.
//

import Foundation
import SwiftData
import CoreLocation

/// Core data model representing an EV charging station.
/// Designed to map from Open Charge Map API responses and persist via SwiftData.
@Model
final class ChargingStation {
    /// Unique identifier (from Open Charge Map or generated)
    @Attribute(.unique) var id: UUID
    
    /// Station name (e.g., "ChargePoint Station #12345")
    var name: String
    
    /// Network operator name (e.g., "ChargePoint", "Electrify America")
    var operatorName: String?
    
    /// Full street address
    var address: String
    
    /// Geographic coordinates
    var latitude: Double
    var longitude: Double
    
    /// Available connector types at this station
    var connectorTypes: [ConnectorType]
    
    /// Number of charging points/plugs available
    var numberOfPoints: Int
    
    /// Current station status (if known)
    var statusType: StatusType?
    
    /// Usage cost description (free-form text from API)
    var usageCost: String?
    
    /// When this data was last updated from the API
    var lastUpdated: Date
    
    /// When this record was cached locally
    var cachedAt: Date
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        name: String,
        operatorName: String? = nil,
        address: String,
        latitude: Double,
        longitude: Double,
        connectorTypes: [ConnectorType],
        numberOfPoints: Int = 1,
        statusType: StatusType? = nil,
        usageCost: String? = nil,
        lastUpdated: Date = Date(),
        cachedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.operatorName = operatorName
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.connectorTypes = connectorTypes
        self.numberOfPoints = numberOfPoints
        self.statusType = statusType
        self.usageCost = usageCost
        self.lastUpdated = lastUpdated
        self.cachedAt = cachedAt
    }
}

// MARK: - Computed Properties

extension ChargingStation {
    /// CLLocationCoordinate2D for MapKit integration
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// CLLocation for distance calculations
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    /// Distance from a given location in meters
    func distance(from userLocation: CLLocation) -> CLLocationDistance {
        location.distance(from: userLocation)
    }
    
    /// Formatted distance string (e.g., "0.3 mi" or "1.2 km")
    /// Formatted distance string (e.g., "0.3 mi" or "1.2 km")
    func formattedDistance(from userLocation: CLLocation) -> String {
        let distanceInMeters = distance(from: userLocation)
        let distance = Measurement(value: distanceInMeters, unit: UnitLength.meters)
        
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .naturalScale
        formatter.numberFormatter.maximumFractionDigits = 1
        
        return formatter.string(from: distance)
    }
    
    /// Comma-separated list of connector types for display
    var connectorSummary: String {
        connectorTypes.map(\.shortName).joined(separator: ", ")
    }
    
    /// Whether the cache is stale (older than 24 hours)
    var isCacheStale: Bool {
        let staleThreshold: TimeInterval = 24 * 60 * 60 // 24 hours
        return Date().timeIntervalSince(cachedAt) > staleThreshold
    }
}

// MARK: - Sample Data (for previews and testing)

extension ChargingStation {
    static var sample: ChargingStation {
        ChargingStation(
            name: "ChargePoint Station",
            operatorName: "ChargePoint",
            address: "123 Main Street, San Francisco, CA 94102",
            latitude: 37.7749,
            longitude: -122.4194,
            connectorTypes: [.ccs, .chademo],
            numberOfPoints: 4,
            statusType: .available,
            usageCost: "$0.35/kWh"
        )
    }
    
    static var samples: [ChargingStation] {
        [
            ChargingStation(
                name: "Electrify America - Target",
                operatorName: "Electrify America",
                address: "456 Market Street, San Francisco, CA 94105",
                latitude: 37.7899,
                longitude: -122.4000,
                connectorTypes: [.ccs],
                numberOfPoints: 8,
                statusType: .available,
                usageCost: "$0.43/kWh"
            ),
            ChargingStation(
                name: "Tesla Supercharger",
                operatorName: "Tesla",
                address: "789 Howard Street, San Francisco, CA 94103",
                latitude: 37.7850,
                longitude: -122.4050,
                connectorTypes: [.tesla],
                numberOfPoints: 12,
                statusType: .occupied,
                usageCost: "$0.38/kWh peak"
            ),
            ChargingStation(
                name: "EVgo Fast Charging",
                operatorName: "EVgo",
                address: "321 Folsom Street, San Francisco, CA 94107",
                latitude: 37.7870,
                longitude: -122.3950,
                connectorTypes: [.ccs, .chademo],
                numberOfPoints: 2,
                statusType: .unknown
            )
        ]
    }
}
