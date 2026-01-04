//
//  CacheStatusView.swift
//  EVCharger
//
//  Created by Map-Maven on 2026-01-04.
//

import SwiftUI

/// Displays cache status information in settings
struct CacheStatusView: View {
    
    let cacheInfo: CacheInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Station count
            HStack {
                Label("Cached Stations", systemImage: "bolt.fill")
                Spacer()
                Text("\(cacheInfo.stationCount)")
                    .foregroundStyle(.secondary)
            }
            
            // Last updated
            if let lastUpdated = cacheInfo.lastUpdated {
                HStack {
                    Label("Last Updated", systemImage: "clock.fill")
                    Spacer()
                    Text(lastUpdated, style: .relative)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Size estimate
            HStack {
                Label("Cache Size", systemImage: "externaldrive.fill")
                Spacer()
                Text(cacheInfo.sizeEstimate)
                    .foregroundStyle(.secondary)
            }
        }
        .font(.subheadline)
    }
}

// MARK: - Preview

#Preview {
    List {
        CacheStatusView(cacheInfo: CacheInfo(
            stationCount: 142,
            lastUpdated: Date().addingTimeInterval(-3600),
            sizeEstimate: "71 KB"
        ))
    }
}
