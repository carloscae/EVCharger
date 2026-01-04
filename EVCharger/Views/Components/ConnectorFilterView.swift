//
//  ConnectorFilterView.swift
//  EVCharger
//
//  Created by Map-Maven on 2026-01-04.
//

import SwiftUI

/// Horizontal scrolling filter chips for connector types.
struct ConnectorFilterView: View {
    
    @Binding var selectedConnector: ConnectorType?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All" chip
                FilterChip(
                    label: "All",
                    icon: "bolt.fill",
                    isSelected: selectedConnector == nil
                ) {
                    selectedConnector = nil
                }
                
                // Connector type chips
                ForEach(ConnectorType.allCases) { connector in
                    FilterChip(
                        label: connector.displayName,
                        icon: connector.iconName,
                        isSelected: selectedConnector == connector
                    ) {
                        selectedConnector = connector
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

/// Individual filter chip button
struct FilterChip: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.green : Color.secondary.opacity(0.15))
            )
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        ConnectorFilterView(selectedConnector: .constant(nil))
        ConnectorFilterView(selectedConnector: .constant(.ccs))
    }
    .padding()
}
