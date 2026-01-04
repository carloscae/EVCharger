//
//  AmenityService.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import Foundation
import MapKit

/// Categories of amenities near charging stations
enum AmenityCategory: String, CaseIterable, Identifiable {
    case food = "Food & Drink"
    case restrooms = "Restrooms"
    case shopping = "Shopping"
    case coffee = "Coffee"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .restrooms: return "toilet"
        case .shopping: return "bag"
        case .coffee: return "cup.and.saucer"
        }
    }
    
    var mkCategory: MKPointOfInterestCategory {
        switch self {
        case .food: return .restaurant
        case .restrooms: return .restroom
        case .shopping: return .store
        case .coffee: return .cafe
        }
    }
}

/// A nearby amenity
struct Amenity: Identifiable {
    let id = UUID()
    let name: String
    let category: AmenityCategory
    let distance: Double // meters from station
    let coordinate: CLLocationCoordinate2D
    let mapItem: MKMapItem
}

/// Service for finding amenities near charging stations
actor AmenityService {
    
    /// Search for amenities near a location
    /// - Parameters:
    ///   - location: Center point to search around
    ///   - categories: Types of amenities to find
    ///   - radiusMeters: Search radius
    /// - Returns: Array of nearby amenities
    func searchAmenities(
        near location: CLLocationCoordinate2D,
        categories: [AmenityCategory] = AmenityCategory.allCases,
        radiusMeters: Double = 500
    ) async -> [Amenity] {
        
        var allAmenities: [Amenity] = []
        let centerLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        for category in categories {
            let amenities = await searchCategory(
                category,
                near: location,
                centerLocation: centerLocation,
                radius: radiusMeters
            )
            allAmenities.append(contentsOf: amenities)
        }
        
        // Sort by distance
        return allAmenities.sorted { $0.distance < $1.distance }
    }
    
    private func searchCategory(
        _ category: AmenityCategory,
        near location: CLLocationCoordinate2D,
        centerLocation: CLLocation,
        radius: Double
    ) async -> [Amenity] {
        
        let request = MKLocalPointsOfInterestRequest(center: location, radius: radius)
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [category.mkCategory])
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            
            return response.mapItems.prefix(5).map { item in
                let itemLocation = CLLocation(
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude
                )
                
                return Amenity(
                    name: item.name ?? "Unknown",
                    category: category,
                    distance: centerLocation.distance(from: itemLocation),
                    coordinate: item.placemark.coordinate,
                    mapItem: item
                )
            }
        } catch {
            return []
        }
    }
}
