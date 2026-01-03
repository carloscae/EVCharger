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
    
    /// Human-readable display name for the connector type
    var displayName: String {
        switch self {
        case .ccs: return "CCS (Combined Charging System)"
        case .chademo: return "CHAdeMO"
        case .tesla: return "Tesla Supercharger"
        case .j1772: return "J1772 (Level 2)"
        case .type2: return "Type 2 (Mennekes)"
        }
    }
    
    /// Short label for compact UI (CarPlay lists)
    var shortName: String { rawValue }
    
    /// SF Symbol name for visual representation
    var iconName: String {
        switch self {
        case .tesla: return "bolt.fill"
        default: return "ev.plug.dc.ccs1"
        }
    }
}
