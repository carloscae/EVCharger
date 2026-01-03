# EVCharger Quick Brief

> **One-sentence summary:** CarPlay-native EV charger finder using free Open Charge Map API, with one-tap navigation and connector filtering.

---

## Core Philosophy

1. **Single Moment Focus** — Find a charger now, navigate to it
2. **Infra-Free** — No backend, no user accounts, all local
3. **CarPlay-First** — iPhone companion is secondary
4. **Kill Criteria Enforcement** — No route planning, no payments, no reviews

---

## Tech Stack

| Component | Technology |
|-----------|------------|
| Platform | iOS 16+ with CarPlay |
| Language | Swift 5.9+ |
| UI | SwiftUI (iPhone), CPTemplates (CarPlay) |
| Data | SwiftData / UserDefaults |
| API | Open Charge Map (free), NREL backup |
| Networking | URLSession + Combine |

---

## Data Model

```swift
ChargingStation {
    id, name, operator, address, lat/lng,
    connectorTypes: [.ccs, .chademo, .tesla, .j1772],
    numberOfPoints, status, cost, lastUpdated
}
```

---

## Key Screens

### CarPlay
1. **Nearby List** (CPListTemplate) — Chargers sorted by distance
2. **Charger Detail** (CPPointOfInterestTemplate) — Info + Navigate button

### iPhone
1. **Settings** — Connector preference, cache status, premium

---

## Quick Commands

```bash
# Build
xcodebuild -scheme EVCharger -destination 'platform=iOS Simulator,name=iPhone 15'

# Run tests
xcodebuild test -scheme EVCharger -destination 'platform=iOS Simulator,name=iPhone 15'

# Archive for TestFlight
xcodebuild archive -scheme EVCharger -archivePath build/EVCharger.xcarchive
```

---

## File Structure

```
EVCharger/
├── EVCharger/
│   ├── App/
│   │   ├── EVChargerApp.swift
│   │   └── ContentView.swift
│   ├── CarPlay/
│   │   ├── CarPlaySceneDelegate.swift
│   │   ├── NearbyChargersTemplate.swift
│   │   └── ChargerDetailTemplate.swift
│   ├── Models/
│   │   ├── ChargingStation.swift
│   │   └── ConnectorType.swift
│   ├── Services/
│   │   ├── OpenChargeMapService.swift
│   │   └── LocationService.swift
│   ├── ViewModels/
│   │   └── ChargersViewModel.swift
│   └── Views/
│       └── SettingsView.swift
├── EVChargerTests/
└── docs/
```

---

## Constraints

- **12 items max** in CarPlay lists
- **5 templates max** depth
- **No ads** — instant rejection
- **Single category** — EV Charging only
- **Works when locked** — avoid protected data classes
