//
//  ChargerDetailView.swift
//  EVCharger
//
//  Created by Map-Maven on 2026-01-04.
//

import SwiftUI
import SwiftData
import MapKit

/// Detail view for a charging station showing full info and navigation.
struct ChargerDetailView: View {
    
    let station: ChargingStation
    let userLocation: CLLocation?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var estimatedTravelTime: TimeInterval?
    @State private var isCalculatingETA = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 20) {
                    // Station info
                    VStack(alignment: .leading, spacing: 6) {
                     HStack {
                         Text(station.name)
                             .font(.title2.bold())
                         
                         Spacer()
                         
                         // Status badge under address
                         StatusBadge(status: station.statusType)
                             .padding(.top, 4)
                        }
                        
                      
                        Text(station.address)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        if let operatorName = station.operatorName {
                            Label(operatorName, systemImage: "building.2")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        

                        

                    }
                    
                    // Full-width Drive button (Apple Maps style)
                    DriveButton(
                        travelTime: estimatedTravelTime,
                        isLoading: isCalculatingETA
                    ) {
                        NavigationService.navigateToStation(station)
                    }
                    
                    Divider()
                    
                    // Connectors section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Connectors")
                            .font(.headline)
                        
                        // Use detailed connection cards if available
                        if !station.connections.isEmpty {
                            ForEach(station.connections) { connection in
                                ConnectionCardView(connection: connection)
                            }
                        } else {
                            // Fallback to basic connector type cards
                            ForEach(station.connectorTypes, id: \.self) { connector in
                                ConnectorCardView(connector: connector)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Details section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Details")
                            .font(.headline)
                        
                        DetailRow(label: "Charging Points", value: "\(station.numberOfPoints)")
                        
                        if let cost = station.usageCost, !cost.isEmpty {
                            DetailRow(label: "Usage Cost", value: cost)
                        }
                        
                        DetailRow(
                            label: "Last Updated",
                            value: station.lastUpdated.formatted(date: .abbreviated, time: .shortened)
                        )
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Station Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .task {
            await calculateETA()
        }
    }
    
    
    private func calculateETA() async {
        guard let userLocation else {
            isCalculatingETA = false
            return
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: station.coordinate))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        do {
            let response = try await directions.calculate()
            if let route = response.routes.first {
                estimatedTravelTime = route.expectedTravelTime
            }
        } catch {
            print("Failed to calculate ETA: \(error)")
        }
        
        isCalculatingETA = false
    }
}

// MARK: - Drive Button (Full-width, Apple Maps style)

struct DriveButton: View {
    let travelTime: TimeInterval?
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "car.fill")
                    .font(.title2)
                
                // ETA label
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                        .tint(.white)
                } else if let time = travelTime {
                    Text(formatTravelTime(time))
                        .font(.subheadline.weight(.semibold))
                } else {
                    Text("Drive")
                        .font(.subheadline.weight(.semibold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.cyan.gradient)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func formatTravelTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours)h"
            }
            return "\(hours)h \(remainingMinutes)m"
        }
    }
}

// MARK: - Supporting Views

struct StatusBadge: View {
    let status: StatusType?
    
    var body: some View {
        Text(statusText)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.15))
            .foregroundStyle(statusColor)
            .clipShape(Capsule())
    }
    
    private var statusText: String {
        switch status {
        case .available: return "Available"
        case .occupied: return "Occupied"
        case .outOfService: return "Out of Service"
        case .unknown, .none: return "Unknown"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .available: return .green
        case .occupied: return .orange
        case .outOfService: return .red
        case .unknown, .none: return .gray
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ChargerDetailView(
            station: .sample,
            userLocation: CLLocation(latitude: 37.78, longitude: -122.41)
        )
    }
}

