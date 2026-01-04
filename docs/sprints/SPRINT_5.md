# Sprint 5: Quick Wins

**Start Date:** 2026-01-04  
**Target Duration:** ~2 days  
**Goal:** User engagement features

---

## Tasks

### S5-01: Favorites Feature
**Status:** `[x]` Complete  
**Estimated:** 2 hours

**Deliverables:**
- [x] Star toggle button in ChargerDetailView
- [x] SwiftData `FavoriteStation` model
- [x] Favorites persistence working

**Files:**
- `EVCharger/Models/FavoriteStation.swift`
- `EVCharger/Views/ChargerDetailView.swift`
- `EVCharger/Views/ChargerListView.swift`
- `EVCharger/CarPlay/CarPlaySceneDelegate.swift`

---

### S5-02: Recents Feature
**Status:** `[x]` Complete  
**Estimated:** 2 hours

**Deliverables:**
- [x] SwiftData `RecentStation` model
- [x] Track detail view opens
- [x] Last 10 entries, auto-prune older

**Files:**
- `EVCharger/Models/RecentStation.swift`
- `EVCharger/Views/ChargerDetailView.swift`
- `EVCharger/Views/ChargerListView.swift`

---

### S5-03: Smart Sorting
**Status:** `[x]` Complete  
**Estimated:** 1 hour

**Deliverables:**
- [x] SortOption enum (distance/speed/availability)
- [x] Menu picker in ChargerListView header
- [x] Sorting logic in ViewModel

**Files:**
- `EVCharger/Views/ChargerListView.swift`
- `EVCharger/ViewModels/ChargersViewModel.swift`
- `EVCharger/CarPlay/CarPlaySceneDelegate.swift`

---

## Success Criteria

- [ ] Can star/unstar chargers, persists across launches
- [ ] Recent chargers shown (last 10 detail views)
- [ ] Can sort by distance, speed, or availability
- [ ] All features work on iPhone and CarPlay

---

## Notes

- Favorites and Recents use SwiftData for persistence
- Sorting applies to both nearby and search results
