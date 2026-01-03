//
//  ChargerRowView.swift
//  EVCharger
//
//  Created by Map-Maven on 2026-01-04.
//

import SwiftUI
import CoreLocation

/// Row view for a charging station in the list.
struct ChargerRowView: View {
    
    let station: ChargingStation
    let userLocation: CLLocation?
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            ZStack {
                Circle()
                    .fill(statusColor.gradient)
                    .frame(width: 44, height: 44)
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            // Station info
            VStack(alignment: .leading, spacing: 4) {
                Text(station.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                
                if let operatorName = station.operatorName {
                    Text(operatorName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Connector badges
                HStack(spacing: 4) {
                    ForEach(station.connectorTypes.prefix(3), id: \.self) { connector in
                        ConnectorBadgeView(connector: connector, size: .small)
                    }
                    
                    if station.connectorTypes.count > 3 {
                        Text("+\(station.connectorTypes.count - 3)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Distance and points
            VStack(alignment: .trailing, spacing: 4) {
                if let location = userLocation {
                    Text(station.formattedDistance(from: location))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.green)
                }
                
                HStack(spacing: 2) {
                    Image(systemName: "ev.plug.dc.ccs1")
                        .font(.caption2)
                    Text("\(station.numberOfPoints)")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
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
    List {
        ChargerRowView(
            station: .sample,
            userLocation: CLLocation(latitude: 37.7749, longitude: -122.4194)
        )
    }
}
