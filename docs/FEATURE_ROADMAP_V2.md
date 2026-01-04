# EVCharger Feature Roadmap v2.4

## Sprint Structure (Revised)

| Sprint | Focus |
|--------|-------|
| 5 | Favorites, Recents, Sorting |
| 6 | Widget, Siri, Multi-Connector UI |
| 7 | Vehicle Settings, Route Planner Core |
| 8 | Smart Features, Route Overlay |
| 9 | CarPlay Routes |
| 10 | **Release Prep** |

---

## Features

### Sprint 5: Quick Wins
- [ ] Favorites (star toggle)
- [ ] Recents (last 10 detail views)
- [ ] Smart Sorting (distance/speed/availability)

### Sprint 6: Platform Integration
- [ ] Lock Screen Widget
- [ ] Siri: "Find charger" + "Navigate to charger"
- [ ] **Multi-connector selection UI in Settings**

### Sprint 7: Route Planner Core
- [ ] Bundle OpenEV Data JSON
- [ ] Vehicle Settings (pre-fill + edit + iCloud)
- [ ] Basic route calculation
- [ ] Route alternatives display

### Sprint 8: Smart Features
- [ ] Fast charger preference
- [ ] Amenity search (MapKit)
- [ ] WeatherKit integration
- [ ] Route overlay + Skip/Stop Now

### Sprint 9: CarPlay Routes
- [ ] Apply for Navigation entitlement
- [ ] CarPlay route view
- [ ] Segment navigation

### Sprint 10: Release Prep
- [ ] App Icons
- [ ] App Store Screenshots
- [ ] Metadata & Keywords
- [ ] Final QA

---

## Key UX

### Route Overlay
```
┌─────────────────────────────────────┐
│ 📍 Next: Kettleman City             │
│    Tesla SC • 45mi • ~25min charge  │
│  [Stop Now]        [Skip Stop]      │
└─────────────────────────────────────┘
```

### Stop Now
→ List of closest chargers along route

### Skip Stop
→ Replace with different charger OR skip entirely

---

## Settings

| Setting | UI |
|---------|-----|
| My Vehicle | Picker + edit fields |
| Preferred Connectors | **Multi-select** |
| Fast Charger Pref | Toggle |
| Amenity Pref | Toggle |
| Weather | Toggle (AUTO/OFF) |
| Safety Buffer | Slider |
