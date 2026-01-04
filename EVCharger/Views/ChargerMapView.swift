//
//  ChargerMapView.swift
//  EVCharger
//
//  Created by Map-Maven on 2026-01-04.
//

import SwiftUI
import MapKit

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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Compact header (always visible)
                VStack(spacing: 30) {
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
                
                Divider()
                
                // List (visible when expanded)
                // List (visible when expanded)
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
        .sheet(item: $selectedStation) { station in
            ChargerDetailView(
                station: station,
                userLocation: viewModel.currentUserLocation
            )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
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
