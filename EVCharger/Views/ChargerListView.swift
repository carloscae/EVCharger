//
//  ChargerListView.swift
//  EVCharger
//
//  Created by Map-Maven on 2026-01-04.
//

import SwiftUI
import CoreLocation

/// List view of charging stations sorted by distance.
struct ChargerListView: View {
    
    @Bindable var viewModel: ChargersViewModel
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            // Connector filter section
            Section {
                ConnectorFilterView(selectedConnector: $viewModel.selectedConnector)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
            }
            
            // Stations list
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
                            ChargerDetailView(station: station)
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
