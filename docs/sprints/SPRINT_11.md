# Sprint 11: Performance & Snappiness

**Goal**: Make the app feel instant and reduce data dependency for a "No Bullshit" 1.0 release.

---

## Critical Issues Identified

| Issue | Impact | Status |
|-------|--------|--------|
| Cache not loaded on cold start | Blank screen for 2-3 sec | ⬜ Open |
| No API fetch throttle (TTL) | Every location update triggers network call | ⬜ Open |
| Location subscription too aggressive (5s debounce) | Battery drain, API spam | ⬜ Open |
| CacheService underutilized | Exists but barely integrated | ⬜ Open |
| No distance threshold before re-fetch | Moving 10m triggers full refresh | ⬜ Open |
| Two taps to navigate | Detail View → Navigate button | ⬜ Open |
| Map sheet blocks screen | Default height OK but expansion is abrupt | ⬜ Open |

---

## Tasks

### Phase 1: Instant Launch (Critical) <!-- effort: 3 pts -->
- [ ] **S11-01**: Refactor `ContentView` to use `.task` and call `loadCacheAndFetchIfNeeded()` <!-- id: 20 -->
- [ ] **S11-02**: Add `lastFetchTime` and `lastFetchLocation` tracking to ViewModel <!-- id: 21 -->
- [ ] **S11-03**: Implement 15-minute TTL check in `shouldFetchFromAPI()` <!-- id: 22 -->
- [ ] **S11-04**: Implement 500m distance threshold in `shouldFetchFromAPI()` <!-- id: 23 -->
- [ ] **S11-05**: Add `loadCacheAndFetchIfNeeded()` for instant start pattern <!-- id: 24 -->
- [ ] **S11-06**: Change location subscription debounce from 5s → 30s <!-- id: 25 -->
- [ ] **S11-07**: Add `fetchAllCached()` to CacheService for global load <!-- id: 26 -->
- [ ] **S11-08**: Persist `lastFetchTimestamp` in UserDefaults <!-- id: 27 -->

### Phase 2: UX Efficiency <!-- effort: 2 pts -->
- [ ] **S11-09**: Add "One-Tap Navigate" button to `ChargerRowView` <!-- id: 28 -->
- [ ] **S11-10**: (Optional) Add `.height(200)` detent for glanceable list <!-- id: 29 -->

### Phase 3: Verification <!-- effort: 1 pt -->
- [ ] **S11-11**: Build verification (zero warnings) <!-- id: 30 -->
- [ ] **S11-12**: Manual QA: Instant launch, TTL, distance threshold, one-tap nav <!-- id: 31 -->

---

## Success Criteria

| Metric | Target |
|--------|--------|
| Cold start to stations visible | < 500ms |
| API calls on app reopen (within TTL + distance) | 0 |
| Taps to start navigation | 1 |
| Build warnings | 0 |

---

## Effort Estimate

**Total**: ~6 story points (1-2 days of focused work)
