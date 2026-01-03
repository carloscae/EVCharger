# Sprint 2: iPhone App

**Start Date:** 2026-01-04  
**Target Duration:** ~5 days  
**Goal:** Complete iPhone experience with map and list views

---

## Role Summary

| Role | Tasks |
|------|-------|
| **State Engineer** | S2-01 (ViewModel) |
| **UI Developer** | S2-02 (Map View), S2-03 (List View), S2-04 (Detail View), S2-05 (Navigation) |

---

## Tasks

### S2-01: Implement ChargersViewModel
**Role:** State Engineer  
**Status:** `[ ]` Not Started  
**Dependencies:** None (S1 complete)  
**Estimated:** 2 hours

**Deliverables:**
- [ ] `ChargersViewModel` @Observable class
- [ ] Integrate `OpenChargeMapService` and `LocationService`
- [ ] `stations: [ChargingStation]` with filtering
- [ ] `selectedConnector: ConnectorType?` filter state
- [ ] `isLoading`, `error` states
- [ ] `fetchNearbyChargers()` async method
- [ ] Offline-first: check cache, then fetch

**Files:**
- `EVCharger/ViewModels/ChargersViewModel.swift`

---

### S2-02: Implement Map View
**Role:** UI Developer  
**Status:** `[ ]` Not Started  
**Dependencies:** S2-01  
**Estimated:** 3 hours

**Deliverables:**
- [ ] `ChargerMapView` with MapKit
- [ ] Center on user location
- [ ] Charger pins with custom annotation
- [ ] Tap pin → select charger
- [ ] Region change → update visible chargers
- [ ] List toggle button overlay

**Files:**
- `EVCharger/Views/ChargerMapView.swift`
- `EVCharger/Views/Components/ChargerAnnotation.swift`

---

### S2-03: Implement List View
**Role:** UI Developer  
**Status:** `[ ]` Not Started  
**Dependencies:** S2-01  
**Estimated:** 2 hours

**Deliverables:**
- [ ] `ChargerListView` with SwiftUI List
- [ ] `ChargerRowView` reusable component
- [ ] Distance display (km/mi)
- [ ] Connector type badges
- [ ] Search bar (filter by name)
- [ ] Connector filter picker

**Files:**
- `EVCharger/Views/ChargerListView.swift`
- `EVCharger/Views/Components/ChargerRowView.swift`
- `EVCharger/Views/Components/ConnectorFilterView.swift`

---

### S2-04: Implement Detail View
**Role:** UI Developer  
**Status:** `[ ]` Not Started  
**Dependencies:** S2-01  
**Estimated:** 2 hours

**Deliverables:**
- [ ] `ChargerDetailView` sheet/navigation
- [ ] Station name, operator, address
- [ ] Connector types list with icons
- [ ] Number of charging points
- [ ] Usage cost (if available)
- [ ] Navigate button (prominent)

**Files:**
- `EVCharger/Views/ChargerDetailView.swift`
- `EVCharger/Views/Components/ConnectorBadgeView.swift`

---

### S2-05: Implement Navigation Handoff
**Role:** UI Developer  
**Status:** `[ ]` Not Started  
**Dependencies:** S2-04  
**Estimated:** 1 hour

**Deliverables:**
- [ ] `NavigationService` or helper function
- [ ] Open Apple Maps with driving directions
- [ ] Works from detail view and map callout
- [ ] Handle MapKit URL scheme

**Files:**
- `EVCharger/Services/NavigationService.swift`

---

## Success Criteria

- [ ] App launches to map view
- [ ] Map shows charger pins near user
- [ ] List view shows chargers sorted by distance
- [ ] Connector filter works on both views
- [ ] Tap charger → see detail sheet
- [ ] Tap Navigate → opens Apple Maps with directions

---

## Blockers & Notes

*Add blockers during sprint.*

---

## Completed Tasks

*Move completed tasks here with agent details.*
