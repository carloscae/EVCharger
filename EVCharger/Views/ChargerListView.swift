//
//  ChargerListView.swift
//  EVCharger
//
//  Created by Map-Maven on 2026-01-04.
//

import SwiftUI
import CoreLocation
import SwiftData

/// List view of charging stations sorted by distance.
struct ChargerListView: View {
    
    @Bindable var viewModel: ChargersViewModel
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \FavoriteStation.favoritedAt, order: .reverse) 
    private var favoriteStations: [FavoriteStation]
    
    @Query(sort: \RecentStation.viewedAt, order: .reverse)
    private var recentStations: [RecentStation]
    
    /// Favorite stations matched with actual station data
    private var favorites: [ChargingStation] {
        let favoriteIds = Set(favoriteStations.map(\.stationId))
        return viewModel.stations.filter { favoriteIds.contains($0.id) }
    }
    
    /// Recent stations matched with actual station data (excluding favorites)
    private var recents: [ChargingStation] {
        let favoriteIds = Set(favoriteStations.map(\.stationId))
        let recentIds = recentStations.prefix(5).map(\.stationId)
        return recentIds.compactMap { id in
            viewModel.stations.first { $0.id == id && !favoriteIds.contains($0.id) }
        }
    }
    
    var body: some View {
        List {
            // Connector filter section
            Section {
                ConnectorFilterView(selectedConnector: $viewModel.selectedConnector)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
            }
            
            // MARK: - Favorites Section
            if !favorites.isEmpty && searchText.isEmpty {
                Section {
                    ForEach(favorites, id: \.id) { station in
                        NavigationLink {
                            ChargerDetailView(
                                station: station,
                                userLocation: viewModel.currentUserLocation
                            )
                        } label: {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.caption)
                                ChargerRowView(
                                    station: station,
                                    userLocation: viewModel.currentUserLocation
                                )
                            }
                        }
                    }
                } header: {
                    Label("Favorites", systemImage: "star.fill")
                }
            }
            
            // MARK: - Recents Section
            if !recents.isEmpty && searchText.isEmpty {
                Section {
                    ForEach(recents, id: \.id) { station in
                        NavigationLink {
                            ChargerDetailView(
                                station: station,
                                userLocation: viewModel.currentUserLocation
                            )
                        } label: {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                ChargerRowView(
                                    station: station,
                                    userLocation: viewModel.currentUserLocation
                                )
                            }
                        }
                    }
                } header: {
                    Label("Recent", systemImage: "clock")
                }
            }
            
            // MARK: - All Stations
            Section {
                if filteredStations.isEmpty {
                    ContentUnavailableView(
                        "No Chargers Found",
                        systemImage: "bolt.slash.fill",
                        description: Text("Try adjusting your filters or moving the map.")
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(filteredStations, id: \.id) { station in
                        NavigationLink {
                            ChargerDetailView(
                                station: station,
                                userLocation: viewModel.currentUserLocation
                            )
                        } label: {
                            ChargerRowView(
                                station: station,
                                userLocation: viewModel.currentUserLocation
                            )
                        }
                    }
                }
            } header: {
                HStack {
                    Text("\(filteredStations.count) Chargers")
                    Spacer()
                    
                    // Sort picker
                    Menu {
                        ForEach(SortOption.allCases) { option in
                            Button {
                                viewModel.selectedSortOption = option
                            } label: {
                                Label(option.rawValue, systemImage: option.icon)
                                if viewModel.selectedSortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    } label: {
                        Label(viewModel.selectedSortOption.rawValue, systemImage: "arrow.up.arrow.down")
                            .font(.caption)
                    }
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $searchText, prompt: "Search stations...")
        .navigationTitle("Nearby Chargers")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Map") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.refresh() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(viewModel.isLoading)
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    /// Filter stations by search text
    private var filteredStations: [ChargingStation] {
        if searchText.isEmpty {
            return viewModel.stations
        }
        return viewModel.stations.filter { station in
            station.name.localizedCaseInsensitiveContains(searchText) ||
            (station.operatorName?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            station.address.localizedCaseInsensitiveContains(searchText)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ChargerListView(viewModel: ChargersViewModel())
    }
}
