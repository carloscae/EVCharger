//
//  OpenChargeMapServiceTests.swift
//  EVChargerTests
//
//  Unit tests for Open Charge Map API service
//  Tests parsing, filtering, and error handling
//

import XCTest
@testable import EVCharger

final class OpenChargeMapServiceTests: XCTestCase {
    
    // MARK: - Test Data
    
    /// Sample JSON response from Open Charge Map API
    private let validStationJSON = """
    [
        {
            "ID": 12345,
            "UUID": "550e8400-e29b-41d4-a716-446655440000",
            "OperatorInfo": {
                "ID": 1,
                "Title": "ChargePoint"
            },
            "AddressInfo": {
                "Title": "Downtown Charging Hub",
                "AddressLine1": "123 Main Street",
                "Town": "San Francisco",
                "StateOrProvince": "CA",
                "Postcode": "94102",
                "Latitude": 37.7749,
                "Longitude": -122.4194
            },
            "Connections": [
                {
                    "ID": 1,
                    "ConnectionTypeID": 33,
                    "PowerKW": 150
                },
                {
                    "ID": 2,
                    "ConnectionTypeID": 2,
                    "PowerKW": 50
                }
            ],
            "NumberOfPoints": 4,
            "StatusTypeID": 50,
            "UsageCost": "$0.35/kWh"
        }
    ]
    """
    
    private let emptyResponseJSON = "[]"
    
    private let malformedJSON = "{ invalid json }"
    
    // MARK: - OCMPoi Parsing Tests
    
    func testParseValidStationResponse() throws {
        // Given
        let data = Data(validStationJSON.utf8)
        let decoder = JSONDecoder()
        
        // When
        let poiArray = try decoder.decode([OCMPoi].self, from: data)
        
        // Then
        XCTAssertEqual(poiArray.count, 1)
        
        let poi = poiArray[0]
        XCTAssertEqual(poi.ID, 12345)
        XCTAssertEqual(poi.ocmUUID, "550e8400-e29b-41d4-a716-446655440000")
        XCTAssertEqual(poi.OperatorInfo?.Title, "ChargePoint")
        XCTAssertEqual(poi.AddressInfo?.Title, "Downtown Charging Hub")
        XCTAssertEqual(poi.AddressInfo?.Latitude, 37.7749)
        XCTAssertEqual(poi.AddressInfo?.Longitude, -122.4194)
        XCTAssertEqual(poi.Connections?.count, 2)
        XCTAssertEqual(poi.NumberOfPoints, 4)
        XCTAssertEqual(poi.StatusTypeID, 50)
        XCTAssertEqual(poi.UsageCost, "$0.35/kWh")
    }
    
    func testParseEmptyResponse() throws {
        // Given
        let data = Data(emptyResponseJSON.utf8)
        let decoder = JSONDecoder()
        
        // When
        let poiArray = try decoder.decode([OCMPoi].self, from: data)
        
        // Then
        XCTAssertTrue(poiArray.isEmpty)
    }
    
    func testParseMalformedResponse() {
        // Given
        let data = Data(malformedJSON.utf8)
        let decoder = JSONDecoder()
        
        // When/Then
        XCTAssertThrowsError(try decoder.decode([OCMPoi].self, from: data))
    }
    
    // MARK: - ChargingStation Conversion Tests
    
    func testConvertPOIToChargingStation() throws {
        // Given
        let data = Data(validStationJSON.utf8)
        let decoder = JSONDecoder()
        let poiArray = try decoder.decode([OCMPoi].self, from: data)
        let poi = poiArray[0]
        
        // When
        let station = poi.toChargingStation()
        
        // Then
        XCTAssertNotNil(station)
        XCTAssertEqual(station?.name, "Downtown Charging Hub")
        XCTAssertEqual(station?.operatorName, "ChargePoint")
        XCTAssertEqual(station?.latitude, 37.7749)
        XCTAssertEqual(station?.longitude, -122.4194)
        XCTAssertEqual(station?.numberOfPoints, 4)
        XCTAssertEqual(station?.statusType, .available) // StatusTypeID 50 = Operational
        XCTAssertEqual(station?.usageCost, "$0.35/kWh")
        
        // Check connector types - should have CCS and CHAdeMO
        XCTAssertTrue(station?.connectorTypes.contains(.ccs) ?? false)
        XCTAssertTrue(station?.connectorTypes.contains(.chademo) ?? false)
    }
    
