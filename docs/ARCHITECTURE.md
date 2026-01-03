# EVCharger Technical Architecture

**Last Updated:** 2026-01-03  
**Maintainer:** Product Lead

---

## Tech Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Platform | iOS | 17.0+ |
| Language | Swift | 5.9+ |
| iPhone UI | SwiftUI | iOS 17+ |
| CarPlay UI | CarPlay Framework | CPTemplates |
| Data Layer | SwiftData | iOS 17+ |
| Networking | URLSession + Combine | Native |
| Location | CoreLocation | Native |
| Maps Integration | MapKit | Native |

---

## Directory Structure

```
EVCharger/
├── EVCharger/                      # Main app target
│   ├── App/
│   │   ├── EVChargerApp.swift      # App entry point
│   │   ├── ContentView.swift       # Root view
│   │   └── Info.plist              # App configuration
│   │
│   ├── CarPlay/                    # CarPlay interface
│   │   ├── CarPlaySceneDelegate.swift    # CarPlay lifecycle
│   │   ├── NearbyChargersTemplate.swift  # Main list view
│   │   └── ChargerDetailTemplate.swift   # Detail + navigate
│   │
│   ├── Models/                     # Data models
│   │   ├── ChargingStation.swift   # Core entity
│   │   ├── ConnectorType.swift     # Connector enum
│   │   └── UserPreferences.swift   # Settings model
│   │
│   ├── Services/                   # Business logic
│   │   ├── OpenChargeMapService.swift   # API client
│   │   ├── LocationService.swift        # GPS tracking
│   │   ├── CacheService.swift           # Local caching
│   │   └── NRELService.swift            # Backup API
│   │
│   ├── ViewModels/                 # State management
│   │   ├── ChargersViewModel.swift      # Main data flow
│   │   └── SettingsViewModel.swift      # Preferences
│   │
│   └── Views/                      # SwiftUI views
│       ├── SettingsView.swift           # Settings screen
│       ├── ConnectorPickerView.swift    # Connector selector
│       └── Components/                   # Reusable UI
│
├── EVChargerTests/                 # Unit tests
│   ├── OpenChargeMapServiceTests.swift
│   ├── ChargingStationTests.swift
│   └── CacheServiceTests.swift
│
├── EVChargerUITests/               # UI tests
│   └── SettingsFlowTests.swift
│
├── docs/                           # Documentation
│   ├── ONBOARDING.md
│   ├── ARCHITECTURE.md
│   ├── EVCHARGER_product_spec.md
│   ├── EVCHARGER_brief.md
│   └── sprints/
│
└── .agent/                         # Multi-agent system
    ├── workflows/
    ├── active/
    └── stats/
```

---

## State Management

### Pattern: Observable ViewModel

```swift
@Observable
class ChargersViewModel {
    var stations: [ChargingStation] = []
    var selectedConnector: ConnectorType?
    var isLoading = false
    var error: Error?
    
    private let apiService: OpenChargeMapService
    private let locationService: LocationService
    private let cacheService: CacheService
    
    func fetchNearbyChargers() async { ... }
    func filterByConnector(_ type: ConnectorType) { ... }
}
```

### Data Flow
```
User Location → API Request → Cache → ViewModel → UI
                    ↓
              (Offline fallback)
                    ↓
              Cached Data → ViewModel → UI
```

---

## CarPlay Architecture

### Scene Setup

```swift
// Info.plist
UIApplicationSceneManifest:
  CPTemplateApplicationSceneSessionRoleApplication:
    - UISceneDelegateClassName: CarPlaySceneDelegate
    - UISceneConfigurationName: CarPlayConfiguration
```

### Template Hierarchy

```
CPTabBarTemplate (root)
├── CPListTemplate (Nearby)        // Max 12 items
│   └── CPListItem (Charger row)
│       └── CPPointOfInterestTemplate (Detail)
│           └── Navigation button → Apple Maps
└── CPListTemplate (Settings)      // Connector filter
```

### CarPlay Constraints

| Constraint | Value | Impact |
|------------|-------|--------|
| List items | 12 max | Pagination not supported |
| Template depth | 5 max | Keep flows shallow |
| Grid items | 8 max | Limited grid use |
| Driving Task | 2 templates | N/A (we use EV Charging) |

---

## Networking Layer

### Open Charge Map API

```swift
struct OpenChargeMapService {
    private let baseURL = "https://api.openchargemap.io/v3"
    
    func fetchChargers(
        latitude: Double,
        longitude: Double,
        distance: Int = 50,  // km
        maxResults: Int = 12
    ) async throws -> [ChargingStation]
}
```

### Request Pattern
```
GET /poi?latitude={lat}&longitude={lng}&distance={km}&maxresults={n}&compact=true
```

### Caching Strategy

**Approach: Offline-First**

Faster launch, better for spotty cellular in parking garages.

| Data | Cache Duration | Storage | Behavior |
|------|----------------|---------|----------|
| Station locations | 24 hours | SwiftData | Use cache first, refresh in background |
| User preferences | Indefinite | UserDefaults | Always local |
| Real-time status | No cache | Memory only | Fetch on-demand |

---

## Navigation Integration

### Apple Maps Handoff

```swift
func navigateToStation(_ station: ChargingStation) {
    let coordinate = CLLocationCoordinate2D(
        latitude: station.latitude,
        longitude: station.longitude
    )
    let placemark = MKPlacemark(coordinate: coordinate)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = station.name
    mapItem.openInMaps(launchOptions: [
        MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
    ])
}
```

---

## Purchase Flow (StoreKit 2)

**Model:** $3.99 one-time with 7-day free trial

```swift
// Product ID
let productID = "com.evcharger.fullapp"

// Trial configuration in App Store Connect
// - Introductory offer: 7-day free trial
// - Then: $3.99 one-time purchase
```

No feature gating — all users get full experience.

---

## Build & Deploy

### Xcode Configuration

| Scheme | Purpose |
|--------|---------|
| EVCharger | Development |
| EVCharger-Release | TestFlight/App Store |

### Build Commands

```bash
# Debug build
xcodebuild -scheme EVCharger \
  -destination 'platform=iOS Simulator,name=iPhone 15'

# Run tests
xcodebuild test -scheme EVCharger \
  -destination 'platform=iOS Simulator,name=iPhone 15'

# Archive
xcodebuild archive -scheme EVCharger \
  -archivePath build/EVCharger.xcarchive
```

---

## Key Design Decisions

### 1. iOS 17+ Target
**Rationale:** SwiftData is much cleaner than Core Data. EV owners tend to have newer phones.

### 2. SwiftData over Core Data
**Rationale:** Simpler API, Swift-native, sufficient for our caching needs.

### 3. Offline-First Caching
**Rationale:** Faster launch, works in parking garages with poor signal.

### 4. Open Charge Map as Primary
**Rationale:** Free, global coverage, full caching rights. NREL only covers US.

### 5. Paid Upfront with Trial
**Rationale:** Users complained about subscription fatigue. $3.99 with 7-day trial converts better than freemium.

---

## UI Decisions

### iPhone Default View
**Decision:** Map default with prominent list toggle
**Rationale:** More engaging first impression, visual discovery.

### Design System
| Aspect | Value |
|--------|-------|
| Dark Mode | Both light and dark supported |
| Brand Color | Green #34C759 (SF Symbol green) |
| Style | Minimal, Apple-like |

---

## Security Considerations

- **No user accounts** — no PII storage
- **Location data** — used only for charger lookup, not stored server-side
- **API keys** — Open Charge Map is key-optional (rate limited)
- **iPhone locked** — app works without unlocking (avoid Data Protection Class A/B)
