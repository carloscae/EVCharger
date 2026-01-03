# Product Lead Onboarding Workflow

**Usage:** `/onboard-product-lead`  
**Purpose:** Onboard as Product Lead with full project context

---

## Step 1: Identity

```
Name: [Your Name or "Product Lead"]
Role: Product Lead
Session: [Current timestamp]
Responsibilities: Planning, coordination, sprint management, builds
```

---

## Step 2: Read Full Product Spec

Read the complete product specification:

```bash
cat docs/EVCHARGER_product_spec.md
```

Understand:
- Target users
- Feature set (MVP vs Premium)
- Non-goals (kill criteria)
- Technical constraints
- Monetization strategy

---

## Step 3: Read Architecture

```bash
cat docs/ARCHITECTURE.md
```

Understand:
- Tech stack decisions
- Directory structure
- State management patterns
- CarPlay template constraints

---

## Step 4: Check Project State

```bash
cat .agent/active/project_state.md
```

Review:
- Current sprint progress
- Active blockers
- Priority queue

---

## Step 5: Review Claims & Roster

```bash
cat .agent/active/claims.md
cat .agent/active/roster.md
```

Understand:
- Who's working on what
- What tasks are available
- Any coordination needed

---

## Step 6: Review Active Sprint

```bash
cat docs/sprints/SPRINT_1.md
```

For each task:
- Check status
- Verify dependencies are correct
- Identify blockers
- Note overdue items

---

## Step 7: Check Time Log

```bash
cat .agent/stats/time_log.md
```

Review time investment across roles.

---

## Step 8: Product Lead Actions

### Planning Mode
- Adjust task priorities if needed
- Update sprint scope if blocked
- Plan next sprint when current is >75% complete

### Coordination Mode
- Unblock agents waiting for decisions
- Answer architectural questions
- Approve scope changes

### Build Mode (Only PL triggers builds)
- Run `xcodebuild` as needed
- Manage TestFlight distribution
- Handle App Store submission

---

## Step 9: Claim PL Tasks

Product Lead can claim tasks marked as PL responsibility:
- Entitlement requests
- Build/deploy tasks
- Sprint planning tasks

Update claims ledger if claiming.

---

## Step 10: Update Project State

After review, update `.agent/active/project_state.md`:

```markdown
**Last Updated:** [timestamp]
**Updated By:** [Your Name]

## Current Sprint
Sprint X: [Title]
Progress: X/Y tasks complete

## Blockers
- [List any blockers]

## Next Priority
- [List priority tasks]
```

---

## Quick Reference

| File | Purpose |
|------|---------|
| `docs/EVCHARGER_product_spec.md` | Full product spec |
| `docs/ARCHITECTURE.md` | Technical reference |
| `docs/sprints/ROADMAP.md` | Sprint timeline |
| `.agent/active/project_state.md` | Current status |
| `.agent/active/claims.md` | Task claims |
| `.agent/active/roster.md` | Active agents |
