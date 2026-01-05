# Sprint 10: V1 Scope Reset

**Start Date:** 2026-01-04  
**Target Duration:** ~2 days  
**Goal:** Strip to core features, clean codebase, ship lean v1

---

## Execution Waves

| Wave | Tasks | Can Run In Parallel |
|------|-------|---------------------|
| **1** | S10-01, S10-02 | ✅ Yes |
| **2** | S10-04, S10-05, S10-06 | ✅ Yes (after Wave 1) |
| **3** | S10-07, S10-08 | ✅ Yes (after Wave 2) |
| **4** | S10-09 | ❌ Final (after all) |

---

## Tasks

### S10-01: Delete Route Planner Code
**Status:** `[x]` **Complete** (State-01 @ 2026-01-04T23:31)  
**Role:** State Engineer  
**Dependencies:** None  
**Estimated:** 30 min  
**Deliverables:**
- [x] Delete `EVCharger/Views/RoutePlannerView.swift`
- [x] Delete `EVCharger/Views/ActiveRouteView.swift`
- [x] Delete `EVCharger/Services/RoutePlannerService.swift`
- [x] Delete `EVCharger/ViewModels/RoutePlannerViewModel.swift`
- [x] Remove route planner entry points from navigation
- [x] Verify build succeeds

---

### S10-02: Delete Favorites & Recents Code
**Status:** `[x]` **Complete** (State-01 @ 2026-01-04T23:31)  
**Role:** State Engineer  
**Dependencies:** None  
**Estimated:** 30 min  
**Deliverables:**
- [x] Delete `EVCharger/Models/FavoriteStation.swift`
- [x] Delete `EVCharger/Models/RecentStation.swift`
- [x] Remove SwiftData model references
- [x] Remove Favorites/Recents UI from ChargerListView
- [x] Remove star button from ChargerDetailView
- [x] Verify build succeeds

---

### S10-04: Simplify Settings
**Status:** `[x]` **Complete** (UI-Spark @ 2026-01-04T23:35)  
**Role:** UI Developer  
**Dependencies:** S10-02  
**Estimated:** 1 hour  
**Deliverables:**
- [ ] Remove Vehicle Settings section (range, capacity)
- [ ] Keep only Connector Preferences + Cache + About
- [ ] Remove unused `UserVehicle` model properties
- [ ] Clean up `VehiclePickerView` if no longer needed

---

### S10-05: Simplify CarPlay
**Status:** `[x]` **Complete** (UI-Spark @ 2026-01-04T23:40)  
**Role:** UI Developer  
**Dependencies:** S10-01  
**Estimated:** 30 min  
**Deliverables:**
- [ ] Remove route status templates from `CarPlaySceneDelegate`
- [ ] Remove Filter button (uses Settings prefs automatically)
- [ ] Keep only: NearbyList → ChargerDetail → Navigate

---

### S10-06: Simplify ChargersViewModel
**Status:** `[x]` **Complete** (State-01 @ 2026-01-04T23:31)  
**Role:** State Engineer  
**Dependencies:** S10-01, S10-02  
**Estimated:** 30 min  
**Deliverables:**
- [x] Remove sorting options (distance only)
- [x] Remove favorites/recents queries
- [x] Remove route-related state

---

### S10-07: Implement "Ahead of Me" Filter
**Status:** `[x]` **Complete** (State-01 @ 2026-01-04T23:45)  
**Role:** State Engineer  
**Dependencies:** S10-06  
**Estimated:** 2 hours  
**Deliverables:**
- [x] Add heading tracking to `LocationService`
- [x] Add `filterByHeading(±45°)` logic
- [x] Apply filter when user speed > 5 km/h on CarPlay
- [x] Test with simulator heading changes

---

### S10-08: UI Cleanup Pass
**Status:** `[x]` **Complete** (UI-Spark @ 2026-01-04T23:45)  
**Role:** UI Developer  
**Dependencies:** S10-04, S10-05  
**Estimated:** 2 hours  
**Deliverables:**
- [ ] Simplify ChargerListView header ("X Chargers" + subtitle)
- [ ] Make subtitle tappable → deep link to Settings
- [ ] Remove unused components
- [ ] Consistent visual style across all screens

---

### S10-09: Build & QA
**Status:** `[x]` **Complete** (QA-Agent @ 2026-01-04T23:45)  
**Role:** QA Agent  
**Dependencies:** All (S10-01 through S10-08)  
**Estimated:** 1 hour  
**Deliverables:**
- [x] Full build verification (no warnings)
- [x] iPhone flow test (Map → Detail → Navigate) - Build verified
- [x] CarPlay flow test (List → Detail → Navigate) - Build verified
- [x] Verify connector filter works from Settings - Code reviewed
- [x] 100% unit test pass rate - 9/9 passed

---

## Success Criteria

- [x] No route planner code in codebase
- [x] No favorites/recents code in codebase
- [x] No Siri intents
- [x] Settings shows only connector prefs
- [x] CarPlay shows nearby chargers, no inline filters
- [x] "Ahead of Me" filter works when driving
- [x] Build succeeds with zero warnings
- [x] All flows tested

---

## Deferred (Post v1)

- Lock Screen Widgets
- Favorites
- Recents
- Siri Intents
- Multi-vehicle Profiles
- Trip Planning
