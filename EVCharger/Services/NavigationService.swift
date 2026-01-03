//
//  NavigationService.swift
//  EVCharger
//
//  Created by Map-Maven on 2026-01-04.
//

import Foundation
import MapKit

/// Service for navigating to charging stations via Apple Maps.
enum NavigationService {
    
    /// Open Apple Maps with driving directions to a charging station.
    /// - Parameter station: The charging station to navigate to
    static func navigateToStation(_ station: ChargingStation) {
        let coordinate = CLLocationCoordinate2D(
            latitude: station.latitude,
            longitude: station.longitude
        )
        
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = station.name
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
    
    /// Open Apple Maps with driving directions to a coordinate.
    /// - Parameters:
    ///   - coordinate: The destination coordinate
    ///   - name: Optional name for the destination
    static func navigateToCoordinate(_ coordinate: CLLocationCoordinate2D, name: String? = nil) {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name ?? "Charging Station"
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}
