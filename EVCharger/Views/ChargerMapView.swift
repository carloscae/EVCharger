//
//  ChargerMapView.swift
//  EVCharger
//
//  Created by Map-Maven on 2026-01-04.
//

import SwiftUI
import MapKit

/// Main map view displaying nearby charging stations.
/// Centers on user location with custom annotations for chargers.
struct ChargerMapView: View {
    
    @Bindable var viewModel: ChargersViewModel
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var showingList = false
    @State private var selectedStation: ChargingStation?
    
    var body: some View {
        ZStack {
            // Map with charger annotations
            Map(position: $cameraPosition, selection: $selectedStation) {
                // User location
                UserAnnotation()
                
                // Charger annotations
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
                MapScaleView()
            }
            .ignoresSafeArea(edges: .top)
            .onMapCameraChange(frequency: .onEnd) { context in
                // Fetch chargers when map region changes
                Task {
                    await viewModel.fetchChargers(
                        at: context.region.center,
                        radiusKm: regionRadiusKm(context.region)
                    )
                }
            }
            
            // Overlay controls
            VStack {
                Spacer()
                
                // Bottom card with toggle and filter
                VStack(spacing: 12) {
                    // Header row
                    HStack {
                        Image(systemName: "bolt.car.fill")
                            .font(.title2)
                            .foregroundStyle(.green)
                        
                        Text("Nearby Chargers")
                            .font(.headline)
                        
                        Spacer()
                        
                        // List toggle
                        Button {
                            showingList = true
                        } label: {
                            Image(systemName: "list.bullet")
                                .font(.title3)
                                .padding(8)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                    }
                    
                    // Connector filter chips
                    ConnectorFilterView(selectedConnector: $viewModel.selectedConnector)
                    
                    // Loading/Error state
                    if viewModel.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Finding chargers...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else if let error = viewModel.error {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("\(viewModel.stations.count) chargers nearby")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding()
            }
        }
        .sheet(item: $selectedStation) { station in
            ChargerDetailView(station: station)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingList) {
            NavigationStack {
                ChargerListView(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.fetchNearbyChargers()
        }
    }
    
    /// Calculate approximate radius in km from map region span
    private func regionRadiusKm(_ region: MKCoordinateRegion) -> Double {
        let latDelta = region.span.latitudeDelta
        // Approximate: 1 degree latitude ≈ 111 km
        let radiusKm = (latDelta * 111) / 2
        return max(1, min(radiusKm, 50)) // Clamp between 1-50 km
    }
}

// MARK: - Charger Annotation

/// Custom annotation view for charging station pins
struct ChargerAnnotation: View {
    let station: ChargingStation
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(statusColor.gradient)
                .frame(width: 36, height: 36)
                .shadow(color: statusColor.opacity(0.5), radius: 4, y: 2)
            
            // Icon
            Image(systemName: "bolt.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
    
    private var statusColor: Color {
        switch station.statusType {
        case .available:
            return .green
        case .occupied:
            return .orange
        case .outOfService:
            return .red
        case .unknown, .none:
            return .blue
        }
    }
}

// MARK: - Preview

#Preview {
    ChargerMapView(viewModel: ChargersViewModel())
}
