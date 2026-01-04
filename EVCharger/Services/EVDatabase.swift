//
//  EVDatabase.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import Foundation

/// Service for loading and querying the bundled EV vehicle database
final class EVDatabase {
    
    /// Shared instance
    static let shared = EVDatabase()
    
    /// All vehicles loaded from JSON
    private(set) var vehicles: [EVVehicle] = []
    
    /// Vehicles grouped by brand
    var vehiclesByBrand: [String: [EVVehicle]] {
        Dictionary(grouping: vehicles, by: \.brand)
    }
    
    /// All unique brands
    var brands: [String] {
        Array(Set(vehicles.map(\.brand))).sorted()
    }
    
    private init() {
        loadVehicles()
    }
    
    /// Load vehicles from bundled JSON
    private func loadVehicles() {
        guard let url = Bundle.main.url(forResource: "ev-data", withExtension: "json") else {
            print("EVDatabase: ev-data.json not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            vehicles = try JSONDecoder().decode([EVVehicle].self, from: data)
            print("EVDatabase: Loaded \(vehicles.count) vehicles")
        } catch {
            print("EVDatabase: Failed to load vehicles: \(error)")
        }
    }
    
    /// Search vehicles by name (brand, model, or variant)
    func search(_ query: String) -> [EVVehicle] {
        guard !query.isEmpty else { return vehicles }
        
        let lowercased = query.lowercased()
        return vehicles.filter { vehicle in
            vehicle.brand.lowercased().contains(lowercased) ||
            vehicle.model.lowercased().contains(lowercased) ||
            vehicle.variant.lowercased().contains(lowercased)
        }
    }
    
    /// Find vehicle by ID
    func vehicle(id: String) -> EVVehicle? {
        vehicles.first { $0.id == id }
    }
    
    /// Vehicles matching a specific connector type
    func vehicles(with connector: ConnectorType) -> [EVVehicle] {
        vehicles.filter { $0.connectors.contains(connector) }
    }
}
