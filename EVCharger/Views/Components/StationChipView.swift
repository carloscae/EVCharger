//
//  StationChipView.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import SwiftUI
import CoreLocation

/// Apple Maps style place chip with large circular icon
struct StationChipView: View {
    
    let station: ChargingStation
    let userLocation: CLLocation?
    
    private var distanceText: String {
        guard let location = userLocation else { return "" }
        let stationLocation = CLLocation(
            latitude: station.coordinate.latitude,
            longitude: station.coordinate.longitude
        )
        let distance = location.distance(from: stationLocation)
        if distance < 1000 {
            return "\(Int(distance)) m"
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
    
    private var iconColor: Color {
        switch station.statusType {
        case .available: return .green
        case .occupied: return .orange
        case .outOfService: return .red
        case .unknown, .none: return .blue
        }
    }
    
    var body: some View {
        VStack(spacing: 2) {
            // Large circular icon (Apple Maps style)
            ZStack {
                Circle()
                    .fill(iconColor.gradient)
                    .frame(width: 64, height: 64)
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.white)
            }
            
            // Name
            Text(station.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .foregroundStyle(.primary)
            
            // Distance
            if !distanceText.isEmpty {
                Text(distanceText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 80)
    }
}

/// Apple Maps style "Places >" section header with horizontal scroll
struct StationChipsSection: View {
    
    let title: String
    let icon: String
    let stations: [ChargingStation]
    let userLocation: CLLocation?
    let onSelect: (ChargingStation) -> Void
    let onSeeAll: () -> Void
    
    var body: some View {
        if !stations.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                // Header with chevron (Apple Maps style)
                Button {
                    onSeeAll()
                } label: {
                    HStack(spacing: 4) {
                        Text(title)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.primary)
                        
                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                
                // Horizontal scroll of chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(stations.prefix(8), id: \.id) { station in
                            Button {
                                onSelect(station)
                            } label: {
                                StationChipView(
                                    station: station,
                                    userLocation: userLocation
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(alignment: .leading, spacing: 24) {
        StationChipsSection(
            title: "Favorites",
            icon: "star.fill",
            stations: [],
            userLocation: nil,
            onSelect: { _ in },
            onSeeAll: {}
        )
    }
    .padding(.vertical)
}
