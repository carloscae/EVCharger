# Sprint 3: CarPlay

**Start Date:** 2026-01-04  
**Target Duration:** ~4 days  
**Goal:** Complete CarPlay experience (reuses shared layer from Sprint 2)

---

## Role Summary

| Role | Tasks |
|------|-------|
| **UI Developer** | S3-01 (CarPlay Scene), S3-02 (Nearby List), S3-03 (Detail Template), S3-04 (Filter) |
| **Platform Specialist** | S3-05 (Integration Testing) |

---

## Tasks

### S3-01: Implement CarPlay Scene Delegate
**Role:** UI Developer  
**Status:** `[ ]` Not Started  
**Dependencies:** None (Sprint 2 complete)  
**Estimated:** 1.5 hours

**Deliverables:**
- [ ] Update `CarPlaySceneDelegate` with full lifecycle
- [ ] Connect to shared `ChargersViewModel`
- [ ] Set up root `CPTabBarTemplate` or `CPListTemplate`
- [ ] Handle CarPlay connect/disconnect events
- [ ] Trigger location + charger fetch on connect

**Files:**
- `EVCharger/CarPlay/CarPlaySceneDelegate.swift`

---

### S3-02: Implement Nearby Chargers List
**Role:** UI Developer  
**Status:** `[ ]` Not Started  
**Dependencies:** S3-01  
**Estimated:** 2 hours

**Deliverables:**
- [ ] `CPListTemplate` showing nearby chargers
- [ ] `CPListItem` with charger name, distance, connector icons
- [ ] Max 12 items (CarPlay limit)
- [ ] Sorted by distance
- [ ] Item tap → push detail template

**Files:**
- `EVCharger/CarPlay/NearbyChargersTemplate.swift`
- `EVCharger/CarPlay/Helpers/CPListItemBuilder.swift`

---

### S3-03: Implement Charger Detail Template
**Role:** UI Developer  
**Status:** `[ ]` Not Started  
**Dependencies:** S3-02  
**Estimated:** 2 hours

**Deliverables:**
- [ ] `CPPointOfInterestTemplate` or `CPInformationTemplate`
- [ ] Station name, address, operator
- [ ] Connector types display
- [ ] Navigate button → Apple Maps handoff
- [ ] Back navigation

**Files:**
- `EVCharger/CarPlay/ChargerDetailTemplate.swift`

---

### S3-04: Implement Connector Filter
**Role:** UI Developer  
**Status:** `[ ]` Not Started  
**Dependencies:** S3-02  
**Estimated:** 1.5 hours

**Deliverables:**
- [ ] Filter button in list header or as tab
- [ ] `CPListTemplate` or `CPGridTemplate` for filter options
- [ ] CCS, CHAdeMO, Tesla, J1772, All options
- [ ] Persist selection to `UserPreferences`
- [ ] Refresh list on filter change

**Files:**
- `EVCharger/CarPlay/ConnectorFilterTemplate.swift`

---

### S3-05: CarPlay Integration Testing
**Role:** Platform Specialist  
**Status:** `[ ]` Not Started  
**Dependencies:** S3-01, S3-02, S3-03, S3-04  
**Estimated:** 1 hour

**Deliverables:**
- [ ] Test in CarPlay Simulator
- [ ] Verify list displays correctly
- [ ] Verify detail view shows all info
- [ ] Verify navigation handoff works
- [ ] Verify filter persists across sessions
- [ ] Test offline mode with cached data

**Files:**
- `EVChargerTests/CarPlayIntegrationTests.swift` (if applicable)

**Note:** Real device testing requires CarPlay entitlement (pending).

---

## Success Criteria

- [ ] CarPlay app launches with charger list
- [ ] List shows max 12 chargers sorted by distance
- [ ] Tap charger → see detail template
- [ ] Tap Navigate → opens Apple Maps
- [ ] Connector filter works and persists
- [ ] Uses same ViewModel as iPhone app

---

## Blockers & Notes

- **CarPlay entitlement pending** — Can test in simulator, but device testing requires Apple approval (S1-05)

---

## Completed Tasks

*Move completed tasks here with agent details.*
