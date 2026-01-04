//
//  VehiclePickerView.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import SwiftUI

/// Searchable vehicle picker for selecting from the EV database
struct VehiclePickerView: View {
    
    @Binding var searchText: String
    let onSelect: (EVVehicle) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    /// All vehicles from database
    private let allVehicles = EVDatabase.shared.vehicles
    
    /// Filtered vehicles based on search
    private var filteredVehicles: [EVVehicle] {
        if searchText.isEmpty {
            return allVehicles
        }
        return EVDatabase.shared.search(searchText)
    }
    
    /// Vehicles grouped by brand for display
    private var vehiclesByBrand: [String: [EVVehicle]] {
        Dictionary(grouping: filteredVehicles, by: \.brand)
    }
    
    /// Sorted brand names
    private var sortedBrands: [String] {
        vehiclesByBrand.keys.sorted()
    }
    
    var body: some View {
        NavigationStack {
            List {
                if filteredVehicles.isEmpty {
                    ContentUnavailableView(
                        "No Vehicles Found",
                        systemImage: "car.fill",
                        description: Text("Try a different search term")
                    )
                } else {
                    ForEach(sortedBrands, id: \.self) { brand in
                        Section(brand) {
                            ForEach(vehiclesByBrand[brand] ?? []) { vehicle in
                                Button {
                                    onSelect(vehicle)
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(vehicle.model) \(vehicle.variant)")
                                            .foregroundStyle(.primary)
                                        
                                        HStack(spacing: 12) {
                                            Label("\(vehicle.rangeKm) km", systemImage: "road.lanes")
                                            Label("\(vehicle.maxDcChargingKw) kW", systemImage: "bolt.fill")
                                        }
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 2)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search vehicles...")
            .navigationTitle("Select Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VehiclePickerView(
        searchText: .constant(""),
        onSelect: { _ in }
    )
}
