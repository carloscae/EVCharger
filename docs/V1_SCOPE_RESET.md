# AllCharge v1 Scope Reset

**Date:** 2026-01-04  
**Status:** Draft for Review

---

## Vision

**One job:** *Find me a charger I can use, right now.*

---

## Core Use Cases

| # | Use Case | Context | Platform |
|---|----------|---------|----------|
| **1** | Stationary → Nearest Charger | At home, hotel, shopping | iPhone |
| **2** | Driving → Charger Ahead | En route, highway | CarPlay |

---

## v1 Features (Keep)

| Feature | iPhone | CarPlay | Notes |
|---------|--------|---------|-------|
| **Map View** | ✅ | — | Charger pins, centered on user |
| **List View** | ✅ | ✅ | Sorted by distance |
| **Charger Detail** | ✅ | ✅ | Name, address, connectors, operator |
| **Navigate (Apple Maps)** | ✅ | ✅ | One-tap handoff |
| **Connector Filter** | ✅ (Settings) | ✅ (from Settings) | Set once, applied everywhere |
| **"Ahead of Me" Filter** | — | ✅ | Filter by heading (±45°) |
| **Offline Cache** | ✅ | ✅ | 24-hour cache |
| **Settings** | ✅ | — | Connector prefs, cache |

---

## v1 Features (Cut)

| Feature | Reason |
|---------|--------|
| **Route Planner** | Too complex, not core |
| **Trip Planning** | Requires text input (impossible on CarPlay) |
| **Favorites** | Nice-to-have, not solving core problem |
| **Recents** | Nice-to-have, not solving core problem |
| **Siri Intents** | Adds complexity, low discoverability |
| **Widgets** | Nice-to-have, defer post-launch |
| **Vehicle Settings** (range, capacity) | Only needed for route planning |
| **Smart Features** (amenities, weather) | Scope creep |
| **Sorting Options** (speed, availability) | Distance is king |

---

## Code Removal Plan

### Files to Delete
```
EVCharger/Views/RoutePlannerView.swift
EVCharger/Views/ActiveRouteView.swift
EVCharger/Services/RoutePlannerService.swift
EVCharger/ViewModels/RoutePlannerViewModel.swift
EVCharger/Models/FavoriteStation.swift
EVCharger/Models/RecentStation.swift
EVCharger/Intents/ (entire folder)
```

### Files to Simplify
| File | Change |
|------|--------|
| `SettingsView.swift` | Remove vehicle range/capacity, keep only connector prefs |
| `CarPlaySceneDelegate.swift` | Remove route status templates |
| `ChargersViewModel.swift` | Remove sorting options, remove favorites/recents queries |

---

## UI Simplification

### iPhone
```
┌─────────────────────────────────┐
│ 12 Chargers                     │
│ Showing: CCS, Tesla ›           │  ← Tappable → Settings
├─────────────────────────────────┤
│ [Map with pins]                 │
│                                 │
│ [Charger List below]            │
└─────────────────────────────────┘
```

### CarPlay
```
┌─────────────────────────────────┐
│ Nearby Chargers                 │
├─────────────────────────────────┤
│ Tesla Supercharger - 0.8 km     │
│ Shell Recharge - 1.2 km         │
│ BP Pulse - 2.1 km               │
│ ...                             │
└─────────────────────────────────┘
```
- No inline filter controls
- Uses connector prefs from iPhone Settings
- Filters by heading when driving (ahead of me)

---

## New Feature: "Ahead of Me" (CarPlay)

When user is moving (speed > 5 km/h), filter chargers to ±45° of current heading.

```swift
// Pseudocode
let userHeading = locationManager.heading.trueHeading
let chargerBearing = bearing(from: userLocation, to: chargerLocation)
let angleDiff = abs(userHeading - chargerBearing)
let isAhead = angleDiff <= 45 || angleDiff >= 315
```

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Time to first charger shown | < 2 seconds |
| CarPlay interaction to navigate | < 3 taps |
| App Store rating | 4.5+ stars |

---

## Next Steps

1. **Approve this scope** (you are here)
2. **Remove cut features** from codebase
3. **Implement "Ahead of Me"** filter
4. **UI cleanup pass** — simplify screens per mockups above
5. **QA / Polish**
6. **Release Prep** (icons, screenshots, metadata)
