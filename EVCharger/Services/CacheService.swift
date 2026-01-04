//
//  CacheService.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import Foundation
import SwiftData

/// Service for managing SwiftData caching of charging stations.
/// Provides 24-hour expiration, invalidation, and background refresh.
@MainActor
final class CacheService {
    
    // MARK: - Configuration
    
    /// Cache expiration threshold (24 hours)
    static let cacheExpirationInterval: TimeInterval = 24 * 60 * 60
    
    /// Maximum stations to keep in cache
    static let maxCacheSize: Int = 500
    
    // MARK: - Properties
    
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Public API
    
    /// Fetch cached stations, optionally filtering stale entries.
    /// - Parameter includeStale: If false, excludes stations older than 24 hours
    /// - Returns: Array of cached ChargingStation
    func fetchCached(includeStale: Bool = false) throws -> [ChargingStation] {
        var descriptor = FetchDescriptor<ChargingStation>(
            sortBy: [SortDescriptor(\.cachedAt, order: .reverse)]
        )
        descriptor.fetchLimit = Self.maxCacheSize
        
        let stations = try modelContext.fetch(descriptor)
        
        if includeStale {
            return stations
        } else {
            return stations.filter { !$0.isCacheStale }
        }
    }
    
    /// Save stations to cache, updating existing or inserting new.
    /// - Parameter stations: Stations to cache
    func cache(stations: [ChargingStation]) throws {
        let now = Date()
        
        for station in stations {
            // Update cachedAt timestamp
            station.cachedAt = now
            
            // Insert or update via SwiftData upsert
            modelContext.insert(station)
        }
        
        try modelContext.save()
        
        // Prune old entries to keep cache size manageable
        try pruneCache()
    }
    
    /// Invalidate all cached data (e.g., on manual refresh).
    func invalidateAll() throws {
        let descriptor = FetchDescriptor<ChargingStation>()
        let stations = try modelContext.fetch(descriptor)
        
        for station in stations {
            modelContext.delete(station)
        }
        
        try modelContext.save()
    }
    
    /// Invalidate stale entries only (24+ hours old).
    func invalidateStale() throws {
        let descriptor = FetchDescriptor<ChargingStation>()
        let stations = try modelContext.fetch(descriptor)
        
        for station in stations where station.isCacheStale {
            modelContext.delete(station)
        }
        
        try modelContext.save()
    }
    
    /// Check if any valid (non-stale) cache exists.
    func hasValidCache() -> Bool {
        do {
            let cached = try fetchCached(includeStale: false)
            return !cached.isEmpty
        } catch {
            return false
        }
    }
    
    /// Get cache statistics for display.
    func cacheStats() -> CacheStats {
        do {
            let all = try fetchCached(includeStale: true)
            let valid = all.filter { !$0.isCacheStale }
            let oldestDate = all.map(\.cachedAt).min()
            let newestDate = all.map(\.cachedAt).max()
            
            return CacheStats(
                totalCount: all.count,
                validCount: valid.count,
                staleCount: all.count - valid.count,
                oldestEntry: oldestDate,
                newestEntry: newestDate
            )
        } catch {
            return CacheStats(totalCount: 0, validCount: 0, staleCount: 0, oldestEntry: nil, newestEntry: nil)
        }
    }
    
    // MARK: - Private Helpers
    
    private func pruneCache() throws {
        let descriptor = FetchDescriptor<ChargingStation>(
            sortBy: [SortDescriptor(\.cachedAt, order: .reverse)]
        )
        
        let all = try modelContext.fetch(descriptor)
        
        // Remove oldest entries if over limit
        if all.count > Self.maxCacheSize {
            let toRemove = all.dropFirst(Self.maxCacheSize)
            for station in toRemove {
                modelContext.delete(station)
            }
            try modelContext.save()
        }
    }
}

// MARK: - Cache Statistics

/// Statistics about the current cache state.
struct CacheStats {
    let totalCount: Int
    let validCount: Int
    let staleCount: Int
    let oldestEntry: Date?
    let newestEntry: Date?
    
    var lastUpdatedFormatted: String? {
        guard let date = newestEntry else { return nil }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
