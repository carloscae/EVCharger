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

/// Enhanced connector card showing power, quantity, AC/DC type, and status
/// Matches the equipment details shown on OpenChargeMap website
struct ConnectionCardView: View {
    
    let connection: ConnectionInfo
    
    var body: some View {
        HStack(spacing: 12) {
            // Left: Icon with quantity badge
            ZStack(alignment: .bottomLeading) {
                Image(systemName: connection.connectorType.sfSymbol)
                    .font(.title2)
                    .foregroundStyle(connectorColor)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(connectorColor.opacity(0.12))
                    )
                
                // Quantity badge
                Text("\(connection.quantity) x")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(statusColor)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .offset(x: -4, y: 4)
            }
            
            // Right: Details
            VStack(alignment: .leading, spacing: 4) {
                // Connector name
                Text(connection.connectorType.displayName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                // Power and current type
                HStack(spacing: 8) {
                    if let power = connection.formattedPower {
                        Text(power)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    if let currentType = connection.currentType {
                        Text(currentType)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(currentType == "DC" ? Color.blue.opacity(0.15) : Color.green.opacity(0.15))
                            .foregroundStyle(currentType == "DC" ? .blue : .green)
                            .clipShape(Capsule())
                    }
                }
                
                // Status
                Text(connection.statusText)
                    .font(.caption)
                    .foregroundStyle(statusColor)
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private var connectorColor: Color {
        switch connection.connectorType {
        case .ccs: return .blue
        case .chademo: return .orange
        case .tesla: return .red
        case .j1772: return .green
        case .type2: return .purple
        }
    }
    
    private var statusColor: Color {
        connection.isOperational ? .green : .orange
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

#Preview("Connection Cards") {
    VStack(spacing: 12) {
        ConnectionCardView(connection: ConnectionInfo(
            id: 1,
            connectorType: .chademo,
            powerKW: 50,
            quantity: 1,
            levelID: 3,
            statusID: 50
        ))
        ConnectionCardView(connection: ConnectionInfo(
            id: 2,
            connectorType: .ccs,
            powerKW: 50,
            quantity: 1,
            levelID: 3,
            statusID: 50
        ))
        ConnectionCardView(connection: ConnectionInfo(
            id: 3,
            connectorType: .type2,
            powerKW: 43,
            quantity: 1,
            levelID: 2,
            statusID: 50
        ))
    }
    .padding()
}
