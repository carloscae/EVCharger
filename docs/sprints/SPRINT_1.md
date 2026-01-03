# Sprint 1: Foundation

**Start Date:** 2026-01-03  
**Target Duration:** ~5 days  
**Goal:** Establish project structure and shared data layer

---

## Role Summary

| Role | Tasks |
|------|-------|
| **Platform Specialist** | S1-01 (Xcode Project) |
| **State Engineer** | S1-02 (Data Models), S1-03 (API Service), S1-04 (Location Service) |
| **Product Lead** | S1-05 (Entitlement Request) |

---

## Tasks

### S1-01: Create Xcode Project
**Role:** Platform Specialist  
**Status:** `[ ]` Not Started  
**Dependencies:** None  
**Estimated:** 1 hour

**Deliverables:**
- [ ] New Xcode project with SwiftUI lifecycle
- [ ] iOS 16+ deployment target
- [ ] CarPlay capability enabled
- [ ] SwiftData framework added
- [ ] MapKit framework added
- [ ] Directory structure per ARCHITECTURE.md

**Files:**
- `EVCharger.xcodeproj`
- `EVCharger/App/EVChargerApp.swift`
- `EVCharger/App/ContentView.swift`

---

### S1-02: Implement Data Models
**Role:** State Engineer  
**Status:** `[ ]` Not Started  
**Dependencies:** S1-01  
**Estimated:** 2 hours

**Deliverables:**
- [ ] `ChargingStation` model with all fields
- [ ] `ConnectorType` enum (CCS, CHAdeMO, Tesla, J1772, Type2)
- [ ] `StatusType` enum (Available, Occupied, Unknown, OutOfService)
- [ ] `UserPreferences` model for settings
- [ ] SwiftData schema for caching

**Files:**
- `EVCharger/Models/ChargingStation.swift`
- `EVCharger/Models/ConnectorType.swift`
- `EVCharger/Models/UserPreferences.swift`

---

### S1-03: Implement Open Charge Map Service
**Role:** State Engineer  
**Status:** `[ ]` Not Started  
**Dependencies:** S1-02  
**Estimated:** 3 hours

**Deliverables:**
- [ ] `OpenChargeMapService` with async fetch
- [ ] API response parsing to `ChargingStation`
- [ ] Distance-based query (lat, lng, radius)
- [ ] Connector type filtering
- [ ] Error handling
- [ ] Unit tests for parsing

**Files:**
- `EVCharger/Services/OpenChargeMapService.swift`
- `EVChargerTests/OpenChargeMapServiceTests.swift`

---

### S1-04: Implement Location Service
**Role:** State Engineer  
**Status:** `[ ]` Not Started  
**Dependencies:** S1-01  
**Estimated:** 2 hours

**Deliverables:**
- [ ] `LocationService` using CoreLocation
- [ ] Request location permissions
- [ ] Get current location
- [ ] Location update publisher for map centering
- [ ] Handle permission denied gracefully

**Files:**
- `EVCharger/Services/LocationService.swift`

---

### S1-05: Request CarPlay Entitlement
**Role:** Product Lead  
**Status:** `[/]` In Progress (claimed by Antigravity @ 2026-01-03)  
**Dependencies:** None  
**Estimated:** 1 hour

**Deliverables:**
- [ ] Register at developer.apple.com/carplay
- [ ] Submit EV Charging category request
- [ ] Document app description and screenshots mock
- [ ] Track entitlement approval status

**Files:**
- `docs/ENTITLEMENT_STATUS.md` (new)

---

## Success Criteria

- [ ] Xcode project builds without errors
- [ ] Data models compile and are testable
- [ ] API service fetches real charger data
- [ ] Location service provides user coordinates
- [ ] CarPlay entitlement request submitted

---

## Blockers & Notes

*Add blockers during sprint.*

---

## Completed Tasks

*Move completed tasks here with agent details.*
