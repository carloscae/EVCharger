//
//  ConnectorType.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-03.
//

import Foundation

/// Represents the types of EV charging connectors supported by the app.
/// These are the most common connector standards used worldwide.
enum ConnectorType: String, Codable, CaseIterable, Identifiable {
    case ccs = "CCS"
    case chademo = "CHAdeMO"
    case tesla = "Tesla"
    case j1772 = "J1772"
    case type2 = "Type 2"
    
    var id: String { rawValue }
    
    /// Short display name for the connector type (used in lists, map, CarPlay)
    var displayName: String { rawValue }
    
    /// Hint text to help users understand which connector they need (used in Settings)
    var hint: String {
        switch self {
        case .ccs: return "Most newer EVs"
        case .chademo: return "Nissan Leaf, older EVs"
        case .tesla: return "Tesla vehicles"
        case .j1772: return "Level 2 / All EVs"
        case .type2: return "European standard"
        }
    }
    
    /// Custom icon asset name for Image() (connector-specific icons in asset catalog)
    var iconName: String {
        switch self {
        case .ccs: return "connector.ccs"
        case .chademo: return "connector.chademo"
        case .tesla: return "connector.tesla"
        case .j1772: return "connector.j1772"
        case .type2: return "connector.type2"
        }
    }
    
    /// SF Symbol name for Label/systemImage contexts (fallback for Picker, etc.)
    var sfSymbol: String {
        switch self {
        case .ccs: return "ev.plug.dc.ccs1"
        case .chademo: return "ev.plug.dc.chademo"
        case .tesla: return "bolt.fill"
        case .j1772: return "ev.plug.ac.type.1"
        case .type2: return "ev.plug.ac.type.2"
        }
    }
}

// MARK: - Connection Info (Detailed connector data from API)

/// Represents a specific charging connection point with power and status details.
/// Maps to OpenChargeMap's "Connections" array.
struct ConnectionInfo: Codable, Identifiable, Hashable {
    var id: Int
    var connectorType: ConnectorType
    var powerKW: Double?
    var quantity: Int
    var levelID: Int?  // 1=Level 1, 2=Level 2, 3=Level 3 DC
    var statusID: Int?
    
    /// Formatted power string (e.g., "50 kW" or "22 kW")
    var formattedPower: String? {
        guard let power = powerKW, power > 0 else { return nil }
        if power == floor(power) {
            return "\(Int(power)) kW"
        }
        return String(format: "%.1f kW", power)
    }
    
    /// AC or DC label based on level
    var currentType: String? {
        guard let level = levelID else { return nil }
        switch level {
        case 1, 2: return "AC"
        case 3: return "DC"
        default: return nil
        }
    }
    
    /// Operational status text
    var statusText: String {
        guard let status = statusID else { return "Unknown" }
        switch status {
        case 50: return "Operational"
        case 30, 75: return "Partly Operational"
        case 100, 150, 200: return "Out of Service"
        default: return "Unknown"
        }
    }
    
    /// Whether connector is operational
    var isOperational: Bool {
        statusID == 50
    }
}