    func testFormattedAddress() throws {
        // Given
        let data = Data(validStationJSON.utf8)
        let decoder = JSONDecoder()
        let poiArray = try decoder.decode([OCMPoi].self, from: data)
        let addressInfo = poiArray[0].AddressInfo!
        
        // When
        let formatted = addressInfo.formattedAddress
        
        // Then
        XCTAssertTrue(formatted.contains("123 Main Street"))
        XCTAssertTrue(formatted.contains("San Francisco"))
        XCTAssertTrue(formatted.contains("CA"))
    }
    
    // MARK: - Connector Type Mapping Tests
    
    func testConnectorTypeToOCMId() {
        XCTAssertEqual(ConnectorType.ccs.ocmConnectionTypeId, 33)
        XCTAssertEqual(ConnectorType.chademo.ocmConnectionTypeId, 2)
        XCTAssertEqual(ConnectorType.tesla.ocmConnectionTypeId, 30)
        XCTAssertEqual(ConnectorType.j1772.ocmConnectionTypeId, 1)
        XCTAssertEqual(ConnectorType.type2.ocmConnectionTypeId, 25)
    }
    
    func testOCMIdToConnectorType() {
        XCTAssertEqual(ConnectorType.fromOCMConnectionTypeId(1), .j1772)
        XCTAssertEqual(ConnectorType.fromOCMConnectionTypeId(2), .chademo)
        XCTAssertEqual(ConnectorType.fromOCMConnectionTypeId(25), .type2)
        XCTAssertEqual(ConnectorType.fromOCMConnectionTypeId(30), .tesla)
        XCTAssertEqual(ConnectorType.fromOCMConnectionTypeId(33), .ccs)
        
        // Tesla variants
        XCTAssertEqual(ConnectorType.fromOCMConnectionTypeId(27), .tesla)
        XCTAssertEqual(ConnectorType.fromOCMConnectionTypeId(8), .tesla)
        
        // CCS Type 2
        XCTAssertEqual(ConnectorType.fromOCMConnectionTypeId(32), .ccs)
        
        // Unknown type returns nil
        XCTAssertNil(ConnectorType.fromOCMConnectionTypeId(9999))
    }
    
    // MARK: - Status Type Mapping Tests
    
    func testStatusTypeMappingFromOCMId() throws {
        // Test status type inference via POI parsing
        let stationWithStatus50 = """
        [{"ID": 1, "AddressInfo": {"Latitude": 0, "Longitude": 0}, "StatusTypeID": 50}]
        """
        let stationWithStatus30 = """
        [{"ID": 2, "AddressInfo": {"Latitude": 0, "Longitude": 0}, "StatusTypeID": 30}]
        """
        let stationWithStatus100 = """
        [{"ID": 3, "AddressInfo": {"Latitude": 0, "Longitude": 0}, "StatusTypeID": 100}]
        """
        
        let decoder = JSONDecoder()
        
        // Status 50 = Operational → Available
        let poi1 = try decoder.decode([OCMPoi].self, from: Data(stationWithStatus50.utf8))[0]
        XCTAssertEqual(poi1.toChargingStation()?.statusType, .available)
        
        // Status 30 = Temporarily Unavailable → Occupied
        let poi2 = try decoder.decode([OCMPoi].self, from: Data(stationWithStatus30.utf8))[0]
        XCTAssertEqual(poi2.toChargingStation()?.statusType, .occupied)
        
        // Status 100 = Not Operational → OutOfService
        let poi3 = try decoder.decode([OCMPoi].self, from: Data(stationWithStatus100.utf8))[0]
        XCTAssertEqual(poi3.toChargingStation()?.statusType, .outOfService)
    }
    
    // MARK: - Error Type Tests
    
    func testOpenChargeMapErrorDescriptions() {
        XCTAssertNotNil(OpenChargeMapError.invalidURL.errorDescription)
        XCTAssertNotNil(OpenChargeMapError.invalidResponse.errorDescription)
        XCTAssertNotNil(OpenChargeMapError.httpError(statusCode: 429).errorDescription)
        XCTAssertTrue(OpenChargeMapError.httpError(statusCode: 429).errorDescription?.contains("429") ?? false)
    }
}
