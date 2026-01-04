//
//  ConnectorBadgeView.swift
//  EVCharger
//
//  Created by Map-Maven on 2026-01-04.
//

import SwiftUI

/// Compact badge for list views - text only, no icon
struct ConnectorBadgeView: View {
    
    let connector: ConnectorType
    
    var body: some View {
        Text(connector.displayName)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(connectorColor.opacity(0.15))
            )
            .foregroundStyle(connectorColor)
    }
    
    private var connectorColor: Color {
        switch connector {
        case .ccs: return .blue
        case .chademo: return .orange
        case .tesla: return .red
        case .j1772: return .green
        case .type2: return .purple
        }
    }
}

/// Large connector card for detail views - prominent icon + name + hint
struct ConnectorCardView: View {
    
    let connector: ConnectorType
    
    var body: some View {
        HStack(spacing: 12) {
            // Large icon
            Image(systemName: connector.sfSymbol)
                .font(.title2)
                .foregroundStyle(connectorColor)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(connectorColor.opacity(0.12))
                )
            
            // Name and hint
            VStack(alignment: .leading, spacing: 2) {
                Text(connector.displayName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(connector.hint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private var connectorColor: Color {
        switch connector {
        case .ccs: return .blue
        case .chademo: return .orange
        case .tesla: return .red
        case .j1772: return .green
        case .type2: return .purple
        }
    }
}

// MARK: - Preview

#Preview("Compact Badges") {
    HStack {
        ForEach(ConnectorType.allCases) { connector in
            ConnectorBadgeView(connector: connector)
        }
    }
    .padding()
}

#Preview("Detail Cards") {
    VStack(spacing: 12) {
        ForEach(ConnectorType.allCases) { connector in
            ConnectorCardView(connector: connector)
        }
    }
    .padding()
}

