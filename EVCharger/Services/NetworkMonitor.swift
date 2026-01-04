//
//  NetworkMonitor.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import Foundation
import Network
import Combine

/// Service for monitoring network connectivity.
/// Publishes connection status changes for offline mode support.
@Observable
final class NetworkMonitor {
    
    // MARK: - Published State
    
    /// Whether the device currently has network connectivity
    private(set) var isConnected: Bool = true
    
    /// Current connection type (wifi, cellular, etc.)
    private(set) var connectionType: ConnectionType = .unknown
    
    /// Whether we're in offline mode (no connection detected)
    var isOffline: Bool { !isConnected }
    
    // MARK: - Publishers
    
    /// Publisher for connection status changes
    private let connectionSubject = CurrentValueSubject<Bool, Never>(true)
    var connectionPublisher: AnyPublisher<Bool, Never> {
        connectionSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.evcharger.networkmonitor")
    
    // MARK: - Initialization
    
    init() {
        self.monitor = NWPathMonitor()
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Public Methods
    
    /// Start monitoring network changes.
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateConnectionStatus(path)
            }
        }
        monitor.start(queue: queue)
    }
    
    /// Stop monitoring network changes.
    func stopMonitoring() {
        monitor.cancel()
    }
    
    // MARK: - Private Helpers
    
    private func updateConnectionStatus(_ path: NWPath) {
        isConnected = path.status == .satisfied
        connectionSubject.send(isConnected)
        
        // Determine connection type
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else if path.status == .satisfied {
            connectionType = .other
        } else {
            connectionType = .none
        }
    }
}

// MARK: - Connection Type

extension NetworkMonitor {
    enum ConnectionType: String {
        case wifi = "WiFi"
        case cellular = "Cellular"
        case ethernet = "Ethernet"
        case other = "Other"
        case none = "No Connection"
        case unknown = "Unknown"
        
        var icon: String {
            switch self {
            case .wifi: return "wifi"
            case .cellular: return "antenna.radiowaves.left.and.right"
            case .ethernet: return "cable.connector"
            case .other, .unknown: return "network"
            case .none: return "wifi.slash"
            }
        }
    }
}
