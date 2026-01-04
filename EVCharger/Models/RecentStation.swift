//
//  RecentStation.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import Foundation
import SwiftData

/// Tracks recently viewed charging stations
/// Stores station ID and timestamp for display ordering
@Model
final class RecentStation {
    /// The unique ID of the recently viewed charging station
    @Attribute(.unique) var stationId: UUID
    
    /// When the station detail was last viewed
    var viewedAt: Date
    
    init(stationId: UUID, viewedAt: Date = Date()) {
        self.stationId = stationId
        self.viewedAt = viewedAt
    }
}
