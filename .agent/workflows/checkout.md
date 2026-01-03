# Task Checkout Workflow

**Usage:** `/checkout`  
**Purpose:** Complete a task with proper documentation and handoff

---

## Step 1: Self-Verification

Before checking out, verify:

- [ ] **Code compiles** — No build errors
- [ ] **Feature works** — Manual testing passed
- [ ] **Tests pass** — Unit tests green
- [ ] **No regressions** — Existing features still work

```bash
# Run tests
xcodebuild test -scheme EVCharger -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## Step 2: Update Documentation

If you changed architecture, update `docs/ARCHITECTURE.md`:

- New patterns or conventions
- New files or directories
- Changed data flow
- New dependencies

---

## Step 3: Update Sprint File

In `docs/sprints/SPRINT_X.md`:

1. Change task status to complete:
```markdown
**Status:** `[x]` Complete
```

2. Check off completed deliverables:
```markdown
- [x] Deliverable 1
- [x] Deliverable 2
```

3. Move task to "Completed Tasks" section:
```markdown
## Completed Tasks

### S1-02: Implement Data Models
**Completed By:** SwiftUI-Sage  
**Completed At:** 2026-01-03T15:30  
**Time Spent:** 1.5 hours  
**Notes:** Added extra validation to connector types
```

---

## Step 4: Update Claims Ledger

In `.agent/active/claims.md`:

Change status to "Completed":
```markdown
| S1-02 | SwiftUI-Sage | State Engineer | 2026-01-03T10:00 | Completed |
```

---

## Step 5: Update Roster

In `.agent/active/roster.md`:

Option A — Claim next task:
```markdown
| SwiftUI-Sage | State Engineer | S1-03 | 2026-01-03T15:30 |
```

Option B — Sign off (move to Hall of Fame):
```markdown
## Hall of Fame

| SwiftUI-Sage | State Engineer | 1 | 1.5h |
```

---

## Step 6: Log Time

In `.agent/stats/time_log.md`:

1. Update summary:
```markdown
| State Engineer | 1.5h | 1 |
```

2. Add log entry:
```markdown
### 2026-01-03

| SwiftUI-Sage | State Engineer | S1-02 | 1.5h | Added extra validation |
```

---

## Step 7: Check Follow-ups

Review if your completed task unblocks others:

- [ ] Check tasks that depended on yours
- [ ] Note newly available tasks in project_state.md

Update `.agent/active/project_state.md`:
```markdown
## Next Priority
- S1-03: Now unblocked (S1-02 complete)
```

---

## Step 8: Final Report

Generate a brief report for Product Lead:

```markdown
## Task Completion Report

**Task:** S1-02: Implement Data Models
**Agent:** SwiftUI-Sage
**Role:** State Engineer
**Time Spent:** 1.5 hours

### Completed
- ChargingStation model with all fields
- ConnectorType enum
- StatusType enum
- UserPreferences model
- SwiftData schema

### Notes
- Added extra validation to connector types for API compatibility
- Type2 connector added per European market feedback

### Unblocked
- S1-03: Implement Open Charge Map Service

### Next Steps
Recommend: State Engineer continues to S1-03 for continuity
```

---

## Checklist Summary

- [ ] Verified code compiles and works
- [ ] Tests pass
- [ ] ARCHITECTURE.md updated (if needed)
- [ ] Sprint file updated with completion
- [ ] Claims ledger updated
- [ ] Roster updated
- [ ] Time logged
- [ ] Follow-ups noted
- [ ] Final report generated
