//
//  StationListView.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import SwiftUI
import CoreLocation

/// Full list view for Favorites or Recents (See All)
struct StationListView: View {
    
    let title: String
    let stations: [ChargingStation]
    let userLocation: CLLocation?
    let onSelect: (ChargingStation) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(stations, id: \.id) { station in
                    Button {
                        onSelect(station)
                    } label: {
                        ChargerRowView(
                            station: station,
                            userLocation: userLocation
                        )
                    }
                    .foregroundStyle(.primary)
                }
            }
            .listStyle(.plain)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    StationListView(
        title: "Favorites",
        stations: [],
        userLocation: nil
    ) { _ in }
}
