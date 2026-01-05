# Agent Onboarding Guide

Welcome to EVCharger! This doc gets you productive in 5 minutes.

---

## What is EVCharger?

**CarPlay-native EV charger finder** — find nearby chargers, filter by connector, one-tap navigate.

---

## Non-Negotiables

1. ❌ **No payments** — no backend complexity
2. ❌ **No user accounts** — local storage only
3. ❌ **No ads** — Apple prohibits in CarPlay
4. ✅ **CarPlay-first** — iPhone is secondary
5. ✅ **Swift-native only** — Objective-C code (`@objc`, NSObject, etc.) requires explicit user authorization

---

## Tech Stack

| What | Tech |
|------|------|
| Platform | iOS 17+ CarPlay |
| Language | Swift 5.9+ |
| iPhone UI | SwiftUI |
| CarPlay UI | CPTemplates |
| Data | SwiftData |
| API | Open Charge Map (free) |
| Maps | MapKit (Directions, Polylines) |

---

## Key Entities

```swift
ChargingStation  // Core model: id, name, address, connectors, location
ConnectorType    // Enum: CCS, CHAdeMO, Tesla, J1772, Type2
StatusType       // Enum: Available, Occupied, Unknown, OutOfService
PlannedRoute     // Route with charging stops
UserVehicle      // Vehicle settings for range calculation
```

---

## Screen Map

```
CarPlay:
  NearbyList → ChargerDetail → Apple Maps
  RouteStatus → NextStop → Apple Maps (multi-stop handoff)

iPhone:
  Map → ChargerDetail → Navigate
  RoutePlanner → MapPreview → Navigate (in-app + handoff)
  Settings (connector prefs, vehicle, cache)
```

---

## File Locations

| Component | Path |
|-----------|------|
| CarPlay Logic | `EVCharger/CarPlay/` |
| Models | `EVCharger/Models/` |
| API Service | `EVCharger/Services/OpenChargeMapService.swift` |
| Settings UI | `EVCharger/Views/SettingsView.swift` |

---

## Quick Commands

```bash
# Build for simulator
xcodebuild -scheme EVCharger -destination 'platform=iOS Simulator,name=iPhone 15'

# Run tests
xcodebuild test -scheme EVCharger -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## Getting Started

1. Read this doc ✓
2. Check `.agent/active/project_state.md` for current sprint
3. Check `.agent/active/claims.md` before claiming a task
4. Run `/onboard` workflow to claim your first task

---

## Need More?

- **Full Spec:** `docs/EVCHARGER_product_spec.md`
- **Architecture:** `docs/ARCHITECTURE.md`
- **Active Sprint:** See `.agent/active/project_state.md`
