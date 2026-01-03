//
//  LocationService.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import Foundation
import CoreLocation
import Combine

/// Service for managing user location using CoreLocation.
/// Provides reactive location updates and permission handling for map centering.
@Observable
final class LocationService: NSObject {
    
    // MARK: - Published State
    
    /// Current user location, nil if not yet determined or permissions denied
    private(set) var currentLocation: CLLocation?
    
    /// Current authorization status
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    /// Human-readable error message when location unavailable
    private(set) var errorMessage: String?
    
    /// Whether location services are available and authorized
    var isLocationAvailable: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    /// Whether we're actively updating location
    private(set) var isUpdating: Bool = false
    
    // MARK: - Private Properties
    
    private let locationManager: CLLocationManager
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    private let locationSubject = PassthroughSubject<CLLocation, Never>()
    
    /// Publisher for location updates - use for reactive map centering
    var locationPublisher: AnyPublisher<CLLocation, Never> {
        locationSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100 // Update every 100 meters
        
        // Set initial authorization status
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Public Methods
    
    /// Request location permissions from the user.
    /// Call this before attempting to get location.
    func requestPermission() {
        guard authorizationStatus == .notDetermined else { return }
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Start continuous location updates.
    /// Updates are published via `locationPublisher`.
    func startUpdating() {
        guard isLocationAvailable else {
            errorMessage = "Location access not authorized"
            return
        }
        
        errorMessage = nil
        isUpdating = true
        locationManager.startUpdatingLocation()
    }
    
    /// Stop continuous location updates.
    func stopUpdating() {
        isUpdating = false
        locationManager.stopUpdatingLocation()
    }
    
    /// Get current location with a one-shot async request.
    /// - Returns: The current location
    /// - Throws: LocationError if location cannot be determined
    func getCurrentLocation() async throws -> CLLocation {
        // Return cached location if recent (within 60 seconds)
        if let location = currentLocation,
           abs(location.timestamp.timeIntervalSinceNow) < 60 {
            return location
        }
        
        guard isLocationAvailable else {
            throw LocationError.notAuthorized
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.requestLocation()
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        errorMessage = nil
        
        // Publish to reactive stream
        locationSubject.send(location)
        
        // Complete one-shot request if pending
        if let continuation = locationContinuation {
            self.locationContinuation = nil
            continuation.resume(returning: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let clError = error as? CLError
        
        switch clError?.code {
        case .denied:
            errorMessage = "Location access denied. Enable in Settings."
            authorizationStatus = .denied
        case .locationUnknown:
            errorMessage = "Unable to determine location. Please try again."
        default:
            errorMessage = "Location error: \(error.localizedDescription)"
        }
        
        // Fail one-shot request if pending
        if let continuation = locationContinuation {
            self.locationContinuation = nil
            continuation.resume(throwing: LocationError.failed(error))
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            errorMessage = nil
        case .denied, .restricted:
            errorMessage = "Location access denied. Enable in Settings."
            stopUpdating()
        case .notDetermined:
            errorMessage = nil
        @unknown default:
            break
        }
    }
}

// MARK: - LocationError

/// Errors that can occur during location operations
enum LocationError: LocalizedError {
    case notAuthorized
    case failed(Error)
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Location access not authorized. Please enable in Settings."
        case .failed(let error):
            return "Location failed: \(error.localizedDescription)"
        }
    }
}
