# Sprint 11: UI Polish & Fixes

**Start Date:** 2026-01-04  
**Target Duration:** ~2 days  
**Goal:** Fix UI issues and implement proper Favorites/Recents UX

---

## Issues to Address

### 1. Route Planner Redesign
**Status:** `[ ]` Pending Discussion  
**Priority:** High

**Current Issues:**
- User feedback: "I don't like this at all"
- Needs design discussion before implementation

**Questions for User:**
1. What specifically doesn't work for you? (UI layout, flow, features?)
2. Do you want a map-based route entry or form-based?
3. Should it be a full-screen view or overlay/sheet?
4. Which existing app's route planner UX do you like? (Google Maps, Apple Maps, A Better Route Planner, etc.)

---

### 2. Favorites: Add Star Button + Horizontal Grid
**Status:** `[x]` Complete  
**Priority:** High

**Current Problem:**
- No visible way to star/favorite a charger
- Favorites section in list not visible/appearing

**Solution:**
- [ ] Add star button to ChargerDetailView header
- [ ] Add star button to ChargerRowView (swipe action or icon)
- [ ] Replace list section with horizontal scrolling icon grid
- [ ] Grid shows above main charger list
- [ ] Each grid item: station icon + short name + distance

**Design Reference:**
```
┌─────────────────────────────────────┐
│ ⭐ Favorites                    See All │
│ ┌────┐ ┌────┐ ┌────┐ ┌────┐         │
│ │ ⚡ │ │ ⚡ │ │ ⚡ │ │ ⚡ │  →      │
│ │Tesla│ │Shell│ │BP  │ │Ionity│       │
│ │0.3km│ │1.2km│ │2.1km│ │3.4km│       │
│ └────┘ └────┘ └────┘ └────┘         │
└─────────────────────────────────────┘
```

---

### 3. Recents: Horizontal Grid (Same as Favorites)
**Status:** `[x]` Complete  
**Priority:** High

**Current Problem:**
- Recents section not appearing in UI
- Tracking works but display missing

**Solution:**
- [ ] Horizontal scrolling grid below Favorites
- [ ] Same design pattern as Favorites
- [ ] Shows last 5-8 viewed stations
- [ ] Clock icon instead of star

**Design Reference:**
```
┌─────────────────────────────────────┐
│ 🕐 Recent                       Clear │
│ ┌────┐ ┌────┐ ┌────┐ ┌────┐         │
│ │ ⚡ │ │ ⚡ │ │ ⚡ │ │ ⚡ │  →      │
│ │Last1│ │Last2│ │Last3│ │Last4│       │
│ │0.8km│ │1.5km│ │2.0km│ │4.1km│       │
│ └────┘ └────┘ └────┘ └────┘         │
└─────────────────────────────────────┘
```

---

## Implementation Order

1. **Task 2**: Favorites (add star + horizontal grid)
2. **Task 3**: Recents (same grid pattern)
3. **Task 1**: Route Planner (after design discussion)

---

## Success Criteria

- [ ] Can star/unstar chargers from detail view
- [ ] Favorites appear as horizontal grid above list
- [ ] Recents appear as horizontal grid below favorites
- [ ] Route Planner redesigned per user feedback
