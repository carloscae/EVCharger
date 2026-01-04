# Sprint 6: Platform Integration

**Start Date:** 2026-01-04  
**Target Duration:** ~2 days  
**Goal:** iOS platform features

---

## Tasks

### S6-01: Lock Screen Widget
**Status:** `[ ]` Not Started  
**Estimated:** 3 hours

**Deliverables:**
- [ ] Widget extension target
- [ ] Accessory Circular: nearest charger distance
- [ ] Accessory Rectangular: name + distance
- [ ] Home Screen Small: top 3 nearby

**Files:**
- `EVChargerWidget/` (new target)

---

### S6-02: Siri Integration
**Status:** `[x]` Complete  
**Estimated:** 3 hours

**Deliverables:**
- [x] FindChargerIntent - opens app with nearby list
- [x] NavigateToChargerIntent - navigates to nearest compatible charger
- [x] EVChargerShortcuts provider

**Files:**
- `EVCharger/Intents/` (new)

---

### S6-03: Multi-Connector Selection UI
**Status:** `[x]` Complete  
**Estimated:** 1 hour

**Deliverables:**
- [x] Multi-select toggle list in Settings
- [x] JSON-encoded @AppStorage persistence

**Files:**
- `EVCharger/Views/SettingsView.swift`

---

## Success Criteria

- [ ] Widget shows nearest charger on Lock Screen
- [ ] Siri responds to "Find a charger" / "Navigate to charger"
- [ ] Can select multiple connector types in Settings
