# Sprint 4: Polish & Premium

**Start Date:** 2026-01-04  
**Target Duration:** ~4 days  
**Goal:** Production-ready app with caching, offline mode, and purchase flow

---

## Role Summary

| Role | Tasks |
|------|-------|
| **State Engineer** | S4-01 (Caching), S4-02 (Offline Mode) |
| **UI Developer** | S4-03 (Settings Screen) |
| **Platform Specialist** | S4-04 (StoreKit), S4-05 (Polish & QA) |

---

## Tasks

### S4-01: Implement SwiftData Caching
**Role:** State Engineer  
**Status:** `[ ]` Not Started  
**Dependencies:** None (Sprint 3 complete)  
**Estimated:** 2 hours

**Deliverables:**
- [ ] `CacheService` using SwiftData
- [ ] Store fetched `ChargingStation` data
- [ ] 24-hour cache expiration logic
- [ ] Cache invalidation on manual refresh
- [ ] Background refresh on app launch

**Files:**
- `EVCharger/Services/CacheService.swift`
- `EVCharger/Models/CachedStation.swift` (if needed)

---

### S4-02: Implement Offline Mode
**Role:** State Engineer  
**Status:** `[ ]` Not Started  
**Dependencies:** S4-01  
**Estimated:** 1.5 hours

**Deliverables:**
- [ ] Detect network availability
- [ ] Fall back to cached data when offline
- [ ] Show "Offline" indicator in UI
- [ ] Graceful error handling
- [ ] Auto-refresh when back online

**Files:**
- `EVCharger/Services/NetworkMonitor.swift`
- Updates to `ChargersViewModel.swift`

---

### S4-03: Implement Settings Screen
**Role:** UI Developer  
**Status:** `[ ]` Not Started  
**Dependencies:** None  
**Estimated:** 2 hours

**Deliverables:**
- [ ] `SettingsView` with navigation
- [ ] Default connector preference selector
- [ ] Cache status display (last updated, size)
- [ ] Clear cache button
- [ ] About section (version, credits)
- [ ] Link to App Store review

**Files:**
- `EVCharger/Views/SettingsView.swift`
- `EVCharger/Views/Components/CacheStatusView.swift`

---

### S4-04: Implement StoreKit Purchase Flow
**Role:** Platform Specialist  
**Status:** `[ ]` Not Started  
**Dependencies:** None  
**Estimated:** 2 hours

**Deliverables:**
- [ ] Configure product in App Store Connect
- [ ] `StoreManager` using StoreKit 2
- [ ] 7-day free trial configuration
- [ ] Purchase restoration
- [ ] Receipt validation (local)
- [ ] Handle trial expiration gracefully

**Files:**
- `EVCharger/Services/StoreManager.swift`
- `EVCharger/Views/Components/TrialBannerView.swift`

**Note:** Product ID: `com.evcharger.fullapp` ($3.99)

---

### S4-05: Polish & QA
**Role:** Platform Specialist  
**Status:** `[ ]` Not Started  
**Dependencies:** S4-01, S4-02, S4-03, S4-04  
**Estimated:** 2 hours

**Deliverables:**
- [ ] Test all iPhone flows end-to-end
- [ ] Test all CarPlay flows end-to-end
- [ ] Verify offline mode works correctly
- [ ] Verify purchase flow works
- [ ] Fix any UI polish issues
- [ ] Performance profiling (memory, battery)
- [ ] Accessibility audit (VoiceOver)

**Files:**
- Bug fixes across codebase

---

## Success Criteria

- [ ] App works fully offline with cached data
- [ ] 24-hour cache auto-refreshes
- [ ] Settings screen complete and functional
- [ ] Purchase flow works (StoreKit sandbox)
- [ ] No critical bugs in iPhone or CarPlay
- [ ] App ready for TestFlight

---

## Blockers & Notes

- StoreKit testing requires App Store Connect setup
- Real purchase testing in sandbox mode

---

## Completed Tasks

*Move completed tasks here with agent details.*
