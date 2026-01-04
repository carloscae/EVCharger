# Agent Onboarding Guide

Welcome to EVCharger! This doc gets you productive in 5 minutes.

---

## What is EVCharger?

**CarPlay-native EV charger finder** — find nearby chargers, filter by connector, one-tap navigate.

---

## Non-Negotiables

1. ❌ **No route planning** — we're not ABRP
2. ❌ **No payments** — no backend complexity
3. ❌ **No user accounts** — local storage only
4. ❌ **No ads** — Apple prohibits in CarPlay
5. ✅ **CarPlay-first** — iPhone is secondary
6. ✅ **Swift-native only** — Objective-C code (`@objc`, NSObject, etc.) requires explicit user authorization

---

## Tech Stack

| What | Tech |
|------|------|
| Platform | iOS 16+ CarPlay |
| Language | Swift 5.9+ |
| iPhone UI | SwiftUI |
| CarPlay UI | CPTemplates |
| Data | SwiftData |
| API | Open Charge Map (free) |

---

## Key Entities

```swift
ChargingStation  // Core model: id, name, address, connectors, location
ConnectorType    // Enum: CCS, CHAdeMO, Tesla, J1772, Type2
StatusType       // Enum: Available, Occupied, Unknown, OutOfService
```

---

## Screen Map

```
CarPlay:
  NearbyList → ChargerDetail → Apple Maps

iPhone:
  Settings (connector prefs, cache, premium)
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
2. Check `docs/sprints/SPRINT_1.md` for current sprint
3. Check `.agent/active/claims.md` before claiming a task
4. Run `/onboard` workflow to claim your first task

---

## Need More?

- **Full Spec:** `docs/EVCHARGER_product_spec.md`
- **Architecture:** `docs/ARCHITECTURE.md`
- **Active Sprint:** `docs/sprints/SPRINT_1.md`
