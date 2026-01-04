//
//  FavoriteStation.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import Foundation
import SwiftData

/// Tracks a user's favorite charging stations
/// Stores only the station ID to avoid data duplication
@Model
final class FavoriteStation {
    /// The unique ID of the favorited charging station
    @Attribute(.unique) var stationId: UUID
    
    /// When the station was favorited
    var favoritedAt: Date
    
    init(stationId: UUID, favoritedAt: Date = Date()) {
        self.stationId = stationId
        self.favoritedAt = favoritedAt
    }
}
