# EVCharger Sprint Roadmap

**Project Start:** 2026-01-03  
**Target MVP:** Sprint 4 complete  
**Target App Store:** Post-Sprint 5

---

## Sprint Timeline

| Sprint | Duration | Goal | Key Deliverables |
|--------|----------|------|------------------|
| **Sprint 1** | ~5 days | Foundation | Xcode project, models, API service, shared layer |
| **Sprint 2** | ~5 days | iPhone App | Map view, list view, detail view, navigation |
| **Sprint 3** | ~4 days | CarPlay | CarPlay templates, connector filter, shared ViewModel |
| **Sprint 4** | ~4 days | Polish & Premium | Caching, offline mode, IAP, settings |
| **Sprint 5** | ~3 days | Release Prep | App Store assets, entitlement, TestFlight |

---

## Sprint 1: Foundation

**Goal:** Establish project structure and shared data layer

**Success Criteria:**
- [ ] Xcode project builds and runs
- [ ] Data models compile
- [ ] Open Charge Map API returns data
- [ ] LocationService provides user position
- [ ] CarPlay entitlement requested

---

## Sprint 2: iPhone App

**Goal:** Complete iPhone experience with map and list views

**Success Criteria:**
- [ ] Map view shows charger pins
- [ ] List view with search/filter
- [ ] Detail view with charger info
- [ ] Navigate button opens Apple Maps
- [ ] Connector type filter works

---

## Sprint 3: CarPlay

**Goal:** Complete CarPlay experience (reuses shared layer)

**Success Criteria:**
- [ ] CarPlay shows nearby chargers list
- [ ] Tap charger → see details
- [ ] Tap navigate → opens Apple Maps
- [ ] Connector filter works
- [ ] Same ViewModel as iPhone

---

## Sprint 4: Polish & Premium

**Goal:** Production-ready app with monetization

**Success Criteria:**
- [ ] 24-hour caching implemented
- [ ] Works offline with cached data
- [ ] Premium IAP flows work
- [ ] Settings screen complete

---

## Sprint 5: Release Prep

**Goal:** App Store submission ready

**Success Criteria:**
- [ ] App Store screenshots (iPhone + CarPlay)
- [ ] Privacy policy published
- [ ] CarPlay entitlement approved
- [ ] TestFlight build distributed

---

## Post-MVP Backlog

| Feature | Priority | Notes |
|---------|----------|-------|
| Favorite chargers | P2 | Save preferred locations |
| Multi-vehicle profiles | P2 | Store connector prefs per vehicle |
| Real-time availability | P2 | Live status from Open Charge Map |
| iOS Widget | P3 | Quick glance at nearest chargers |
| Apple Watch | P3 | Tied to real-time status feature |
| Localization | P3 | Multi-language support |
