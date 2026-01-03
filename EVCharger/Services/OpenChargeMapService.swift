//
//  OpenChargeMapService.swift
//  EVCharger
//
//  Created by Antigravity on 2026-01-04.
//

import Foundation
import CoreLocation

/// Service for fetching EV charging station data from the Open Charge Map API.
/// API Docs: https://openchargemap.org/site/develop/api
actor OpenChargeMapService {
    
    // MARK: - Configuration
    
    /// Base URL for Open Charge Map API v3
    private let baseURL = "https://api.openchargemap.io/v3/poi/"
    
    /// API key (Open Charge Map allows limited anonymous access, but key is recommended)
    /// Register at: https://openchargemap.org/site/profile/applications
    private let apiKey: String?
    
    /// Shared URLSession for network requests
    private let session: URLSession
    
    /// JSON decoder configured for API responses
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    
    init(apiKey: String? = nil, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
        
        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Public API
    
    /// Fetch charging stations near a location.
    /// - Parameters:
    ///   - location: Center point for the search
    ///   - radiusKm: Search radius in kilometers (default 10km)
    ///   - maxResults: Maximum number of results (default 50, max 500)
    ///   - connectorTypes: Optional filter for specific connector types
    /// - Returns: Array of ChargingStation models
    func fetchNearbyStations(
        location: CLLocationCoordinate2D,
        radiusKm: Double = 10,
        maxResults: Int = 50,
        connectorTypes: [ConnectorType]? = nil
    ) async throws -> [ChargingStation] {
        let url = try buildURL(
            latitude: location.latitude,
            longitude: location.longitude,
            radiusKm: radiusKm,
            maxResults: maxResults,
            connectorTypes: connectorTypes
        )
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenChargeMapError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw OpenChargeMapError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let apiResults = try decoder.decode([OCMPoi].self, from: data)
        return apiResults.compactMap { $0.toChargingStation() }
    }
    
    /// Fetch a single charging station by ID.
    func fetchStation(id: Int) async throws -> ChargingStation? {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "chargepointid", value: String(id)),
            URLQueryItem(name: "output", value: "json"),
            URLQueryItem(name: "compact", value: "false")
        ]
        
        if let apiKey {
            components.queryItems?.append(URLQueryItem(name: "key", value: apiKey))
        }
        
        guard let url = components.url else {
            throw OpenChargeMapError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw OpenChargeMapError.invalidResponse
        }
        
        let apiResults = try decoder.decode([OCMPoi].self, from: data)
        return apiResults.first?.toChargingStation()
    }
    
    // MARK: - Private Helpers
    
    private func buildURL(
        latitude: Double,
        longitude: Double,
        radiusKm: Double,
        maxResults: Int,
        connectorTypes: [ConnectorType]?
    ) throws -> URL {
        var components = URLComponents(string: baseURL)!
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "output", value: "json"),
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "distance", value: String(radiusKm)),
            URLQueryItem(name: "distanceunit", value: "km"),
            URLQueryItem(name: "maxresults", value: String(min(maxResults, 500))),
            URLQueryItem(name: "compact", value: "false"),
            URLQueryItem(name: "verbose", value: "false")
        ]
        
        // Add API key if available
        if let apiKey {
            queryItems.append(URLQueryItem(name: "key", value: apiKey))
        }
        
        // Add connector type filter if specified
        if let connectorTypes, !connectorTypes.isEmpty {
            let connectionTypeIds = connectorTypes.compactMap { $0.ocmConnectionTypeId }
            if !connectionTypeIds.isEmpty {
                queryItems.append(URLQueryItem(
                    name: "connectiontypeid",
                    value: connectionTypeIds.map(String.init).joined(separator: ",")
                ))
            }
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw OpenChargeMapError.invalidURL
        }
        
        return url
    }
}

// MARK: - Error Types

enum OpenChargeMapError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case noResults
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "Server returned error: \(statusCode)"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .noResults:
            return "No charging stations found"
        }
    }
}

// MARK: - API Response Models (Internal)

/// Root POI object from Open Charge Map API
struct OCMPoi: Decodable {
    let ID: Int
    let ocmUUID: String?
    let DataProviderID: Int?
    let OperatorInfo: OCMOperator?
    let UsageTypeID: Int?
    let AddressInfo: OCMAddressInfo?
    let Connections: [OCMConnection]?
    let NumberOfPoints: Int?
    let StatusTypeID: Int?
    let StatusType: OCMStatusType?
    let DateLastStatusUpdate: String?
    let UsageCost: String?
    
