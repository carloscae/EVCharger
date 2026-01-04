//
//  ChargersViewModel.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import Foundation
import CoreLocation
import SwiftData
import Combine

/// Main ViewModel for charger discovery.
/// Integrates location and API services with offline-first caching.
@Observable
@MainActor
final class ChargersViewModel {
    
    // MARK: - Published State
    
    /// All fetched stations (filtered by selectedConnector if set)
    private(set) var stations: [ChargingStation] = []
    
    /// Currently selected connector type filter (nil = show all)
    var selectedConnector: ConnectorType? = nil {
        didSet { applyFilter() }
    }
    
    /// Loading indicator
    private(set) var isLoading: Bool = false
    
    /// Error message for display
    private(set) var error: String?
    
    /// Whether we're in offline mode
    private(set) var isOffline: Bool = false
    
    /// Selected station for detail view
    var selectedStation: ChargingStation?
    
    /// Current search radius in km
    var searchRadiusKm: Double = 10
    
    /// Current user location for distance calculations (exposed from LocationService)
    var currentUserLocation: CLLocation? {
        locationService.currentLocation
    }
    
    // MARK: - Private State
    
    /// Unfiltered stations from last fetch
    private var allStations: [ChargingStation] = []
    
    /// Services
    private let apiService: OpenChargeMapService
    private let locationService: LocationService
    private let networkMonitor: NetworkMonitor
    
    /// SwiftData context for caching
    private var modelContext: ModelContext?
    private var cacheService: CacheService?
    
    /// Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        apiService: OpenChargeMapService = OpenChargeMapService(),
        locationService: LocationService = LocationService(),
        networkMonitor: NetworkMonitor = NetworkMonitor()
    ) {
        self.apiService = apiService
        self.locationService = locationService
        self.networkMonitor = networkMonitor
        
        setupLocationSubscription()
        setupNetworkSubscription()
    }
    
    /// Configure SwiftData context for caching
    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.cacheService = CacheService(modelContext: modelContext)
    }
    
    // MARK: - Public Methods
    
    /// Fetch chargers near the user's current location.
    /// Uses offline-first approach: loads cache, then refreshes from network.
    func fetchNearbyChargers() async {
        isLoading = true
        error = nil
        
        do {
            // 1. Get user location
            guard locationService.isLocationAvailable else {
                locationService.requestPermission()
                error = "Location access required to find nearby chargers."
                isLoading = false
                return
            }
            
            let location = try await locationService.getCurrentLocation()
            
            // 2. Load from cache first (offline-first)
            await loadCachedStations(near: location)
            
            // 3. Check if offline - use cache only
            if networkMonitor.isOffline {
                isOffline = true
                if allStations.isEmpty {
                    error = "You're offline. No cached chargers available."
                }
                isLoading = false
                return
            }
            
            isOffline = false
            
            // 4. Fetch fresh data from API
            let freshStations = try await apiService.fetchNearbyStations(
                location: location.coordinate,
                radiusKm: searchRadiusKm,
                maxResults: 100,
                connectorTypes: selectedConnector.map { [$0] }
            )
            
            // 5. Update state and cache
            allStations = freshStations
            applyFilter()
            
            // Cache the results
            await cacheStations(freshStations)
            
            error = nil
            
        } catch let locationError as LocationError {
            error = locationError.errorDescription
        } catch let apiError as OpenChargeMapError {
            // Network error - fall back to cache
            if allStations.isEmpty {
                error = apiError.errorDescription
            } else {
                // We have cached data, show it with offline indicator
                isOffline = true
            }
        } catch {
            if allStations.isEmpty {
                self.error = "Failed to fetch chargers: \(error.localizedDescription)"
            } else {
                isOffline = true
            }
        }
        
        isLoading = false
    }
    
    /// Fetch chargers for a specific map region (for region-based updates).
    func fetchChargers(at coordinate: CLLocationCoordinate2D, radiusKm: Double? = nil) async {
        isLoading = true
        error = nil
        
        do {
            let freshStations = try await apiService.fetchNearbyStations(
                location: coordinate,
                radiusKm: radiusKm ?? searchRadiusKm,
                maxResults: 100,
                connectorTypes: selectedConnector.map { [$0] }
            )
            
            allStations = freshStations
            applyFilter()
            
            await cacheStations(freshStations)
            
        } catch let apiError as OpenChargeMapError {
            error = apiError.errorDescription
        } catch {
            self.error = "Failed to fetch chargers: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Clear the current filter and show all stations.
    func clearFilter() {
        selectedConnector = nil
    }
    
    /// Refresh data (pull-to-refresh action).
    func refresh() async {
        await fetchNearbyChargers()
    }
    
    // MARK: - Private Methods
    
    private func setupLocationSubscription() {
        // Auto-refresh when location updates significantly
        locationService.locationPublisher
            .debounce(for: .seconds(5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.fetchNearbyChargers()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupNetworkSubscription() {
        // Auto-refresh when coming back online
        networkMonitor.connectionPublisher
            .removeDuplicates()
            .filter { $0 } // Only when connected
            .dropFirst() // Skip initial value
            .sink { [weak self] _ in
                Task { [weak self] in
                    await self?.fetchNearbyChargers()
                }
            }
            .store(in: &cancellables)
        
        // Update offline state
        networkMonitor.connectionPublisher
            .sink { [weak self] isConnected in
                self?.isOffline = !isConnected
            }
            .store(in: &cancellables)
    }
    
    private func applyFilter() {
        if let connector = selectedConnector {
            stations = allStations.filter { $0.connectorTypes.contains(connector) }
        } else {
            stations = allStations
        }
        
        // Sort by distance if location available
        if let userLocation = locationService.currentLocation {
            stations.sort { station1, station2 in
                let distance1 = station1.distance(from: userLocation)
                let distance2 = station2.distance(from: userLocation)
                return distance1 < distance2
            }
        }
    }
    
    // MARK: - Caching (SwiftData)
    
    private func loadCachedStations(near location: CLLocation) async {
        guard let context = modelContext else { return }
        
        // Fetch cached stations within a reasonable distance
        let descriptor = FetchDescriptor<ChargingStation>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            let cached = try context.fetch(descriptor)
            
            // Filter to stations within search radius
            let nearbyCache = cached.filter { station in
                station.distance(from: location) <= searchRadiusKm * 1000 // convert to meters
            }
            
            if !nearbyCache.isEmpty && allStations.isEmpty {
                allStations = nearbyCache
                applyFilter()
            }
        } catch {
            // Cache miss is fine, will fetch from network
            print("Cache load failed: \(error)")
        }
    }
    
    private func cacheStations(_ stations: [ChargingStation]) async {
        guard let context = modelContext else { return }
        
        // Insert or update stations in cache
        for station in stations {
            context.insert(station)
        }
        
        do {
            try context.save()
        } catch {
            print("Cache save failed: \(error)")
        }
    }
}

