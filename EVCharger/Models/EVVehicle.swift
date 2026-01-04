//
//  EVVehicle.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import Foundation

/// Represents an electric vehicle from the EV database
struct EVVehicle: Codable, Identifiable, Hashable {
    let id: String
    let brand: String
    let model: String
    let variant: String
    let year: Int
    let batteryCapacityKwh: Double
    let usableCapacityKwh: Double
    let rangeKm: Int
    let rangeMiles: Int
    let maxDcChargingKw: Int
    let connectorTypes: [String]
    
    /// Full display name for picker
    var displayName: String {
        "\(brand) \(model) \(variant)"
    }
    
    /// Short name
    var shortName: String {
        "\(brand) \(model)"
    }
    
    /// Connector types as ConnectorType enum
    var connectors: [ConnectorType] {
        connectorTypes.compactMap { string in
            switch string.uppercased() {
            case "CCS": return .ccs
            case "CHADEMO": return .chademo
            case "TESLA": return .tesla
            case "J1772": return .j1772
            case "TYPE2", "TYPE 2": return .type2
            default: return nil
            }
        }
    }
}

/// User's saved vehicle settings
struct UserVehicle: Codable {
    var vehicleId: String?           // ID from database (nil if manual entry)
    var customName: String?          // User's custom name for this vehicle
    var batteryCapacityKwh: Double   // May be edited from database default
    var usableCapacityKwh: Double    // May be edited
    var rangeKm: Int                 // Max range (may be adjusted for battery degradation)
    var maxDcChargingKw: Int         // Max DC charging speed
    var connectorTypes: [ConnectorType]
    
    /// Display name for UI
    var displayName: String {
        customName ?? "My Vehicle"
    }
    
    /// Default empty vehicle
    static var empty: UserVehicle {
        UserVehicle(
            vehicleId: nil,
            customName: nil,
            batteryCapacityKwh: 75,
            usableCapacityKwh: 70,
            rangeKm: 400,
            maxDcChargingKw: 150,
            connectorTypes: [.ccs]
        )
    }
    
    /// Create from database vehicle
    static func from(_ vehicle: EVVehicle) -> UserVehicle {
        UserVehicle(
            vehicleId: vehicle.id,
            customName: vehicle.displayName,
            batteryCapacityKwh: vehicle.batteryCapacityKwh,
            usableCapacityKwh: vehicle.usableCapacityKwh,
            rangeKm: vehicle.rangeKm,
            maxDcChargingKw: vehicle.maxDcChargingKw,
            connectorTypes: vehicle.connectors
        )
    }
}
