//
//  RoutePlannerService.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import Foundation
import CoreLocation

/// Route planning result with charging stops
struct PlannedRoute {
    let destination: CLLocationCoordinate2D
    let destinationName: String
    let totalDistanceKm: Double
    let stops: [ChargingStop]
    let estimatedTripTimeMinutes: Int
    let estimatedChargingTimeMinutes: Int
    
    /// Total time including driving + charging
    var totalTimeMinutes: Int {
        estimatedTripTimeMinutes + estimatedChargingTimeMinutes
    }
}

/// A charging stop along the route
struct ChargingStop {
    let station: ChargingStation
    let distanceFromStartKm: Double
    let arrivalChargePercent: Int
    let departureChargePercent: Int  // Always 80% unless final stop
    let chargingTimeMinutes: Int
    let estimatedArrivalOffset: Int  // Minutes from trip start
}

/// Service for calculating routes with EV charging stops
actor RoutePlannerService {
    
    /// Default safety buffer in km
    static let defaultSafetyBufferKm: Double = 50
    
    /// Target charge level at each stop (fast charging is slower after 80%)
    static let targetChargePercent: Int = 80
    
    /// Average charging speed factor (accounts for taper, etc.)
    static let chargingEfficiencyFactor: Double = 0.7
    
    /// Average driving speed for time estimates (km/h)
    static let averageSpeedKmh: Double = 80
    
    private let apiService: OpenChargeMapService
    
    init(apiService: OpenChargeMapService = OpenChargeMapService(apiKey: APIConfig.openChargeMapAPIKey)) {
        self.apiService = apiService
    }
    
    /// Plan a route with charging stops
    /// - Parameters:
    ///   - from: Starting location
    ///   - to: Destination location
    ///   - destinationName: Name of destination
    ///   - vehicle: User's vehicle settings
    ///   - currentChargePercent: Current battery level (0-100)
    ///   - safetyBufferKm: Minimum range to keep as buffer
    /// - Returns: Planned route with charging stops
    func planRoute(
        from start: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        destinationName: String,
        vehicle: UserVehicle,
        currentChargePercent: Int,
        safetyBufferKm: Double = defaultSafetyBufferKm
    ) async throws -> PlannedRoute {
        
        // Calculate total distance (straight line for MVP, MapKit would be better)
        let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
        let endLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        let totalDistanceKm = startLocation.distance(from: endLocation) / 1000 * 1.3 // Add 30% for road distance
        
        // Calculate usable range
        let maxRangeKm = Double(vehicle.rangeKm)
        let currentRangeKm = maxRangeKm * Double(currentChargePercent) / 100
        let usableRangeKm = currentRangeKm - safetyBufferKm
        
        var stops: [ChargingStop] = []
        var currentDistanceKm: Double = 0
        var currentCharge = currentChargePercent
        var tripTimeMinutes: Int = 0
        var totalChargingTime: Int = 0
        
        // Check if we need any stops
        if usableRangeKm >= totalDistanceKm {
            // Can make it without stopping
            tripTimeMinutes = Int(totalDistanceKm / Self.averageSpeedKmh * 60)
            
            return PlannedRoute(
                destination: destination,
                destinationName: destinationName,
                totalDistanceKm: totalDistanceKm,
                stops: [],
                estimatedTripTimeMinutes: tripTimeMinutes,
                estimatedChargingTimeMinutes: 0
            )
        }
        
        // Greedy algorithm: find chargers along the route
        var currentPosition = start
        let targetChargeRange = maxRangeKm * Double(Self.targetChargePercent) / 100
        
        while currentDistanceKm < totalDistanceKm {
            let remainingDistance = totalDistanceKm - currentDistanceKm
            let currentRangeAvailable = maxRangeKm * Double(currentCharge) / 100 - safetyBufferKm
            
            // Can we make it to destination?
            if currentRangeAvailable >= remainingDistance {
                break
            }
            
            // Need to find a charging stop
            // Look for chargers within 80% of our current range
            let searchRangeKm = currentRangeAvailable * 0.8
            let searchPoint = interpolatePoint(
                from: currentPosition,
                to: destination,
                distanceKm: searchRangeKm,
                totalDistanceKm: remainingDistance
            )
            
            // Fetch nearby chargers
            let stations = try await apiService.fetchNearbyStations(
                location: searchPoint,
                radiusKm: 20,
                maxResults: 10,
                connectorTypes: vehicle.connectorTypes
            )
            
            guard let bestStation = selectBestStation(
                stations: stations,
                currentPosition: currentPosition,
                destination: destination,
                preferFastCharging: true
            ) else {
                // No suitable charger found - return partial route
                break
            }
            
            // Calculate arrival charge
            let stationLocation = CLLocation(latitude: bestStation.latitude, longitude: bestStation.longitude)
            let currentLoc = CLLocation(latitude: currentPosition.latitude, longitude: currentPosition.longitude)
            let distanceToStationKm = currentLoc.distance(from: stationLocation) / 1000
            let chargeUsedPercent = Int(distanceToStationKm / maxRangeKm * 100)
            let arrivalCharge = max(10, currentCharge - chargeUsedPercent)
            
            // Calculate charging time (simplified)
            let chargeNeeded = Self.targetChargePercent - arrivalCharge
            let kwhNeeded = Double(chargeNeeded) / 100 * vehicle.usableCapacityKwh
            let effectiveChargingSpeed = Double(vehicle.maxDcChargingKw) * Self.chargingEfficiencyFactor
            let chargingMinutes = Int(kwhNeeded / effectiveChargingSpeed * 60)
            
            // Update trip state
            currentDistanceKm += distanceToStationKm
            tripTimeMinutes += Int(distanceToStationKm / Self.averageSpeedKmh * 60)
            totalChargingTime += chargingMinutes
            
            let stop = ChargingStop(
                station: bestStation,
                distanceFromStartKm: currentDistanceKm,
                arrivalChargePercent: arrivalCharge,
                departureChargePercent: Self.targetChargePercent,
                chargingTimeMinutes: chargingMinutes,
                estimatedArrivalOffset: tripTimeMinutes
            )
            stops.append(stop)
            
            // Update for next iteration
            currentPosition = bestStation.coordinate
            currentCharge = Self.targetChargePercent
        }
        
        // Add final leg time
        let finalLegDistance = totalDistanceKm - currentDistanceKm
        tripTimeMinutes += Int(finalLegDistance / Self.averageSpeedKmh * 60)
        
        return PlannedRoute(
            destination: destination,
            destinationName: destinationName,
            totalDistanceKm: totalDistanceKm,
            stops: stops,
            estimatedTripTimeMinutes: tripTimeMinutes,
            estimatedChargingTimeMinutes: totalChargingTime
        )
    }
    
    // MARK: - Private Helpers
    
    /// Interpolate a point along the route
    private func interpolatePoint(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D,
        distanceKm: Double,
        totalDistanceKm: Double
    ) -> CLLocationCoordinate2D {
        let fraction = min(1.0, distanceKm / totalDistanceKm)
        let lat = start.latitude + (end.latitude - start.latitude) * fraction
        let lon = start.longitude + (end.longitude - start.longitude) * fraction
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    /// Select the best charging station from candidates
    private func selectBestStation(
        stations: [ChargingStation],
        currentPosition: CLLocationCoordinate2D,
        destination: CLLocationCoordinate2D,
        preferFastCharging: Bool
    ) -> ChargingStation? {
        guard !stations.isEmpty else { return nil }
        
        let currentLoc = CLLocation(latitude: currentPosition.latitude, longitude: currentPosition.longitude)
        let destLoc = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        
        // Score stations: prefer ones along route with fast charging
        let scored = stations.map { station -> (ChargingStation, Double) in
            let stationLoc = CLLocation(latitude: station.latitude, longitude: station.longitude)
            
            // Distance from current position
            let distFromCurrent = currentLoc.distance(from: stationLoc) / 1000
            
            // How much it adds to trip (detour penalty)
            let directDist = currentLoc.distance(from: destLoc) / 1000
            let viaStation = distFromCurrent + stationLoc.distance(from: destLoc) / 1000
            let detour = viaStation - directDist
            
            // Prefer fast chargers (CCS, Tesla)
            let hasFastCharger = station.connectorTypes.contains { $0 == .ccs || $0 == .tesla }
            let speedBonus: Double = hasFastCharger && preferFastCharging ? -10 : 0
            
            // Score: lower is better
            let score = detour + speedBonus
            return (station, score)
        }
        
        return scored.min { $0.1 < $1.1 }?.0
    }
}
