//
//  ChargerDetailView.swift
//  EVCharger
//
//  Created by Map-Maven on 2026-01-04.
//

import SwiftUI
import MapKit

/// Detail view for a charging station showing full info and navigation.
struct ChargerDetailView: View {
    
    let station: ChargingStation
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Mini map header
                Map(initialPosition: .region(stationRegion)) {
                    Marker(station.name, coordinate: station.coordinate)
                        .tint(.green)
                }
                .frame(height: 180)
                .allowsHitTesting(false)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(station.name)
                                .font(.title2.bold())
                            
                            Spacer()
                            
                            StatusBadge(status: station.statusType)
                        }
                        
                        if let operatorName = station.operatorName {
                            Label(operatorName, systemImage: "building.2")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Label(station.address, systemImage: "mappin.and.ellipse")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                    
                    // Connectors section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Connectors", systemImage: "ev.plug.dc.ccs1")
                            .font(.headline)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(station.connectorTypes, id: \.self) { connector in
                                ConnectorBadgeView(connector: connector, size: .large)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Details section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Details", systemImage: "info.circle")
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
                    
                    Spacer(minLength: 20)
                    
                    // Navigate button
                    Button {
                        NavigationService.navigateToStation(station)
                    } label: {
                        Label("Navigate", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.gradient)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
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
    }
    
    private var stationRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: station.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
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
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ChargerDetailView(station: .sample)
    }
}
