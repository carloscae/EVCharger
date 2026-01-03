# Agent Onboarding Workflow

**Usage:** `/onboard`  
**Purpose:** Join the project and claim your first task

---

## Step 1: Choose Your Identity

Pick a unique agent name. Suggestions:
- Role + adjective: `SwiftUI-Sage`, `CarPlay-Crafter`
- Tech + animal: `API-Falcon`, `Cache-Owl`
- Or use your default agent name

**Identity Format:**
```
Name: [Your Name]
Role: [UI Developer | State Engineer | Platform Specialist | QA Agent]
Session: [Current timestamp]
```

---

## Step 2: Read Core Docs

Read these files in order:

1. `docs/ONBOARDING.md` — Quick project summary
2. `docs/ARCHITECTURE.md` — Technical decisions
3. `docs/EVCHARGER_brief.md` — Compact reference

> **Time limit:** 5 minutes for all three. These are intentionally short.

---

## Step 3: Find Active Sprint

```bash
ls docs/sprints/
```

Read the highest-numbered `SPRINT_X.md` file.

---

## Step 4: Check Claims Ledger

```bash
cat .agent/active/claims.md
```

**Do not claim a task that's already claimed by another agent.**

---

## Step 5: Select Your Task

Priority order:
1. **Blockers first** — Tasks marked as blocking others
2. **Dependencies met** — All dependencies completed
3. **Role match** — Tasks matching your role
4. **First available** — In task number order

---

## Step 6: Claim Your Task

### Update Claims Ledger
Add your claim to `.agent/active/claims.md`:

```markdown
| S1-02 | SwiftUI-Sage | State Engineer | 2026-01-03T10:00 | In Progress |
```

### Update Sprint File
Change task status in `docs/sprints/SPRINT_X.md`:

```markdown
**Status:** `[/]` In Progress (claimed by SwiftUI-Sage @ 2026-01-03T10:00)
```

### Update Roster
Add yourself to `.agent/active/roster.md`:

```markdown
| SwiftUI-Sage | State Engineer | S1-02 | 2026-01-03T10:00 |
```

---

## Step 7: Execute Your Task

Follow the task's deliverables checklist. Key rules:

- ✅ Write clean, documented code
- ✅ Add unit tests for new logic
- ✅ Update ARCHITECTURE.md if you add patterns
- ❌ Don't expand scope beyond deliverables
- ❌ Don't start other tasks until complete

---

## Step 8: Complete Your Task

Run the `/checkout` workflow when done:

```
/checkout
```

This will:
- Verify your work
- Update documentation
- Mark task complete
- Log your time
- Generate handoff report

---

## Quick Reference

| File | Purpose |
|------|---------|
| `docs/ONBOARDING.md` | Project quick-start |
| `docs/ARCHITECTURE.md` | Technical reference |
| `docs/sprints/SPRINT_X.md` | Current tasks |
| `.agent/active/claims.md` | Who's working on what |
| `.agent/active/roster.md` | Active agents |
| `.agent/workflows/checkout.md` | Complete a task |
