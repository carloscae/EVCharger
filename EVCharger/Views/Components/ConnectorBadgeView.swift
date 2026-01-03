//
//  ConnectorBadgeView.swift
//  EVCharger
//
//  Created by Map-Maven on 2026-01-04.
//

import SwiftUI

/// Badge view displaying a connector type with icon and label.
struct ConnectorBadgeView: View {
    
    let connector: ConnectorType
    var size: BadgeSize = .regular
    
    enum BadgeSize {
        case small, regular, large
        
        var iconFont: Font {
            switch self {
            case .small: return .system(size: 8)
            case .regular: return .caption2
            case .large: return .caption
            }
        }
        
        var labelFont: Font {
            switch self {
            case .small: return .system(size: 9, weight: .medium)
            case .regular: return .caption2.weight(.medium)
            case .large: return .caption.weight(.medium)
            }
        }
        
        var horizontalPadding: CGFloat {
            switch self {
            case .small: return 6
            case .regular: return 8
            case .large: return 10
            }
        }
        
        var verticalPadding: CGFloat {
            switch self {
            case .small: return 3
            case .regular: return 4
            case .large: return 6
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: connector.iconName)
                .font(size.iconFont)
            
            Text(connector.shortName)
                .font(size.labelFont)
        }
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(
            Capsule()
                .fill(connectorColor.opacity(0.15))
        )
        .foregroundStyle(connectorColor)
    }
    
    private var connectorColor: Color {
        switch connector {
        case .ccs:
            return .blue
        case .chademo:
            return .orange
        case .tesla:
            return .red
        case .j1772:
            return .green
        case .type2:
            return .purple
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        HStack {
            ForEach(ConnectorType.allCases) { connector in
                ConnectorBadgeView(connector: connector, size: .small)
            }
        }
        
        HStack {
            ForEach(ConnectorType.allCases) { connector in
                ConnectorBadgeView(connector: connector, size: .regular)
            }
        }
        
        HStack {
            ForEach(ConnectorType.allCases) { connector in
                ConnectorBadgeView(connector: connector, size: .large)
            }
        }
    }
    .padding()
}
