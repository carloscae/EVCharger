//
//  SettingsView.swift
//  EVCharger
//
//  Created by Map-Maven on 2026-01-04.
//

import SwiftUI
import SwiftData

/// Settings screen with preferences, cache management, and app info
struct SettingsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("defaultConnector") private var defaultConnectorRaw: String = ""
    @State private var showingClearCacheAlert = false
    @State private var cacheInfo: CacheInfo = CacheInfo()
    
    /// Current default connector preference
    private var defaultConnector: ConnectorType? {
        get { ConnectorType(rawValue: defaultConnectorRaw) }
        set { defaultConnectorRaw = newValue?.rawValue ?? "" }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Preferences
                Section {
                    // Default connector picker
                    Picker("Default Connector", selection: Binding(
                        get: { defaultConnectorRaw },
                        set: { defaultConnectorRaw = $0 }
                    )) {
                        Text("All Types").tag("")
                        ForEach(ConnectorType.allCases) { connector in
                            Label(connector.displayName, systemImage: connector.iconName)
                                .tag(connector.rawValue)
                        }
                    }
                } header: {
                    Text("Preferences")
                } footer: {
                    Text("Filter chargers by your preferred connector type")
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
