//
//  UserPreferences.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-03.
//

import Foundation
import SwiftData

/// Stores user preferences for charger filtering and app behavior.
/// Persisted via SwiftData for offline access.
@Model
final class UserPreferences {
    /// Unique identifier (singleton pattern - only one instance)
    @Attribute(.unique) var id: UUID
    
    /// Preferred connector types for filtering (empty = show all)
    var preferredConnectors: [ConnectorType]
    
    /// Default search radius in meters
    var searchRadiusMeters: Double
    
    /// Whether to use metric units (km) vs imperial (miles)
    var useMetricUnits: Bool
    
    /// When preferences were last modified
    var lastModified: Date
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        preferredConnectors: [ConnectorType] = [],
        searchRadiusMeters: Double = 16093.4, // Default 10 miles
        useMetricUnits: Bool = false,
        lastModified: Date = Date()
    ) {
        self.id = id
        self.preferredConnectors = preferredConnectors
        self.searchRadiusMeters = searchRadiusMeters
        self.useMetricUnits = useMetricUnits
        self.lastModified = lastModified
    }
}

// MARK: - Computed Properties

extension UserPreferences {
    /// Search radius in miles
    var searchRadiusMiles: Double {
        get { searchRadiusMeters / 1609.34 }
        set { searchRadiusMeters = newValue * 1609.34 }
    }
    
    /// Search radius in kilometers
    var searchRadiusKm: Double {
        get { searchRadiusMeters / 1000 }
        set { searchRadiusMeters = newValue * 1000 }
    }
    
    /// Formatted search radius string based on unit preference
    var formattedSearchRadius: String {
        if useMetricUnits {
            return String(format: "%.0f km", searchRadiusKm)
        } else {
            return String(format: "%.0f mi", searchRadiusMiles)
        }
    }
    
    /// Whether any connector filter is active
    var hasConnectorFilter: Bool {
        !preferredConnectors.isEmpty
    }
    
    /// Human-readable summary of active filters
    var filterSummary: String {
        if preferredConnectors.isEmpty {
            return "All connectors"
        } else {
            return preferredConnectors.map(\.displayName).joined(separator: ", ")
        }
    }
}

// MARK: - Default Instance

extension UserPreferences {
    /// Default preferences for new users
    static var defaults: UserPreferences {
        UserPreferences()
    }
}
