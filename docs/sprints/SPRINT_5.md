# Sprint 5: Release Prep

**Start Date:** 2026-01-04  
**Target Duration:** ~3 days  
**Goal:** App Store submission ready

---

## Role Summary

| Role | Tasks |
|------|-------|
| **UI Developer** | S5-01 (App Icons), S5-02 (Screenshots) |
| **Product Lead** | S5-03 (App Store Listing), S5-04 (Legal), S5-05 (TestFlight) |

---

## Tasks

### S5-01: Create App Icons
**Role:** UI Developer  
**Status:** `[ ]` Not Started  
**Dependencies:** None  
**Estimated:** 1 hour

**Deliverables:**
- [ ] App icon design (green/electric theme)
- [ ] 1024x1024 App Store icon
- [ ] All required iOS sizes (via asset catalog)
- [ ] CarPlay icon variant (if required)

**Files:**
- `EVCharger/Assets.xcassets/AppIcon.appiconset/`

---

### S5-02: Create App Store Screenshots
**Role:** UI Developer  
**Status:** `[ ]` Not Started  
**Dependencies:** None  
**Estimated:** 2 hours

**Deliverables:**
- [ ] iPhone screenshots (6.7", 6.5", 5.5")
- [ ] CarPlay screenshots (if possible)
- [ ] Screenshot frames and captions
- [ ] Key features highlighted

**Files:**
- `docs/appstore/screenshots/`

---

### S5-03: Prepare App Store Listing
**Role:** Product Lead  
**Status:** `[ ]` Not Started  
**Dependencies:** S5-01, S5-02  
**Estimated:** 1.5 hours

**Deliverables:**
- [ ] App name: "EVCharger - Find EV Chargers"
- [ ] Subtitle (30 chars)
- [ ] Description (4000 chars)
- [ ] Keywords (100 chars)
- [ ] What's New text
- [ ] Category: Navigation (EV Charging)
- [ ] Age rating questionnaire

**Files:**
- `docs/appstore/listing.md`

---

### S5-04: Legal & Privacy
**Role:** Product Lead  
**Status:** `[ ]` Not Started  
**Dependencies:** None  
**Estimated:** 1 hour

**Deliverables:**
- [ ] Privacy Policy (hosted URL)
- [ ] Terms of Service (optional)
- [ ] App Privacy details for App Store
- [ ] Data collection disclosure (location only)

**Files:**
- `docs/legal/privacy_policy.md`
- Host on website or GitHub Pages

---

### S5-05: TestFlight Distribution
**Role:** Product Lead  
**Status:** `[ ]` Not Started  
**Dependencies:** S5-01, S5-03, S5-04, CarPlay Entitlement (S1-05)  
**Estimated:** 1.5 hours

**Deliverables:**
- [ ] Archive build for App Store
- [ ] Upload to App Store Connect
- [ ] Configure TestFlight beta testing
- [ ] Add external testers (if any)
- [ ] Submit for beta app review

**Files:**
- Build artifacts

**Blockers:**
- Requires CarPlay entitlement approval (S1-05)
- Requires Apple Developer enrollment complete

---

## Success Criteria

- [ ] App icon visible in all contexts
- [ ] Screenshots ready for all required sizes
- [ ] App Store listing complete
- [ ] Privacy Policy published
- [ ] TestFlight build distributed to testers
- [ ] Ready for App Store review

---

## Blockers & Notes

- **Apple Developer enrollment** must be complete
- **CarPlay entitlement** (S1-05) must be approved before TestFlight
- Privacy Policy needs hosting (GitHub Pages or similar)

---

## Completed Tasks

*Move completed tasks here with agent details.*
