//
//  StatusType.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-03.
//

import Foundation
import SwiftUI

/// Represents the operational status of a charging station or connector.
enum StatusType: String, Codable, CaseIterable, Identifiable {
    case available = "Available"
    case occupied = "Occupied"
    case unknown = "Unknown"
    case outOfService = "Out of Service"
    
    var id: String { rawValue }
    
    /// Human-readable display text
    var displayName: String { rawValue }
    
    /// Color for status indicator in UI
    var color: Color {
        switch self {
        case .available: return .green
        case .occupied: return .orange
        case .unknown: return .gray
        case .outOfService: return .red
        }
    }
    
    /// SF Symbol for status visualization
    var iconName: String {
        switch self {
        case .available: return "checkmark.circle.fill"
        case .occupied: return "clock.fill"
        case .unknown: return "questionmark.circle"
        case .outOfService: return "xmark.circle.fill"
        }
    }
}
