# EVCharger: Simple EV Charger Finder for CarPlay

**Version:** 1.0  
**Last Updated:** 2026-01-03  
**Product Lead:** Antigravity (AI Agent)

---

## Executive Summary

EVCharger is a **CarPlay-focused EV charging station finder** that solves a single driving moment: *"I need to find a charger nearby that matches my connector type, now."*

Unlike ABRP ($50/year subscription) or network-specific apps (ChargePoint, Electrify America), EVCharger is a **one-time purchase** that provides instant access to 200,000+ global charging locations via the free Open Charge Map API.

---

## The Problem

| Pain Point | User Quote | Current Solutions |
|------------|-----------|-------------------|
| Expensive subscriptions | "I would use the app 4 days a year max. No way am I going to pay 50 quid for the privilege." | A Better Route Planner ($50/year) |
| Network fragmentation | "I have 5 different charger apps installed" | ChargePoint, EA, EVgo, Tesla, Blink |
| Apple Maps limitations | "EV routing only works with ~3 car models" | Built-in only for select vehicles |
| CarPlay feature gaps | "Most apps don't work on CarPlay" | PlugShare has limited CarPlay |

---

## The Solution

**One app. All chargers. One tap to navigate.**

### Core Value Proposition
- 🔌 **200,000+ chargers worldwide** via Open Charge Map
- 🚗 **Dual-platform design** — full experience on both iPhone and CarPlay
- ⚡ **Connector filtering** (CCS, CHAdeMO, Tesla, J1772)
- 📍 **One-tap navigation** handoff to Apple Maps
- 💰 **One-time purchase** — no subscriptions

---

## Target Users

### Primary Persona: Weekend EV Driver
- Owns EV for 6-24 months
- Drives mostly locally, monthly road trips
- Frustrated by subscription fatigue
- Values simplicity over route planning

### Secondary Persona: Multi-EV Household
- Has 2+ EVs with different connector types
- Needs quick connector filtering
- Wants reliable offline access

---

## Feature Set

### MVP (v1.0)

| Feature | Priority | Description |
|---------|----------|-------------|
| Nearby Chargers List | P0 | Show chargers sorted by distance |
| Connector Filter | P0 | CCS, CHAdeMO, Tesla, J1772 presets |
| One-Tap Navigate | P0 | Hand off to Apple Maps |
| Charger Details | P0 | Address, connector types, operator |
| Offline Cache | P0 | 24-hour cache of locations |
| CarPlay Interface | P0 | CPListTemplate, CPPointOfInterestTemplate |
| iPhone Map View | P0 | Full map with charger pins |
| iPhone List View | P0 | Searchable/filterable charger list |
| iPhone Detail View | P0 | Charger info with navigate button |
| Settings | P1 | Connector preferences, cache management |

### Post-Launch Features

| Feature | Description |
|---------|-------------|
| Real-Time Availability | Live status from Open Charge Map |
| Favorite Chargers | Save preferred locations |
| Multiple Vehicle Profiles | Store connector prefs per vehicle |
| iOS Widget | Quick glance at nearest chargers |
| Apple Watch | Companion for real-time status |

### Non-Goals (Kill Criteria)

| Feature | Reason |
|---------|--------|
| Route Planning | Competes with ABRP — scope creep |
| Payment Integration | Requires backend — platform complexity |
| Charger Network Accounts | Platform complexity |
| User Reviews/Ratings | Requires backend |

---

## Technical Architecture

### Platform
- **Target:** iOS 16+ with CarPlay
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI (iPhone), CarPlay Framework (CPTemplates)
- **Data Persistence:** SwiftData / UserDefaults
- **Networking:** URLSession with Combine
- **Maps:** MapKit (iPhone)

### Dual-Platform Architecture

```
┌─────────────────────────────────────────┐
│           Shared Layer (~80%)           │
│  • ChargersViewModel                    │
│  • OpenChargeMapService                 │
│  • LocationService / CacheService       │
│  • Models (ChargingStation, etc.)       │
└─────────────────────────────────────────┘
           │                    │
           ▼                    ▼
┌─────────────────┐    ┌─────────────────┐
│   iPhone UI     │    │   CarPlay UI    │
│   (SwiftUI)     │    │   (CPTemplates) │
│  • MapView      │    │  • ListTemplate │
│  • ListView     │    │  • POITemplate  │
│  • DetailView   │    │                 │
└─────────────────┘    └─────────────────┘
```

### External APIs
- **Open Charge Map** (Primary): Free, 200K+ locations, full caching support
- **NREL Alt Fuel Stations** (Backup): Government API for US coverage

