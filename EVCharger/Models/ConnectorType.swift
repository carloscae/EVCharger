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
    
    /// Custom icon asset name for visual representation
    var iconName: String {
        switch self {
        case .ccs: return "connector.ccs"
        case .chademo: return "connector.chademo"
        case .tesla: return "connector.tesla"
        case .j1772: return "connector.j1772"
        case .type2: return "connector.type2"
        }
    }
}
