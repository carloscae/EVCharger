//
//  ActiveRouteView.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import SwiftUI
import MapKit

/// Overlay view shown during active route navigation
struct ActiveRouteView: View {
    
    let route: PlannedRoute
    @Binding var currentStopIndex: Int
    let onSkipStop: (Int) -> Void
    let onStopNow: () -> Void
    let onEndRoute: () -> Void
    
    @State private var showingSkipConfirmation = false
    @State private var showingStopNowSheet = false
    
    /// Current stop (if any)
    private var currentStop: ChargingStop? {
        guard currentStopIndex < route.stops.count else { return nil }
        return route.stops[currentStopIndex]
    }
    
    /// Remaining stops
    private var remainingStops: [ChargingStop] {
        guard currentStopIndex < route.stops.count else { return [] }
        return Array(route.stops[currentStopIndex...])
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Route to \(route.destinationName)")
                        .font(.headline)
                    Text("\(Int(route.totalDistanceKm)) km • \(formatTime(route.totalTimeMinutes))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    onEndRoute()
                } label: {
                    Text("End")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.red.opacity(0.15))
                        .foregroundStyle(.red)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Current/Next Stop
            if let stop = currentStop {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "bolt.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.green)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Next Stop")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(stop.station.name)
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(Int(stop.distanceFromStartKm)) km")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("~\(stop.chargingTimeMinutes) min charge")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        // Navigate to stop
                        Button {
                            NavigationService.navigateToStation(stop.station)
                        } label: {
                            Label("Navigate", systemImage: "arrow.triangle.turn.up.right.diamond")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        
                        // Skip this stop
                        Button {
                            showingSkipConfirmation = true
                        } label: {
                            Label("Skip", systemImage: "forward.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    // Stop Now button
                    Button {
                        showingStopNowSheet = true
                    } label: {
                        Label("Need to Stop Now", systemImage: "exclamationmark.triangle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                }
                .padding()
            } else {
                // No more stops - heading to destination
                VStack(spacing: 12) {
                    Image(systemName: "flag.checkered")
                        .font(.largeTitle)
                        .foregroundStyle(.green)
                    
                    Text("Heading to Destination")
                        .font(.headline)
                    
                    Text("No more charging stops needed!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            
            Spacer()
        }
        .alert("Skip This Stop?", isPresented: $showingSkipConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Skip", role: .destructive) {
                onSkipStop(currentStopIndex)
            }
        } message: {
            Text("Make sure you have enough charge to reach the next stop or destination.")
        }
        .sheet(isPresented: $showingStopNowSheet) {
            StopNowSheet(
                route: route,
                currentPosition: currentStop?.station.coordinate,
                onSelectStation: { station in
                    showingStopNowSheet = false
                    NavigationService.navigateToStation(station)
                }
            )
        }
    }
    
    private func formatTime(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        }
        let hours = minutes / 60
        let mins = minutes % 60
        return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
    }
}

/// Sheet for finding immediate charging when user needs to stop
struct StopNowSheet: View {
    
    let route: PlannedRoute
    let currentPosition: CLLocationCoordinate2D?
    let onSelectStation: (ChargingStation) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var nearbyStations: [ChargingStation] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Finding nearby chargers...")
                } else if nearbyStations.isEmpty {
                    ContentUnavailableView(
                        "No Chargers Nearby",
                        systemImage: "bolt.slash",
                        description: Text("Try expanding your search or continuing to the next planned stop.")
                    )
                } else {
                    List(nearbyStations) { station in
                        Button {
                            onSelectStation(station)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(station.name)
                                    .foregroundStyle(.primary)
                                
                                HStack {
                                    ForEach(station.connectorTypes, id: \.self) { connector in
                                        Text(connector.displayName)
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(.blue.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Stop Now")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                await loadNearbyStations()
            }
        }
    }
    
    private func loadNearbyStations() async {
        guard let position = currentPosition else {
            isLoading = false
            return
        }
        
        let service = OpenChargeMapService(apiKey: APIConfig.openChargeMapAPIKey)
        
        do {
            nearbyStations = try await service.fetchNearbyStations(
                location: position,
                radiusKm: 15,
                maxResults: 10
            )
        } catch {
            nearbyStations = []
        }
        
        isLoading = false
    }
}

// MARK: - Preview

#Preview {
    ActiveRouteView(
        route: PlannedRoute(
            destination: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437),
            destinationName: "Los Angeles",
            totalDistanceKm: 600,
            stops: [],
            estimatedTripTimeMinutes: 360,
            estimatedChargingTimeMinutes: 45
        ),
        currentStopIndex: .constant(0),
        onSkipStop: { _ in },
        onStopNow: {},
        onEndRoute: {}
    )
}