### Key Technical Constraints
- **CarPlay UI Limits:** Max 12 items in lists, 5 template depth
- **Single Category:** EV Charging entitlement only
- **No Ads:** Apple prohibits ads in CarPlay apps
- **Offline Required:** Must work with iPhone locked

---

## Data Model

```swift
struct ChargingStation: Identifiable, Codable {
    let id: UUID
    let name: String
    let operatorName: String?
    let address: String
    let latitude: Double
    let longitude: Double
    let connectorTypes: [ConnectorType]
    let numberOfPoints: Int
    let statusType: StatusType?
    let usageCost: String?
    let lastUpdated: Date
}

enum ConnectorType: String, Codable, CaseIterable {
    case ccs = "CCS"
    case chademo = "CHAdeMO"
    case tesla = "Tesla"
    case j1772 = "J1772"
    case type2 = "Type 2"
}

enum StatusType: String, Codable {
    case available = "Available"
    case occupied = "Occupied"
    case unknown = "Unknown"
    case outOfService = "Out of Service"
}
```

---

## Screen Flow

### iPhone
```
┌─────────────────┐
│   Map View      │ ← Full map with charger pins
│   [📍] [📍] [📍] │
│   [List Toggle] │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   List View     │ ← Searchable, filterable
│  [Charger 1]    │
│  [Charger 2]    │
│  [Filter: CCS]  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Detail View    │
│  Name, Address  │
│  Connectors     │
│  [Navigate]     │
└─────────────────┘
         │
         ▼
    Apple Maps
```

### CarPlay
```
┌─────────────────┐
│   Nearby List   │ ← CPListTemplate (max 12 items)
│  [Charger 1]    │
│  [Charger 2]    │
│  [Filter: CCS]  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Charger Detail │ ← CPPointOfInterestTemplate
│  Name, Address  │
│  Connector Info │
│  [Navigate]     │
└─────────────────┘
         │
         ▼
    Apple Maps
```

### Settings (iPhone)
```
┌─────────────────┐
│  Settings       │
├─────────────────┤
│ • My Connector  │
│ • Cache Status  │
│ • About         │
└─────────────────┘
```

---

## Monetization

| Model | Detail |
|-------|--------|
| **Price** | $3.99 one-time purchase |
| **Trial** | 7-day free trial (full features) |
| **No Subscription** | Key differentiator vs ABRP ($50/yr) |
| **No Feature Gating** | Full experience for all users |

**Rationale:** 
- $3.99 = "coffee money" impulse buy threshold
- Free trial converts better than freemium
- No paywall logic = simpler codebase
- Matches user expectation ("4 days/year usage")

---

## Success Metrics

| Metric | Target | Rationale |
|--------|--------|-----------|
| App Store Rating | 4.5+ stars | Quality indicator |
| Trial → Paid Conversion | 30%+ | Value validation |
| CarPlay Session Length | <30 sec | Speed of task completion |
| Cache Hit Rate | 90%+ | Offline reliability |

---

## Competitive Analysis

| App | CarPlay | Price | Charger Data | Route Planning |
|-----|---------|-------|--------------|----------------|
| **EVCharger (Ours)** | ✅ Native | $3.99 once | Open Charge Map | ❌ |
| A Better Route Planner | ✅ | $50/year | Multiple sources | ✅ Full |
| PlugShare | ⚠️ Limited | Free | Crowdsourced | ❌ |
| ChargePoint | ⚠️ Network only | Free | ChargePoint only | ❌ |
| Apple Maps | ✅ Built-in | Free | Limited | ⚠️ Select cars |

**Our Advantage:** Simple, cheap, network-agnostic, CarPlay-native, no subscription.

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| CarPlay entitlement denial | Low | High | Apply early, follow guidelines exactly |
| Open Charge Map downtime | Low | Medium | NREL backup, aggressive caching |
| Apple Maps integration issues | Low | Medium | Test on multiple iOS versions |
| Feature creep pressure | Medium | Medium | Strict kill criteria enforcement |

---

## Appendix: CarPlay Requirements

### Apple's Constraints
- UI: Template-only (CPListTemplate, CPPointOfInterestTemplate, CPGridTemplate)
- Depth: Max 5 templates deep
- Lists: Max 12 items
- Ads: Explicitly prohibited
- Category: Single entitlement (EV Charging)

### Entitlement Process
1. Apply at developer.apple.com/carplay
2. Select "EV Charging" category
3. Submit app description + screenshots
4. Wait 3-14 days for approval
