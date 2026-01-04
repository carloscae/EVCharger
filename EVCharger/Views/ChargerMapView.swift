//
//  ChargerMapView.swift
//  EVCharger
//
//  Created by Map-Maven on 2026-01-04.
//

import SwiftUI
import MapKit
import SwiftData

/// Main map view displaying nearby charging stations.
/// Apple Maps style with draggable bottom sheet and floating controls.
struct ChargerMapView: View {
    
    @Bindable var viewModel: ChargersViewModel
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var showingSettings = false
    @State private var selectedStation: ChargingStation?
    @State private var sheetDetent: PresentationDetent = .height(140)
    
    var body: some View {
        Map(position: $cameraPosition, selection: $selectedStation) {
            UserAnnotation()
            
            ForEach(viewModel.stations, id: \.id) { station in
                Annotation(
                    station.name,
                    coordinate: station.coordinate,
                    anchor: .bottom
                ) {
                    ChargerAnnotation(station: station)
                }
                .tag(station)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            Task {
                await viewModel.fetchChargers(
                    at: context.region.center,
                    radiusKm: regionRadiusKm(context.region)
                )
            }
        }
        // Bottom sheet (Apple Maps style)
        .sheet(isPresented: .constant(true)) {
            ChargerSheetContent(
                viewModel: viewModel,
                selectedStation: $selectedStation,
                showingSettings: $showingSettings
            )
            .presentationDetents([.height(120), .medium, .large], selection: $sheetDetent)
            .presentationDragIndicator(.visible)
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            .interactiveDismissDisabled()
        }
        .task {
            await viewModel.fetchNearbyChargers()
        }
    }
    
    private func regionRadiusKm(_ region: MKCoordinateRegion) -> Double {
        let latDelta = region.span.latitudeDelta
        let radiusKm = (latDelta * 111) / 2
        return max(1, min(radiusKm, 50))
    }
}

// MARK: - Sheet Content

struct ChargerSheetContent: View {
    @Bindable var viewModel: ChargersViewModel
    @Binding var selectedStation: ChargingStation?
    @Binding var showingSettings: Bool
    @State private var showingRoutePlanner = false
    @State private var showingFavoritesList = false
    @State private var showingRecentsList = false
    
    @Query(sort: \FavoriteStation.favoritedAt, order: .reverse) 
    private var favoriteStations: [FavoriteStation]
    
    @Query(sort: \RecentStation.viewedAt, order: .reverse)
    private var recentStations: [RecentStation]
    
    @Query
    private var cachedStations: [ChargingStation]
    
    /// All available stations - prefer live data, fallback to cache
    private var allStations: [ChargingStation] {
        viewModel.stations.isEmpty ? cachedStations : viewModel.stations
    }
    
    /// Favorite stations matched with actual station data
    private var favorites: [ChargingStation] {
        let favoriteIds = Set(favoriteStations.map(\.stationId))
        return allStations.filter { favoriteIds.contains($0.id) }
    }
    
    /// Recent stations matched with actual station data (excluding favorites)
    private var recents: [ChargingStation] {
        let favoriteIds = Set(favoriteStations.map(\.stationId))
        let recentIds = recentStations.prefix(5).map(\.stationId)
        return recentIds.compactMap { id in
            allStations.first { $0.id == id && !favoriteIds.contains($0.id) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Compact header (always visible)
                VStack(spacing: 20) {
                    HStack {
                        // Dynamic title
                        Group {
                            if viewModel.isLoading {
                                Text("Finding chargers...")
                            } else if viewModel.error != nil {
                                Text("Unable to load")
                                    .foregroundStyle(.orange)
                            } else {
                                // Show 200+ when at API limit
                                let count = viewModel.stations.count
                                let label = count >= 200 ? "200+ Chargers" : "\(count) Chargers"
                                Text(label)
                            }
                        }
                        .font(.title2.bold())
                        .contentTransition(.numericText())
                        
                        Spacer()
                        
                        // Route Planner button
                        Button { showingRoutePlanner = true } label: {
                            Image(systemName: "map.fill")
                                .font(.title2)
                                .foregroundStyle(.blue)
                        }
                        
                        Button { showingSettings = true } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Filter chips
                    ConnectorFilterView(selectedConnector: $viewModel.selectedConnector)
                }
                .padding(.horizontal)
                .padding(.top, 24)
                .padding(.bottom, 16)
                
                // Favorites & Recents (eager loaded - visible immediately)
                if !favorites.isEmpty {
                    StationChipsSection(
                        title: "Favorites",
                        icon: "star.fill",
                        stations: favorites,
                        userLocation: viewModel.currentUserLocation,
                        onSelect: { station in
                            selectedStation = station
                        },
                        onSeeAll: {
                            showingFavoritesList = true
                        }
                    )
                    .padding(.bottom, 18)
                }
                
                if !recents.isEmpty {
                    StationChipsSection(
                        title: "Recent",
                        icon: "clock",
                        stations: recents,
                        userLocation: viewModel.currentUserLocation,
                        onSelect: { station in
                            selectedStation = station
                        },
                        onSeeAll: {
                            showingRecentsList = true
                        }
                    )
                    .padding(.bottom, 18)
                }
                
                // Main station list (lazy loaded - efficient for 200+ stations)
                List {
                    ForEach(viewModel.stations, id: \.id) { station in
                        Button {
                            selectedStation = station
                        } label: {
                            ChargerRowView(
                                station: station,
                                userLocation: viewModel.currentUserLocation
                            )
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .foregroundStyle(.primary)
                    }
                }
                .listStyle(.plain)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingRoutePlanner) {
            RoutePlannerView()
        }
        .sheet(item: $selectedStation) { station in
            ChargerDetailView(
                station: station,
                userLocation: viewModel.currentUserLocation
            )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingFavoritesList) {
            StationListView(
                title: "Favorites",
                stations: favorites,
                userLocation: viewModel.currentUserLocation
            ) { station in
                showingFavoritesList = false
                selectedStation = station
            }
        }
        .sheet(isPresented: $showingRecentsList) {
            StationListView(
                title: "Recent",
                stations: recents,
                userLocation: viewModel.currentUserLocation
            ) { station in
                showingRecentsList = false
                selectedStation = station
            }
        }
    }
}

// MARK: - Charger Annotation

struct ChargerAnnotation: View {
    let station: ChargingStation
    
    var body: some View {
        ZStack {
            Circle()
                .fill(statusColor.gradient)
                .frame(width: 36, height: 36)
                .shadow(color: statusColor.opacity(0.5), radius: 4, y: 2)
            
            Image(systemName: "bolt.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
    
    private var statusColor: Color {
        switch station.statusType {
        case .available: return .green
        case .occupied: return .orange
        case .outOfService: return .red
        case .unknown, .none: return .blue
        }
    }
}

#Preview {
    ChargerMapView(viewModel: ChargersViewModel())
}
