//
//  FindChargerIntent.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import AppIntents
import CoreLocation

/// Siri Intent: "Find a charger" - Opens app with nearby charger list
struct FindChargerIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Find a Charger"
    static var description = IntentDescription("Find nearby EV charging stations")
    
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        // Simply opens the app - the app's default view shows nearby chargers
        return .result()
    }
}

/// Siri Intent: "Navigate to charger" - Opens Maps to nearest compatible charger
struct NavigateToChargerIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Navigate to Charger"
    static var description = IntentDescription("Navigate to the nearest EV charging station matching your preferred connector types")
    
    static var openAppWhenRun: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        // Get user's location
        let locationService = LocationService()
        
        guard locationService.isLocationAvailable,
              let userLocation = locationService.currentLocation else {
            return .result(value: "Location not available. Please enable location services.")
        }
        
        // Fetch nearby chargers
        let apiService = OpenChargeMapService(apiKey: APIConfig.openChargeMapAPIKey)
        
        do {
            let stations = try await apiService.fetchNearbyStations(
                location: userLocation.coordinate,
                radiusKm: 10,
                maxResults: 10
            )
            
            // Get preferred connectors from UserDefaults
            let preferredConnectors = loadPreferredConnectors()
            
            // Filter by preferred connectors if set
            let filteredStations: [ChargingStation]
            if preferredConnectors.isEmpty {
                filteredStations = stations
            } else {
                filteredStations = stations.filter { station in
                    station.connectorTypes.contains { preferredConnectors.contains($0) }
                }
            }
            
            guard let nearestStation = filteredStations.first else {
                return .result(value: "No compatible chargers found nearby.")
            }
            
            // Open Apple Maps for navigation
            NavigationService.navigateToStation(nearestStation)
            
            return .result(value: "Navigating to \(nearestStation.name)")
            
        } catch {
            return .result(value: "Unable to find chargers: \(error.localizedDescription)")
        }
    }
    
    private func loadPreferredConnectors() -> Set<ConnectorType> {
        guard let data = UserDefaults.standard.data(forKey: "preferredConnectors"),
              let connectors = try? JSONDecoder().decode(Set<ConnectorType>.self, from: data) else {
            return []
        }
        return connectors
    }
}
