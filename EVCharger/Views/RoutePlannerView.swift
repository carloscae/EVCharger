//
//  RoutePlannerView.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import SwiftUI
import MapKit

/// Main route planner view for trip planning with charging stops
struct RoutePlannerView: View {
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage("userVehicle") private var userVehicleData: Data = Data()
    
    @State private var destinationSearch = ""
    @State private var currentChargePercent: Double = 80
    @State private var plannedRoute: PlannedRoute?
    @State private var isPlanning = false
    @State private var errorMessage: String?
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedDestination: MKMapItem?
    
    /// User's vehicle from settings
    private var userVehicle: UserVehicle {
        (try? JSONDecoder().decode(UserVehicle.self, from: userVehicleData)) ?? .empty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Vehicle Info
                Section {
                    HStack {
                        Image(systemName: "car.fill")
                            .foregroundStyle(.green)
                        Text(userVehicle.displayName)
                        Spacer()
                        Text("\(userVehicle.rangeKm) km range")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Vehicle")
                }
                
                // MARK: - Destination
                Section {
                    TextField("Search destination...", text: $destinationSearch)
                        .textContentType(.location)
                        .onSubmit {
                            Task { await searchDestinations() }
                        }
                    
                    if !searchResults.isEmpty && selectedDestination == nil {
                        ForEach(searchResults, id: \.self) { item in
                            Button {
                                selectedDestination = item
                                destinationSearch = item.name ?? "Unknown"
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name ?? "Unknown")
                                        .foregroundStyle(.primary)
                                    if let address = item.placemark.title {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    if let dest = selectedDestination {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundStyle(.red)
                            Text(dest.name ?? "Selected")
                            Spacer()
                            Button("Clear") {
                                selectedDestination = nil
                                searchResults = []
                            }
                            .font(.caption)
                        }
                    }
                } header: {
                    Text("Destination")
                }
                
                // MARK: - Current Charge
                Section {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Current Charge")
                            Spacer()
                            Text("\(Int(currentChargePercent))%")
                                .foregroundStyle(.green)
                                .fontWeight(.semibold)
                        }
                        
                        Slider(value: $currentChargePercent, in: 10...100, step: 5)
                            .tint(.green)
                    }
                } header: {
                    Text("Battery")
                }
                
                // MARK: - Plan Button
                Section {
                    Button {
                        Task { await planRoute() }
                    } label: {
                        HStack {
                            Spacer()
                            if isPlanning {
                                ProgressView()
                                    .padding(.trailing, 8)
                            }
                            Text(isPlanning ? "Planning..." : "Plan Route")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(selectedDestination == nil || isPlanning)
                }
                
                // MARK: - Error
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
                
                // MARK: - Route Result
                if let route = plannedRoute {
                    Section {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Total Distance")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(Int(route.totalDistanceKm)) km")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Total Time")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(formatTime(route.totalTimeMinutes))
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        if route.stops.isEmpty {
                            Label("No charging stops needed!", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Label("\(route.stops.count) charging stop(s)", systemImage: "bolt.fill")
                            Label("\(route.estimatedChargingTimeMinutes) min charging", systemImage: "clock")
                        }
                    } header: {
                        Text("Route Summary")
                    }
                    
                    // MARK: - Charging Stops
                    if !route.stops.isEmpty {
                        Section {
                            ForEach(Array(route.stops.enumerated()), id: \.offset) { index, stop in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Stop \(index + 1)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Text("\(Int(stop.distanceFromStartKm)) km from start")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Text(stop.station.name)
                                        .fontWeight(.medium)
                                    
                                    HStack(spacing: 16) {
                                        Label("\(stop.arrivalChargePercent)% → \(stop.departureChargePercent)%", systemImage: "battery.50percent")
                                        Label("~\(stop.chargingTimeMinutes) min", systemImage: "clock")
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    
                                    Button {
                                        NavigationService.navigateToStation(stop.station)
                                    } label: {
                                        Label("Navigate", systemImage: "arrow.triangle.turn.up.right.diamond")
                                            .font(.caption)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        } header: {
                            Text("Charging Stops")
                        }
                    }
                }
            }
            .navigationTitle("Route Planner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func searchDestinations() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = destinationSearch
        request.resultTypes = .address
        
        let search = MKLocalSearch(request: request)
        do {
            let response = try await search.start()
            searchResults = Array(response.mapItems.prefix(5))
        } catch {
            searchResults = []
        }
    }
    
    private func planRoute() async {
        guard let destination = selectedDestination,
              let coordinate = destination.placemark.location?.coordinate else {
            return
        }
        
        isPlanning = true
        errorMessage = nil
        
        // Get current location (simplified - would use LocationService in production)
        let start = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // SF default
        
        let planner = RoutePlannerService()
        
        do {
            plannedRoute = try await planner.planRoute(
                from: start,
                to: coordinate,
                destinationName: destination.name ?? "Destination",
                vehicle: userVehicle,
                currentChargePercent: Int(currentChargePercent)
            )
        } catch {
            errorMessage = "Failed to plan route: \(error.localizedDescription)"
        }
        
        isPlanning = false
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

// MARK: - Preview

#Preview {
    RoutePlannerView()
}