    // Map property names to JSON keys (ocmUUID maps to "UUID" in JSON to avoid Foundation.UUID shadowing)
    private enum CodingKeys: String, CodingKey {
        case ID, DataProviderID, OperatorInfo, UsageTypeID, AddressInfo
        case Connections, NumberOfPoints, StatusTypeID, StatusType
        case DateLastStatusUpdate, UsageCost
        case ocmUUID = "UUID"
    }
    
    /// Convert API response to our domain model
    func toChargingStation() -> ChargingStation? {
        guard let address = AddressInfo else { return nil }
        
        // Parse connector types from connections
        let connectors = (Connections ?? []).compactMap { connection -> ConnectorType? in
            guard let typeId = connection.ConnectionTypeID else { return nil }
            return ConnectorType.fromOCMConnectionTypeId(typeId)
        }
        
        // Remove duplicates while preserving order
        let uniqueConnectors = connectors.reduce(into: [ConnectorType]()) { result, connector in
            if !result.contains(connector) {
                result.append(connector)
            }
        }
        
        // Parse status
        let status: StatusType? = {
            guard let statusId = StatusTypeID else { return .unknown }
            switch statusId {
            case 50: return .available      // Operational
            case 30, 75: return .occupied   // Temporarily Unavailable / Partly Operational
            case 100, 150, 200: return .outOfService // Not Operational / Planned / Removed
            default: return .unknown
            }
        }()
        
        // Parse last updated date
        let lastUpdated: Date = {
            if let dateString = DateLastStatusUpdate {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                return formatter.date(from: dateString) ?? Date()
            }
            return Date()
        }()
        
        return ChargingStation(
            id: UUID(uuidString: ocmUUID ?? "") ?? UUID(),
            name: address.Title ?? "Charging Station",
            operatorName: OperatorInfo?.Title,
            address: address.formattedAddress,
            latitude: address.Latitude ?? 0,
            longitude: address.Longitude ?? 0,
            connectorTypes: uniqueConnectors.isEmpty ? [.ccs] : uniqueConnectors,
            numberOfPoints: NumberOfPoints ?? 1,
            statusType: status,
            usageCost: UsageCost,
            lastUpdated: lastUpdated
        )
    }
}

struct OCMOperator: Decodable {
    let ID: Int?
    let Title: String?
    let WebsiteURL: String?
}

struct OCMAddressInfo: Decodable {
    let Title: String?
    let AddressLine1: String?
    let AddressLine2: String?
    let Town: String?
    let StateOrProvince: String?
    let Postcode: String?
    let CountryID: Int?
    let Latitude: Double?
    let Longitude: Double?
    
    /// Combine address components into a formatted string
    var formattedAddress: String {
        let components = [AddressLine1, Town, StateOrProvince, Postcode]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        return components.joined(separator: ", ")
    }
}

struct OCMConnection: Decodable {
    let ID: Int?
    let ConnectionTypeID: Int?
    let StatusTypeID: Int?
    let LevelID: Int?
    let PowerKW: Double?
    let Quantity: Int?
}

struct OCMStatusType: Decodable {
    let ID: Int?
    let Title: String?
    let IsOperational: Bool?
}

// MARK: - ConnectorType OCM Mapping Extension

extension ConnectorType {
    /// Open Charge Map connection type ID for this connector
    var ocmConnectionTypeId: Int? {
        switch self {
        case .ccs: return 33      // CCS (Type 1) or 32 for CCS (Type 2)
        case .chademo: return 2   // CHAdeMO
        case .tesla: return 30    // Tesla Supercharger (or 27 for Tesla Model S)
        case .j1772: return 1     // J1772
        case .type2: return 25    // Type 2 (Mennekes)
        }
    }
    
    /// Create ConnectorType from Open Charge Map connection type ID
    static func fromOCMConnectionTypeId(_ id: Int) -> ConnectorType? {
        switch id {
        case 1: return .j1772
        case 2: return .chademo
        case 25: return .type2
        case 27, 30, 8: return .tesla  // Tesla variants
        case 32, 33: return .ccs       // CCS Type 1 & 2
        default: return nil
        }
    }
}
