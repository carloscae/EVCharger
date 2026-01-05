//
//  SettingsView.swift
//  EVCharger
//
//  Created by Map-Maven on 2026-01-04.
//

import SwiftUI
import SwiftData

// MARK: - Notifications

extension Notification.Name {
    static let connectorPreferencesDidChange = Notification.Name("connectorPreferencesDidChange")
}

/// Settings screen with preferences, cache management, and app info
struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("preferredConnectors") private var preferredConnectorsData: Data = Data()
    @State private var showingClearCacheAlert = false
    @State private var cacheInfo: CacheInfo = CacheInfo()
    
    /// Current preferred connectors (multi-select)
    private var preferredConnectors: Set<ConnectorType> {
        get {
            (try? JSONDecoder().decode(Set<ConnectorType>.self, from: preferredConnectorsData)) ?? []
        }
        set {
            preferredConnectorsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    

    
    var body: some View {
        NavigationStack {
            List {

                
                // MARK: - Connector Preferences
                Section {
                    ForEach(ConnectorType.allCases) { connector in
                        Button {
                            toggleConnector(connector)
                        } label: {
                            HStack {
                                Image(systemName: connector.sfSymbol)
                                    .foregroundStyle(.primary)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(connector.displayName)
                                        .foregroundStyle(.primary)
                                    Text(connector.hint)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                if preferredConnectors.contains(connector) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Preferred Connectors")
                } footer: {
                    if preferredConnectors.isEmpty {
                        Text("Tap to select your car's connector types. All types shown when none selected.")
                    } else {
                        Text("\(preferredConnectors.count) selected — Filters chargers on map and CarPlay")
                    }
                }
                
                // MARK: - Cache
                Section {
                    CacheStatusView(cacheInfo: cacheInfo)
                    
                    Button(role: .destructive) {
                        showingClearCacheAlert = true
                    } label: {
                        Label("Clear Cache", systemImage: "trash")
                    }
                } header: {
                    Text("Cache")
                } footer: {
                    Text("Cached data allows offline browsing")
                }
                
                // MARK: - About
                Section {
                    LabeledContent("Version") {
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                    
                    LabeledContent("Build") {
                        Text(buildNumber)
                            .foregroundStyle(.secondary)
                    }
                    
                    Link(destination: reviewURL) {
                        Label("Rate on App Store", systemImage: "star.fill")
                    }
                    
                    Link(destination: privacyURL) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                } header: {
                    Text("About")
                }
                
                // MARK: - Credits
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Data provided by Open Charge Map")
                            .font(.footnote)
                        Text("openchargemap.org")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Credits")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Clear Cache?", isPresented: $showingClearCacheAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearCache()
                }
            } message: {
                Text("This will remove all cached charger data. Fresh data will be downloaded on next launch.")
            }
            .onAppear {
                loadCacheInfo()
            }
        }
    }
    

    
    // MARK: - Connector Toggle
    
    private func toggleConnector(_ connector: ConnectorType) {
        var current = (try? JSONDecoder().decode(Set<ConnectorType>.self, from: preferredConnectorsData)) ?? []
        if current.contains(connector) {
            current.remove(connector)
        } else {
            current.insert(connector)
        }
        preferredConnectorsData = (try? JSONEncoder().encode(current)) ?? Data()
        
        // Notify observers that filter preferences changed
        NotificationCenter.default.post(name: .connectorPreferencesDidChange, object: nil)
    }
    
    // MARK: - App Info
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    private var reviewURL: URL {
        URL(string: "https://apps.apple.com/app/id123456789?action=write-review")!
    }
    
    private var privacyURL: URL {
        URL(string: "https://evcharger.app/privacy")!
    }
    
    // MARK: - Cache Management
    
    private func loadCacheInfo() {
        // Query cached stations from SwiftData
        let descriptor = FetchDescriptor<ChargingStation>()
        do {
            let stations = try modelContext.fetch(descriptor)
            cacheInfo = CacheInfo(
                stationCount: stations.count,
                lastUpdated: stations.first?.lastUpdated,
                sizeEstimate: estimateCacheSize(stations: stations)
            )
        } catch {
            cacheInfo = CacheInfo()
        }
    }
    
    private func estimateCacheSize(stations: [ChargingStation]) -> String {
        // Rough estimate: ~500 bytes per station
        let bytes = stations.count * 500
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    private func clearCache() {
        // Delete all cached stations
        do {
            try modelContext.delete(model: ChargingStation.self)
            cacheInfo = CacheInfo()
        } catch {
            print("Failed to clear cache: \(error)")
        }
    }
}

// MARK: - Cache Info Model

struct CacheInfo {
    var stationCount: Int = 0
    var lastUpdated: Date? = nil
    var sizeEstimate: String = "0 KB"
}

// MARK: - Preview

#Preview {
    SettingsView()
}
