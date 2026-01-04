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
/// Sorting options for the charger list
enum SortOption: String, CaseIterable, Identifiable {
    case distance = "Distance"
    case speed = "Speed"
    case availability = "Availability"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .distance: return "location.fill"
        case .speed: return "bolt.fill"
        case .availability: return "checkmark.circle.fill"
        }
    }
}

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
    
    /// Currently selected sort option
    var selectedSortOption: SortOption = .distance {
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
        apiService: OpenChargeMapService = OpenChargeMapService(apiKey: APIConfig.openChargeMapAPIKey),
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
                maxResults: 200,
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
                maxResults: 200,
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
        
        // Apply selected sort option
        switch selectedSortOption {
        case .distance:
            if let userLocation = locationService.currentLocation {
                stations.sort { s1, s2 in
                    s1.distance(from: userLocation) < s2.distance(from: userLocation)
                }
            }
            
        case .speed:
            // Sort by max power (kW) - higher first
            // Use connector types as proxy (CCS/Tesla typically faster)
            stations.sort { s1, s2 in
                let power1 = maxPowerRating(for: s1)
                let power2 = maxPowerRating(for: s2)
                return power1 > power2
            }
            
        case .availability:
            // Sort by availability status
            stations.sort { s1, s2 in
                availabilityRank(s1.statusType) < availabilityRank(s2.statusType)
            }
        }
    }
    
    /// Estimate power rating based on connector types
    private func maxPowerRating(for station: ChargingStation) -> Int {
        var maxPower = 0
        for connector in station.connectorTypes {
            switch connector {
            case .ccs: maxPower = max(maxPower, 350)
            case .tesla: maxPower = max(maxPower, 250)
            case .chademo: maxPower = max(maxPower, 100)
            case .type2: maxPower = max(maxPower, 22)
            case .j1772: maxPower = max(maxPower, 19)
            }
        }
        return maxPower
    }
    
    /// Lower rank = better availability
    private func availabilityRank(_ status: StatusType?) -> Int {
        switch status {
        case .available: return 0
        case .unknown, .none: return 1
        case .occupied: return 2
        case .outOfService: return 3
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

